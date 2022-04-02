
mutable struct DroiteIntervale
    a::Rational{Int64}
    b::Rational{Int64}
    c1::Int64
    c2::Int64
end # Une droite est représentée par une équation de la forme ax + by = 1

# Début Convex hull (code modifié à partir d'une source sur internet à retrouver...)
mutable struct Point
    x::Rational{Int64}
    y::Rational{Int64}
    ind::Int64
    c1::Int64
    c2::Int64
end

function Base.isless(p::Point, q::Point)
    p.x < q.x || (p.x == q.x && p.y < q.y)
end

function isrightturn(p::Point, q::Point, r::Point)
    (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x) < 0
end

function grahamscan(points::Vector{Point})
    sort!(points)
    upperhull = halfhull(points)
    lowerhull = halfhull(reverse(points))
    [upperhull..., lowerhull[2:end-1]...]
end

function halfhull(points::Vector{Point})
    halfhull = points[1:2]
    for p in points[3:end]
        push!(halfhull, p)
        while length(halfhull) > 2 && !isrightturn(halfhull[end-2:end]...)
            deleteat!(halfhull, length(halfhull) - 1)
        end
    end
    halfhull
end
#Fin convex hull

# Détermination d'une enveloppe inférieure de droite sur le segment [0,1] (En réalité, [-0.1,1])
# Entrée : Vecteur de droites (dont on veut calculer l'enveloppe inférieure)
# Sortie : Vecteur de droites (définissant l'enveloppe inférieure dans l'ordre)
function lowerHull(Lc::Vector{DroiteIntervale})
    i::Int64 = 0
    count::Int64 = 1 # compteur
    nbPts::Int64 = length(Lc) + 3 # Nombres de points utilisés pour le calcul d'enveloppe convexe incluant les trois points "dummy"
    P::Vector{Point} = Vector{Point}(undef,nbPts)
    Lr::Vector{DroiteIntervale} = Vector{DroiteIntervale}(undef,0)

  	for i in 1:length(Lc)
        P[count] = Point(Lc[i].a,Lc[i].b,i,Lc[i].c1,Lc[i].c2)
        count += 1
  	end # Boucle d'instanciation des points "légitimes"
    P[count] = Point(-10,0,count,0,0) # Point "dummy" associé à la droite d'équation x = - 0.1 soit -10x = 1
    P[count + 1] = Point(1,0,count + 1,0,0) # Point "dummy" associé à la droite d'équation x = 1
    P[count + 2] = Point(0,-1,count + 2,0,0) # Point "dummy" associé à la droite d'équation -y = 1 soit y = -1

  	PF::Vector{Point} = grahamscan(P) # PF contient les points qui ne sont pas situés à l'intérieur de l'enveloppe convexe

    # Transformation en points en droites
    i = 1
    while (PF[i].ind > length(Lc))
        i += 1
    end # On saute les dummy points
    while (i <= length(PF)) && (PF[i].ind <= length(Lc)) # On s'arrête aux dummy points
        push!(Lr,DroiteIntervale(PF[i].x,PF[i].y,PF[i].c1,PF[i].c2))
        i += 1
    end
    return Lr
end

