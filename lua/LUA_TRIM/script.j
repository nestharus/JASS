//StringTrim 1.0.0.0
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("StringTrim", [[
    //////////////////////////////////////////////////////////////////
    //code
    
    //! i function string:trim(removelast)
        //! i local t = ""
        //! i local inside = false
        //! i local escaped = false
        //! i local escaping = false
        //! i local count = 0
        //! i local linecount = 0
        //! i local charcount = 0

        //! i for c in self:gmatch"." do
            //! i escaped = false
            //! i if (c == "\t" and not inside) then
                //! i count = count + 4
            //! i end
            //! i if ((count == 0 and charcount ~= 0) or (c ~= " " and c ~= "\t")) and ((charcount ~= 0 and linecount == 0) or c ~= "\n") then
                //! i t = t .. c
            //! i end
            //! i if (c == " " and not inside) then
                //! i count = count + 1
            //! i else
                //! i count = 0
                //! i if (c == "\n" and not inside and not escaping) then
                    //! i linecount = linecount + 1
                    //! i charcount = 0
                //! i else
                    //! i linecount = 0

                    //! i if (not escaping) then
                        //! i if (c == "\"") then
                            //! i inside = not inside
                        //! i elseif (c == "\\") then
                            //! i escaping = true
                            //! i escaped = true
                        //! i elseif (c ~= "\t") then
                            //! i charcount = charcount + 1
                        //! i end
                    //! i end
                //! i end
            //! i end

            //! i escaping = escaped
        //! i end

        //! i if (not inside and removelast and t:sub(t:len()) == "\n") then
            //! i t = t:sub(1, t:len()-1)
        //! i end

        //! i return t
    //! i end
    
    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock