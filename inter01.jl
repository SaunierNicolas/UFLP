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


function greedyInit_inter01(I::Int64,J::Int64,f::Vector{Vector{Float64}},c::Vector{Vector{Vector{Float64}}})
    
    polytope::Vector{Affectation} = generationAffectationInitiale(I,J,f,c) #1ere iteration
    
    new_affectations::Vector{Affectation} = Vector{Affectation}(undef,0)
    new_polytope::Vector{Affectation} = Vector{Affectation}(undef,0)


    # droitePlot = []
    # for a = polytope
    #     push!(droitePlot,a.droiteCout)
    # end

    #plotDroites(droitePlot)

    #Ajout itératif de site 
    for n = 1:J-1

        new_polytope,new_affectations = generationPolytope(I,J,c,f,polytope)
        union!(new_polytope,polytope)

        droites_new_polytope::Vector{Droite} = Vector{Droite}(undef,length(new_polytope))
        for d = 1:length(new_polytope)
            droites_new_polytope[d] = new_polytope[d].droiteCout
        end

        indiceDroites_new_polytope::Vector{Int64} = lowerHull(droites_new_polytope)

        polytope = Vector{Affectation}(undef,0)
        for d = 1:length(indiceDroites_new_polytope)
            push!(polytope,new_polytope[indiceDroites_new_polytope[d]])
        end

        lambdas::Vector{Float64} = [1.0]

        for d = 1:length(polytope)-1

            cut,lambda = intersection(polytope[d].droiteCout,polytope[d+1].droiteCout)

            #Gestion des droites non-confondues qui se coupent sur lambda=0 ou lambda=1
            if !cut #Ces droites ne sont pas identifiee par la fonction intersection()
                if polytope[d].droiteCout.c1 == polytope[d+1].droiteCout.c1
                    lambda = 0
                elseif polytope[d].droiteCout.c2 == polytope[d+1].droiteCout.c2
                    lambda = 1
                end
            end

            push!(lambdas,lambda)
        end

        push!(lambdas,0.0)

        n = length(lambdas)

        for d = 1:length(polytope)
            polytope[n-d].borneSup = lambdas[d]
            polytope[n-d].borneInf = lambdas[d+1]
        end

    end


    # println("polytope : ")
    # for a = polytope
    #     println(a.vecteurAffectation,a.y," sur [",a.borneInf,";",a.borneSup,"] (",a.droiteCout.c1,",",a.droiteCout.c2,")")
    # end

    # droites_new_affectations::Vector{Droite} = Vector{Droite}(undef,length(new_affectations))
    # for a = 1:length(new_affectations)
    #     droites_new_affectations[a] = new_affectations[a].droiteCout
    # end
    
    # droites_new_affectations::Vector{Droite} = Vector{Droite}(undef,length(polytope))
    # for a = 1:length(polytope)
    #     droites_new_affectations[a] = polytope[a].droiteCout
    # end


    
    # droites_new_affectations::Vector{Droite} = Vector{Droite}(undef,length(polyplot))

    # for a = 1:length(polyplot)
    #     droites_new_affectations[a] = polyplot[a].droiteCout
    # end

    #plotDroites(droites_new_affectations)


    ouvertures_sites::Vector{Vector{Int64}} = Vector{Vector{Int64}}(undef,length(polytope))
    for a = 1:length(polytope)
        ouvertures_sites[a] = deepcopy(polytope[a].y)
    end

    #retrait des valeurs doublons
    unique!(ouvertures_sites)

    return ouvertures_sites

end

