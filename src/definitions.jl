using DataFrames

struct Individual
    id # ::Any
    dose # ::Union{AbstractVector, Number, Missing}
    dosing # ::Vector
    observations # ::Vector
    covariates
    function Individual(id, dose, dosing, observations; covariates...)
        return new(id, dose, dosing, observations, covariates)
    end
end

struct Cohort
    individuals
    length # ::Int
end

function dataframe(cohort::Cohort)
    df = DataFrame()
    map(ind -> append!(df, dataframe(ind)), cohort.individuals)
    return df
end


function dataframe(individual::Individual)
    time = vcat(individual.dosing, individual.observations)
    entries = length(time)
    amt = zeros(entries)
    amt[1:length(individual.dosing)] .= coalesce(individual.dose, 0)
    indices = sortperm(time)
    covs = map((key, value) -> key => fill(value, entries), keys(individual.covariates), values(individual.covariates))
    id = fill(individual.id, entries)
    time = time[indices]
    amt = amt[indices]
    dv =  zeros(length(time))
    return DataFrame(
        :ID => id, 
        :TIME => time,
        :EVID => Integer.(amt .> 0), # What if dose is zero for EVID == 1
        :AMT => amt,
        :DV => dv,
        covs...
    )
end


    

