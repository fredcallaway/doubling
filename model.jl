using Memoize
using Base: @kwdef
using Distributions

@enum Turn begin
    mine
    yours
    either
end
const invert_turn = Dict(either => either, mine => yours, yours => mine)

@kwdef struct State
    flips_left::Int
    score::Int = 0
    bet::Int = 1
    turn::Turn = either
end

my_turn(s::State) = s.turn != yours
your_turn(s::State) = s.turn != mine

"See the game from the other player's perspective."
invert(s::State) = State(s.flips_left, -s.score, s.bet, invert_turn[s.turn])
double(s::State, new_turn::Turn) = State(s.flips_left, s.score, 2s.bet, new_turn)

function should_double(s::State)
    flip_value(double(s, yours)) > flip_value(s)
end

function should_accept(s::State)
    flip_value(double(s, mine)) > -s.bet
end

"The value of a game state to you (including possibility of doubling)"
function value(s::State)
    if s.flips_left == 0
        return sign(s.score) * s.bet
    end
    if my_turn(s) && should_double(s)
        double_value(s)
    elseif your_turn(s) && should_double(invert(s))
        -double_value(invert(s))
    else
        flip_value(s)
    end
end

"The value of doubling to you"
function double_value(s::State)
    if should_accept(invert(s))
        flip_value(double(s, yours))
    else
        s.bet
    end
end

"The value of continuing the game (without doubling on this step)"
@memoize function flip_value(s::State)
    (;flips_left, score, bet, turn) = s
    sum((-1, 1)) do flip
        s′ = State(
            flips_left - 1,
            score + flip,
            bet,
            turn
        )
        0.5 * value(s′)
    end
end
