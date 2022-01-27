include("greedyInit.jl")
include("localSearch.jl")

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
    f = [10,7,3,11,5,4]

    #cout service client
    c = [
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
            [0,0,0,0,1,0,1,1,0,0], #1
            [0,0,0,0,0,0,0,0,0,0], #0
            [0,0,0,0,0,0,0,0,0,0], #0
            [1,0,1,0,0,1,0,0,1,0], #1
            [0,1,0,1,0,0,0,0,0,1], #1
            [0,0,0,0,0,0,0,0,0,0], #0
            ]

    y_init = [1,0,0,1,1,0]

   # x_opt,y_opt = localSearch(i,j,y_init,f,c)

    

end

main()