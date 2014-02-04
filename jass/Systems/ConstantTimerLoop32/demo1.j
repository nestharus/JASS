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

struct CTL4 extends array
    implement CTL
    implement CTLExpire
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"----"+I2S(this))
        call destroy()
    implement CTLNull
    implement CTLEnd
endstruct
struct CTL3 extends array
    implement CTL
    implement CTLExpire
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"---"+I2S(this))
        call destroy()
        call CTL4.create()
    implement CTLEnd
endstruct
struct CTL2 extends array
    implement CTLExpire
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"--"+I2S(this))
        call destroy()
        call CTL3.create()
    implement CTLNull
    implement CTLEnd
endstruct
struct TestCTL extends array
    implement CTLExpire
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"-"+I2S(this))
        call destroy()
        call CTL2.create()
    implement CTLEnd
    private static method init takes nothing returns nothing
        call create()
        call create()
    endmethod
    implement OnInit
endstruct