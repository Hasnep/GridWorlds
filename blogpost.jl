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
world = CliffWorld(start = (1, 4), goal = (6, 4); cliffs = cliffs', step_reward = -1, cliff_reward = -100)

# Create an agent at the start position

agent = Agent(world.start, 0)

# Draw the agent in the world

plot(world,agent; filepath = joinpath(pwd(), "images", "world.svg"))


# ![A simple caveworld](images/world.svg)

# ## The ϵ-greedy policy

# To encourage exploration, the ϵ-greedy policy will select a random action with probability ϵ (explore).
# Otherwise, it will select the optimal action(s) (exploit).

function ϵ_greedy(cliff_world::CliffWorld, agent::Agent, ϵ::Real)
    @assert 0 <= ϵ <= 1 "ϵ is a probability, so it must be between 0 and 1"
    ## Equally divide the explore probability
    output = Dict(actions .=> ϵ / length(actions))
    ## Calculate which choice(s) are exploit
    hypothetical_states::Dict{Symbol,Agent} = Dict(actions .=> take_action.(Ref(cliff_world), Ref(agent), actions))
    maximum_reward = maximum(getfield.(values(hypothetical_states), :reward))
    optimal_actions = filter(s -> s.second.reward == maximum_reward, hypothetical_states) |> keys
    ## Split the exploit probability between the optimal actions
    for action in optimal_actions
        output[action] += (1 - ϵ) / length(optimal_actions)
    end
    return output
end

# The probability of selecting each action at the start position is:

ϵ_greedy(world,agent , 0.1)

# The probability of selecting each action next to the cliff is:

agent = Agent((3, 3), 0)
ϵ_greedy(world,agent , 0.1)

# Draw a line

path = [(1, 1), (1, 2), (2, 2)]
plot(world, agent, path, filepath = joinpath(pwd(), "images", "world_path.svg"))

# ![A simple cliffworld with a path](images/world_path.svg)
