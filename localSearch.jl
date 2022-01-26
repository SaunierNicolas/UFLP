
function localSearch(i,j,y,f,c)
    #kp-exchange
    return (pairingClient(i,j,y,c),0)
end

#détermine la meilleure affectation client-depot (depot = site ouvert)
function pairingClient(n_client,n_site,y,c)
    
    #initialisation de x 
    x = Array{Int64}(undef,n_client,n_site)
    for i = 1:n_client
        for j = 1:n_site
            x[i,j] = 0
        end
    end

    #recherche du cout minimum
    for i = 1:n_client
        indiceDepot_minCost = 1
        for j = 1:n_site
            if y[j] == 1
                if c[i][j] < c[i][indiceDepot_minCost]
                    indiceDepot_minCost = j
                end
            end
        end
        x[i,indiceDepot_minCost] = 1
    end

    return x
end