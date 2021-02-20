module CliffWorlds

export CliffWorld, Agent, plot,Position,actions,take_action

using Luxor

Position = Tuple{Int,Int}

Base.@kwdef struct CliffWorld
    start::Position
    goal::Position
    cliffs::Matrix{Bool}
    step_reward::Real
    cliff_reward::Real
end

import Base.size # TODO: Do I need this?
Base.size(cliff_world::CliffWorld) = Base.size(cliff_world.cliffs)


const transitions = Dict(:up => (0, 1), :down => (0, -1), :left => (-1, 0), :right => (1, 0))
const actions = keys(transitions)

struct Agent
    position::Position
    reward::Real
end

"""
Return the agent's new state after taking an action.
"""
function take_action(cliff_world::CliffWorld, agent::Agent, action::Symbol)::Agent
    new_position::Position = agent.position .+ transitions[action]
    # Assume the reward is going to change because we take a step
    reward_δ::Real = cliff_world.step_reward
    # Check if the agent is still in bounds
    if all((1, 1) .<= new_position .<= size(cliff_world))
        # Check if the new position is a cliff
        if cliff_world.cliffs[new_position...]
            # When the agent falls off the cliff, reset their position
            new_position = cliff_world.start
            reward_δ = cliff_world.cliff_reward             
        end
    else
        # If the agent went out of bounds then the agent doesn't move
        new_position = agent.position
    end
    return Agent(new_position,          agent.reward + reward_δ) 
end

"""
Plot a cliffworld.
"""
function plot(cliff_world::CliffWorld, agent::Agent, path; filepath, scale_by = 50)
    grid_width, grid_height = size(cliff_world)

    Drawing(grid_height * scale_by, grid_width * scale_by, filepath)

    translate(-scale_by / 2, -scale_by / 2)
    scale(scale_by)

    stroke_colour = "black"
    setline(1)

    for x in 1:grid_width, y in 1:grid_height
        sethue(cliff_world.cliffs[x, y] ? "red" : "lightblue")
        box(Point(y, x), 1, 1, :fill)
        sethue(stroke_colour)
        box(Point(y, x), 1, 1, :stroke)
    end
    
    # Draw agent
    sethue("purple")
    circle(agent.position..., 0.5, :fill)

    # Draw path
    sethue("orange")
    setline(5)

    if length(path) > 0
        path_points = [Point(p[1], p[2]) for p in path]
        prettypoly(path_points, :stroke, () -> circle(O, 0.1, :fill))
    end

    finish()
end

plot(cliff_world::CliffWorld,agent::Agent; kwargs...) = plot(cliff_world, agent, []; kwargs...)

end # module
