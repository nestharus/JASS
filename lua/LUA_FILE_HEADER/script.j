/*
*	Writes map header to map (run once, but multiple times won't hurt)
*
******************************************************************************/

	/*
	*	comment after initialization
	*/
    ///*
    //! externalblock extension=lua FileExporter $FILENAME$
        //! runtextmacro LUA_FILE_HEADER()
        //! i initmap()
    //! endexternalblock
    //*/

    /*
	*	replace FILE_NAME with the name of your map
	*
	*	uncomment after initialization
	*/
    ///! import "luajass.FILE_NAME.j"
	
	/*
	*	for initialization, you will also have to do the following
	*
	*		CTRL + F
	*		//! i local FILENAME
	*/

/******************************************************************************
*
*	API
*
*		import and run lua script to current script (see Lua reference manual)
*
*			lua scripts are shared across all maps
*			jass scripts are local to a map
*
*			-	function dofile(name)
*			-	function require(name)
*			-	function loadfile(name)
*
*		returns code inside of file
*
*			-	function readlua(name)
*			-	function readjass(name)
*
*		writes code to file
*
*			-	function writelua(name, code)
*			-	function writejass(name, code)
*
*		deletes file
*
*			-	function deletelua(name)
*			-	function deletejass(name)
*
*		output directories containing map files
*		this is used to zip the files up and share them with other people
*		working on the same map
*
*			-	function outputdirectories()
*
*		output logs is used to display logs so that you don't have
*		to go to grimex.txt and reload it
*
*			-	function outputlogs()
*/

