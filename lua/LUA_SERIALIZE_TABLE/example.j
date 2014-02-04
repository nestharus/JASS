//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    
    //! i dofile("SerializeTable")

    //! i local t = {}
    //! i t.name = "boo"
    //! i t[15] = "rawr"
    //! i t.growl = {}
    //! i t.growl.blemish = "kaka"
    
    //! i local tstr = table.save(t)
    //! i logf(tstr .. "\n\n")
    //! i local ts = table.load(tstr)
    //! i logf(ts.name)
    //! i logf(ts[15])
    //! i logf(ts.growl.blemish)
    //! i ts.growl.boo = "hello"
//! endexternalblock