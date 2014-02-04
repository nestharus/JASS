//GetVarObject 3.0.0.5
//function getvarobject(base, objtype, varname, import)
    //base: base id of object
        //"hpea", "Amov", "Bphx", etc
        
    //objtype: type of object
        //"units", "abilities", "items", etc
        
    //varname: name assigned to variable
        //OBJECTTYPE_NAME
        //"UNITS_MY_UNIT", "ABILITIES_RAIN_OF_CHAOS", etc
        
    //import: should the variable be imported into the map as a global?
        //true, false, nil
        
//function getvarobjectname(value)
    //retrieve name given value ("hpea", etc)
    
//function getvarobjectvalue(objectname)
    //retrieve value given name ("UNITS_MY_UNIT", etc)
    
//function updateobjects()
    //call at end of script
        
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