include("lowerHull.jl")

function generationDroite(i_client,j_site,select_client,c)

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
