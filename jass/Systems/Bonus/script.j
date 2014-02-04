library Bonus /* v2.0.0.2
*************************************************************************************
*
*   Adds bonuses to units. In the ini area, these bonuses can be enabled and disabled.
*   Ranges of bonus values can also be modified.
*
*   Bonuses
*       -   Armor                   any unit                        non percent bonus
*       -   Damage                  units with attack only          non percent bonus
*       -   Agility                 hero only                       non percent bonus
*       -   Strength                hero only                       non percent bonus
*       -   Intelligence            hero only                       non percent bonus
*       -   Life                    any unit                        non percent bonus
*       -   Life Regeneration       any unit                        non percent bonus
*       -   Mana                    any unit                        non percent bonus
*       -   Mana Regeneration       units with mana only            percent bonus
*       -   Sight Range             any unit                        non percent bonus
*       -   Attack Speed            units with attack only          percent bonus
*
*************************************************************************************
*
*   */uses/*
*       */ UnitIndexer /*       hiveworkshop.com/forums/jass-resources-412/system-unit-indexer-172090/
*       */ Table /*             hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
************************************************************************************
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *                                   PRELOAD
    *
    *   Preloads all bonus abilities. This will add a hefty load time to the map but will
    *   prevent lag in game.
    *
    *************************************************************************************/
    private constant boolean PRELOAD = false
endglobals
/*
*************************************************************************************
*
*   Bonuses
*
*       constant integer BONUS_ARMOR
*       constant integer BONUS_DAMAGE
*       constant integer BONUS_AGILITY
*       constant integer BONUS_STRENGTH
*       constant integer BONUS_INTELLIGENCE
*       constant integer BONUS_LIFE
*       constant integer BONUS_LIFE_REGEN
*       constant integer BONUS_MANA
*       constant integer BONUS_MANA_REGEN
*       constant integer BONUS_ATTACK_SPEED
*       constant integer BONUS_SIGHT
*
*   Functions
*
*       function GetUnitBonus takes unit whichUnit, integer whichBonus returns integer
*       function SetUnitBonus takes unit whichUnit, integer whichBonus, integer value returns nothing
*       function AddUnitBonus takes unit whichUnit, integer whichBonus, integer value returns nothing
*
************************************************************************************/
    //! runtextmacro BONUS_SCRIPT()
    function SetUnitBonus takes unit u, integer b, integer v returns nothing
        local boolean n
        local integer a
        local integer p
        local integer on
        local integer i
        local integer nch
        local integer nb
        debug if (not IsUnitIndexed(u)) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "UNIT BONUS ERROR: INVALID UNIT")
            debug return
        debug endif
        debug if (0==pm[b]) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "UNIT BONUS ERROR: INVALID BONUS TYPE")
            debug return
        debug endif
        set i=GetUnitUserData(u)
        if (v != cb[i][b]) then
            set nch=0
            if (ir[b]) then
                set n=0>v
                set cb[i][b]=v
                set p=b+pm[b]-1
                set on=p+1
                call UnitRemoveAbility(u,bo[on])
                if (n) then
                    set v=v-ps[on]
                endif
                loop
                    if (0>v-ps[p]) then
                        call UnitRemoveAbility(u,bo[p])
                    else
                        call UnitAddAbility(u,bo[p])
                        call UnitMakeAbilityPermanent(u,true,bo[p])
                        set v=v-ps[p]
                    endif
                    exitwhen p==b
                    set p=p-1
                endloop
                if (n) then
                    call UnitAddAbility(u,bo[on])
                    call UnitMakeAbilityPermanent(u,true,bo[on])
                endif
            else
                set nb=v
                set v=v-cb[i][b]
                set cb[i][b]=nb
                set a=bo[b]
                set on=b+pm[b]+1
                loop
                    loop
                        exitwhen 0<v
                        set v=v-ps[on]
                        set nch=nch+1
                    endloop
                    set p=b+pm[b]
                    loop
                        if (0<=v-ps[p]) then
                            set v=v-ps[p]
                            call UnitAddAbility(u,a)
                            call SetUnitAbilityLevel(u,a,bp[p]+2)
                            call UnitRemoveAbility(u,a)
                        else
                            set p=p-1
                            exitwhen p==b
                        endif
                    endloop
                    exitwhen 0==v
                endloop
                loop
                    exitwhen 0==nch
                    set nch=nch-1
                    call UnitAddAbility(u,a)
                    call SetUnitAbilityLevel(u,a,(-bp[on])+2)
                    call UnitRemoveAbility(u,a)
                endloop
            endif
        endif
    endfunction
    function GetUnitBonus takes unit u, integer b returns integer
        return cb[GetUnitUserData(u)][b]
    endfunction
    function AddUnitBonus takes unit u, integer b, integer v returns nothing
        call SetUnitBonus(u,b,GetUnitBonus(u,b)+v)
    endfunction
endlibrary