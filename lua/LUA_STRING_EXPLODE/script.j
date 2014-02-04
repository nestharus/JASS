//StringExplode 1.0.0.0
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("StringExplode", [[
    //////////////////////////////////////////////////////////////////
    //code

    //! i function string:explode ( seperator ) 
        //! i local pos, arr = 0, {}
        //! i for st, sp in function() return string.find( self, seperator, pos, true ) end do -- for each divider found
            //! i table.insert( arr, string.sub( self, pos, st-1 ) ) -- Attach chars left of current divider
            //! i pos = sp + 1 -- Jump past current divider
        //! i end
        //! i table.insert( arr, string.sub( self, pos ) ) -- Attach chars right of last divider
        //! i return arr
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock