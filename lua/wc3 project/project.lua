require "lfs"
require [[utils\file\fileobject]]
require [[utils\warcraft\warcraft]]
require [[utils\web\web]]

project = {}

local serialize = require [[utils\file\ser]]

local function isprojectinitialized(map)
	if (lfs.attributes("export", "mode") ~= "directory") then
		lfs.mkdir ("export")
	end

	local triggers = io.open([[export\Triggers\war3map.wct]], "r")
	local projectinitialized = triggers:read("*a"):match([[//! include "mapname.j"]]) ~= nil
	triggers:close()

	return projectinitialized
end

--for importing into map
local function initializejass(path, mapname)
	jass = io.open(path .. mapname .. ".j", "w")
	jass:close()
end

--project file
local function initializelua(path, mapname)
	lua = io.open(path .. mapname .. ".lua", "w")

	do
		local project = {}

		project.name = mapname		--map name of project

		project.objects = {}

		project.objects.units = {}
		project.objects.items = {}
		project.objects.destructibles = {}
		project.objects.doodads = {}
		project.objects.abilities = {}
		project.objects.buffs = {}
		project.objects.upgrades = {}

		-----------------------------------------------------------------
		--
		--	resources format (loaded from script.lua)
		--	name is folder name containing script.lua
		--
		--		install(project, path, mapname, map)
		--			runs when the resource exists
		--		uninstall(project, path, mapname, map)
		--			runs when the resource no longer exists
		--
		--		settings = {}
		--		requirements = {}
		--			-	array
		--
		--
		--
		-----------------------------------------------------------------
		project.resources = {}

		lua:write(serialize(project))
	end

	lua:close()
end

--initialize the map to include the jass file
local function initializemap(map)
	warcraft.triggermerger(map, [[importtriggers.lua]])
end

local function getresources(path)
	local ext = nil
	local files = {}
	files.lua = {}
	files.jass = {}

	local ifiles = nil
	local fileo = nil

	for file in lfs.dir(path) do
		if (lfs.attributes(path .. file, "mode") == "directory" and file ~= "." and file ~= "..") then
			ifiles = getresources(path .. file .. "\\")

			for i,v in ipairs(ifiles.lua) do
				files.lua[#files.lua + 1] = v
			end

			for i,v in ipairs(ifiles.jass) do
				files.jass[#files.jass + 1] = v
			end

		elseif (lfs.attributes(path .. file, "mode") == "file") then
			if (file == "script.j" or file == "script.lua") then
				if (file == "script.j") then
					ext = ".j"
				else
					ext = ".lua"
				end

				fileo = {["target"] = path .. file, ["path"] = path, ["name"] = "script", ["ext"] = ext}

				if (ext == ".lua") then
					files.lua[#files.lua + 1] = fileo
				elseif (ext == ".j") then
					files.jass[#files.jass + 1] = fileo
				end
			end
		end
	end

	return files
end

function project.open(map)
	local file = getfileobject(map, {"w3m", "w3x"})

	map = file.target

	local path = file.path
	local mapname = file.name

	--warcraft.filexporter(map, [[exporttriggers.lua]])

	if (not isprojectinitialized(map)) then
		--initializemap(map)
		initializejass(path, mapname)
		initializelua(path, mapname)
	end

	--
	--access

	--if lfs.attributes(strFileName,"mode") == "file" then

	--[[Triggers]]
end

--open project
--project.open([[C:\projects\warcraft 3\lua\wc3 project\Sample\mapname\mapname]])

--file = getfileobject([[C:\projects\warcraft 3\lua\wc3 project\Sample\mapname\mapname]], {"w3m", "w3x"})	--done in opening project

--retrieve resources
--files = getresources(file.path)




--------------------------------------------------------------------------------------
--	open project
--
--		import triggers
--		create project .j file
--		create project .lua file
--
--------------------------------------------------------------------------------------
--	retrieve resources
--
--		loop over project folder and all sub-folders in search of script.lua and
--		script.j files
--
--		organize into two arrays
--
--------------------------------------------------------------------------------------
--	determine what resources are missing
--
--		go over currently installed resources and compare to found resources
--
--------------------------------------------------------------------------------------
--	uninstall missing resources
--
--		for any resource that was removed, uninstall it
--
--------------------------------------------------------------------------------------
--	determine dependencies for current resources
--
--		build a list of resources required to run the stuff the map will use
--
--------------------------------------------------------------------------------------
--	find missing dependencies and add to list to be installed
--
--		for each missing dependency, search for it via include directories and online
--		add the missing dependency to the list of resources to be installed
--		find all of its missing dependencies
--
--------------------------------------------------------------------------------------
--	determine what resources were added
--
--		compare currently installed resources to resources that will be added
--
--------------------------------------------------------------------------------------
--	run user code (for customizing installations)
--
--		this will allow the user to customize settings, like # of abilities to generate
--		installation = map installation, not script
--
--------------------------------------------------------------------------------------
--	install added resources (keep in mind dependencies)
--
--		go over all resources and organize them so that they will install in the correct
--		order
--
--		pass everything into the correct grimext exes in packs
--
--------------------------------------------------------------------------------------
--	update resources
--
--		go through resources and perform updates (should be daily)
--
--------------------------------------------------------------------------------------
--	run user code (for customizing building)
--
--		now the resources are ready to build code, so allow the user to work with them
--		this could be injections or whatever else
--
--------------------------------------------------------------------------------------
--	build resources (keep in mind dependencies)
--
--		build the jass file that will be imported into the map
--		dependencies still matter for order of Lua code
--
--------------------------------------------------------------------------------------
--	build map
--
--		run the map through jasshelper
--		run the map through wurst
--
--------------------------------------------------------------------------------------


--[==[lua = [[C:\projects\warcraft 3\lua\wc3 project\Sample\mapname\src\imports\MapBounds\script.lua]]

dofile(lua)

mp = dofile(file.path .. file.name .. ".lua")

init = dofile(lua)

if (mp.resources.MapBounds == nil) then
	init(mp, file.path, file.name, file.target)
end

local jass = nil
local script = mp.resources.MapBounds.install(mp, file.path, file.name, file.target)

if (script ~= nil) then
	if (jass == nil) then
		jass = script
	else
		jass = jass .. "\n" .. script
	end
end]==]

--local file = ltn12.sink.file(io.open('test.j', 'w'))
--local a,b,c,d = http.request([[http://www.hiveworkshop.com/forums/attachments/lab-715/131505d1387750709-new-unitindexer-new-approach-unit-index.j]])
--print(a)

--get([[http://dl.dropboxusercontent.com/s/r9r989xytb7qgzd/script.j?dl=1&token_hash=AAET7OLu5Mi7RNlEEQMl4m6yHNuIS50f2ElZfaXCtd7mUw]], "test.j")

--require("luasec")

--get([[http://www.hiveworkshop.com/forums/pastebin_data/ir76d2/_files/package.txt]], "test.lua")
--package = dofile("test.lua")

--for i,v in ipairs(package) do
	--print(v.version)
	--get(v.url, tostring(i) .. "test.lua")
--end
