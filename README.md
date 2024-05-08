# PrettyTypes.jl
Pretty printer designed for function types

## Example

This example uses `ast_transform` function to add type printing on each repl input.
To add such extension to the repl look at my [`startup.jl`](https://github.com/kwasielewski/dotfiles/blob/main/Julia/startup.jl) file.

```julia
julia> addTwo(x::Int, y::Int) = x + y
Int64 * Int64 -> Int64
addTwo (generic function with 1 method)

julia> addTwo
Int64 * Int64 -> Int64
addTwo (generic function with 1 method)
```
