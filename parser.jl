# --------------------------------------------------------------------------- #
# Loading an instance of SPP (format: OR-library)

function loadUFLP(fname)
    cd("Data")
    file=open(fname)
    
  
    n_site, n_client = parse.(Int, split(readline(file)) )
    
    f=zeros(Float64, n_site)

    for i=1:n_site
        capacity,f_cost = parse.(Float64, split(readline(file)))
        f[i] = f_cost
    end


    c = Vector{Vector{Float64}}(undef,0)
    for i = 1:n_client
        push!(c,zeros(Float64,n_site))
    end

    for i = 1:n_client
        demand = readline(file)

        for j = 1:div(n_site,7)
            cost = parse.(Float64, split(readline(file)))
            for k = 1:7
                c[i][k+(j-1)*7] = cost[k]
            end
            
        end
        if n_site % 7 > 0
            cost = parse.(Float64, split(readline(file)))
            for j = 1:(n_site % 7)
                c[i][div(n_site,7)*7+j] = cost[j]
            end
        end
    end
    
    close(file)
    cd("..")
    return n_client,n_site,f,c
end

# --------------------------------------------------------------------------- #
# collect the un-hidden filenames available in a given directory

function getfname()
  # target : string := chemin + nom du repertoire ou se trouve les instances

  # positionne le currentdirectory dans le repertoire cible
  #cd(joinpath(homedir(),target)) 

  # retourne le repertoire courant
  #println("pwd = ", pwd())
  cd("Data")
  # recupere tous les fichiers se trouvant dans le repertoire data
  allfiles = readdir()

  # vecteur booleen qui marque les noms de fichiers valides
  flag = trues(size(allfiles))

  k=1  
  for f in allfiles
      # traite chaque fichier du repertoire
      if f[1] != '.'
          # pas un fichier cache => conserver
          #println("fname = ", f) 
      else
          # fichier cache => supprimer
          flag[k] = false
      end
      k = k+1
  end

  # extrait les noms valides et retourne le vecteur correspondant
  finstances = allfiles[flag]

  cd("..")
  return finstances
end

