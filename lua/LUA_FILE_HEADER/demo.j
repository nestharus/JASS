//! externalblock extension=lua FileExporter $FILENAME$
    //run the header first
    //! runtextmacro LUA_FILE_HEADER()
    
    //writing an lua script to a follow
    //! i writelua("MyScript", [[
        //! i function Hello() 
            //! i logf("hi") 
        //! i end
    //! i ]])
    
    //using the lua script just written
    //! i dofile("MyScript")
    
    //calling a function inside of written lua script
    //! i Hello()
    
    //writing 3 jass scripts that are imported into the map automatically
    //-----------------------------------------------------------
        //! i writejass("MyScript", [[
            //! i struct Tester1 extends array
                //! i private static method onInit takes nothing returns nothing
                    //! i call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "hello world")
                //! i endmethod
            //! i endstruct
        //! i ]])
        
        //! i writejass("MyScript2", [[
            //! i struct Tester2 extends array
                //! i private static method onInit takes nothing returns nothing
                    //! i call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "hello world")
                //! i endmethod
            //! i endstruct
        //! i ]])
        
        //! i writejass("MyScript3", [[
            //! i struct Tester3 extends array
                //! i private static method onInit takes nothing returns nothing
                    //! i call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "hello world")
                //! i endmethod
            //! i endstruct
        //! i ]])
    //-----------------------------------------------------------
    
    //delete the second jass script
    //! i deletejass("MyScript2")
    
    //write jass script 1 and lua script to grimext logs
    //! i logf(readjass("MyScript"))
    //! i logf(readlua("MyScript"))
    
    //clear out so that you don't have to delete this demo from your directory : D
    //! i deletelua("MyScript")
    //! i deletejass("MyScript")
    //! i deletejass("MyScript3")
//! endexternalblock