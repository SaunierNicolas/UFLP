
function localSearch(i,j,x,y,f,c,l_1,l_2)
    
    y_new = deepcopy(y)
    x_new = deepcopy(x)
    x_new = pairingClient(i,j,y,c,l_1,l_2)

    println("kp 2-1")
    println(zValue(i,j,x_new,y_new,f[1],c[1]),zValue(i,j,x_new,y_new,f[2],c[2]),y_new)
    change,y_new = kp_2_1(i,j,x,y_new,f,c,l_1,l_2)
    while change == true
        println(zValue(i,j,x_new,y_new,f[1],c[1]),zValue(i,j,x_new,y_new,f[2],c[2]),y_new)
        change,y_new = kp_2_1(i,j,x,y_new,f,c,l_1,l_2)
    end

    x_new = pairingClient(i,j,y_new,c,l_1,l_2)
    

    return (x_new,y_new)
end

#détermine la meilleure affectation client-depot (depot = site ouvert)
function pairingClient(n_client,n_site,y,c,l_1,l_2)
    
    #initialisation de x 
    x = Vector{Vector{Int64}}(undef,0)
    for i = 1:n_client
        push!(x,zeros(n_site))
        
    end

    #Recherche du cout minimum.
    for i = 1:n_client
        indiceDepot_minCost = 1
        for j = 1:n_site
            if y[j] == 1
                costMin = l_1*c[1][i][j] + l_2*c[2][i][j]
                cost_ij = l_1*c[1][i][indiceDepot_minCost] + l_2*c[2][i][indiceDepot_minCost]
                if cost_ij < costMin
                    indiceDepot_minCost = j
                end
            end
        end
        x[i][indiceDepot_minCost] = 1
    end


    return x
end

#Retourne si le kp 2-1 est applicable, et le vecteur y post-kp.
function kp_2_1(i,j,x,y,f,c,l_1,l_2)

    kp21_feasability = false
    y_new = deepcopy(y)
    z_init = zValue(i,j,x,y,f,c)
 

    #Listes contenant les indices des site ouverts (1) ou fermées (0).
    indice_1 = Vector{Int64}(undef,0)
    indice_0 = Vector{Int64}(undef,0)

    #Initialisation des listes d'indices.
    for k = 1:j
        if y[k]==1
            push!(indice_1,k)
        else 
            push!(indice_0,k)
        end
    end

    #Si il y a moins de 2 site ouverts, pas de kp 2-1 possible.
    if (length(indice_1) < 2)
        return false,y
    end

    #Recherche d'un kp 2-1.
    for a = 1:length(indice_1)
        for b = 1:length(indice_1)
            for d = 1:length(indice_0)
                
                if (a!=b)&&(b!=d)

                    #swapping
                    y_new[indice_1[a]] = 0
                    y_new[indice_1[b]] = 0
                    y_new[indice_0[d]] = 1

                    #println(a,",",b,",",d," : ",y)

                    #évaluation de la nouvelle solution
                    x_new = pairingClient(i,j,y_new,c,l_1,l_2)
                    z_new = zValue_pondere(i,j,x_new,y_new,f,c,l_1,l_2)

                    if (z_new < z_init)
                        kp21_feasability = true
                        return kp21_feasability,y_new
                    end

                    #unswapping
                    y_new[indice_1[a]] = 1
                    y_new[indice_1[b]] = 1
                    y_new[indice_0[d]] = 0
                end
            end
        end
    end
    kp21_feasability = false
    return kp21_feasability,y_new
end

#Retourne si le kp 1-1 est applicable, et le vecteur y post-kp.
#=function kp_1_1(i,j,x,y,f,c)

    kp11_feasability = false
    y_new = deepcopy(y)
    z_init = zValue(i,j,x,y,f,c)
 

    #Listes contenant les indices des site ouverts (1) ou fermées (0).
    indice_1 = Vector{Int64}(undef,0)
    indice_0 = Vector{Int64}(undef,0)

    #Initialisation des listes d'indices.
    for k = 1:j
        if y[k]==1
            push!(indice_1,k)
        else 
            push!(indice_0,k)
        end
    end

    #Si il y a moins de 1 site ouverts, pas de kp 1-1 possible.
    if (length(indice_1) < 1)
        return false,y
    end

    #Recherche d'un kp 1-1.
    for a = 1:length(indice_1)
        for b = 1:length(indice_0)

            if (a!=b)
                #swapping
                y_new[indice_1[a]] = 0
                y_new[indice_0[b]] = 1

                #println(a,",",b,",",d," : ",y)

                #évaluation de la nouvelle solution
                x_new = pairingClient(i,j,y_new,c)
                z_new = zValue(i,j,x_new,y_new,f,c)
                println(z_new,",",z_init)
                if (z_new < z_init)
                    kp21_feasability = true
                    return kp21_feasability,y_new
                end

                #unswapping
                y_new[a] = 1
                y_new[b] = 0

            end
            
        end
    end
    println("fin")
    kp11_feasability = false
    return kp11_feasability,y_new
end=#






function zValue(i,j,x,y,f,c)
    sum_y = 0
    for n = 1:j
        sum_y += y[n]*f[n]
    end
    sum_x = 0

    for n = 1:i
        for m = 1:j
            sum_x += x[n][m] * c[n][m]
        end
    end

    return sum_y+sum_x
end

function zValue_pondere(i,j,x,y,f,c,l_1,l_2)
    return (zValue(i,j,x,y,f[1],c[1])*l_1) + (zValue(i,j,x,y,f[2],c[2])*l_2)
end
