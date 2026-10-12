# API reference

## Using analyzers
Most methods in the Julia-XAI ecosystem work by calling `analyze` on an input and an analyzer:
```@docs
analyze
```

The return type of `analyze` is an `Attribution`:
```@docs
Attribution
```

## Visualizing feature attributions
`Attribution`s can be visualized using `heatmap`:
```@docs
VisionHeatmaps.heatmap
TextHeatmaps.heatmap
```

By default, `heatmap` picks a pipeline based on the attribution's pooling function.
For a complete list of pooling functions, refer to the
[XAIBase.jl documentation](https://julia-xai.github.io/XAIDocs/XAIBase/stable/).
```@docs
VisionHeatmaps.default_pipeline
TextHeatmaps.default_pipeline
```

## Index
```@index
```
