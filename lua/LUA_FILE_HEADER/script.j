//Writes map header to map (run once, but multiple times won't hurt)
//------------------------------------------------------------------------
    //function initmap()
    
    //comment after initialization
    ///*
    //! externalblock extension=lua FileExporter $FILENAME$
        //! runtextmacro LUA_FILE_HEADER()
        //! i initmap()
    //! endexternalblock
    //*/

    //uncomment after initialization
    ///! import "luajass.FILE_NAME.j"
//------------------------------------------------------------------------


//import and run lua script to current script (all do same thing)
//------------------------
    //function dofile(name)
    //function require(name)
    //function loadfile(name)

//lua scripts are shared across all maps
//jass scripts are local to a map

//returns code inside of file
//------------------------
    //function readlua(name)
    //function readjass(name)

//writes code to file
//------------------------
    //function writelua(name, code)
    //function writejass(name, code)

//deletes file
//------------------------
    //function deletelua(name)
    //function deletejass(name)

//! textmacro LUA_FILE_HEADER
    //! i do
        //replace "FILE_NAME" with the name of the map
        //must be valid directory name
        //! i local FILENAME = "FILE_NAME"
        
        //! i function getfilename() 
            //! i return FILENAME 
        //! i end
        
        //Initialization
        ///////////////////////////////////////////////////////////////////////
        //! i local PATH_LUA_p = "grimext\\luadir"
        //! i local PATH_JASS_p = PATH_LUA_p .. "\\" .. FILENAME .. "_dir"
        
        //! i local PATH_LUA = PATH_LUA_p .. "\\"
        //! i local PATH_JASS = PATH_JASS_p .. "\\"
        //! i local JASS_HUB = "jass\\luajass." .. FILENAME .. ".j"
        //! i function initmap()
            //! i os.execute("if not exist " .. PATH_LUA .. " (mkdir " .. PATH_LUA .. ")")
            //! i os.execute("if not exist " .. PATH_JASS .. " (mkdir " .. PATH_JASS .. ")")
            //! i local file = io.open(JASS_HUB, "r")
            //! i if (file == nil) then
                //! i file = io.open(JASS_HUB, "w")
                //! i file:write("")
                //! i file:close()
            //! i else
                //! i file:close()
            //! i end
            
            //! i os.execute("if not exist grimext\\luadir\\" .. FILENAME .. "_dir (mkdir grimext\\luadir\\" .. FILENAME .. "_dir)")
        //! i end
        ///////////////////////////////////////////////////////////////////////
        
        //! i local olddofile = dofile
        //! i local oldrequire = require
        //! i local oldloadfile = loadfile
        //! i function dofile(name)
            //! i oldrequire("luadir\\" .. name)
        //! i end
        //! i function require(name)
            //! i dofile(name)
        //! i end
        //! i function loadfile(name)
            //! i dofile(name)
        //! i end
        
        //! i local function getluapath(name)
            //! i return (PATH_LUA .. name .. ".lua")
        //! i end
        //! i local function getjasspath(name)
            //! i return (PATH_JASS .. name .. ".luajass.j")
        //! i end
        //! i local function getjassimport(name)
            //! i return ("\/\/! import \"..\\" .. getjasspath(name) .. "\"")
        //! i end
        
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
            //! i local code = read(JASS_HUB)
            //! i local line = getjassimport(name) .. "\n"
            //! i local s,k = code:find(line)
            //! i if (s == nil) then
                //! i write(JASS_HUB, code .. line)
            //! i end
        //! i end
        
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
            //! i local code = read(JASS_HUB)
            //! i local s,k = code:find(line)
            //! i if (s ~= nil) then
                //! i write(JASS_HUB, code:sub(1,s-1) .. code:sub(k+1))
            //! i end
        //! i end
    //! i end
//! endtextmacro