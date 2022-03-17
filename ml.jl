function P_pass(x,k,t)
    res = 1/(1+exp(-(k*x-t)))

    return res

end

function P_fail(x,k,t)
    res = 1-P_pass(x,k,t)
    return res
end

function P_xi_yi(x,y,k,t)
    if y == 1
        return P_pass(x,k,t)
    else
        return P_fail(x,k,t)
    end
end


x_i = [1,1.2,1.3,1.4,1.5,1.6,2.3,3.1,4.7,5.3]
y_i = [0,0,0,0,1,0,1,1,1,1]

resu = 0

for i = 1:10
    global resu = resu + log(10,P_xi_yi(x_i[i],y_i[i],1,2))
    println(log(10,P_xi_yi(x_i[i],y_i[i],1,2)))
end

println(resu)

