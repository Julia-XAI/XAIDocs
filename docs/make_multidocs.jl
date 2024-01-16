import MultiDocumenter as MD

clonedir = mktempdir()

docs = [
    MD.MultiDocRef(
        upstream = joinpath(clonedir, "ExplainableAI"),
        path = "explainableai",
        name = "ExplainableAI",
        giturl = "https://github.com/Julia-XAI/ExplainableAI.jl.git",
    ),
    MD.MultiDocRef(
        upstream = joinpath(clonedir, "RelevancePropagation"),
        path = "RelevancePropagation",
        name = "RelevancePropagation",
        giturl = "https://github.com/Julia-XAI/RelevancePropagation.jl.git",
    ),
    MD.DropdownNav("Heatmapping", [
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "VisionHeatmaps"),
            path = "visionheatmaps",
            name = "VisionHeatmaps",
            giturl = "https://github.com/Julia-XAI/VisionHeatmaps.jl.git",
        ),
        MD.MultiDocRef(
            upstream = joinpath(clonedir, "TextHeatmaps"),
            path = "textheatmaps",
            name = "TextHeatmaps",
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
