//! externalblock extension=lua ObjectMerger $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i dofile("GetVarObject")
    
    //! i local id = getvarobject("nfr2", "units", "UNITS_DUMMY_CASTER", true)
    //! i createobject("nfr2", id)
    //! i makechange(current, "unam", "DummyCaster")
    //! i makechange(current, "upat", "")
    //! i makechange(current, "ucol", "0")
    //! i makechange(current, "uine", "0")
    //! i makechange(current, "usnd", "")
    //! i makechange(current, "ushb", "")
    //! i makechange(current, "uubs", "")
    //! i makechange(current, "usca", .01)
    //! i makechange(current, "uhom", 1)
    //! i makechange(current, "ucbs", 0)
    //! i makechange(current, "ucpt", 0)
    //! i makechange(current, "uabi", "Aloc,Avul")
    
    //! i updateobjects()
//! endexternalblock