/*
*	function getvarobject(base, objtype, varname, import)
*
*		creates a new object and puts it into the map
*		it also creates a new JASS variable and binds it to that
*		object
*
*		base (string)
*
*			-	refers to the base id of the object
*
*			Examples:	"hpea" "Amoy" "Bphx"
*
*		objtype (string)
*
*			-	refers to the type of object
*
*			Examples:	"units" "abilities" "items"
*
*		varname (string)
*
*			-	name assigned to the variable
*
*			Convention:	OBJTYPE_NAME
*
*			Examples:	"UNITS_MY_UNIT" "ABILITIES_RAIN_OF_CHAOS"
*
*		import (boolean)
*
*			-	if true, imports the variable into the map as a global
*
*	function getvarobjectname(value)
*
*		given a value, retrieves the name of an object
*
*		Examples:	getvarobjectname("hpea")	->	"UNITS_PEASANT"?
*					getvarobjectname("Hpal")	->	"UNITS_PALADIN"?
*
*	function getvarobjectvalue(objectname)
*
*		given a name, retrieves the value of an object
*
*		Examples:	getvarobjectvalue("UNITS_MY_UNIT")	->	"hpea"?
*					getvarobjectvalue("UNITS_MY_ABIL")	->	"abil"?
*
*	function updateobjects()
*
*		updates the object table
*
*		this should always be called at the end of any script
*
*		Example
*
*			getvarobject("hpea", "units", "UNITS_NEW_PEASANT", true)
*			updateobjects()
*/

//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    
    //! i writelua("GetVarObject", [[
    //////////////////////////////////////////////////////////////////
    //code
    
    //! i local filename = "JassGlobals"
    //! i local filename_lua = getfilename() .. "_VAR_OBJECT_JassGlobals1"
    
    //! i dofile("GetObjectId")
    
    //! i local vars = readlua(filename_lua)
    //! i local vars2 = readjass(filename)
    //! i local varsdata
    //! i local newvars = ""
    
    //! i if (vars == nil) then
        //! i vars = {}
        //! i vars2 = ""
        //! i varsdata = ""
    //! i else
        //! i if (vars ~= "return {}") then
            //! i varsdata = vars:sub(9,vars:len()-1)
            //! i vars = loadstring(vars)()
        //! i else
            //! i varsdata = ""
            //! i vars = {}
        //! i end
        //! i if (vars2 == nil) then
            //! i vars2 = ""
        //! i else
            //! i vars2 = vars2:sub(string.len("globals")+1, vars2:len()-string.len("\nendglobals"))
        //! i end
    //! i end
    
    //! i local imports = {}
    //! i do
        //! i local s,k = vars2:find("constant integer ")
        //! i local s2,k2
        //! i while (s ~= nil) do
            //! i s2,k2 = vars2:find("=", k)
            //! i imports[vars2:sub(k+1, s2-1)] = true
            //! i s,k = vars2:find("constant integer ", k2)
        //! i end
    //! i end
    
    //! i function getvarobject(base, objtype, varname, import)
        //! i local value = vars[varname]
        //! i local imported
        //! i if (import == nil) then
            //! i import = false
        //! i end
        //! i if (value == nil) then
            //! i imported = false
            //! i value = getobjectid(base, objtype)
            //! i while (vars["1" .. value] ~= nil) do
                //! i value = getobjectid(base, objtype)
            //! i end
            //! i vars[varname] = value
            //! i vars["1" .. value] = varname
            //! i if (newvars == "") then
                //! i newvars = "['" .. varname .. "']='" .. vars[varname] .. "',['1" .. value .. "']='" .. varname .. "'"
            //! i else
                //! i newvars = newvars .. ",['" .. varname .. "']='" .. vars[varname] .. "',['1" .. value .. "']='" .. varname .. "'"
            //! i end
        //! i else
            //! i imported = imports[varname] or false
            //! i if (currentobjecttype() ~= objtype) then
                //! i setobjecttype(objtype)
            //! i end
        //! i end
        //! i if (import ~= imported) then
            //! i if (not imported) then
                //! i vars2 = vars2 .. "\nconstant integer " .. varname .. "='" .. value .. "'"
            //! i elseif (imported) then
                //! i local s,k = string.find(vars2, "\nconstant integer " .. varname .. "='" .. value .. "'")
                //! i vars2 = vars2:sub(1,s-1) .. vars2:sub(k+1, vars2:len())
            //! i end
            //! i imports[varname] = import
        //! i end
        //! i return value
    //! i end
    
    //! i function getvarobjectname(value)
        //! i return vars["1" .. value]
    //! i end
    
    //! i function getvarobjectvalue(objectname)
        //! i return vars[objectname]
    //! i end
    
    //! i function updateobjects()
        //! i writejass(filename, "globals" .. vars2 .. "\nendglobals")
        //! i if (varsdata == "") then
            //! i varsdata = newvars
        //! i elseif (newvars ~= "") then
            //! i varsdata = varsdata .. "," .. newvars
        //! i end
        //! i newvars = ""
        //! i writelua(filename_lua, "return {" .. varsdata .. "}")
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock