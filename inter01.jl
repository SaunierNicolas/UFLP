include("lowerHull.jl")

mutable struct Affectation
    vecteurAffectation::Vector{Int64} #Indique pour le site associé au client indicé
    vecteurDroites::Vector{Droite} #La droite associé au client indicé (selon l'affectation)
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

    #Création des affectations initiales

    droites_affectation_initial::Vector{Droite} = generationDroiteAffectationInitiale(I,J,c,f)

    for j = 1:J

        vecteurAffect::Vector{Int64} = fill(j,I)

        droitesClient::Vector{Droite} = generationVecteurDroiteClientLambda(I,J,c,vecteurAffect)

        y::Vector{Int64} = zeros(Int64,J)
        y[j] = 1

        a::Affectation = Affectation(vecteurAffect,droitesClient,droites_affectation_initial[j],0,1,y)
        push!(affectations,a)

    end

    indices_affectations_polytopes = lowerHull(droites_affectation_initial)
    polytope::Vector{Affectation} = Vector{Affectation}(undef,0)

    for i = 1:length(indices_affectations_polytopes)
        push!(polytope,affectations[indices_affectations_polytopes[i]])
    end
    
    lambdas::Vector{Float64} = [1.0]

    for d = 1:length(polytope)-1
        cut,lambda = intersection(polytope[d].droiteCout,polytope[d+1].droiteCout)
        push!(lambdas,lambda)
    end        
    push!(lambdas,0.0)



    n = length(lambdas)
    for d = 1:length(polytope)
        polytope[n-d].borneSup = lambdas[d]
        polytope[n-d].borneInf = lambdas[d+1]
    end

    println(lambdas)

    println("Affectation : ",)
    for a = 1:length(polytope)
        println(polytope[a].vecteurAffectation," sur [",polytope[a].borneInf,";",polytope[a].borneSup,"]")
    end

    affectationsOuvertes::Vector{Affectation} = Vector{Affectation}(undef,0)
    affectationsFermees::Vector{Affectation} = Vector{Affectation}(undef,0)


    #Découpage en sous intervalles
    
    aff = affectations[1]
    ouvertureSite(I,J,6,aff,c,f)


end

