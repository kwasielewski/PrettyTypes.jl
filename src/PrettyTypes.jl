module PrettyTypes

export @type

macro type(exp)
	quote
		tp = typeof($exp)
		if tp <: Function
			mtds = methods($exp)
			if length(mtds) == 1
				signature = mtds[1].sig.types[2:end]
				rettp = Base.return_types($exp, signature)
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
