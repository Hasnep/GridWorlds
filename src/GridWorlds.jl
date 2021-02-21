module GridWorlds

export GridWorld, Agent, plot, Position, actions, take_action

using Luxor

Position = Tuple{Int, Int}

Base.@kwdef struct GridWorld
    start::Position
    goal::Position
    cliffs::Matrix{Bool}
    step_reward::Real
    cliff_reward::Real
end

import Base.size # TODO: Do I need this?
Base.size(gridworld::GridWorld) = Base.size(gridworld.cliffs)


const transitions = Dict(:up => (0, 1), :down => (0, -1), :left => (-1, 0), :right => (1, 0))
const actions = keys(transitions)

struct Agent
    position::Position
    reward::Real
end

"""
Return the agent's new state after taking an action.
"""
function take_action(gridworld::GridWorld, agent::Agent, action::Symbol)::Agent
    new_position::Position = agent.position .+ transitions[action]
    # Assume the reward is going to change because we take a step
    reward_δ::Real = gridworld.step_reward
    # Check if the agent is still in bounds
    if all((1, 1) .<= new_position .<= size(gridworld))
        # Check if the new position is a cliff
        if gridworld.cliffs[new_position...]
            # When the agent falls off the cliff, reset their position
            new_position = gridworld.start
            reward_δ = gridworld.cliff_reward
        end
    else
        # If the agent went out of bounds then the agent doesn't move
        new_position = agent.position
    end
    return Agent(new_position, agent.reward + reward_δ)
end

"""
Plot a gridworld.
"""
function plot(gridworld::GridWorld; agent::Agent = nothing, path = [], info = nothing, filepath, scale_by = 50)
    grid_width, grid_height = size(gridworld)

    Drawing(grid_width * scale_by, grid_height * scale_by, filepath)

    translate(-scale_by / 2, -scale_by / 2)
    scale(scale_by)

    stroke_colour = "black"
    setline(1)
    fontsize(0.2)

    for x in 1:grid_width, y in 1:grid_height
        if gridworld.cliffs[x, y]
            sethue("red")
        elseif (x, y) == gridworld.start
            sethue("darkblue")
        elseif (x, y) == gridworld.goal
            sethue("green")
        else
            sethue("lightblue")
        end
        box(Point(x, y), 1, 1, :fill)
        sethue(stroke_colour)
        box(Point(x, y), 1, 1, :stroke)
    end

    if !isnothing(info)
        for x in 1:grid_width, y in 1:grid_height
            text(info[x, y], x, y; halign = :center)
        end
    end

    # Draw agent
    if !isnothing(agent)
        sethue("purple")
        circle(agent.position..., 0.5, :fill)
    end

    # Draw path
    sethue("orange")
    setline(5)

    if length(path) > 0
        path_points = [Point(p[1], p[2]) for p in path]
        prettypoly(path_points, :stroke, () -> circle(O, 0.1, :fill))
    end

    finish()
end

end # module
