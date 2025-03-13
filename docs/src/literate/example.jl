# # [Using Analyzers](@id docs-getting-started)
# For this first example, we loaded a pre-trained LeNet5 model
# to look at explanations on the MNIST dataset.

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
#md #     For any explanation of a model, Julia-XAI methods assume the batch dimension
#md #     to come last in the input.
#md #
#md #     For vision models, the input is assumed to be in WHCN order
#md #     (width, height, channels, batch dimension), which is Flux.jl's convention.

# ## Explanations
# We can now select an analyzer of our choice and call [`analyze`](@ref)
# to get an [`Explanation`](@ref). Here, we use the `LRP` method from
# [RelevancePropagation.jl](https://github.com/Julia-XAI/RelevancePropagation.jl):
analyzer = LRP(model)
expl = analyze(input, analyzer);

# The return value `expl` is of type [`Explanation`](@ref) and bundles the following data:
# * `expl.val`: numerical output of the analyzer, e.g. an attribution or gradient
# * `expl.output`: model output for the given analyzer input
# * `expl.output_selection`: index of the output used for the explanation
# * `expl.analyzer`: symbol corresponding the used analyzer, e.g. `:Gradient` or `:LRP`
# * `expl.heatmap`: symbol indicating a preset heatmapping style,
#     e.g. `:attribution`, `:sensitivity` or `:cam`
# * `expl.extras`: optional named tuple that can be used by analyzers
#     to return additional information.
#
# We used an LRP analyzer, so `expl.analyzer` is `:LRP`.
expl.analyzer

# Which by default uses the `:attribution` preset for heatmapping:
expl.heatmap

# By default, the explanation is computed for the maximally activated output.
# Since our digit is a 9 and Julia's indexing is 1-based,
# the output at index `10` of our trained model is maximally activated.

# Finally, we obtain the result of the analyzer in form of an array.
expl.val

# ## Heatmapping basics
# Since the array `expl.val` is not very informative at first sight,
# we can visualize `Explanation`s by computing a `heatmap` using either
# [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) or
# [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/).
using VisionHeatmaps

heatmap(expl)

# If we are only interested in the heatmap, we can combine analysis and heatmapping
# into a single function call:
heatmap(input, analyzer)

# For a more detailed explanation of the `heatmap` function,
# refer to the [heatmapping section](@ref docs-heatmapping).

# ## Output selection
# By passing an additional index to our call to [`analyze`](@ref),
# we can compute an explanation with respect to a specific output index.
# Let's see why the output wasn't interpreted as a 4 (output at index 5)
expl = analyze(input, analyzer, 5)
heatmap(expl)

# This heatmap shows us that the "upper loop" of the hand-drawn 9 has negative relevance
# with respect to the output corresponding to digit 4!

#md # !!! note
#md #
#md #     The output index can also be specified when calling [`VisionHeatmaps.heatmap`](@ref):
#md #     ```julia
#md #     heatmap(input, analyzer, 5)
#md #     ```

# ## Analyzing batches
# ExplainableAI also supports explanations of input batches:
batchsize = 20
xs, _ = MNIST(Float32, :test)[1:batchsize]
batch = reshape(xs, 28, 28, 1, :) # reshape to WHCN format
expl = analyze(batch, analyzer);

# This will return a single `Explanation` `expl` for the entire batch.
# Calling `heatmap` on `expl` will detect the batch dimension and return a vector of heatmaps.
heatmap(expl)

## Custom heatmaps

# The function `heatmap` automatically applies common presets for each method.
#
# Since `InputTimesGradient` computes attributions,
# heatmaps are shown in a blue-white-red color scheme.
# Gradient methods however are typically shown in grayscale:
analyzer = Gradient(model)
heatmap(input, analyzer)
#-
analyzer = InputTimesGradient(model)
heatmap(input, analyzer)

# Using [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/),
# heatmaps can be heavily customized. 
# Check out the [heatmapping documentation](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) for more information.
