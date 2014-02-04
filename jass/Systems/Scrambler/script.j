library Scrambler uses /* v3.0.0.3
*************************************************************************************
*
*   Scrambles/Shuffles a BigInt given a player id.
*
*   This applies a StringHash to the player, converts that hash into base 8, and
*   then uses that as a key. The end result is that each player's code (when
*   this is used for save/load) is scrambled/shuffled differently.
*
*   Scrambling:
*               Shuffles in a specific base a number of times.
*               Useful for mixing up save/load keys (the character sets)
*               Recommend including front digit as data won't be lost for most uses
*   Shuffling:
*               Shuffles through a set of prime bases a number of times.
*               Useful for mixing up save/load codes
*
*************************************************************************************
*
*   REQUIREMENTS
*   
*       */ BigInt /*hiveworkshop.com/forums/jass-functions-413/system-bigint-188973/
*
************************************************************************************
*
*   SETTINGS
*/
    globals
    /*************************************************************************************
    *
    *                                       SALT
    *
    *   Refers to what to append to the player's name when generating scrambler keys
    *   for each player. This is essentially like a password. It's impossible for another
    *   map to descramble a number without this password.
    *
    *   This password can be any string, such as "7/ah+53~r\\ZZ"
    *
    *************************************************************************************/
        private constant string SALT = ""
    endglobals
    
    /*************************************************************************************
    *
    *                                   SetShuffleOrder
    *
    *   Creates the shuffling algorithm using 5 different prime bases.
    *
    *   Shuffling mixes a number up using a variety of bases to produce results rivaling
    *   top random number generators.
    *
    *   Different bases ensure better mixes.
    *
    *   Enabled Bases: 
    *
    *       2
    *           Will shuffle number in groups of 1 bit
    *       3
    *           Will shuffle number in groups of 1.58 bits
    *       5
    *           Will shuffle number in groups of 2.32 bits
    *       7
    *           Will shuffle in groups of 2.81 bits
    *       11
    *           Will shuffle in groups of 3.46 bits
    *
    *   Strategies:
    *
    *       1.
    *           shuffle by large1, shuffle by small1, shuffle by large2, etc
    *       2.
    *           shuffle by small1, shuffle by large1, shuffle by small2, etc
    *       3.
    *           shuffle by small1, shuffle by small2, shuffle by large1, shuffle by small3, etc
    *
    *       Keep in mind that as fractional bits are shuffled, bits split/merge, meaning that the number
    *       can drastically change by becoming much smaller or much larger.
    *
    *
    *   Shuffle Array: so
    *
    *   Ex:
    *
    *       set so[0]=3         //first mix by 1.58 bits
    *       set so[1]=2         //second mix by 1 bit
    *       set so[2]=7         //third mix by 2.81 bits
    *       set so[3]=2         //fourth mix by 1 bit
    *
    *       return 4            //return number of mixes
    *
    *************************************************************************************/
    private keyword so
    private function SetShuffleOrder takes nothing returns integer
        /*************************************************************************************
        *
        *                                       MIXES
        *
        *   array: so
        *   bases: 2,3,5,7,11
        *
        *************************************************************************************/
        set so[0]=5
        set so[1]=2
        set so[2]=3
        set so[3]=11
        set so[4]=2
        set so[5]=7
        set so[6]=3
        
        /*************************************************************************************
        *
        *                                       MIX COUNT
        *
        *************************************************************************************/
        return 7
    endfunction
