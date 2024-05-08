# PrettyTypes.jl
Pretty printer designed for function types

## Example

```julia
julia> incr(x::Int) = x + 1
incr (generic function with 1 method)

julia> @type incr
Int64 -> Int64
typeof(incr) (singleton type of function incr, subtype of Function)
```
