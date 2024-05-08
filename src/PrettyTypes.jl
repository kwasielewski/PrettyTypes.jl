module PrettyTypes

export @type

macro type(exp)
	quote
		tp = typeof($(esc(exp)))
		if tp <: Function
			mtds = methods($(esc(exp)), @__MODULE__)
			if length(mtds) == 1
				signature = mtds[1].sig.types[2:end]
				rettp = Base.return_types($(esc(exp)), signature)
				if length(rettp) == 1
					println(join(signature, ", "),
						" -> ",
						rettp[1])
				end
			end
		end
		tp
	end
end

end # module PrettyTypes
