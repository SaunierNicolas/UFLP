include("greedyInit.jl")

function filter(I,J,y,c)
    
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

    display(points)

    #override pour test
    points = [
        [(6.45,3.099),(1.453,9.076),(3.224,4.306)],
        [(10.8,1.701),(2.168,3.872),(3.404,9.501)],
        [(9.088,3.718),(3.298,6.05),(4.858,6.983)],
        [(4.347,3.416),(1.0,10.45),(2.809,2.185)],
        [(4.895,7.632),(8.466,2.832),(9.948,3.809)],
        [(10.4,2.656),(3.129,4.118),(4.384,8.893)]
    ]

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

end

function eff(d)
    res = []
    for i = 1:length(d)
        nonDominated = true
        a1,b1 = d[i]
        for j = 1:length(d)
            if i!=j 
                a2,b2 = d[j]
                if (a2>a1) && (b2>b1)
                    nonDominated = false
                end
            end
        end

        if nonDominated
            res = push!(res,d[i])
        end
    end
    return res
end

function display(d)

    for i = 1:length(d)
        for j = 1:length(d[i])
            print(d[i][j],"   ")
        end
        print("\n\n")
    end
end

