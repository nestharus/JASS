require "luacom"
require "lfs"
--require "settings.lua"

local shell = luacom.CreateObject("WScript.Shell")

local directory = [[HKEY_CURRENT_USER\Software\Blizzard Entertainment\Warcraft III\]]

warcraft = {}

warcraft.INSTALL_PATH	= shell:RegRead(directory .. [[InstallPath]])

local tool = {}

tool.objectmerger 		= [[ObjectMerger.exe]]
tool.constantmerger 	= [[ConstantMerger.exe]]
tool.fileexporter		= [[FileExporter.exe]]
tool.fileimporter		= [[FileImporter.exe]]
tool.patchgenerator		= [[PatchGenerator.exe]]
tool.tilesetter			= [[TileSetter.exe]]
tool.triggermerger		= [[TriggerMerger.exe]]

function warcraft.launchmap(map_path)
	os.execute("\"" .. warcraft.installpath() .. "\\war3.exe -loadfile" .. map_path .. "\"")
end

function warcraft.launch()
	os.execute("\"" .. warcraft.installpath() .. "\\war3.exe" .. "\"")
end

local function executetool(tool, mappath, luascript)
	local path = "\"" .. warcraft.INSTALL_PATH .. "\""

	return os.execute("cd \"" .. lfs.currentdir() .. "\" && " .. tool .. " \"" .. mappath .. "\" \"" .. warcraft.INSTALL_PATH .. "\" \"" .. luascript .. "\"")
end

function warcraft.objectmerger(mappath, luascript)
	executetool(tool.objectmerger, mappath, luascript)
end
function warcraft.constantmerger(mappath, luascript)
	executetool(tool.constantmerger, mappath, luascript)
end
function warcraft.filexporter(mappath, luascript)
	executetool(tool.fileexporter, mappath, luascript)
end
function warcraft.fileimporter(mappath, luascript)
	executetool(tool.fileimporter, mappath, luascript)
end
function warcraft.patchgenerator(mappath, luascript)
	executetool(tool.patchgenerator, mappath, luascript)
end
function warcraft.tilesetter(mappath, luascript)
	executetool(tool.tilesetter, mappath, luascript)
end
function warcraft.triggermerger(mappath, luascript)
	executetool(tool.triggermerger, mappath, luascript)
end

--map = [[C:\projects\warcraft 3\lua\wc3 project\Sample\mapname\mapname.w3m]]
--lua = [[C:\projects\warcraft 3\lua\wc3 project\Sample\mapname\src\imports\Unit Indexer\install.lua]]

--print(warcraft.objectmerger(map, lua))



--print(warcraft.installpath())

--warcraft.launch()

--sh:RegWrite([[HKEY_CURRENT_USER\Software\Blizzard Entertainment\Warcraft III\Allow Local Files]], "1", "REG_DWORD")

--os.execute(war3.exe -loadfile [[map_path]])

--[==[
]==]

--set jasshelper_run=%jasshelper_run% %jasshelper_path%\common.j %jasshelper_path%\Blizzard.j "%map_path%"
