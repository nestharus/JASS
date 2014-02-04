library ItemPosition /* v2.0.1.0
*************************************************************************************
*
*   Retrieves the unit carrying an item.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ GetItemOwner /*          hiveworkshop.com/forums/submissions-414/snippet-getitemowner-184563/
*       */ AutoFly /*               hiveworkshop.com/forums/submissions-414/autofly-unitindexer-version-195563/
*
************************************************************************************
*
*   Functions
*
*       function ItemGetX takes item i returns real
*       function ItemGetY takes item i returns real
*       function ItemGetZ takes item i returns real
*       function ItemGetLoc takes item i returns location
*
*       function ItemSetX takes item i, real x, boolean modOwner returns nothing
*       function ItemSetY takes item i, real y, boolean modOwner returns nothing
*       function ItemSetZ takes item i, real z, real rate returns nothing
*       function ItemSetPos takes item i, real x, real y, boolean modOwner returns nothing
*       function ItemSetPosZ takes item i, real x, real y, real z, boolean modOwner returns nothing
*
*       modOwner determines what to do when the item is being carried
*           -   true: change carrying unit's position
*           -   false: drop item from carrying unit and then move item
*
************************************************************************************/
    globals
        private location zl = Location(0,0)
    endglobals
    function ItemGetX takes item i returns real
        if (IsItemOwned(i)) then
            return GetUnitX(GetItemOwner(i))
        endif
        return GetWidgetX(i)
    endfunction
    
    function ItemGetY takes item i returns real
        if (IsItemOwned(i)) then
            return GetUnitY(GetItemOwner(i))
        endif
        return GetWidgetY(i)
    endfunction
    
    function ItemGetZ takes item i returns real
        local unit u
        local real z
        if (IsItemOwned(i)) then
            set u = GetItemOwner(i)
            call MoveLocation(zl, GetWidgetX(u), GetWidgetY(u))
            set z = GetUnitFlyHeight(u)+GetLocationZ(zl)
            set u = null
        else
            call MoveLocation(zl, GetWidgetX(i), GetWidgetY(i))
            return GetLocationZ(zl)
        endif
        return z
    endfunction
    
    function ItemGetLoc takes item i returns location
        if (IsItemOwned(i)) then
            return GetUnitLoc(GetItemOwner(i))
        endif
        return Location(GetWidgetX(i), GetWidgetY(i))
    endfunction
    
    function ItemSetX takes item i, real x, boolean modOwner returns nothing
        if (IsItemOwned(i)) then
            if (modOwner) then
                call SetUnitX(GetItemOwner(i), x)
            endif
        else
            call SetItemPosition(i, x, GetWidgetY(i))
        endif
    endfunction
    
    function ItemSetY takes item i, real y, boolean modOwner returns nothing
        if (IsItemOwned(i)) then
            if (modOwner) then
                call SetUnitY(GetItemOwner(i), y)
            endif
        else
            call SetItemPosition(i, GetItemX(i), y)
        endif
    endfunction
    
    function ItemSetZ takes item i, real z, real rate returns nothing
        local unit u
        if (IsItemOwned(i)) then
            set u = GetItemOwner(i)
            call MoveLocation(zl, GetUnitX(u), GetUnitY(u))
            call SetUnitFlyHeight(u, z - GetLocationZ(zl), rate)
            set u = null
        endif
    endfunction
    
    function ItemSetPos takes item i, real x, real y, boolean modOwner returns nothing
        local unit u
        if (IsItemOwned(i)) then
            if (modOwner) then
                set u = GetItemOwner(i)
                call SetUnitX(u, x)
                call SetUnitY(u, y)
                set u = null
            endif
        else
            call SetItemPosition(i, x, y)
        endif
    endfunction
    
    function ItemSetPosZ takes item i, real x, real y, real z, boolean modOwner returns nothing
        local unit u
        if (IsItemOwned(i)) then
            if (modOwner) then
                set u = GetItemOwner(i)
                call MoveLocation(zl, x, y)
                call SetUnitX(u, x)
                call SetUnitY(u, y)
                call SetUnitFlyHeight(u, z - GetLocationZ(zl), 0)
                set u = null
            endif
        else
            call SetItemPosition(i, x, y)
        endif
    endfunction
endlibrary