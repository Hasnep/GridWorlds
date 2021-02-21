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

plot(world; agent = agent, filepath = joinpath(pwd(), "build", "images", "world.svg"))


# ![A simple caveworld](images/world.svg)

# ## The ϵ-greedy policy

# To encourage exploration, the ϵ-greedy policy will select a random action with probability ϵ (explore).
# Otherwise, it will select the optimal action(s) (exploit).

function ϵ_greedy(cliff_world::CliffWorld, agent::Agent; ϵ::Real)
    @assert 0 <= ϵ <= 1 "ϵ is a probability, so it must be between 0 and 1"
    ## Equally divide the explore probability
    output = Dict(actions .=> ϵ / length(actions))
    ## Calculate which choice(s) are exploit
    hypothetical_states::Dict{Symbol, Agent} = Dict(actions .=> take_action.(Ref(cliff_world), Ref(agent), actions))
    maximum_reward = maximum(getfield.(values(hypothetical_states), :reward))
    optimal_actions = filter(s -> s.second.reward == maximum_reward, hypothetical_states) |> keys
    ## Split the exploit probability between the optimal actions
    for action in optimal_actions
        output[action] += (1 - ϵ) / length(optimal_actions)
    end
    return output
end

# The probability of selecting each action at the start position is:

ϵ_greedy(world, agent; ϵ = 0.1)

# The probability of selecting each action next to the cliff is:

agent = Agent((3, 3), 0)
ϵ_greedy(world, agent; ϵ = 0.1)

# Calculate the optimal path using IPE
# Use the bellman equation
# $$ V^{(t+1)}(S*t) \leftarrow \sum*{S*{t+1}, R*{t+1}} p\left[S_{t+1},R_{t+1}|S_t,\pi(S_t)\right] \left(R*{t+1}+\gamma V^{t}(S*{t+1})\right) $$

function ipe_step(V, cliff_world, policy; γ = 1)
    world_width, world_height = size(cliff_world)
    V_prime = zeros(world_width, world_height)
    for x in 1:world_width, y in 1:world_height
        if (x, y) != cliff_world.goal
            hypothetical_states::Dict{Symbol, Agent} =
                Dict(actions .=> take_action.(Ref(cliff_world), Ref(Agent((x, y), 0)), actions))
            hypothetical_rewards = Dict([action => state.reward for (action, state) in hypothetical_states])
            action_probabilities = policy(cliff_world, agent)
            V_prime[x, y] =
                sum(action_probabilities[action] * (hypothetical_rewards[action] + γ * V[x, y]) for action in actions)
        end
    end
    return V_prime
end

policy_exploit(w, a) = ϵ_greedy(w, a; ϵ = 0)

# V = zeros(size(world)...)
# for iteration in 1:10
#     V_prime =    ipe_step(V, world, policy_exploit)
#     V .= V_prime
#     plot(world; info = V, filepath = joinpath(pwd(), "build", "images", "ipe_iteration_$iteration.svg"))
# end

# ![A simple cliffworld with a path](images/ipe_iteration_1.svg)
# ![A simple cliffworld with a path](images/ipe_iteration_10.svg)


# Draw a line

path = [(1, 1), (1, 2), (2, 2)]
plot(world; agent = agent, path = path, filepath = joinpath(pwd(), "build", "images", "world_path.svg"))

# ![A simple cliffworld with a path](images/world_path.svg)
