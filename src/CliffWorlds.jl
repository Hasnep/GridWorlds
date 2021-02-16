module CliffWorlds

export CliffWorld, plot, size, state_action_state, Position, actions, state_transitions

using Luxor

Position = Tuple{Int,Int}

const actions = Dict(:up => (0, 1), :down => (0, -1), :left => (-1, 0), :right => (1, 0))

mutable struct CliffWorld
    state::Position
    start::Position
    goal::Position
    cliffs::Matrix{Bool}
    step_penalty::Real
    cliff_penalty::Real

    function CliffWorld(start, goal; cliffs, step_penalty, cliff_penalty)
        return new(start, start, goal, cliffs, step_penalty, cliff_penalty)
    end
end

import Base.size
size(cliff_world::CliffWorld) = Base.size(cliff_world.cliffs)

"""
Calculate the new state and reward for a given state and action.
"""
function state_action_state(cliff_world, state::Position, action::Symbol)::NamedTuple{(:state, :reward),Tuple{Position,Number}}
    new_state = state .+ actions[action]
    reward = cliff_world.step_penalty
    if all((1, 1) .<= new_state .<= size(cliff_world))
        if cliff_world.cliffs[new_state]
            new_state = cliff_world.start
            reward = cliff_world.cliff_penalty
        end
    else
        new_state = state
    end
    return (state = new_state, reward = reward)
end

"""
Calculate the new state and reward for each action taken at a state.
"""
state_transitions(cliff_world, state)::Dict{Symbol,NamedTuple{(:state, :reward),Tuple{Position,Number}}} =
    Dict(keys(actions) .=> state_action_state.(Ref(cliff_world), Ref(state), keys(actions)))

"""
Plot a cliffworld.
"""
function plot(cliff_world::CliffWorld, path; filepath, scale_by = 50)
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

    # Draw path
    sethue("orange")
    setline(5)

    if length(path) > 0
        path_points = [Point(p[1], p[2]) for p in path]
        prettypoly(path_points, :stroke, () -> circle(O, 0.1, :fill))
    end

    finish()
end

plot(cliff_world::CliffWorld; kwargs...) = plot(cliff_world, []; kwargs...)

end # module
