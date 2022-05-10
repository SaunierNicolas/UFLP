include("greedyInit.jl")
include("localSearch.jl")
include("parser.jl")
include("filtering.jl")
include("inter01.jl")
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

    #Décommenter pour charger des données didactiques
    #I,J,f,c,x_init,y_init = donnees_didactique()

    #nom du ficher de l'instance a charger
    nomInstance = "F52-54.txt"

    I::Int64,J::Int64,c::Vector{Vector{Vector{Float64}}},f::Vector{Vector{Float64}} = parser(nomInstance)

    #Vrai si l'on souhaite plus d'information

    #Vrai si l'on souhaite une ouverture des sites par decoupage d'decoupageIntervalle
    #Faux si l'on souhaite une ouverture des sites par echantillonnage
    decoupageIntervalle = true

    #Si l'ouverture des sites se fait avec l'echantillonnage, il faut indiquer une precision.
    precision = 1000

    println("Instance ",nomInstance)

    if (decoupageIntervalle)
        println("Ouverture des sites par decoupage d'intervalle")
    else
        println("Ouverture des sites par echantillonnage, avec une precision de ",precision)
    end
    
    execution(I,J,c,f,decoupageIntervalle,precision)
    

end

function execution(I,J,c,f,ouvertureInter,precision)


    ouvertures_sites::Vector{Vector{Int64}} = Vector{Vector{Int64}}(undef,0)

    t_ouverture = 0.0

    if ouvertureInter
        t_ouverture = @elapsed ouvertures_sites = greedyInit_inter01(I,J,f,c)
    else
        t_ouverture = @elapsed ouvertures_sites = echantillonnage(I,J,f,c,precision)
    end

    affectations_clients::Vector{Vector{Int64}} = Vector{Vector{Int64}}(undef,0)

    groupe_points_c1::Vector{Vector{Float64}} = Vector{Vector{Float64}}(undef,0)
    groupe_points_c2::Vector{Vector{Float64}} = Vector{Vector{Float64}}(undef,0)

    total_points::Vector{Tuple{Float64,Float64}} = Vector{Tuple{Float64,Float64}}(undef,0)
    total_points_c1::Vector{Float64} = Vector{Float64}(undef,0)
    total_points_c2::Vector{Float64} = Vector{Float64}(undef,0)

    println("ouvertures terminée : ",length(ouvertures_sites) , " services ouverts (",t_ouverture," s)")

    println("calcul des affectations :")
    t_filtrage = Vector{Float64}(undef,length(ouvertures_sites))
    for k = 1:length(ouvertures_sites)
        print(k,"/",length(ouvertures_sites))

        y = ouvertures_sites[k]
        t_filtrage[k] = @elapsed affectations_clients = affectationClient(I,J,y,c)
        println("(",t_filtrage[k],"s)")
        vecteur_couts::Vector{Tuple{Float64,Float64}} = Vector{Tuple{Float64,Float64}}(undef,0)
        for x = affectations_clients
            cout = cout_affectation(I,J,x,y,c,f)
            push!(vecteur_couts,cout)
        end

        vecteur_couts = filtrage_point_finale(vecteur_couts)
        union!(total_points,vecteur_couts)

        valeurs_axe_1,valeurs_axe_2 = VectCouple_to_vect(vecteur_couts)
        push!(groupe_points_c1,valeurs_axe_1)
        push!(groupe_points_c2,valeurs_axe_2)

    end

    total_points = filtrage_point_finale(total_points)

    total_points_c1,total_points_c2 = VectCouple_to_vect(total_points)

    sum = 0.0
    for k = t_filtrage
        sum += k
    end
    println("temps filtrage total : ",sum," s")
    println("temps filtrage moyen  : ",sum/length(t_filtrage)," s")

    println("nombre de point non-dominés : ",length(total_points))

    #scatter(groupe_points_c1,groupe_points_c2,label=false)
    scatter(total_points_c1,total_points_c2,label=false,title="Solutions non-dominées",xlabel="cout 1",ylabel="cout 2")


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

function affectation_to_points(liste_vecteurAffectation,I,J,c,f)

    points::Vector{Tuple{Float64,Float64}} = Vector{Tuple{Float64,Float64}}(undef,0)

    for a = liste_vecteurAffectation
        c1 = 0
        c2 = 0
        for j = 1:J
            i = a[j]
            c1 += c[1][i][j]
            c2 += c[2][i][j]
        end
        push!(points,(c1,c2))
    end

    return points

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

function cout_affectation(I,J,x,y,c,f)

    cout1::Float64 = 0
    cout2::Float64 = 0


    for j = 1:J
        if y[j] == 1
            cout1 += f[1][j]
            cout2 += f[2][j]
        end
    end

    for i = 1:I
        j = x[i]
        cout1 += c[1][i][j]
        cout2 += c[2][i][j]
    end

    return cout1,cout2

end

function filtrage_point_finale(points)

    res::Vector{Tuple{Float64,Float64}} = Vector{Tuple{Float64,Float64}}(undef,0)
    for i = 1:length(points)
        nonDominated = true
        a1,b1 = points[i]
        for j = 1:length(points)
            if i!=j 
                a2,b2 = points[j]
                if ((a2<=a1) && (b2<b1))||
                    ((a2<a1) && (b2<=b1))
                    nonDominated = false
                end
            end
        end

        if nonDominated
            push!(res,points[i])
        end
    end
    return res

end

function donnees_didactique()
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

    return I,J,f,c,x_init,y_init

end

main()