/*
************************************************************************************
*
*   function Scramble takes BigInt intToScramble, integer forPlayerId, integer shuffles, Base baseToScrambleIn, boolean includeFront returns nothing
*   function Unscramble takes BigInt intToScramble, integer forPlayerId, integer shuffles, Base baseToScrambleIn, boolean includeFront returns nothing
*
*   function Shuffle takes BigInt intToScramble, integer forPlayerId, integer shuffles returns nothing
*   function Unshuffle takes BigInt intToScramble, integer forPlayerId, integer shuffles returns nothing
*
************************************************************************************
*
*   function Scramble takes BigInt intToScramble, integer forPlayerId, integer shuffles, Base baseToScrambleIn, boolean includeFront returns nothing
*
*       Scrambles a BigInt at the binary level.
*
*           intToScramble:          BigInt
*           forPlayerId:            id of human player*
*           shuffles:               how many times to shuffle number (must be > 0)
*           baseToScrambleIn:       what base to scramble number in
*
************************************************************************************
*
*   function Unscramble takes BigInt intToScramble, integer forPlayerId, integer shuffles, Base baseToScrambleIn, boolean includeFront returns nothing
*
*       Unscrambles a BigInt at the binary level.
*
*           intToScramble:          BigInt
*           forPlayerId:            id of human player*
*           shuffles:               how many times to unshuffle number
*           baseToScrambleIn:       what base to shuffle number in
*           includeFront:           this determines whether to include front number or not
*
*                                   including  the front number isn't advisable as 0s 
*                                   may move to the front, meaning data can be lost
*
*                                   Scramble(1000) -> 0001, or 1
*
************************************************************************************
*
*   function Shuffle takes BigInt intToScramble, integer forPlayerId, integer shuffles returns nothing
*
*       Scrambles a BigInt using user-defined algorithm.
*
*           intToScramble:          BigInt
*           forPlayerId:            id of human player*
*           shuffles:               how many times to shuffle number (must be > 0)
*
************************************************************************************
*
*   function Unshuffle takes BigInt intToScramble, integer forPlayerId, integer shuffles returns nothing
*
*       Scrambles a BigInt using user-defined algorithm.
*
*           intToScramble:          BigInt
*           forPlayerId:            id of human player*
*           shuffles:               how many times to unshuffle number
*
************************************************************************************/
    globals
        private integer array ss
        private boolean array se
        private BigInt array d
        private integer i
        private integer dc
        private integer k
        private integer s1
        private integer s2
        private integer s3
        private integer pid
        private trigger mt=CreateTrigger()      //mix trigger
        private trigger dt=CreateTrigger()      //demix trigger
        private trigger st=CreateTrigger()      //scramble trigger
        private trigger ut=CreateTrigger()      //unscramble trigger
        private BigInt bi
        private Base array bs
        private integer array so
        private integer sc=0
    endglobals
    private function LNF takes BigInt int,boolean i0 returns nothing
        set dc=0
        if (i0) then
            loop
                set int=int.next
                exitwhen int.head
                set d[dc]=int
                set dc=dc+1
            endloop
        else
            loop
                set int=int.next
                exitwhen int.next.head
                set d[dc]=int
                set dc=dc + 1
            endloop
            set int=int.next
        endif
    endfunction
    private function LNB takes BigInt int,boolean i0 returns nothing
        set dc=0
        if (not i0) then
            set int=int.prev
        endif
        loop
            set int=int.prev
            exitwhen int.head
            set d[dc]=int
            set dc=dc+1
        endloop
    endfunction
    private function FLP takes integer id,integer i2 returns nothing
        //find last position
        loop
            exitwhen 0==i2
            set s1=dc
            loop
                exitwhen 0==s1
                set s1=s1-1
                if (se[k]) then
                    set k=ss[id]
                else
                    set k=k+1
                endif
            endloop
            set i2=i2-1
        endloop
    endfunction
    function Scramble takes BigInt int,integer id,integer shuffles,Base bb,boolean i0 returns nothing
        local Base b=int.base
        set pid=id
        set k=ss[id]
        set i=shuffles
        debug if (0!=ss[id]) then
            if (b!=bb) then
                set int.base=bb
            endif
            //load number
            call LNF(int,i0)
            //scramble
            call TriggerEvaluate(st)
            if (b!=bb) then
                set int.base=b
            endif
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"SCRAMBLER ERROR: INVALID PLAYER "+I2S(id))
        debug endif
    endfunction
    function Unscramble takes BigInt int,integer id,integer shuffles,integer bb,boolean i0 returns nothing
        local Base b=int.base
        set i=shuffles
        set pid=id
        set k=ss[id]
        debug if (0!=ss[id]) then
            if (b!=bb) then
                set int.base=bb
            endif
            //load number
            call LNB(int,i0)
            //retrieve last position
            call FLP(id,shuffles)
            //unscramble
            call TriggerEvaluate(ut)
            if (b!=bb) then
                set int.base=b
            endif
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"SCRAMBLER ERROR: INVALID PLAYER "+I2S(id))
        debug endif
    endfunction
    //scramble
    private function St takes nothing returns boolean
        loop
            exitwhen 0==i   //exitwhen no more shuffles
            set s1=dc       //loop through digits from left-1 to right
                            //don't shuffle left most to save a bit as
                            //left most must be 1
            loop
                exitwhen 0==s1  //exitwhen no more digits
                set s1=s1-1     //shift down as array ends at n-1
                //current digit slot - hash digit (shift right)
                set s2=s1-ss[k]
                //if s2 is negative, add total digits until positive
                loop
                    exitwhen 0<=s2
                    set s2=dc+s2
                endloop
                //swap s2 and s1
                set s3=d[s2].digit
                set d[s2].digit=d[s1].digit
                set d[s1].digit=s3
                //if out of digits, go back to first digit on hash
                //otherwise, go to next digit
                //last existing digit is marked as end
                if (se[k]) then
                    set k=ss[pid]
                else
                    set k=k+1
                endif
            endloop
            set i=i-1
        endloop
        return false
    endfunction
    //unscramble
    private function Ut takes nothing returns boolean
        //go backwards
        loop
            exitwhen 0==i
            set s1 = dc
            loop
                exitwhen 0==s1
                set s1=s1-1
                set k=k-1
                if (0==ss[k]) then
                    set k=ss[pid+12]
                endif
                set s2=s1+ss[k]
                loop
                    exitwhen s2<dc
                    set s2=s2-dc
                endloop
                set s3=d[s2].digit
                set d[s2].digit=d[s1].digit
                set d[s1].digit=s3
            endloop
            set i=i-1
        endloop
        return false
    endfunction
    //shuffle
    private function Mt takes nothing returns boolean
        local integer sh=0
        set k=ss[pid]
        loop
            exitwhen sh==sc
            set i=1
            set bi.base=bs[so[sh]]
            call LNF(bi,false)
            call St()
            set sh=sh+1
            set k=ss[pid]
        endloop
        return false
    endfunction
    //unshuffle
    private function Dt takes nothing returns boolean
        local integer sh=sc
        set k=ss[pid]
        loop
            exitwhen 0==sh
            set sh=sh-1
            set i=1
            set bi.base=bs[so[sh]]
            call LNB(bi,false)
            call FLP(pid,1)
            call Ut()
            set k=ss[pid]
        endloop
        return false
    endfunction
    
    function Shuffle takes BigInt int, integer id, integer h returns nothing
        local Base b=int.base
        debug if (0!=ss[id]) then
            set bi=int
            set pid=id
            loop
                exitwhen 0==h
                call TriggerEvaluate(mt)
                set h=h-1
            endloop
            set int.base=b
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"SCRAMBLER ERROR: INVALID PLAYER "+I2S(id))
        debug endif
    endfunction
    function Unshuffle takes BigInt int, integer id, integer h returns nothing
        local Base b=int.base
        debug if (0!=ss[id]) then
            set bi=int
            set pid=id
            loop
                exitwhen 0==h
                call TriggerEvaluate(dt)
                set h=h-1
            endloop
            set int.base=b
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"SCRAMBLER ERROR: INVALID PLAYER "+I2S(id))
        debug endif
    endfunction
    private module Init
        private static method onInit takes nothing returns nothing
            local integer is=11
            local integer hh
            local integer ks=25
            local Base b8=Base["012345678"]
            local BigInt bg
            call TriggerAddCondition(mt,Condition(function Mt))
            call TriggerAddCondition(dt,Condition(function Dt))
            call TriggerAddCondition(st,Condition(function St))
            call TriggerAddCondition(ut,Condition(function Ut))
            set bs[2]=Base["01"]
            set bs[3]=Base["012"]
            set bs[5]=Base["01234"]
            set bs[7]=Base["0123456"]
            set bs[11]=Base["0123456789A"]
            set sc=SetShuffleOrder()
            loop
                if (GetPlayerSlotState(Player(is))==PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(is))==MAP_CONTROL_USER) then
                    set ss[is]=ks
                    set hh=StringHash(StringCase(GetPlayerName(Player(is))+SALT,false))
                    if (0>hh) then
                        set hh=-hh
                    endif
                    set bg=BigInt.create()
                    set bg.base = b8
                    call bg.add(hh)
                    set bg=bg.prev
                    loop
                        set ss[ks]=bg.digit+1
                        set bg=bg.prev
                        exitwhen bg.head
                        set ks=ks+1
                    endloop
                    set se[ks]=true
                    set ss[is+12]=ks
                    call bg.destroy()
                    set ks=ks+2
                endif
                exitwhen 0==is
                set is=is-1
            endloop
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary