include("inter01.jl")
include("filtering.jl")
include("lowerHull.jl")

function test()
    c1 = [
        [3,2,4],
        [6,3,2],
        [2,7,4],
        [8,5,6]
    ]
    c2 = [
        [7,3,1],
        [6,4,2],
        [4,3,5],
        [2,8,7]
    ]

    c = [c1,c2]

    droites = generationDroite(4,3,1,c)

    points = lowerHull(droites)

    println(points)

end

test()