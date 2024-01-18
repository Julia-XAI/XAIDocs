import MultiDocumenter as MD

clonedir = mktempdir()

docs = [
    MD.DropdownNav("Methods", [
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "ExplainableAI"),
            path = "explainableai",
            name = "ExplainableAI.jl",
            giturl = "https://github.com/Julia-XAI/ExplainableAI.jl.git",
        ),
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "RelevancePropagation"),
            path = "RelevancePropagation",
            name = "RelevancePropagation.jl",
            giturl = "https://github.com/Julia-XAI/RelevancePropagation.jl.git",
        ),
    ]),
    MD.DropdownNav("Heatmapping", [
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "VisionHeatmaps"),
            path = "VisionHeatmaps",
            name = "VisionHeatmaps.jl",
            giturl = "https://github.com/Julia-XAI/VisionHeatmaps.jl.git",
        ),
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "TextHeatmaps"),
            path = "TextHeatmaps",
            name = "TextHeatmaps.jl",
            giturl = "https://github.com/Julia-XAI/TextHeatmaps.jl.git",
        ),
    ]),
]

outpath = joinpath(@__DIR__, "out")

MD.make(
    outpath,
    docs;
    search_engine = MD.SearchConfig(
        index_versions = ["stable"],
        engine = MD.FlexSearch
    )
)
