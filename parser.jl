function parser(fileToOpen::String)
    fileDirectory = "Data/"*fileToOpen
    file = open(fileDirectory)
    line = readlines(file)
    I = parse(Int64,line[1])
    J = parse(Int64,line[2])

    c1::Vector{Vector{Float64}} = Vector{Vector{Float64}}(undef,I)
    c2::Vector{Vector{Float64}} = Vector{Vector{Float64}}(undef,I)
  
    indice_c1 = 3
    indice_c2 = 4+I

    for i in 1:I
      parsed_row_c1::Vector{String} = split(line[i+indice_c1]," ")
      parsed_row_c2::Vector{String} = split(line[i+indice_c2]," ")
      row_c1::Vector{Float64} = Vector{Float64}(undef,J)
      row_c2::Vector{Float64} = Vector{Float64}(undef,J)
      for j in 1:J
        row_c1[j] = parse(Float64,parsed_row_c1[j])
        row_c2[j] = parse(Float64,parsed_row_c2[j])
      end
      c1[i] = deepcopy(row_c1)
      c2[i] = deepcopy(row_c2)
    end

    f1::Vector{Float64} = Vector{Float64}(undef,J)
    f2::Vector{Float64} = Vector{Float64}(undef,J)


    indice_f1 = (2*I)+6
    indice_f2 = (2*I)+8

    parsed_row_f1::Vector{String} = split(line[indice_f1]," ")
    parsed_row_f2::Vector{String} = split(line[indice_f2]," ")

     for i in 1:J
        f1[i] = parse(Int64,parsed_row_f1[i])
        f2[i] = parse(Int64,parsed_row_f2[i])
      end

      c::Vector{Vector{Vector{Float64}}} = [c1,c2]
      f::Vector{Vector{Float64}} = [f1,f2]

    return I,J,c,f
end