module PrettyTypes

export @type

macro type(exp)
	quote
		tp = typeof($(esc(exp)))
		if tp <: Function
			mtds = methods($(esc(exp)))
			if length(mtds) == 1
				signature = mtds[1].sig.types[2:end]
				rettp = Base.return_types($(esc(exp)), signature)
				if length(signature) == 0
					signature = ["()"]
				end
				if length(rettp) == 1
					println(join(signature, " * "),
						" -> ",
						rettp[1])
				end
			end
		end
		tp
	end
end

function ast_transform(e::Expr, m::Module)
	return Expr(:block, quote (macroexpand($m, @type macroexpand($m, $e))) end, e)
end

end # module PrettyTypes
