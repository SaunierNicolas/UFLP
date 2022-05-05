include("inter01.jl")
include("filtering.jl")
include("lowerHull.jl")
using Plots

function test()

    a = [[1,2,3,4],[5,6,7,8]]
    b = [[5,6,7,8],[1,2,3,4]]

    scatter(a,b)
end

test()