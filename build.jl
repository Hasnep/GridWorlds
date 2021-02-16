import Literate
# using CliffWorlds
Literate.markdown(joinpath(pwd(), "blogpost.jl"); documenter = false, execute = true)
run(Cmd(`pandoc blogpost.md --output=build/blogpost.html`))
