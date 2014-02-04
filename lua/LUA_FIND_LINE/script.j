//StringFindLine 1.0.0.1
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("StringFindLine", [[
    //////////////////////////////////////////////////////////////////
    //code

    //! i function string:findline(tag, atstart, position)
        //! i local pos = 1
        //! i if (position ~= nil) then
            //! i pos = position
        //! i end

        //! i local s, k = string.find(self, tag, pos, true)

        //! i if (s ~= nil) then
            //! i k = string.find(self, "\n", k, true)
            //! i if (not atstart) then
                //! i repeat s = s - 1
                //! i until s == 0 or self:sub(s, s) == "\n"
                //! i s = s + 1
            //! i end

            //! i if (s == 1 or self:sub(s-1, s-1) == "\n") then
                //! i return string.sub(self, s, k), s, k
            //! i end
        //! i end

        //! i return nil
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock