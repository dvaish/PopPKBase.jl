using Plots

function binnedboxplot!(
    df::DataFrame, 
    metric::Union{Symbol, String}, 
    var::Union{Symbol, String}, 
    bins::AbstractVector;
    target = missing; 
    size = (800, 800), 
    id = :ID,
    α = 3,
    color = :lightblue,
)
    individuals = length(unique(df[:, id]))
    data = PopPKBase.bin(df[:, metric], bins, bins)
    for i in bins
        relevant = filter(x -> (j < x[metrics[i]] < j + 1) && (x[var] !== missing), df)
        data = relevant[:, var]
        boxplot!(
            [j + 0.5],
            isempty(data) ? [0] : data,
            outliers = false,
            color = color,
            subplot = i,
            title = metrics[i],
            α = α * nrow(relevant) / individuals
        )
    end
    hline!(transpose([target for i = 1:length(metrics)*2]), color = :red)
    ylabel!("Count")
    xlabel!("Z-Score")
end