module PrettyTypes

export @type

union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x::Type) = (x,)

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
					has_union = any(x -> x isa Union, print_signature)
					if has_union
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
					else
                    	println(join(print_signature, " * "), " -> ", rettp[1])
					end
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
