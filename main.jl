include("greedyInit.jl")
include("localSearch.jl")

#import Pkg; Pkg.add("Plots")
using Plots
#=Un UFLP : 
Soit :
    -i le nombre de client 
    -j le nombre de site pou vant acceuillir un depot
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
    f = [f_1,f_2]

    
    j2 = 4
    i2 = 8
    f2 = [8,15,7,6]
    c2 = [
        [5,2,10,11],
        [3,0,8,9],
        [4,1,10,7],
        [7,4,13,4],
        [10,7,10,2],
        [10,13,5,3],
        [5,8,0,8],
        [3,6,2,11]
    ]
    
    (x_init,y_init) = greedyConstruction(i,j,f,c)
    println("DEPOT OUVERT", y_init)
    println("MATRICE", x_init)

    #Valeur arbitraire pour x et y en attendant l'implémentation de la construction gloutonne
    

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

    x_opt_1,y_opt_1 = localSearch(i,j,x_init,y_init,f,c,1,0)
    x_opt_2,y_opt_2 = localSearch(i,j,x_init,y_init,f,c,1,0)


    println("y_init_1 : ",y_init)
    println("z_init_1 : ",zValue(i,j,x_init,y_init,f,c_1))
    println("y_opt_1 : ",y_opt_1)
    println("z_opt_1 : ",zValue(i,j,x_opt_1,y_opt_1,f,c_1))

    println("y_init_2 : ",y_init)
    println("z_init_2 : ",zValue(i,j,x_init,y_init,f,c_2))
    println("y_opt_2 : ",y_opt_2)
    println("z_opt_2 : ",zValue(i,j,x_opt_2,y_opt_2,f,c_2))


    #x = 1:10; y = [rand(10),rand(10)];
    #scatter(x, y)

for i = 1:10
    println(rand(6))
end

end

main()