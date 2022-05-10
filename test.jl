include("inter01.jl")
include("filtering.jl")
include("lowerHull.jl")
using Plots

function test()


    I = 4
    J = 3
    y = [1,1,1]
    c1 = [
        [2,4,8],
        [5,7,2],
        [4,3,5],
        [3,4,8]
    ]
    c2 = [
        [8,9,4],
        [2,7,5],
        [1,6,9],
        [4,2,7]
    ]
    
    c = [c1,c2]
    affectationClient(I,J,y,c)
end

function test_inter()

    I = 4
    J = 4

    c1::Vector{Vector{Float64}} = [
        [5,8,1,3],
        [4,6,3,8],
        [3,8,3,1],
        [3,4,2,3]
    ]

    c2::Vector{Vector{Float64}} = [
        [7,3,3,4],
        [4,3,8,9],
        [5,3,6,8],
        [2,2,7,7]
        ]

    f1 = [3,4,6,7]
    f2 = [5,7,3,1]

    c = [c1,c2]
    f = [f1,f2]


    a_init = generationDroiteAffectationInitiale(I,J,c,f)
    client_init_3 = generationVecteurDroiteClientLambda(I,J,c,[3,3,3,3])
    client_init_2 = generationVecteurDroiteClientLambda(I,J,c,[2,2,2,2])
    i = 4
    droitePlot = [client_init_2[i],client_init_3[i]]
    plotDroites(droitePlot,false)
    #d = greedyInit_inter01(I,J,f,c)

end

#test()
test_inter()