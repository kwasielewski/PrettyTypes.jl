module PrettyTypes

export @type

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
                    print_signature = getproperty.(signature, (:name,))
                end

                rettp = Base.return_types($(esc(exp)), signature)

                if length(signature) == 0
                    print_signature = ["()"]
                end
                if length(rettp) == 1
                    if length(constraints) > 0
                        print("[", join(constraints, ", "), "] => ")
                    end
                    println(join(print_signature, " * "), " -> ", rettp[1])
                end
            end
        end
        tp
    end
end

function ast_transform(e::Expr, m::Module)
    return Expr(:block, quote
            (macroexpand($m, @type macroexpand($m, $e)))
        end, e)
end

end # module PrettyTypes
