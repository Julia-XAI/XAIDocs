# # [Using Analyzers](@id docs-getting-started)
# For this first example, we loaded a pre-trained LeNet5 model
# to look at feature attributions on the MNIST dataset.

# Note that most of the methods in the Julia-XAI ecosystem are **not** limited to Flux.jl models.
using ExplainableAI
using RelevancePropagation
using Zygote
using Flux

using BSON # hide
model = BSON.load("../model.bson", @__MODULE__)[:model] # load pre-trained LeNet-5 model

#md # !!! note "Loading XAI methods"
#md #
#md #     Currently, the following methods are available in the Julia-XAI ecosystem:
#md #     - [ExplainableAI.jl](https://github.com/Julia-XAI/ExplainableAI.jl) – applicable on any differentiable classifier
#md #       - `Gradient`
#md #       - `InputTimesGradient`
#md #       - `SmoothGrad`
#md #       - `IntegratedGradients`
#md #       - `GradCAM`
#md #     - [RelevancePropagation.jl](https://github.com/Julia-XAI/RelevancePropagation.jl) – applicable on Flux.jl models
#md #       - `LRP`
#md #       - `CRP`
#md #
#md #     For a complete list of available methods, refer to the individual package documentations.

# ## Preparing the input data
# We use MLDatasets to load a single image from the MNIST dataset:
using MLDatasets
using ImageCore, ImageIO, ImageShow

index = 10
x, y = MNIST(Float32, :test)[10]

convert2image(MNIST, x)

# By convention in Flux.jl, this input needs to be resized to WHCN format
# by adding a color channel and batch dimensions.
input = reshape(x, 28, 28, 1, :);

#md # !!! note "Input format"
#md #
#md #     To compute feature attributions, Julia-XAI methods assume the batch dimension
#md #     to come last in the input.
#md #
#md #     For vision models, the input is assumed to be in WHCN order
#md #     (*width, height, channels, batch dimension*), which matches Flux.jl's convention.

# ## Feature attributions
# We can now select an analyzer of our choice and call [`analyze`](@ref)
# to get an [`Attribution`](@ref). Here, we use the `LRP` method from
# [RelevancePropagation.jl](https://github.com/Julia-XAI/RelevancePropagation.jl):
analyzer = LRP(model)
attr = analyze(input, analyzer);

# The return value `attr` is of type [`Attribution`](@ref) and bundles the following data:
# * `attr.val`: numerical output of the analyzer, e.g. an attribution or gradient
# * `attr.input`: input the analyzer was applied to
# * `attr.output`: model output for the given analyzer input
# * `attr.output_selection`: index of the output the attribution was computed for
# * `attr.pooling`: pooling function that reduces `attr.val` over its feature dimension,
#     e.g. over the color channels of an image
# * `attr.extras`: optional named tuple that can be used by analyzers
#     to return additional information.
#
# LRP computes signed relevances that are conserved across layers,
# so they are pooled by summation:
attr.pooling

# By default, the feature attribution is computed for the maximally activated output.
# Since our digit is a 9 and Julia's indexing is 1-based,
# the output at index `10` of our trained model is maximally activated.

# Finally, we obtain the result of the analyzer in form of an array.
attr.val

# ## Heatmapping basics
# Since the array `attr.val` is not very informative at first sight,
# we can visualize `Attribution`s by computing a `heatmap` using either
# [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) or
# [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/).
using VisionHeatmaps

heatmap(attr)

# By default, to support batched attributions, a vector of heatmaps is returned.
# Since the following examples don't use batches, we will use the `only` function to unpack singleton heatmaps:
heatmap(attr) |> only

# If we are only interested in the heatmap, we can combine analysis and heatmapping
# into a single function call:
heatmap(input, analyzer) |> only

# ## Output selection
# By passing an additional index to our call to [`analyze`](@ref),
# we can compute a feature attribution with respect to a specific output index.
# Let's see why the output wasn't interpreted as a 4 (output at index 5)
attr = analyze(input, analyzer, 5)
heatmap(attr) |> only

# This heatmap shows us that the "upper loop" of the hand-drawn 9 has negative relevance
# with respect to the output corresponding to digit 4!

# The output index can also be specified when calling `heatmap`:
heatmap(input, analyzer, 5) |> only

# ## Analyzing batches
# Feature attributions can also be computed for input batches:
batchsize = 20
xs, _ = MNIST(Float32, :test)[1:batchsize]
batch = reshape(xs, 28, 28, 1, :) # reshape to WHCN format
attr = analyze(batch, analyzer);

# This will return a single `Attribution` `attr` for the entire batch.
# Calling `heatmap` on `attr` will detect the batch dimension and return a vector of heatmaps.
heatmap(attr)

# ## Heatmapping presets
# The function `heatmap` automatically picks a preset based on the pooling of the attribution.
# Since `LRP` relevances are signed and pooled by summation,
# previous heatmaps were shown in a diverging blue-black-red color scheme.
# Methods based on input sensitivities like `SmoothGrad` are pooled by their norm.
# The resulting non-negative values are shown in a sequential color scheme:
analyzer = SmoothGrad(model)
heatmap(input, analyzer) |> only

#md # ## Custom heatmaps

#md # !!! tip "Check out the VisionHeatmaps.jl documentation"
#md #
#md #     Using [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/),
#md #     heatmaps can be heavily customized.
#md #     Check out the [heatmapping documentation](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) for more information.
