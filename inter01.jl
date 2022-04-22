include("lowerHull.jl")

mutable struct Affectation
    VecteurAffectation::Vector{Int64} #Indique pour le site associé au client indicé
    VecteurDroites::Vector{Droite} #La droite associé au client indicé (selon l'affectation)
    droiteCout::Droite
    borneInf::Float64
    borneSup::Float64
    y::Vector{Int64}
end 

mutable struct Droite
    a::Rational{Int64}
    b::Rational{Int64}
    c1::Int64
    c2::Int64
end


function greedyInit_inter01(I,J,f,c)

    #1ere iteration

    affectations::Vector{Affectation} = Vector{Affectation}(undef,0)

    droites_affectation_initial::Vector{Droite} = generationDroiteAffectationInitiale(I,J,c,f)

    
    for j = 1:J

        vecteurAffect::Vector{Int64} = fill(j,I)

        droitesClient::Vector{Droite} = generationVecteurDroiteClientLambda(I,J,c,vecteurAffect)

        y::Vector{Int64} = zeros(Int64,J)
        y[j] = 1

        a::Affectation = Affectation(vecteurAffect,droitesClient,droites_affectation_initial[j],0,1,y)

        println(a)
        push!(affectations,a)

    end

    droites_polytopes = lowerHull(droites_affectation_initial)
    polytope::Vector{Droite} = Vector{Droite}(undef,0)

    for i = 1:length(droites_polytopes)
        push!(polytope,droites_affectation_initial[droites_polytopes[i]])
    end
    
    lambdas::Vector{Float64} = [1.0]

    for d = 1:length(polytope)-1
        cut,lambda = intersection(polytope[d],polytope[d+1])
        push!(lambdas,lambda)
    end

    push!(lambdas,0.0)

    #println(intervales)




    println("Lambdas d'intersections : ",lambdas)
end


function generationVecteurDroiteClientLambda(I,J,c,v_affect)

    vecteurDroite::Vector{Droite} = Vector{Droite}(undef,I)

    for i = 1:I

        j = v_affect[i] #recuperation de l'indice du site affecte au client i

        c1 = c[1][i][j]
        c2 = c[2][i][j]

        nb_lambda = c2 - c1
        cst = c2

        vecteurDroite[j] = Droite(nb_lambda//cst,1//cst,c1,c2)

    end

    return vecteurDroite
end

#l'affectation est sous forme de vecteur de taille I, contenant l'indice du site ou le client est affecté.

function affectationCost(I,affect,c,lambda)

    sum = 0
    for i = 1:I
        j = affect[i]
        c1 = c[1][i][j] * lambda
        c2 = c[2][i][j] * (1-lambda)
        sum += c1 + c2
    end
    return sum

end


function generationDroiteAffectationInitiale(I,J,c,f)

    droites::Vector{Droite} = Vector{Droite}(undef,J)

    for j = 1:J

        #cout ouverture du site j
        c1 = f[1][j]
        c2 = f[2][j]

        #cout affectation de tout les clients au site
        for i = 1:I
            
            c1 += c[1][i][j]
            c2 += c[2][i][j]

        end

        nb_lambda = c2 - c1
        cst = c2
        
        droites[j] = Droite(nb_lambda//cst,1//cst,c1,c2)
    end

    return droites

end

function plotDroites(droites)
    x = []
    y = []
    max_y = 0
    for i=1:length(droites)

        x = push!(x,[0,1])
        y = push!(y,[droites[i].c1,droites[i].c2])
        max_y = max(droites[i].c1,droites[i].c2,max_y)
    end

    plot(x,y,xlims=(0,1),ylims=(0,max_y))
end

function intersection(d1,d2)

    cut = false
    lambda = -1

    if (d1.c1 < d2.c1 && d1.c2 > d2.c2) || (d1.c1 > d2.c1 && d1.c2 < d2.c2)
        cut = true

        nbLambda1 = d1.c2 - d1.c1
        nbLambda2 = d2.c2 - d2.c1
        cst1 = d1.c2
        cst2 = d2.c2 

        lambda = 1 + (cst2-cst1)/(nbLambda1 - nbLambda2)

    end

    return cut,lambda
end
