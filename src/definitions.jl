using DataFrames
using Random

struct Individual
    id # ::Any
    amt
    dosing
    observations # ::Vector
    covariates
    function Individual(;id = rand(UInt16), amt, dosing, observations, covariates...)
        return new(id, amt, dosing, observations, covariates)
    end
end

struct Cohort
    population
    length
end

function Cohort(population)
    return Cohort(population, length(population))
end

function Cohort(individuals, f)
    population = map(f, individuals)
    return Cohort(population)
end

function cohort!(individuals, f)
    population = map!(f, individuals)
    return Cohort(population)
end

# struct Run
#     id::Symbol
#     amt::Symbol
#     obs::Symbol
#     covariates::Tuple{Union{Symbol, String}}
#     data::DataFrame
# end

# @inline function getter(run::Run, field::Union{Symbol, String})
#     return run.data[getfield(run, field)]
# end

# @inline function id(run::Run)
#     return getter(run, :id)
# end

# @inline function amt(run::Run)
#     return getter(run, :amt)
# end

# @inline function obs(run::Run)
#     return getter(run, :obs)
# end

function DataFrames.DataFrame(cohort::Cohort)
    individuals = map(ind -> append!(df, dataframe(ind)), cohort.individuals)
    dataframe = vcat(individuals...)
    return dataframe
end


function DataFrames.DataFrame(individual::Individual)
    time = vcat(individual.dosing, individual.observations)
    entries = length(time)
    amt = zeros(entries)
    amt[1:length(individual.dosing)] .= coalesce(individual.amt, 0)
    indices = sortperm(time)
    covs = map((key, value) -> key => fill(value, entries), keys(individual.covariates), values(individual.covariates))
    id = fill(individual.id, entries)
    time = time[indices]
    amt = amt[indices]
    dv =  zeros(length(time))
    return DataFrame(
        :ID => id, 
        :TIME => time,
        :EVID => Vector{Int64}(amt .> 0), # What ioamtis zero for EVID == 1
        :AMT => amt,
        :DV => dv,
        covs...
    )
end


    