function generationPolytope(I::Int64,J::Int64,c::Vector{Vector{Vector{Float64}}},f::Vector{Vector{Float64}},polytope::Vector{Affectation})

    new_affectations::Vector{Affectation} = Vector{Affectation}(undef,0)
 
    for a = polytope
        for j = 1:J
            union!(new_affectations,ouvertureSite(I,J,j,a,c,f))
        end
    end

    droites_affectations::Vector{Droite} = Vector{Droite}(undef,length(new_affectations))

    for a = 1:length(new_affectations)
        #println(new_affectations[a].vecteurAffectation,new_affectations[a].y)
        droites_affectations[a] = new_affectations[a].droiteCout
    end

    indices_affectations_polytopes::Vector{Int64} = lowerHull(droites_affectations)

    new_polytope::Vector{Affectation} = Vector{Affectation}(undef,0)

    for i = 1:length(indices_affectations_polytopes)
        push!(new_polytope,new_affectations[indices_affectations_polytopes[i]])
    end

    lambdas::Vector{Float64} = [1.0]

    for d = 1:length(new_polytope)-1

        cut::Bool,lambda::Float64 = intersection(new_polytope[d].droiteCout,new_polytope[d+1].droiteCout)

        #Gestion des droites non-confondues qui se coupent sur lambda=0 ou lambda=1
        if !cut #Ces droites ne sont pas identifiee par la fonction intersection()
            if new_polytope[d].droiteCout.c1 == new_polytope[d+1].droiteCout.c1
                lambda = 0
            elseif new_polytope[d].droiteCout.c2 == new_polytope[d+1].droiteCout.c2
                lambda = 1
            end
        end
        push!(lambdas,lambda)
    end        

    push!(lambdas,0.0)
    
    n = length(lambdas)
    for d = 1:length(new_polytope)
        new_polytope[n-d].borneSup = lambdas[d]
        new_polytope[n-d].borneInf = lambdas[d+1]
    end
    #println(lambdas)

    return new_polytope,new_affectations
end

