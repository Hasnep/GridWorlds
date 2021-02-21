import Literate
using CliffWorlds
mkpath(joinpath(pwd(), "build", "images"))
Literate.markdown(joinpath(pwd(), "blogpost.jl"),joinpath(pwd(), "build"); documenter = false, execute = true)
run(Cmd(`pandoc build/blogpost.md --output=build/blogpost.html`))

# import Pandoc
# Pandoc.parse_file(joinpath(pwd(),"build","blogpost.md"))
