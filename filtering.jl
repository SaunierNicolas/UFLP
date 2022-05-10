include("greedyInit.jl")

mutable struct PointFiltrage
    obj1::Float64
    obj2::Float64
    site::Int64
    precedent
end

function filter(I::Int64,J::Int64,y::Vector{Int64},c::Vector{Vector{Vector{Float64}}})

    echo = false
    echo_etape = false

    #initialisation des points

    nb_site_ouvert = 0
    for j = 1:J
        if y[j] == 1
            nb_site_ouvert += 1
        end
    end


    points::Vector{Vector{PointFiltrage}} = Vector{Vector{PointFiltrage}}(undef,I)

    for i = 1:I
        points[i] = Vector{PointFiltrage}(undef,nb_site_ouvert)
        for j = 1:nb_site_ouvert
            points[i][j] = PointFiltrage(c[1][i][j] , c[2][i][j] ,j,nothing)
        end
    end

    if echo
        display(points)
    end

    override = false
    
    if override
        #override pour test
        points = [
            [PointFiltrage(6.45,3.099,1,nothing),PointFiltrage(1.453,9.076,2,nothing),PointFiltrage(3.224,4.306,3,nothing)],
            [PointFiltrage(10.8,1.701,1,nothing),PointFiltrage(2.168,3.872,2,nothing),PointFiltrage(3.404,9.501,3,nothing)],
            [PointFiltrage(9.088,3.718,1,nothing),PointFiltrage(3.298,6.05,2,nothing),PointFiltrage(4.858,6.983,3,nothing)],
            [PointFiltrage(4.347,3.416,1,nothing),PointFiltrage(1.0,10.45,2,nothing),PointFiltrage(2.809,2.185,3,nothing)],
            [PointFiltrage(4.895,7.632,1,nothing),PointFiltrage(8.466,2.832,2,nothing),PointFiltrage(9.948,3.809,3,nothing)],
            [PointFiltrage(10.4,2.656,1,nothing),PointFiltrage(3.129,4.118,2,nothing),PointFiltrage(4.384,8.893,3,nothing)]
        ]
        #display(points)

        I=6
        J=3
    end

    to_filter::Vector{Vector{PointFiltrage}} = Vector{Vector{PointFiltrage}}(undef,0)

    #Pré-traitement.
    for i = 1:I
        push!(to_filter,eff(points[i]))
    end

    if echo
        println("Après le pré-traiement :")
        display(to_filter)
        println("-----------------------------------------------------------------------")
    end
    
    filtered::Vector{PointFiltrage} = deepcopy(to_filter[1])



    #Filtrage linéaire.
    for i = 2:I
        new_filtered::Vector{PointFiltrage} = Vector{PointFiltrage}(undef,0)
        for j = 1:length(to_filter[i])
            point1 = to_filter[i][j]
            for k = 1:length(filtered)
                point2 = filtered[k]
                push!(new_filtered,PointFiltrage(point1.obj1+point2.obj1,point1.obj2+point2.obj2,point1.site,filtered[k]))
            end
        end

        filtered = eff(new_filtered)
        if echo
            println("Après un filtrage : ")
            display(filtered)
            println("-----------------------------------------------------------------------")
        end
        if echo_etape
            println("client ",i,", nbPoints : ",length(filtered))
        end
    end

    
    # print(typeof(filtered))
    # for p = filtered[1:10]
    #     println("(",p.obj1,", ",p.obj2,")")
    # end

    return filtered

end

function affectationClient(I::Int64,J::Int64,y::Vector{Int64},c::Vector{Vector{Vector{Float64}}})

    points::Vector{PointFiltrage} = filter(I,J,y,c)
    return backtracking(points)

end

function AffectationClient_totale(I::Int64,J::Int64,liste_y::Vector{Vector{Int64}},c::Vector{Vector{Vector{Float64}}},f::Vector{Vector{Float64}})

    points::Vector{PointFiltrage} = Vector{PointFiltrage}(undef,0)
    liste_x::Vector{Vector{Int64}} = Vector{Vector{Vector{Int64}}}(undef,0)
    
    for y = liste_y
        push!(liste_x,backtracking(filter(I,J,y,c)))
    end

    
    return backtracking(points)

