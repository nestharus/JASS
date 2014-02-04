globals
    constant boolean SCRAMBLE=false
    constant boolean DESHUFFLE=false
    constant integer SHUFFLES=1
    constant string NUMBER="65536"
    constant integer RUNS=150
    constant integer NUM_PER_ROW=10
    constant string BASE="0123456789"
    constant string SCRAMBLE_BASE="01"
endglobals
struct tester extends array
    private static string c=NUMBER
    private static integer m=RUNS
    private static integer ad=0
    private static method r takes nothing returns nothing
        local Base b10=Base[BASE]
        local Base b3=Base[SCRAMBLE_BASE]
        local BigInt i
        local string s=""
        local integer a=NUM_PER_ROW
        
        call DestroyTimer(GetExpiredTimer())
        loop
            exitwhen m==0
            set i=BigInt.convertString(c,b10)
            call i.add(ad)
            static if SCRAMBLE then
                call Scramble(i,0,SHUFFLES,b3,false)
            else
                call Shuffle(i,0,SHUFFLES)
            endif
            static if DESHUFFLE then
                static if SCRAMBLE then
                    call Unscramble(i,0,SHUFFLES,b3,false)
                else
                    call Unshuffle(i,0,SHUFFLES)
                endif
            endif
            set s=s+" "+i.toString()
            set a=a-1
            if (a==0) then
                set a=NUM_PER_ROW
                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,6000,s)
                set s=""
            endif
            set ad=ad+1
            set m=m-1
            call i.destroy()
        endloop
        if (a<NUM_PER_ROW) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,6000,s)
        endif
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.r)
    endmethod
endstruct