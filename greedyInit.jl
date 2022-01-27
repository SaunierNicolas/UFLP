

function greedyConstruction(n_client,n_site,f,c)
    costArray = []
    costI = 0 
    x = zeros(Int64, n_client, n_site)
    y = zeros(Int64, n_site)

    #première itération
    for i = 1:n_site
        for j = 1:n_client
            costI += c[j][i]
        end
        costI += f[i]
        append!(costArray, costI)
        costI = 0
    end
    
    premierDepot = findfirst(isequal(minimum(costArray)), costArray)
    y[premierDepot] = 1
    
    x = remplirX(n_client, y, c)

    #Les depots à ouvrir en plus :
    sumCost = 0

    amelioration = true
    while amelioration != false
        costImprovement = zeros(n_site)

        for i = 1:n_site
            if y[i] == 0
                for j = 1:n_client
                    depotOuvert = findfirst(isequal(1), x[j,:])
                    if c[j][i] < c[j][depotOuvert]
                        sumCost += c[j][depotOuvert]-c[j][i]
                    end
                end
                sumCost -= f[i]
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
            x = remplirX(n_client,y,c)
        end
    end 

    return (x, y)
end

#faire fonction fill pour remplir la matrice x avec les site a jour dans y

function remplirX(n_client, y, c)
    min = 100000000
    minK = 0
    x = zeros(Int64, n_client, length(y))

    for j = 1:n_client
        for k = 1:length(y) 
            if y[k] != 0
                if c[j][k] < min
                    min = c[j][k]
                    minK = k
                end
            end
        end   
        x[j, minK] = 1
        minK = 0
        min = 100000000
    end
    return x
end