end

function eff(d::Vector{PointFiltrage})
    res::Vector{PointFiltrage} = Vector{PointFiltrage}(undef,0)
    for i = 1:length(d)
        nonDominated = true
        point1 = d[i]
        for j = 1:length(d)
            if i!=j 
                point2 = d[j]
                if ((point2.obj1<=point1.obj1) && (point2.obj2<point1.obj2))||
                    ((point2.obj1<point1.obj1) && (point2.obj2<=point1.obj2))
                    nonDominated = false
                end
            end
        end

        if nonDominated
            push!(res,d[i])
        end
    end
    return res
end


function display(d)

    if typeof(d) == Vector{PointFiltrage}
        to_disp = [d]
    else
        to_disp = d
    end

    for i = 1:length(to_disp)
            for j = 1:length(to_disp[i])
                current = to_disp[i][j]
                parenthese = 0
                print("(",current.obj1,", ",current.obj2,", ",current.site)
                while current.precedent !== nothing
                    print("(",current.obj1,", ",current.obj2,", ",current.site)
                    current = current.precedent
                    parenthese += 1
                end
                
                for i = 1:parenthese
                    print(")")
                end
                print(", nothing) ")
            end
        print("\n")
    end
    print("\n")
end

function backtracking(filtered::Vector{PointFiltrage})
    resultat::Vector{Vector{Int64}} = Vector{Vector{Int64}}(undef,0)
    #pour chaque point

    for i = 1:length(filtered)
        solution::Vector{Int64} = Vector{Int64}(undef,0)
        current = filtered[i]
        point = current
        while (current.precedent !== nothing)
            push!(solution,current.site)
            current = current.precedent
            point = current
        end
        push!(solution,point.site)

        push!(resultat,solution)
    end

    return resultat
end


#=
function filter_paperStrict(I,J,y,c)
    
    #initialisation des points
    points = []
    for i = 1:I
        row = []
        for j = 1:J
            if y[j] == 1
                row = push!(row,(c[1][i][j] , c[2][i][j]))
            end
        end
        points = push!(points,row)
    end

    #display(points)

    #override pour test
    points = [
        [(6.45,3.099),(1.453,9.076),(3.224,4.306)],
        [(10.8,1.701),(2.168,3.872),(3.404,9.501)],
        [(9.088,3.718),(3.298,6.05),(4.858,6.983)],
        [(4.347,3.416),(1.0,10.45),(2.809,2.185)],
        [(4.895,7.632),(8.466,2.832),(9.948,3.809)],
        [(10.4,2.656),(3.129,4.118),(4.384,8.893)]
    ]
    display(points)

    I=6
    J=3
    
    I_b = I
    d = []

    d_1 = []
    for i = 1:I
        d_1 = push!(d_1,eff(points[i]))
    end

    d = push!(d,d_1)

    stop = floor(Int,log(2,I))
    for k = 2:stop
        d_k = []

        for i = 1:floor(Int,I/2)
            d_k_i = []
            #println(d[k-1]," i = ",i)
            d_k_i_a = d[k-1][2*i-1]
            d_k_i_b = d[k-1][2*i]
            
            for v = 1:length(d_k_i_a)
                d_k_i = push!(d_k_i,d_k_i_a[v])
            end
            for v = 1:length(d_k_i_b)
                d_k_i = push!(d_k_i,d_k_i_b[v])
            end
            #println(d_k_i)
            d_k = push!(d_k,eff(d_k_i))

        end
        d = push!(d,d_k)

        if floor(I_b/2) < I_b/2
            d[k][floor(Int,I_b/2)+1] = d[k-1][I_b]
            I_b = floor(Int,I_b/2)+1
        else
            I_b = I_b/2
        end
    end

    return d

end=#

