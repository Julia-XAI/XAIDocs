using XAIDocs
using Documenter

DocMeta.setdocmeta!(XAIDocs, :DocTestSetup, :(using XAIDocs); recursive=true)

makedocs(;
    modules=[XAIDocs],
    authors="Adrian Hill <gh@adrianhill.de>",
    sitename="XAIDocs.jl",
    format=Documenter.HTML(;
        canonical="https://Julia-XAI.github.io/XAIDocs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Julia-XAI/XAIDocs.jl",
    devbranch="main",
)
