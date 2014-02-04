library Tile /* v1.0.0.0
*************************************************************************************
*
*   Makes it easier to work with Warcraft 3 space on the map. The smallest unit for Warcraft 3 is
*   a 32x32 tile. Will put all x, y components in units of 32 and work with relative magnitudes.
*
************************************************************************************
*
*   */uses/*
*
*       */ WorldBounds /*       hiveworkshop.com/forums/jass-functions-413/snippet-worldbounds-180494/
*
************************************************************************************
*
*   function NormalizeXY takes real c returns integer
*       -   Puts coordinate into units of 32
*
*   function NormalizeRelativeX takes real c returns integer
*   function NormalizeRelativeY takes real c returns integer
*       -   Puts coordinate into units of 32 relative to minimum map coordinates
*
*   function GetMaxRelativeX takes nothing returns integer
*   function GetMaxRelativeY takes nothing returns integer
*       -   Gets max coordinates relative to min coordinates in units of 32
*
************************************************************************************/
    globals
        private integer maxXr
        private integer maxYr
    endglobals
    
    function NormalizeXY takes real c returns integer
        if (0 < c) then
            return R2I(c + 16)/32*32
        endif
        return R2I(c - 16)/32*32
    endfunction
    function NormalizeRelativeX takes real c returns integer
        return R2I(c - WorldBounds.minX + 16)/32
    endfunction
    function NormalizeRelativeY takes real c returns integer
        return R2I(c - WorldBounds.minY + 16)/32
    endfunction
    function GetMaxRelativeX takes nothing returns integer
        return maxXr
    endfunction
    function GetMaxRelativeY takes nothing returns integer
        return maxYr
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            set maxXr = WorldBounds.maxX/32 - WorldBounds.minX/32
            set maxYr = WorldBounds.maxY/32 - WorldBounds.minY/32
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
    
    module Tile
        static method operator [] takes real x returns thistype
            return NormalizeRelativeX(x)
        endmethod
        method operator [] takes real y returns thistype
            return this*(maxYr + 1)+NormalizeRelativeY(y)
        endmethod
    endmodule
endlibrary