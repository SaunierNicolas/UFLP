include("greedyInit.jl")
include("localSearch.jl")
include("parser.jl")

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
    #=
    #instance de test----------------------------------------------------------
    #6 sites
    j = 6
    #10 clients
    i = 10

    #cout ouverture site
    f_1 = [10,7,3,11,5,4]
    f_2 = [3,2,12,9,1,7]

    f = [f_1,f_2]

    #cout service client
    c_1 = [
        [7,2,1,9,7,3],
        [3,2,4,8,2,1],
        [1,2,4,6,1,6],
        [4,1,6,1,3,4],
        [6,5,3,2,7,2],
        [2,6,9,9,4,1],
        [9,2,9,4,6,9],
        [1,1,7,6,1,5],
        [3,9,7,2,5,2],
        [7,4,4,7,5,1]
    ]

    c_2 = [
        [9,7,3,5,8,1],
        [1,2,6,4,1,9],
        [6,6,1,1,6,7],
        [5,4,5,5,2,1],
        [3,6,4,3,9,1],
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

    plot_twist(10,i,j,f,c)=#




    dataFiles = getfname()
    i,j,f1,c1 = loadUFLP(dataFiles[1])
    i,j,f2,c2 = loadUFLP(dataFiles[2])
    f = [f1,f2]
    c = [c1,c2]
    plot_twist(10,i,j,f,c)

end

#En écrivant le nom de cette fonction j'ai eu très envie d'acheter des Twix :)))
#BTW c'est pour faire des plot
#Sinon y'avait la blague "scatter_ploter" qui est vraiment bonne, mais bon faut bien choisir
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


#main()
