//function getdummyphysicalability(name, levels, import)
    //name: the name of the dummy ability (used in buffs and ability)
    //levels: how big the dummy ability should be (1 buff created for each level)
    //import: whether to import to map as variable or not (imports only the ability)
        //imported as 
            //"ABILITIES_" .. name .. "_DUMMY"
            //"ABILITIES_" .. name .. "_DUMMY_2"
        
    //returns a table containing 3 values in it
        //buffs: an array of all the buffs (level 1 through total levels)
        //ability,ability2: contains the id of the created ability (2)

//DummyPhysicalAbility v3.0.0.0
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("DummyPhysicalAbility", [[
    //////////////////////////////////////////////////////////////////
    //code
    
    //! i dofile("GetVarObject")

    //! i function getdummyphysicalability(name, levels, import)
        //! i local buffs = {}
        //! i local buffcount = 0
        //! i do
            //! i local cur = levels
            //! i local curstr
            //! i while (cur > 0) do
                //! i curstr = tostring(cur)
                //! i buffs[cur] = getvarobject("BNva", "buffs", "BUFFS_" .. name .. curstr .. "_DUMMY", false)
                //! i createobject("BNva", buffs[cur])
                //! i makechange(current, "fnam", name .. "_DUMMY" .. curstr)
                //! i cur = cur - 1
            //! i end
        //! i end
        
        //! i local ability = getvarobject("AIob", "abilities", "ABILITIES_" .. name .. "_DUMMY", import)
        //! i createobject("AIob", ability)
        //! i makechange(current, "anam", name .. "_DUMMY")
        //! i makechange(current, "amat", "")
        //! i makechange(current, "asat", "")
        //! i makechange(current, "aspt", "")
        //! i makechange(current, "atat", "")
        //! i makechange(current, "ata0", "")
        //! i makechange(current, "alev", tostring(levels))
        //! i makechange(current, "Idam", "1", "0")
        //! i makechange(current, "ahdu", "1", "0")
        //! i makechange(current, "adur", "1", "0")
        //! i makechange(current, "atar", "1", "")
        //! i do
            //! i local cur = levels
            //! i local curstr
            //! i while (cur > 0) do
                //! i curstr = tostring(cur)
                //! i makechange(current, "abuf", curstr, buffs[cur])
                //! i makechange(current, "Iob5", curstr, "2")
                //! i cur = cur - 1
            //! i end
        //! i end
        
        //! i local ability2 = getvarobject("Afrb", "abilities", "ABILITIES_" .. name .. "_DUMMY_2", import)
        //! i createobject("Afrb", ability2)
        //! i makechange(current, "anam", name .. "_DUMMY_2")
        //! i makechange(current, "amat", "")
        //! i makechange(current, "amho", "1")
        //! i makechange(current, "achd", "0")
        //! i makechange(current, "alev", tostring(levels))
        //! i makechange(current, "atar", "1", "")
        //! i makechange(current, "ahdu", "1", "0")
        //! i makechange(current, "adur", "1", "0")
        //! i do
            //! i local cur = levels
            //! i local curstr
            //! i while (cur > 0) do
                //! i curstr = tostring(cur)
                //! i makechange(current, "abuf", curstr, buffs[cur])
                //! i cur = cur - 1
            //! i end
        //! i end
        
        //! i return {buffs = buffs, ability = ability, ability2 = ability2}
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock