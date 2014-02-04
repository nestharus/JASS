local script = {}

function script.create()
	local body = {}

	function body:addline(line)
		linenumber = #self + 1

		self[linenumber] = line

		return linenumber
	end

	function body:tostring()
		local line = nil
		local script = nil

		local linecount = #self

		for i = 1, linecount do
			line = nil

			if (type(self[i]) == "table") then
				line = self[i]:tostring()
			else
				line = self[i]
			end

			if (line ~= nil) then
				if (script == nil) then
					script = line
				else
					script = script .. "\n" .. line
				end
			end
		end

		return script
	end

	return body
end

return script
