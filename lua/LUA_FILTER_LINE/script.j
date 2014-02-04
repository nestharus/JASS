//StringFilterLine 1.0.0.0
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("StringFilterLine", [[
    //////////////////////////////////////////////////////////////////
    //code
    
    //! i dofile("StringFindLine")

    //! i function string:filterline(startchar, atstart)
        //! i local line, position, e
        //! i while (true) do
            //! i line,position,e = self:findline(startchar, atstart)
            //! i if (line ~= nil) then
                //! i self = self:sub(1, position-1) .. self:sub(e+1, self:len())
            //! i else
                //! i return self
            //! i end
        //! i end
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock