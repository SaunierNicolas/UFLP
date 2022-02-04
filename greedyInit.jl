

function greedyConstruction(n_client,n_site,f,c,l)
    costArray = []
    costI = 0 
    #x = zeros(Int64, n_client, n_site)
    x = Vector{Vector{Int64}}(undef,0)
    for k = 1:n_client
        push!(x,zeros(n_site))
    end
    
    y = zeros(Int64, n_site)

    #première itération
    for i = 1:n_site
        for j = 1:n_client
            costI += (c[1][j][i] * l) + (c[2][j][i] * (1-l))
        end
        costI += (f[1][i]*l)+(f[2][i]*(1-l))
        append!(costArray, costI)
        costI = 0
    end
    
    premierDepot = findfirst(isequal(minimum(costArray)), costArray)
    y[premierDepot] = 1
    
    x = remplirX(n_client, y, c,l)

    #Les depots à ouvrir en plus :
    sumCost = 0

    amelioration = true
    while amelioration != false
        costImprovement = zeros(n_site)

        for i = 1:n_site
            if y[i] == 0
                for j = 1:n_client
                    depotOuvert = 1
                    while x[j][depotOuvert] != 1
                        depotOuvert += 1
                    end
                    cout_pondere = ((c[1][j][i] * l) + (c[2][j][i] * (1-l)))
                    cout_depotOuvert_pondere = ((c[1][j][depotOuvert] * l) + (c[1][j][depotOuvert] *(1-l)))
                    if cout_pondere < cout_depotOuvert_pondere
                        sumCost += cout_depotOuvert_pondere  -  cout_pondere
                    end
                end
                sumCost -= (f[1][i]*l)+(f[2][i]*(1-l))
                costImprovement[i] = sumCost
                sumCost = 0
            end 
        end

        if maximum(costImprovement) <= 0
            #fin du glouton
            amelioration = false
        else
            #tant qu'il y a une valeur positive on continue d'améliorer
            nouveauDepot = findfirst(isequal(maximum(costImprovement)), costImprovement)
            y[nouveauDepot] = 1
            x = remplirX(n_client,y,c,l)
        end
    end 

    return (x, y)
end

#faire fonction fill pour remplir la matrice x avec les site a jour dans y

function remplirX(n_client, y, c,l)
    min = 100000000
    minK = 0
    #x = zeros(Int64, n_client, length(y))
    x = Vector{Vector{Int64}}(undef,0)
    for i = 1:n_client
        push!(x,zeros(length(y)))
    end

    for j = 1:n_client
        for k = 1:length(y) 
            if y[k] != 0
                if ((c[1][j][k] * l) + (c[2][j][k] * (1-l))) < min
                    min = ((c[1][j][k] * l) + (c[2][j][k] * (1-l)))
                    minK = k
                end
            end
        end   
        x[j][minK] = 1
        minK = 0
        min = 100000000
    end
    return x
end