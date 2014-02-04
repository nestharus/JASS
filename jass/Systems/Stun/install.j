//! externalblock extension=lua ObjectMerger $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i dofile("GetVarObject")
    
    //! i local id2 = getvarobject("BSTN", "buffs", "BUFFS_STUN", true)
    //! i createobject("BSTN",id2)
    //! i makechange(current,"fnam","STUN")
    
    //! i local id = getvarobject("ACfb", "abilities", "ABILITIES_STUN", true)
    //! i createobject("ACfb", id)
    //! i makechange(current,"anam","Stun")
    //! i makechange(current,"amat","")
    //! i makechange(current,"amsp","0")
    //! i makechange(current,"arac","0")
    //! i makechange(current,"Htb1","1","0")
    //! i makechange(current,"aran","1","92083")
    //! i makechange(current,"acdn","1","0")
    //! i makechange(current,"ahdu","1","0")
    //! i makechange(current,"adur","1","0")
    //! i makechange(current,"amcs","1","0")
    //! i makechange(current,"atar","1","")
    //! i makechange(current,"abuf","1",id2)
    //! i makechange(current,"aord","firebolt")
    
    //! i updateobjects()
//! endexternalblock