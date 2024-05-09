module PrettyTypes

export @type

union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x) = (x,)

macro type(exp)
    quote
        tp = typeof($(esc(exp)))
        if tp <: Function
            mtds = methods($(esc(exp)))
            if length(mtds) == 1
                constraints = []
                if mtds[1].sig isa DataType
                    signature = mtds[1].sig.types[2:end]
                    print_signature = signature
                elseif mtds[1].sig isa UnionAll
                    push!(constraints, mtds[1].sig.body.parameters[2])
                    signature = mtds[1].sig.body.parameters[2:end]
                    get_or_id = x -> hasproperty(x, :name) ? x.name : x
                    print_signature = get_or_id.(signature)
                end

                rettp = Base.return_types($(esc(exp)), signature)

                if length(signature) == 0
                    print_signature = ["()"]
                end
                if length(rettp) == 1
                    has_union = any(x -> x isa Union, print_signature)
                    has_tvar = any(x -> x isa Symbol, print_signature)
                    if length(constraints) > 0 && !has_union
                        print("[", join(constraints, ", "), "] => ")
                    end
                    if has_union && !has_tvar
                        println("{")
                        print_signature = map(x -> union_types(x), print_signature)
                        for t in Iterators.product(print_signature...)
                            rettp = Base.return_types($(esc(exp)), t)
                            if length(rettp) != 1
                                @warn "Multiple return types for signature: ", join(t, " * ")
                            end
                            println(join(t, " * "), " -> ", rettp[1])
                        end
                        println("}")
                    elseif !has_union
                        println(join(print_signature, " * "), " -> ", rettp[1])
                    end
                end
            end
        end
        tp
    end
end

function ast_transform(e::Expr, m::Module)
    return :(
        begin
            try
                macroexpand($m, @type macroexpand($m, $e))
            catch exc
                trace = stacktrace(Base.catch_backtrace())
                idx = findfirst(x -> occursin("PrettyTypes.jl", string(x.file)), trace)
                @warn("Error in type pretty printing: ",
                    exc,
                    _line = trace[idx].line,
                    _file = string(trace[idx].file))
            end
            $e
        end)
end

end # module PrettyTypes
