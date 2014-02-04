//GetObjectId 1.0.0.5
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("GetObjectId", [[
    //////////////////////////////////////////////////////////////////
    //code

    //! i function getobjectid(obj, objecttype)
        //obj refers to the base object
            //"hpea", "Amov", "Bphx", etc
        //objectType refers to the type of object to create
        
        //! i if (currentobjecttype() ~= objecttype) then
            //! i setobjecttype(objecttype)
        //! i end
        //! i local object = generateid(obj)
        //! i while (
            //! i objectexists(object) or 
            //! i string.find(object, "'", 1, true) ~= nil or 
            //! i string.find(object, '\\', 1, true) ~= nil or 
            //! i string.find(object, ',', 1, true) ~= nil or 
            //! i string.find(object, '/', 1, true) ~= nil) do
            
            //! i object = generateid(obj)
            
        //! i end
        //! i return object
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock