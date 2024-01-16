using XAIDocs
using Test
using Aqua

@testset "XAIDocs.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(XAIDocs)
    end
    # Write your tests here.
end
