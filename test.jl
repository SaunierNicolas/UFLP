include("greedyInit.jl")
include("localSearch.jl")
include("parser.jl")

function test()

    f1 = [1,2,3,4]

    c1 = [
        [1,2,3,4],
        [1,2,3,4],
        [1,2,3,4],
        [1,2,3,4],
        [1,2,3,4]
    ]

    f2 = [10,20,30,40]
    c2 = [
        [10,20,30,40],
        [10,20,30,40],
        [10,20,30,40],
        [10,20,30,40],
        [10,20,30,40]
    ]

    f = [f1,f2]
    c = [c1,c2]

    y = [0,0,1,1]
    
    x = [
        [0,0,0,1],
        [0,0,0,1],
        [0,0,0,1],
        [0,0,0,1],
        [0,0,0,1]
    ]

    l = 0 

    #println("z value ponderee :" ,zValue_pondere(5,4,x,y,f,c,l))

    x_opt,y_opt = localSearch(5,4,x,y,f,c,l)

    println("y opt : ",y_opt)
    println("x opt : ",x_opt)

end

test()