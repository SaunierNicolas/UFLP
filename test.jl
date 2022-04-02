include("inter01.jl")
include("filtering.jl")
include("lowerHull.jl")
using Plots

function test()

    I = 4
    J = 3

    f1 = [4,3,4]
    f2 = [3,4,2]

    f = [f1,f2]

    c1 = [
        [3,2,4],
        [2,3,2],
        [2,7,4],
        [1,5,6]
    ]
    c2 = [
        [7,3,1],
        [6,4,2],
        [4,3,5],
        [2,1,7]
    ]

    c = [c1,c2]

    droites = generationDroiteSite(4,3,c,f)

    plotDroites(droites)

end

test()