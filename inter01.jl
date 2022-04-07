include("lowerHull.jl")

mutable struct Intervale
    borneInf::Float64
    borneSup::Float64
    sites::Int64
end 

mutable struct DroiteIntervale
    a::Rational{Int64}
    b::Rational{Int64}
    c1::Int64
    c2::Int64
end

mutable struct DroiteSite
    a::Rational{Int64}
    b::Rational{Int64}
    c1::Int64
    c2::Int64
    site::Int64
end

function greedyInit_inter01(I,J,f,c)

    pending_intervals = []

    #1ere iteration
    droites_sites = generationDroiteSite(I,J,c,f)
    intervales = []

    polytope = lowerHull(droites_sites)
    println(polytope)
    lambdas = [1.0]

    for d = 1:length(polytope)-1
        cut,lambda = intersection(polytope[d],polytope[d+1])
        push!(lambdas,lambda)
    end
    push!(lambdas,0.0)

    nbDroite = length(polytope)
    nbLambda = length(lambdas)

    push!(intervales,Intervale(lambdas[nbLambda],1,polytope[nbDroite].site))

    for i = 1:nbLambda-1

        push!(intervales,Intervale(lambdas[i],lambdas[i+1],polytope[i].site))

    end

    println(intervales)



    println("Lambdas d'intersections : ",lambdas)
end

function addSite(J,lambdas,site,affect)

    for j = 1:J
        
    end

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

function generationDroiteClient(i_client,j_site,c)

    droites::Vector{Droite} = Vector{Droite}(undef,i_client*j_site)

    for i = 1:i_client
        for j = 1:j_site

            c1 = c[1][i][j]
            c2 = c[2][i][j]

            nb_lambda = c1 - c2
            cst = c2
            
            #dénombrement
            indice = (i-1)*j_site + j

            if cst == 0
                println("faut faire quelque chose")
            else
                droites[indice] = Droite(nb_lambda//cst,1//cst)
            end

        end
    end
    return droites
end

function generationDroiteSite(I,J,c,f)

    droites::Vector{DroiteSite} = Vector{DroiteSite}(undef,J)

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
        
        droites[j] = DroiteSite(nb_lambda//cst,1//cst,c1,c2,j)
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