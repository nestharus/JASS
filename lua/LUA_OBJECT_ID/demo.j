//! externalblock extension=lua ObjectMerger $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i dofile("GetObjectId")

    //generates an object id for hpea (peasant) of object type units
    //! i local object obj = getobjectid("hpea", "units")

    //create the object using the retrieved object id
    //! i setobjecttype("units")
    //! i createobject("hpea", obj)
        //modifications
//! endexternalblock