//! textmacro LUA_FILE_HEADER
    //! i do
		/*
		*	replace "FILE_NAME" with the name of the map
		*
		*	must be valid directory name
		*/
        //! i local FILENAME = "FILE_NAME"
        
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/*
		*	War3 Path Initialization
		*/
		//! i local PATH_WAR3 = string.sub(package.path, string.find(package.path, ".:.-Warcraft III")) .. "\\"
		
		/*
		*	jassnewgenpack Initialization
		*/
		//! i local PATH_JASSNEWGENPACK = PATH_WAR3
		
		//! i local function scandir(directory)
			//! i local t = {}
			
			//! i for filename in io.popen('dir "' .. directory .. '" /b'):lines() do
				//! i t[#t + 1] = filename
			//! i end
			
			//! i log("")
			
			//! i return t
		//! i end
		
		//! i war3files = scandir(PATH_WAR3)
		//! i for i, name in ipairs(war3files) do
			//! i if (string.find(name, "jassnewgenpack") ~= nil) then
				//! i PATH_JASSNEWGENPACK = PATH_JASSNEWGENPACK .. name .. "\\"
				//! i break
			//! i end
		//! i end
		
		/*
		*	grimext initialization
		*/
		//! i local PATH_GRIMEXT = PATH_JASSNEWGENPACK .. "grimext" .. "\\"
		//! i local PATH_LUA = PATH_GRIMEXT .. "luadir" .. "\\"
		//! i local PATH_LUA_JASS = PATH_LUA .. FILENAME .. "_dir" .. "\\"
		
		/*
		*	jass initialization
		*/
		//! i local PATH_JASS = PATH_JASSNEWGENPACK .. "jass\\luajass." .. FILENAME .. ".j"
		
		/*
		*	system and map initialization
		*/
        //! i function initmap()
			/*
			*	initialize system directories
			*/
            //! i os.execute("if not exist \"" .. PATH_LUA .. "\" mkdir \"" .. PATH_LUA .. "\"")
            
			/*
			*	initialize map JASS file
			*/
            //! i local file = io.open(PATH_JASS, "r")
            //! i if (file == nil) then
                //! i io.open(PATH_JASS, "w"):close()
            //! i else
                //! i file:close()
            //! i end
            
			/*
			*	initialize map directory
			*/
            //! i os.execute("if not exist \"" .. PATH_LUA_JASS .. "\" mkdir \"" .. PATH_LUA_JASS .. "\"")
        //! i end
        
		/*
		*	dofile
		*/
        //! i local olddofile = dofile
        //! i local oldrequire = require
        //! i local oldloadfile = loadfile
        //! i function dofile(name)
            //! i olddofile(PATH_LUA .. name .. ".lua")
        //! i end
        //! i function require(name)
			//! i oldrequire(PATH_LUA .. name .. ".lua")
        //! i end
        //! i function loadfile(name)
			//! i oldloadfile(PATH_LUA .. name .. ".lua")
        //! i end
        
		/*
		*	path formatting
		*/
        //! i local function getluapath(name)
            //! i return ("grimext\\luadir\\" .. name .. ".lua")
        //! i end
        //! i local function getjasspath(name)
            //! i return ("grimext\\luadir\\" .. FILENAME .. "_dir" .. "\\" .. name .. ".luajass.j")
        //! i end
        //! i local function getjassimport(name)
            //! i return ("\/\/! import \"..\\" .. getjasspath(name) .. "\"")
        //! i end
		
		/*
		*	file handling
		*/
        //! i local function del(name)
            //! i os.remove(name)
        //! i end
        //! i local function read(path)
            //! i local file = io.open(path, "r")
            //! i code = nil
            //! i if (file ~= nil) then
                //! i code = file:read("*all")
                //! i file:close()
            //! i end
            //! i return code
        //! i end
        //! i local function write(path, code)
            //! i file = io.open(path, "w")
            //! i file:write(code)
            //! i file:close()
        //! i end
        //! i local function import(name)
            //! i local code = read(PATH_JASS)
            //! i local line = getjassimport(name) .. "\n"
            //! i if (code:find("\n" .. line) == nil and code:sub(1, line:len()) ~= line) then
                //! i write(PATH_JASS, code .. line)
            //! i end
        //! i end
        
		/*
		*	script handling
		*/
        //! i function readlua(name)
            //! i return read(getluapath(name))
        //! i end
        //! i function writelua(name, code)
            //! i write(getluapath(name), code)
        //! i end
        //! i function readjass(name)
            //! i return read(getjasspath(name))
        //! i end
        //! i function writejass(name, code)
            //! i write(getjasspath(name), code)
            //! i import(name)
        //! i end
        //! i function deletelua(name)
            //! i del(getluapath(name))
        //! i end
        //! i function deletejass(name)
            //! i del(getjasspath(name))
            //! i local line = getjassimport(name) .. "\n"
            //! i local code = read(PATH_JASS)
            //! i local s, k = code:find("\n" .. line)
            //! i if (s ~= nil) then
                //! i write(PATH_JASS, code:sub(1, s) .. code:sub(k + 1))
			//! i else
				//! i s, k = 1, line:len()
				//! i if (code:sub(1, line:len()) == line) then
					//! i write(PATH_JASS, code:sub(1, s - 1) .. code:sub(k + 1))
				//! i end
            //! i end
        //! i end
		
		/*
		*	output
		*/
		//! i local function print(...)
			/*
			*	cmd output
			*/
			/*
			//! i local print = ""
			//! i for i,v in ipairs(arg) do
				//! i if (print ~= "") then
					//! i print = print .. " & "
				//! i end
				//! i print = print .. " echo " .. tostring(v)
			//! i end
			//! i os.execute("start cmd @cmd /k \"" .. print .. "\"")
			*/
			
			/*
			*	notepad output
			*/
			//! i local print = ""
			//! i for i,v in ipairs(arg) do
				//! i if (print ~= "") then
					//! i print = print .. "\n"
				//! i end
				//! i print = print .. tostring(v)
			//! i end
			//! i local file = io.open(PATH_JASSNEWGENPACK .. "logs\\" .. "luaprint.out", "w")
			//! i file:write(print)
			//! i file:close()
			//! i os.execute("start notepad.exe " .. PATH_JASSNEWGENPACK .. "logs\\" .. "luaprint.out")
		//! i end
		//! i function outputdirectories()
			//! i print(PATH_LUA_JASS, PATH_JASS)
		//! i end
		//! i function outputlogs()
			//! i os.execute("start notepad.exe " .. PATH_JASSNEWGENPACK .. "logs\\" .. "grimex.txt")
		//! i end
		
		/*
		*	clean
		*/
		//! i do
			//! i local temp = string.sub(debug.getinfo(1).short_src, string.find(debug.getinfo(1).short_src, ".*Temp\\"))
			
			//! i tempfiles = scandir(temp)
			//! i for i, name in ipairs(tempfiles) do
				//! i if (string.find(name, "^(V)") ~= nil and (string.find(name, "(\.tmp)$") ~= nil or string.find(name, "(\.tmp\.lua)$") ~= nil)) then
					//! i os.remove(temp .. name)
				//! i end
			//! i end
		//! i end
    //! i end
//! endtextmacro