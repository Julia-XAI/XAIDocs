# This file is run in CI using the `Assets.yml` workflow
# to generate up-to-date heatmaps for the docs and READMEs of the Julia-XAI ecosystem.
using ExplainableAI
using RelevancePropagation
using VisionHeatmaps         # visualization of explanations as heatmaps
using Zygote                 # load autodiff backend for gradient-based methods
using Flux, Metalhead        # pre-trained vision models in Flux
using DataAugmentation       # input preprocessing
using HTTP, FileIO, ImageIO  # load image from URL

assets_dir = "assets/heatmaps"

# Load model
model = VGG(19; pretrain=true).layers
model = strip_softmax(model)
model = canonize(model)

# Load image
url = HTTP.URI(
    "https://raw.githubusercontent.com/adrhill/ExplainableAI.jl/gh-pages/assets/heatmaps/castle.jpg",
)
img = load(url)

# Normalization used for Metalhead models, which use PyTorch weights
PYTORCH_MEAN = (0.485, 0.456, 0.406)
PYTORCH_STD  = (0.229, 0.224, 0.225)

# Preprocess input
mean = (0.485f0, 0.456f0, 0.406f0)
std = (0.229f0, 0.224f0, 0.225f0)
tfm = CenterResizeCrop((224, 224)) |> ImageToTensor() |> Normalize(mean, std)
input = apply(tfm, Image(img))               # apply DataAugmentation transform
input = reshape(input.data, 224, 224, 3, :)  # unpack data and add batch dimension

# Assert model weights are loaded correctly
n_castle = 484
n_streetsign = 920
argmax(model(input))[1] != n_castle && error("Model doesn't correctly predict castle.")

# Run XAI methods
methods = Dict(
    "InputTimesGradient"  => InputTimesGradient,
    "Gradient"            => Gradient,
    "SmoothGrad"          => SmoothGrad,
    "IntegratedGradients" => IntegratedGradients,
    # "GradCAM"                   => model -> GradCAM(model[1], model[2]),
    "LRP"                       => LRP,
    "LRPEpsilonGammaBox"        => model -> LRP(model, EpsilonGammaBox(-3.0f0, 3.0f0)),
    "LRPEpsilonPlus"            => model -> LRP(model, EpsilonPlus()),
    "LRPEpsilonAlpha2Beta1"     => model -> LRP(model, EpsilonAlpha2Beta1()),
    "LRPEpsilonPlusFlat"        => model -> LRP(model, EpsilonPlusFlat()),
    "LRPEpsilonAlpha2Beta1Flat" => model -> LRP(model, EpsilonAlpha2Beta1Flat()),
)

for (name, method) in methods
    @info "Generating $name assets..."
    analyzer = method(model)

    # Max activated neuron corresponds to "castle"
    expl = analyze(input, analyzer)
    h = heatmap(expl)
    save("$assets_dir/castle/$name.png", h)

    # Output neuron 920 corresponds to "street sign"
    expl = analyze(input, analyzer, n_streetsign)
    h = heatmap(expl)
    save("$assets_dir/streetsign/$name.png", h)
end
