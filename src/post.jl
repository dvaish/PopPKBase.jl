include("definitions.jl")

function multifilter(;conditions...)
    f = (x) -> all(map((k, v) -> x[k] == v, keys(conditions), values(conditions)))
    return f
end

function timeify(results::AbstractDataFrame)
end

function ss!(data, metric::Symbol, x0::Pair, xF::Pair; col::Union{Symbol, AbstractString} = :ss)
    initial = filter(PKPD._filter(;x0), data)[metric]
    final = filter(PKPD._filter(;xF), data)[metric]

    @assert !(col in names(data)) "Column already exists"
    @assert length(initial) == length(final) "Initial and finals vectors are of different lengths"
    data[!, col] = initial - final
    return nothing
end
   
function read(path::String)
    open(path) do file
        file_array = readlines(file)
        colnames = filter(x -> x != "", split(file_array[2], ' '))
        colnames = [Symbol(col) for col in colnames]
        data = DataFrame(fill(Float64[], length(colnames)), colnames; makeunique=true)
        for i in 3:length(file_array)
            row = file_array[i]
            if (row == file_array[1]) | (row == file_array[2])
                continue
            else
                row_vector = split(row, ' ')
                row_vector = filter(x -> x != "", row_vector)
                row_vector = map(x -> parse(Float64, x), row_vector)
                push!(data, row_vector)
            end
        end
        return data
    end
end