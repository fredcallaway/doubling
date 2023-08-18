include("model.jl")
using StatsPlots
gr(label="", dpi=200, size=(400,300), lw=2)

function figure(f, name="tmp"; kws...)
    plot(;kws...)
    f()
    savefig("$name")
end

function doubling_threshold(flips_left, turn=either)
    for score in 1:100
        if should_double(State(;flips_left, turn, score))
            return score
        end
    end
end

figure("score_threshold", xlab="flips left", ylab="doubling threshold (flips)") do
    flips_left = 1:100
    plot!(flips_left, doubling_threshold.(flips_left, mine), lab="my turn")
    plot!(flips_left, doubling_threshold.(flips_left, either), lab="either turn")
end

function score_distribution(N)
    wins = Binomial(N, 0.5)
    2 * wins - N
end

function win_prob(s::State)
    final_score = s.score + score_distribution(s.flips_left)
    p_lose = cdf(final_score, -1)
    p_tie = pdf(final_score, 0)
    1 - (p_lose + p_tie/2)
end

figure("prob_threshold", xlab="flips left", ylab="doubling threshold (win prob)") do
    flips_left = 1:100

    y = map(flips_left) do flips_left
        win_prob(State(;flips_left, score=doubling_threshold(flips_left, mine)))
    end
    plot!(flips_left, y, lab="my turn")

    y2 = map(flips_left) do flips_left
        win_prob(State(;flips_left, score=doubling_threshold(flips_left, either)))
    end
    plot!(flips_left, y2, lab="either turn")
end

# %% --------

figure("prob_threshold", xlab="flips left", ylab="doubling threshold (win prob)") do
    flips_left = 1:100

    y = map(flips_left) do flips_left
        threshold = doubling_threshold(flips_left, mine)
        win_prob(State(;flips_left, score=threshold))
    end
    ylo = map(flips_left) do flips_left
        threshold = doubling_threshold(flips_left, mine)
        win_prob(State(;flips_left, score=threshold-1))
    end
    plot!(flips_left, y, ribbon=(y .- ylo, 0))
end