function ouvertureSite(I,J,s,a,c,f)

    droitesClient_s::Vector{Droite} = Vector{Droite}(undef,I)
    y = a.y
    y[s] = 1

    for i = 1:I
        c1 = c[1][i][s]
        c2 = c[2][i][s]

        nb_lambda = c2 - c1
        cst = c2

        droitesClient_s[i] = Droite(nb_lambda//cst,1//cst,c1,c2)
    end

    changement = []

    for i = 1:I

        cut,lambda = intersection(a.vecteurDroites[i],droitesClient_s[i])

        bestSite_avant = 0
        bestSite_apres = 0

        if cut
            if a.vecteurDroites[i].c1 > droitesClient_s[i].c1
                bestSite_avant = s
                bestSite_apres = a.vecteurAffectation[i]
            else
                bestSite_avant = a.vecteurAffectation[i]
                bestSite_apres = s
            end
        else #Si pour tout lambda il n'y a pas de changement
            if a.vecteurDroites[i].c1 > droitesClient_s[i].c1
                bestSite_apres = s
            else
                bestSite_apres = a.vecteurAffectation[i]
            end
            lambda = -1
        end

        push!(changement,(bestSite_avant,bestSite_apres,lambda,i))
    end

    lambdas::Vector{Float64} = Vector{Float64}(undef,0)

    changementCroissant = []

    while length(changement) > 0

        min = 1 #indice du changement au plus petit lambda
        binfm,bsupm,lambdaMin,indiceClientm = changement[min]

        for c = 2:length(changement)
            binf,bsup,lambda,indiceClient = changement[c]
            if lambda < lambdaMin
                min = c
                binfm,bsupm,lambdaMin,indiceClientm = changement[min]
            end
        end

        push!(changementCroissant,changement[min])
        deleteat!(changement,min)
    end

    println(changementCroissant)

    affectation_decoupage = zeros(Int64,I)
    nouvellesAffectations::Vector{Affectation} = Vector{Affectation}(undef,0)
    changementLambda::Vector{Tuple{Float64,Float64,Float64,Int64}} = Vector{Tuple{Float64,Float64,Float64,Int64}}(undef,0)

    #Fixation de toutes les affectations constantes
    for i = 1:I

        avant,apres,lambda,indiceClient = changementCroissant[i]

        if (lambda < a.borneInf)
            affectation_decoupage[indiceClient] = apres
        elseif (lambda > a.borneSup)
            affectation_decoupage[indiceClient] = avant
        else # donc (lambda >= a.borneInf && lambda <= a.borneSup)
            push!(changementLambda,(avant,apres,lambda,indiceClient))
            affectation_decoupage[indiceClient] = avant
        end

    end

    println(affectation_decoupage)

    if length(changementLambda) > 0

        lambdas_decoupage::Vector{Float64} = Vector{Float64}(undef,0)
        push!(lambdas_decoupage,a.borneInf)
        for k = 1:length(changementLambda)
            trash1,trash2,lambda,trash3 = changementLambda[k]
            push!(lambdas_decoupage,lambda)
        end
        push!(lambdas_decoupage,a.borneSup)
        println(lambdas_decoupage)

        #Affectation avant la premiere intersection
        borneInf = lambdas_decoupage[1]
        borneSup = lambdas_decoupage[2]

        #Affectation à la borne inferieur des intersections
        push!(nouvellesAffectations,
            Affectation(
                deepcopy(affectation_decoupage),
                generationVecteurDroiteClientLambda(I,J,c,affectation_decoupage),
                generationDroiteCoutAffectation(I,J,c,f,y,affectation_decoupage),
                deepcopy(borneInf),deepcopy(borneSup),y
            )
        )


        for k = 1:length(changementLambda)

            borneInf = lambdas_decoupage[k+1]
            borneSup = lambdas_decoupage[k+2]
            
            avant,apres,lambda,indiceClient = changementLambda[k]
            affectation_decoupage[indiceClient] = apres
            push!(nouvellesAffectations,
            Affectation(
                deepcopy(affectation_decoupage),
                generationVecteurDroiteClientLambda(I,J,c,affectation_decoupage),
                generationDroiteCoutAffectation(I,J,c,f,y,affectation_decoupage),
                deepcopy(borneInf),deepcopy(borneSup),y
            )
        )
        end
    end



    println("Affectation : ",)
    for i = 1:length(nouvellesAffectations)
        println(nouvellesAffectations[i].vecteurAffectation," sur [",nouvellesAffectations[i].borneInf,";",nouvellesAffectations[i].borneSup,"]")
    end

    return nouvellesAffectations
    

end


function generationVecteurDroiteClientLambda(I,J,c,v_affect)

    vecteurDroite::Vector{Droite} = Vector{Droite}(undef,I)
    
        for i = 1:I

            j = v_affect[i] #recuperation de l'indice du site affecte au client i

            c1 = c[1][i][j]
            c2 = c[2][i][j]

            nb_lambda = c2 - c1
            cst = c2

            vecteurDroite[i] = Droite(nb_lambda//cst,1//cst,c1,c2)

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

function generationDroiteCoutAffectation(I,J,c,f,y,v_affect)


    c1 = 0
    c2 = 0

    #cout ouverture des sites
    for j = 1:J
        if y == 1
            c1 += f[1][j]
            c2 += f[2][j]
        end
    end

    #cout affectation de tout les clients
    for i = 1:I

        j = v_affect[i]

        c1 += c[1][i][j]
        c2 += c[2][i][j]

    end

    nb_lambda = c2 - c1
    cst = c2

    return Droite(nb_lambda//cst,1//cst,c1,c2)
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
