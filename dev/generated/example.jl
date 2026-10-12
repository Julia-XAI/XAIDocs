using ExplainableAI
using RelevancePropagation
using Zygote
using Flux

using BSON # hide
model = BSON.load("../model.bson", @__MODULE__)[:model] # load pre-trained LeNet-5 model

using MLDatasets
using ImageCore, ImageIO, ImageShow

index = 10
x, y = MNIST(Float32, :test)[10]

convert2image(MNIST, x)

input = reshape(x, 28, 28, 1, :);

analyzer = LRP(model)
attr = analyze(input, analyzer);

attr.pooling

attr.val

using VisionHeatmaps

heatmap(attr)

heatmap(attr) |> only

heatmap(input, analyzer) |> only

attr = analyze(input, analyzer, 5)
heatmap(attr) |> only

heatmap(input, analyzer, 5) |> only

batchsize = 20
xs, _ = MNIST(Float32, :test)[1:batchsize]
batch = reshape(xs, 28, 28, 1, :) # reshape to WHCN format
attr = analyze(batch, analyzer);

heatmap(attr)

analyzer = SmoothGrad(model)
heatmap(input, analyzer) |> only

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
