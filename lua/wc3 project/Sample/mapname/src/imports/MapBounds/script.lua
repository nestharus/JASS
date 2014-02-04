local verison = 0

--jass file gets rebuilt each time via build
local function install(project, path, mapname, map)
	local lib = project.resources.MapBounds

	if (lib.version ~= version) then
		print("outdated")
	end
end

local function uninstall(project, path, mapname, map)
	print("hi")
end

local function initialize(project, path, mapname, map)
	local resource = {}

	resource.install = install
	resource.uninstall = uninstall
	resource.settings = {}
	resource.requirements = {}
	resource.version = -1

	project.resources.MapBounds = resource
end

return initialize
