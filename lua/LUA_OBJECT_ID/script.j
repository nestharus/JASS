/*
*	function getobjectid(objectbase, objecttype)
*
*		generates a unique object id
*
*		objectbase
*
*			-	refers to the base of the object
*
*				Examples:	"hpea" "Amoy" "Bphx"
*
*		objecttype
*
*			-	refers to the type of object to create
*
*				Examples:	"units", "abilities", "items"
*
*/
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("GetObjectId", [[
    //////////////////////////////////////////////////////////////////
    //code

    //! i function getobjectid(objectbase, objecttype)
		/*
		*	set object type
		*/
        //! i if (currentobjecttype() ~= objecttype) then
            //! i setobjecttype(objecttype)
        //! i end
		
		/*
		*	the object id
		*/
		//! i local objectid
		
		/*
		*	find a unique object id that does not contain
		*
		*		'	\	,	/
		*/
		//! i repeat
			//! i objectid = generateid(objectbase)
		//! i until
		//! i (
			//! i objectexists(objectid) or
			//! i string.find(objectid, "'", 1, true) ~= nil or 
            //! i string.find(objectid, '\\', 1, true) ~= nil or 
            //! i string.find(objectid, ',', 1, true) ~= nil or 
            //! i string.find(objectid, '/', 1, true) ~= nil
		//! i )
		
        //! i return objectid
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock