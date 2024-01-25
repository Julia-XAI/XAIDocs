# Script to build the Julia-XAI MultiDocumenter docs.
#
#   julia --project docs/make_multidocs.jl [--temp] [deploy]
#
# When `deploy` is passed as an argument, it goes into deployment mode
# and attempts to push the generated site to gh-pages. You can also pass
# `--temp`, in which case the source repositories are cloned into a temporary
# directory (as opposed to `docs/clones`).

using MultiDocumenter
using MultiDocumenter: MultiDocRef, DropdownNav, FlexSearch, SearchConfig

clonedir = ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "clones")
outpath = mktempdir()
@info """
Cloning packages into: $(clonedir)
Building aggregate site into: $(outpath)
"""

docs = [
    MultiDocRef(;
        upstream=joinpath(clonedir, "XAIBase"),
        path="XAIBase",
        name="Getting Started",
        giturl="https://github.com/Julia-XAI/XAIBase.jl.git",
    ),
    DropdownNav(
        "Methods",
        [
            MultiDocRef(;
                upstream=joinpath(clonedir, "ExplainableAI"),
                path="ExplainableAI",
                name="ExplainableAI.jl",
                giturl="https://github.com/Julia-XAI/ExplainableAI.jl.git",
            ),
            MultiDocRef(;
                upstream=joinpath(clonedir, "RelevancePropagation"),
                path="RelevancePropagation",
                name="RelevancePropagation.jl",
                giturl="https://github.com/Julia-XAI/RelevancePropagation.jl.git",
            ),
        ],
    ),
    DropdownNav(
        "Heatmapping",
        [
            MultiDocRef(;
                upstream=joinpath(clonedir, "VisionHeatmaps"),
                path="VisionHeatmaps",
                name="VisionHeatmaps.jl",
                giturl="https://github.com/Julia-XAI/VisionHeatmaps.jl.git",
            ),
            MultiDocRef(;
                upstream=joinpath(clonedir, "TextHeatmaps"),
                path="TextHeatmaps",
                name="TextHeatmaps.jl",
                giturl="https://github.com/Julia-XAI/TextHeatmaps.jl.git",
            ),
        ],
    ),
    MultiDocRef(;
        upstream=joinpath(clonedir, "XAIBase"),
        path="XAIBase",
        name="Interface",
        giturl="https://github.com/Julia-XAI/XAIBase.jl.git",
    ),
]

MultiDocumenter.make(
    outpath,
    docs;
    search_engine=SearchConfig(; index_versions=["stable"], engine=FlexSearch),
    rootpath="/XAIDocs/",
    canonical_domain="https://julia-xai.github.io/",
    sitemap=true,
)

if "deploy" in ARGS
    @warn "Deploying to GitHub" ARGS
    gitroot = normpath(joinpath(@__DIR__, ".."))
    run(`git pull`)
    outbranch = "gh-pages"
    has_outbranch = true
    if !success(`git checkout $outbranch`)
        has_outbranch = false
        if !success(`git switch --orphan $outbranch`)
            @error "Cannot create new orphaned branch $outbranch."
            exit(1)
        end
    end
    for file in readdir(gitroot; join=true)
        endswith(file, ".git") && continue
        rm(file; force=true, recursive=true)
    end
    for file in readdir(outpath)
        cp(joinpath(outpath, file), joinpath(gitroot, file))
    end
    run(`git add .`)
    if success(`git commit -m 'Aggregate documentation'`)
        @info "Pushing updated documentation."
        if has_outbranch
            run(`git push`)
        else
            run(`git push -u origin $outbranch`)
        end
        run(`git checkout main`)
    else
        @info "No changes to aggregated documentation."
    end
else
    @info "Skipping deployment, 'deploy' not passed. Generated files in docs/out." ARGS
    outdir = joinpath(@__DIR__, "out")
    if outdir != outpath
        cp(outpath, outdir; force=true)
    end
end
