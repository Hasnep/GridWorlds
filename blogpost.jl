# # CliffWorld

# Load the `CliffWorlds` package

using CliffWorlds

# Load the package `Luxor.jl` to draw the cliffworlds

using Luxor

# Define a world with a cliff along the bottom

cliffs = [
    0 0 0 0 0 0
    0 0 0 0 0 0
    0 0 0 0 0 0
    0 1 1 1 1 0
]
world = CliffWorld((1, 4), (6, 4); cliffs = cliffs, step_penalty = -1, cliff_penalty = -100)

# Draw the world

plot(world; filepath = joinpath(pwd(), "images", "world.svg"))


# ![A simple caveworld](images/world.svg)

# ## The ϵ-greedy policy

# To encourage exploration, the ϵ-greedy policy will select a random action with probability ϵ (explore).
# Otherwise, it will select the optimal action(s) (exploit).

# function ϵ_greedy(cliff_world::CliffWorld, state::Position, ϵ::Number)
    @assert 0 <= ϵ <= 1 "ϵ is a probability, so it must be between 0 and 1"
    ## Equally divide the explore probability
    output = Dict(keys(actions) .=> ϵ / length(actions))
    new_states_and_rewards::Dict{Symbol,NamedTuple{(:state, :reward),Tuple{Position,Number}}} = state_transitions(cliff_world, state)
    maximum_reward = maximum(new_states).second
    optional_actions = filter(p -> p.second[2] == maximum_reward, new_states)
    return output
# end

# The probability of selecting each action at the start position is:

ϵ_greedy(world, world.start,0.1)

# Draw a line

path = [(1, 1), (1, 2), (2, 2)]
plot(world, path, filepath = joinpath(pwd(), "images", "world_path.svg"))

plot()

# ![A simple caveworld with a path](images/world_path.svg)
