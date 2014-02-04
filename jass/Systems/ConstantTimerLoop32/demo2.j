library Print
    function Print takes string msg returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,240,msg)
    endfunction
    module OnInit
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
endlibrary

struct TestCT32 extends array
    private static integer count = 0
    implement CT32
        local integer i = count
        loop
            exitwhen 0 == count
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"-"+I2S(count))
            set count = count - 1
        endloop
        set count = i
        call stop()
    implement CT32End
    private static method init takes nothing returns nothing
        set count = 3
        call start()
    endmethod
    implement OnInit
endstruct