function ouvertureSite(I::Int64,J::Int64,s::Int64,a::Affectation,c::Vector{Vector{Vector{Float64}}},f::Vector{Vector{Float64}})

    droitesClient_s::Vector{Droite} = Vector{Droite}(undef,I)
    y::Vector{Int64} = deepcopy(a.y)
    y[s] = 1

    #Generation des droites de cout clients relative au site s
    for i = 1:I
        c1::Rational{Int64} = c[1][i][s]
        c2::Rational{Int64} = c[2][i][s]

        nb_lambda::Rational{Int64} = c2 - c1
        cst::Rational{Int64} = c2

        droitesClient_s[i] = Droite(nb_lambda//cst,1//cst,c1,c2)
    end

    changement::Vector{Tuple{Int64,Int64,Float64,Int64}} = Vector{Tuple{Int64,Int64,Float64,Int64}}(undef,0)
    #recherche des intersections, avec le site a ouvrir pour les deux cotes de la borne
    for i = 1:I

        cut::Bool,lambda::Float64 = intersection(a.vecteurDroites[i],droitesClient_s[i])

        bestSite_avant::Int64 = 0
        bestSite_apres::Int64 = 0

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

    changementCroissant = Vector{Tuple{Int64,Int64,Float64,Int64}}(undef,0)
    #Tri des intersections pour lambda croissant
    while length(changement) > 0

        min::Int64 = 1 #indice du changement au plus petit lambda
        binfm::Float64,bsupm::Float64,lambdaMin::Float64,indiceClientm::Int64 = changement[min]

        for c = 2:length(changement)
            binf::Float64,bsup::Float64,lambda::Float64,indiceClient::Int64 = changement[c]
            if lambda < lambdaMin
                min = c
                binfm,bsupm,lambdaMin,indiceClientm = changement[min]
            end
        end

        push!(changementCroissant,changement[min])
        deleteat!(changement,min)
    end

    affectation_decoupage::Vector{Int64} = zeros(Int64,I)
    nouvellesAffectations::Vector{Affectation} = Vector{Affectation}(undef,0)
    changementLambda::Vector{Tuple{Float64,Float64,Float64,Int64}} = Vector{Tuple{Float64,Float64,Float64,Int64}}(undef,0)

    #Fixation de toutes les affectations constantes
    for i = 1:I

        avant::Int64,apres::Int64,lambda::Float64,indiceClient::Int64 = changementCroissant[i]

        if (lambda < a.borneInf)
            affectation_decoupage[indiceClient] = apres
        elseif (lambda > a.borneSup)
            affectation_decoupage[indiceClient] = avant
            
        else # donc (lambda >= a.borneInf && lambda <= a.borneSup)
            #Gestion des cas limites
            if lambda == a.borneInf
                affectation_decoupage[indiceClient] = apres
            elseif lambda == a.borneSup
                affectation_decoupage[indiceClient] = apres
            else
                push!(changementLambda,(avant,apres,lambda,indiceClient))
                affectation_decoupage[indiceClient] = avant
            end
        end

    end

    #println(affectation_decoupage)

    #Creation du vector contenant les valeurs bornantes (avec les lambdas donc)
    lambdas_decoupage::Vector{Float64} = Vector{Float64}(undef,0)
    push!(lambdas_decoupage,a.borneInf)
    for k = 1:length(changementLambda)
        trash1,trash2,lambda::Float64,trash3 = changementLambda[k]
        push!(lambdas_decoupage,lambda)
    end
    push!(lambdas_decoupage,a.borneSup)
    #println(lambdas_decoupage)
    if affectation_decoupage[1] == 0
        println(affectation_decoupage)
        println(lambdas_decoupage)
        println(changementCroissant)
    end
    #Affectation avant la premiere intersection
    borneInf::Float64 = lambdas_decoupage[1]
    borneSup::Float64 = lambdas_decoupage[2]

    #Affectation à la borne inferieur, lorsqu'il n'y a pas encore d'intersection
    
    push!(nouvellesAffectations,
        Affectation(
            deepcopy(affectation_decoupage),
            generationVecteurDroiteClientLambda(I,J,c,affectation_decoupage),
            generationDroiteCoutAffectation(I,J,c,f,y,affectation_decoupage),
            deepcopy(borneInf),deepcopy(borneSup),y
        )
    )

    #Affectation aux intersections, avec les variations
    for k = 1:length(changementLambda)

        borneInf = lambdas_decoupage[k+1]
        borneSup = lambdas_decoupage[k+2]
        
        avant::Int64,apres::Int64,lambda::Float64,indiceClient::Int64 = changementLambda[k]
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

    # println("Affectation : ",)
    # for i = 1:length(nouvellesAffectations)
    #     println(nouvellesAffectations[i].vecteurAffectation," sur [",nouvellesAffectations[i].borneInf,";",nouvellesAffectations[i].borneSup,"]"," y : ",nouvellesAffectations[i].y)
    # end

    return nouvellesAffectations

end

function generationAffectationInitiale(I::Int64,J::Int64,f::Vector{Vector{Float64}},c::Vector{Vector{Vector{Float64}}})


    affectations::Vector{Affectation} = Vector{Affectation}(undef,0)

    #Création des affectations initiales

    droites_affectation_initial::Vector{Droite} = generationDroiteAffectationInitiale(I,J,c,f)

    for j = 1:J

        vecteurAffect::Vector{Int64} = fill(j,I)

        droitesClient::Vector{Droite} = generationVecteurDroiteClientLambda(I,J,c,vecteurAffect)

        y::Vector{Int64} = zeros(Int64,J)
        y[j] = 1

        a::Affectation = Affectation(vecteurAffect,droitesClient,droites_affectation_initial[j],0,1,y)
        push!(affectations,deepcopy(a))

    end 

    indices_affectations_polytopes::Vector{Int64} = lowerHull(droites_affectation_initial)
    polytope::Vector{Affectation} = Vector{Affectation}(undef,0)

    for i = 1:length(indices_affectations_polytopes)
        push!(polytope,affectations[indices_affectations_polytopes[i]])
    end
    
    lambdas::Vector{Float64} = [1.0]

    for d = 1:length(polytope)-1
        cut::Bool,lambda::Float64 = intersection(polytope[d].droiteCout,polytope[d+1].droiteCout)
        push!(lambdas,lambda)
    end     
      
    push!(lambdas,0.0)

    n::Int64 = length(lambdas)
    for d = 1:length(polytope)
        polytope[n-d].borneSup = lambdas[d]
        polytope[n-d].borneInf = lambdas[d+1]
    end

    return polytope

end


function generationVecteurDroiteClientLambda(I::Int64,J::Int64,c::Vector{Vector{Vector{Float64}}},v_affect::Vector{Int64})

    vecteurDroite::Vector{Droite} = Vector{Droite}(undef,I)
    
        for i = 1:I

            j::Int64 = v_affect[i] #recuperation de l'indice du site affecte au client i

            c1::Rational{Int64} = c[1][i][j]
            c2::Rational{Int64} = c[2][i][j]

            nb_lambda::Rational{Int64} = c2 - c1
            cst::Rational{Int64} = c2

            vecteurDroite[i] = Droite(nb_lambda//cst,1//cst,c1,c2)

        end
    

    return vecteurDroite
end

#l'affectation est sous forme de vecteur de taille I, contenant l'indice du site ou le client est affecté.

function affectationCost(I::Int64,affect::Affectation,c::Vector{Vector{Vector{Float64}}},lambda::Float64)

    sum::Int64 = 0
    for i = 1:I
        j::Int64 = affect[i]
        c1::Float64 = c[1][i][j] * lambda
        c2::Float64 = c[2][i][j] * (1-lambda)
        sum::Float64 += c1 + c2
    end
    return sum

end


function generationDroiteAffectationInitiale(I,J,c,f)

    droites::Vector{Droite} = Vector{Droite}(undef,J)

    for j = 1:J

        #cout ouverture du site j
        c1::Rational{Int64} = f[1][j]
        c2::Rational{Int64} = f[2][j]

        #cout affectation de tout les clients au site
        for i = 1:I
            
            c1 += c[1][i][j]
            c2 += c[2][i][j]

        end

        nb_lambda::Rational{Int64} = c2 - c1
        cst::Rational{Int64} = c2
        
        droites[j] = Droite(nb_lambda//cst,1//cst,c1,c2)
    end

    return droites

end

function generationDroiteCoutAffectation(I,J,c,f,y,v_affect)

    c1::Rational{Int64} = 0.0
    c2::Rational{Int64} = 0.0
    #cout ouverture des sites
    for j = 1:J
        if y == 1
            c1 += f[1][j]
            c2 += f[2][j]
        end
    end

    #cout affectation de tout les clients
    for i = 1:I

        j::Int64 = v_affect[i]

        c1 += c[1][i][j]
        c2 += c[2][i][j]

    end

    nb_lambda::Rational{Int64} = c2 - c1
    cst::Rational{Int64} = c2

    return Droite(nb_lambda//cst,1//cst,c1,c2)
end

function plotDroites(droites::Vector{Droite},lbl)
    x = []
    y = []
    max_y = 0
    for i=1:length(droites)

        x = push!(x,[0,1])
        y = push!(y,[droites[i].c1,droites[i].c2])
        max_y = max(droites[i].c1,droites[i].c2,max_y)
    end

    plot(x,y,xlims=(0,1),ylims=(0,max_y),label=lbl,xlabel="Lambda",ylabel="Cout")
end

function intersection(d1::Droite,d2::Droite)

    cut::Bool = false
    lambda::Float64 = -1

    if ((d1.c1 < d2.c1 && d1.c2 > d2.c2) || (d1.c1 > d2.c1 && d1.c2 < d2.c2)) 
        cut = true

        nbLambda1::Float64 = d1.c2 - d1.c1
        nbLambda2::Float64 = d2.c2 - d2.c1
        cst1::Float64 = d1.c2
        cst2::Float64 = d2.c2 

        lambda = 1 + (cst2-cst1)/(nbLambda1 - nbLambda2)
    
    #Gestion des cas limites
    elseif (d1.c1 == d2.c1 && d1.c2 != d2.c2)
        cut = true
        lambda = 0
    elseif (d1.c2 == d2.c2 && d1.c1 != d2.c1)
        cut = true
        lambda = 1
    end

    return cut,lambda
end
