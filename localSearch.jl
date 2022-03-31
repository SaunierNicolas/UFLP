
function localSearch(i,j,x,y,f,c,l)
    
    y_new = deepcopy(y)
    x_new = deepcopy(x)
    x_new = pairingClient(i,j,y,c,l)

    #println("kp 2-1")
    #println("z1 : ",zValue(i,j,x_new,y_new,f[1],c[1]),", z2 : ",zValue(i,j,x_new,y_new,f[2],c[2]),y_new," zp : ",zValue_pondere(i,j,x_new,y_new,f,c,l))
    change,y_new = kp_1_1(i,j,x_new,y_new,f,c,l)
    while change == true
        #println("z1 : ",zValue(i,j,x_new,y_new,f[1],c[1]),", z2 : ",zValue(i,j,x_new,y_new,f[2],c[2]),y_new," zp : ",zValue_pondere(i,j,x_new,y_new,f,c,l))
        change,y_new = kp_1_1(i,j,x_new,y_new,f,c,l)
    end

    x_new = pairingClient(i,j,y_new,c,l)
    

    return (x_new,y_new)
end

#détermine la meilleure affectation client-depot (depot = site ouvert)
function pairingClient(n_client,n_site,y,c,l)
    
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
                costMin = l*c[1][i][j] + (1-l)*c[2][i][j]
                cost_ij = l*c[1][i][indiceDepot_minCost] + (1-l)*c[2][i][indiceDepot_minCost]
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
function kp_2_1(i,j,x,y,f,c,l)

    kp21_feasability = false
    y_new = deepcopy(y)
    z_init = zValue_pondere(i,j,x,y,f,c,l)
 

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
                    x_new = pairingClient(i,j,y_new,c,l)
                    z_new = zValue_pondere(i,j,x_new,y_new,f,c,l)

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
function kp_1_1(i,j,x,y,f,c,l)

    kp11_feasability = false
    y_new = deepcopy(y)
    z_init = zValue_pondere(i,j,x,y,f,c,l)
 

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
    if (length(indice_1) < 2)
        return false,y
    end

    #Recherche d'un kp 1-1.
    for a = 1:length(indice_1)
            for d = 1:length(indice_0)
                
                if (a!=d)

                    #swapping
                    y_new[indice_1[a]] = 0
                    y_new[indice_0[d]] = 1

                    #println(a,",",b,",",d," : ",y)

                    #évaluation de la nouvelle solution
                    x_new = pairingClient(i,j,y_new,c,l)
                    z_new = zValue_pondere(i,j,x_new,y_new,f,c,l)

                    if (z_new < z_init)
                        println("z_new : ",z_new," z_init : ",z_init)
                        println("x_new : ",x_new," x_init ",x )
                        println("y_new : ",y_new," y_init ",y )
                        kp11_feasability = true
                        return kp11_feasability,y_new
                    end

                    #unswapping
                    y_new[indice_1[a]] = 1
                    y_new[indice_0[d]] = 0
                end
            end
        
    end
    kp11_feasability = false
    return kp11_feasability,y_new
end



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

function zValue_pondere(i,j,x,y,f,c,l)
    z1 = zValue(i,j,x,y,f[1],c[1])*l
    z2 = zValue(i,j,x,y,f[2],c[2])*(1-l)
    z = z1+z2
    return z
end
