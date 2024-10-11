using ExplainableAI
using Zygote
using Flux

using BSON # hide
model = BSON.load("../model.bson", @__MODULE__)[:model] # hide
model

using MLDatasets
using ImageCore, ImageIO, ImageShow

index = 10
x, y = MNIST(Float32, :test)[10]
input = reshape(x, 28, 28, 1, :)

convert2image(MNIST, x)

using VisionHeatmaps

analyzer = Gradient(model)
heatmap(input, analyzer)

analyzer = InputTimesGradient(model)
heatmap(input, analyzer)

using ColorSchemes

expl = analyze(input, analyzer)
heatmap(expl; colorscheme=:jet)

heatmap(expl; colorscheme=:inferno)

heatmap(expl; reduce=:sum)

heatmap(expl; reduce=:norm)

heatmap(expl; reduce=:maxabs)

heatmap(expl; rangescale=:centered)

heatmap(expl; rangescale=:extrema)

heatmap(expl; rangescale=:centered, colorscheme=:inferno)

heatmap(expl; rangescale=:extrema, colorscheme=:inferno)

xs, ys = MNIST(Float32, :test)[1:100]
batch = reshape(xs, 28, 28, 1, :); # reshape to WHCN format

heatmaps = heatmap(batch, analyzer)

mosaic(heatmaps; nrow=10)

expl = analyze(batch, analyzer)
heatmaps = heatmap(expl; process_batch=true)
mosaic(heatmaps; nrow=10)

expl = analyze(batch, analyzer, 7) # explain digit "6"
heatmaps = heatmap(expl; process_batch=true)
mosaic(heatmaps; nrow=10)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
