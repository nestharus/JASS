//! externalblock extension=lua ObjectMerger $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i dofile("GetVarObject")
    
    //! i local function create(id,pt)
        //! i createobject("hwtw", id)
        //! i makechange(current, "unsf", "( " .. pt .. " )")
        //! i makechange(current, "upat", "PathTextures\\2x2Default.tga")
        //! i makechange(current, "ushb", "")
        //! i makechange(current, "uubs", "")
        //! i makechange(current, "uabr", "0")
        //! i makechange(current, "uabt", "")
        //! i makechange(current, "ucol", "0")
        //! i makechange(current, "usid", "")
        //! i makechange(current, "usin", "")
        //! i makechange(current, "ubdg", "0")
        //! i makechange(current, "usca", ".01")
        //! i makechange(current, "uabi", "Avul")
        //! i if (pt~="blighted") then
            //! i makechange(current, "upap", pt)
        //! i else
            //! i makechange(current, "upar", pt)
            //! i makechange(current, "upap", "")
        //! i end
        //! i if (pt=="unflyable") then
            //! i makechange(current, "umvt", "fly")
        //! i elseif (pt=="unamph") then
            //! i makechange(current, "umvt", "amph")
        //! i elseif (pt=="unfloat") then
            //! i makechange(current, "umvt", "float")
        //! i else
            //! i makechange(current, "umvt", "foot")
        //! i end
    //! i end
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "unflyable", true),"unflyable")
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "unamph", true),"unamph")
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "unbuildable", true),"unbuildable")
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "unwalkable", true),"unwalkable")
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "unfloat", true),"unfloat")
    //! i create(getvarobject("hwtw", "units", "UNITS_PATH_" .. "blighted", true),"blighted")
    
    //! i updateobjects()
//! endexternalblock