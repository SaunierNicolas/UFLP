include("greedyInit.jl")
include("localSearch.jl")
include("parser.jl")
include("filtering.jl")
include("inter01.jl")

#import Pkg; Pkg.add("Plots")
using Plots
#=Un UFLP : 
Soit :
    -i le nombre de client 
    -j le nombre de site pouvant acceuillir un depot
Var de decision :
    -matrice binaire x_ij (1 si le client i est déservie par le depot du site j)
    -vecteur binaire y_j (1 si le depot du site j est ouvert)
Donnee : 
    -vecteur d'entier f_j (le cout d'ouverture d'un depot sur le site j)
    -matrice d'entier c_ij (le cout de service pour le client i avec le depot du site j)
=#

function main()
    
    #instance de test----------------------------------------------------------
    #6 sites
    J = 6
    #10 clients
    I = 10

    #cout ouverture site
    f_1 = [7,7,3,11,5,4]
    f_2 = [3,2,12,9,10,7]

    f = [f_1,f_2]

    #cout service client
    c_1 = [
        [7,2,1,9,7,3],
        [3,2,4,8,2,1],
        [1,2,4,6,1,6],
        [4,1,6,9,3,4],
        [6,5,3,6,7,2],
        [2,6,9,9,4,1],
        [9,2,9,4,6,9],
        [1,1,7,6,1,5],
        [3,9,7,2,5,2],
        [7,4,4,7,5,1]
    ]

    c_2 = [
        [9,7,3,5,8,1],
        [1,2,6,4,1,9],
        [6,6,1,9,6,7],
        [5,4,5,5,2,1],
        [3,6,4,9,9,1],
        [1,3,8,6,1,3],
        [3,4,5,6,8,9],
        [1,6,1,8,2,3],
        [3,2,9,6,7,6],
        [8,3,9,4,5,3]
    ]

    c = [c_1,c_2]

    
    x_init = [
         #y=[1,0,0,1,1,0]
            [0,0,0,1,0,0],
            [0,0,0,0,1,0],
            [0,0,0,1,0,0],
            [0,0,0,0,1,0],
            [1,0,0,0,0,0],
            [0,0,0,1,0,0],
            [1,0,0,0,0,0],
            [1,0,0,0,0,0],
            [0,0,0,1,0,0],
            [0,0,0,0,1,0]
        ]

    y_init = [1,0,0,1,1,0]


    


    #plot_twist(10,i,j,f,c)

    #plot_twist(10,i,j,f,c)

    #points = filter(i,j,[1,1,0,0,0,0],c)
    
    #plot_filtered(points)
    #=
    dataFiles = getfname()

    i,j,f_raw,c_raw = loadUFLP(dataFiles[1])

    i = 25
    c1 = c_raw[1:25]
    c2 = c_raw[26:50]

    f1 = f_raw[1:8]
    f2 = f_raw[9:16]

    f = [f1,f2]
    c = [c1,c2]=#

    #println(" i : ", i ,"j : ",j)
    #plot_twist(10,i,j,f,c)
    #plot_filtered(filter(i,j,[1,0,1,0,1,0,0,1,1,1,1,0,1,1,0,1],c))
    
    #filter(i,j,ones(Int,j),c)
    #list_y = echantillonnage(i,j,f,c,100)

    coord1 = []
    coord2 = []
    points = []
    #=
    for k = 1:length(list_y)
        points = union(points,filter(i,j,list_y[k],c))
        println("y ",k," : ",list_y[k])
        a,b = VectCouple_to_vect(points)
        coord1 = push!(coord1,a)
        coord2 = push!(coord2,b)
    end
    =#

    #filter(i,j,list_y[1],c)
    #println()

    #scatter(coord1,coord2)
    
    #points_final = eff(points)

    #a,b = VectCouple_to_vect(points_final)

    #scatter(a,b)

    
    ouvertures_sites::Vector{Vector{Int64}} = greedyInit_inter01(I,J,f,c)

    for y = ouvertures_sites
        filter(I,J,y,c)
    end


end

function echantillonnage(i,j,f,c,nb_echant)

    list_y = []

    pas = 1/nb_echant

    for k = 1:nb_echant
        x,y = greedyConstruction(i,j,f,c,k*pas)
        if !(y in list_y)
            list_y = push!(list_y,y)
        end
    end

    return list_y
end


function plot_twist(nb_echantillon,i,j,f,c)

    echantillon_lambda = [1:nb_echantillon]/nb_echantillon
    plot!(xlabel = "lambda")
    plot!(ylabel = "z value")
    echantillon_z_init = Vector{Float64}(undef,nb_echantillon)
    echantillon_z_opt = Vector{Float64}(undef,nb_echantillon)

    for k in 1:nb_echantillon
        lambda = k/nb_echantillon
        x_init,y_init = greedyConstruction(i,j,f,c,lambda)
        x_opt,y_opt = localSearch(i,j,x_init,y_init,f,c,lambda)
        z_init = zValue_pondere(i,j,x_init,y_init,f,c,lambda)
        z_opt = zValue_pondere(i,j,x_opt,y_opt,f,c,lambda)
        echantillon_z_init[k] = z_init
        echantillon_z_opt[k] = z_opt
        println("init : ",z_init/1000," opt : ",z_opt/1000)
    end



    scatter(echantillon_lambda, [echantillon_z_init,echantillon_z_opt] ,label = ["init" "local_opt"],xlabel="lambda",ylabel="z value")
end

function VectCouple_to_vect(points)
    
    x = Vector{Float64}(undef,0)
    y = Vector{Float64}(undef,0)

    for i = 1:length(points)
        a,b = points[i]
        x = push!(x,a)
        y = push!(y,b)
    end

    return x,y
end




main()
