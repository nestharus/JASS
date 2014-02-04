//! textmacro LUA_JASS_IO takes FILE_NAME
    //! i do
        //! i local PATH = "jass\\luajass.$FILE_NAME$.j"

        //! i function jassread()
            //! i local f = io.open(PATH, "r")
            //! i if (f == nil) then
                //! i return nil
            //! i end
            //! i local code = f:read("*all")
            //! i f:close()

            //! i return code
        //! i end

        //! i function jasswrite(code)
            //! i local f = io.open(PATH, "w")
            //! i f:write(code)
            //! i f:close()
        //! i end
    //! i end
//! endtextmacro