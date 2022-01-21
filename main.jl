#include("init.jl")
include("localSearch.jl")

#=Un UFLP : 
Soit :
    -i le nombre de client
    -j le nombre de site pou vant acceuillir un depot
Var de decision :
    -matrice binaire X_ij (1 si le client i est déservie par le depot du site j)
    -vecteur binaire y_j (1 si le depot du site j est ouvert)
Donnee : 
    -vecteur d'entier f_j (le cout d'ouverture d'un depot sur le site j)
    -matrice d'entier c_ij (le cout de service pour le client i avec le depot du site j)
