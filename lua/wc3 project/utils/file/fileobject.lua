require "lfs"

--file.target = file
--file.path = directory containing file
--file.name = filename
--file.ext = extension of file
local function getpath(file)
	if (file == nil) then
		return nil
	end
	if (file.target == nil) then
		return nil
	end

	file.path = file.target:match('^.*\\')

	if (file.path == nil) then
		file.path = lfs.currentdir() .. "\\"
		file.target = file.path .. file.target
	end
end
local function getname(file)
	if (file == nil) then
		return nil
	end

	if (file.target == nil) then
		return nil
	end

	if (file.path == nil) then
		file.name = file.target
	else
		file.name = file.target:sub(file.path:len() + 1, file.target:len())
	end
end
local function getext(file, validextensions)
	if (file == nil) then
		return nil
	end
	if (validextensions == nil) then
		return nil
	end

	local ext = {}

	do
		local fext = nil

		for target in lfs.dir(file.path) do
			fext = target:match("%..*")

			if (fext ~= nil) then
				fext = fext:sub(2, fext:len())
				if (validextensions[fext]) then
					ext[#ext + 1] = fext
				end
			end
		end
	end

	local maxext = nil
	for index, extension in ipairs(ext) do
		if (maxext == nil or lfs.attributes(file.target .. "." .. maxext, "modification") > lfs.attributes(file.target .. "." .. extension, "modification")) then
			maxext = extension
		end
	end

	if (maxext == nil) then
		return nil
	end


	file.ext = "." .. maxext
	file.target = file.target .. file.ext
end

function getfileobject(file, validextensions)
	local name = file
	file = {}
	file.target = name
	getpath(file)
	getname(file)

	local extensions = {}

	for index, extension in ipairs(validextensions) do
		extensions[extension] = true
	end

	getext(file, extensions)

	return file
end
