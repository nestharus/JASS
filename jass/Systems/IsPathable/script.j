library IsPathable /* v1.0.2.3
*************************************************************************************
*
*   The IsTerrainPathable native does not work.
*
*   This library will also check if a point is currently pathable. Will even be
*   able to detect buildings and large clusters of units (avoids the 1024 warcraft
*   limit to pathing)
*
************************************************************************************
*
*   */uses/*
*
*       */ WorldBounds /*           hiveworkshop.com/forums/jass-functions-413/snippet-worldbounds-180494/
*       */ optional UnitIndexer /*  hiveworkshop.com/forums/jass-resources-412/system-unit-indexer-172090/
*
************************************************************************************
*
*   SETTINGS
*/
    globals
        /*
            Enables the 1024 path checking for warcraft 3 (100% accurate path checking)
            The 1024 case is a very rare case and may not be present in the map
            Only enable this if it is truly needed (major performance hit).
        */
        private constant boolean SAFE_PATHING = false
    endglobals
/*
************************************************************************************
*
*   constant integer PATH_TYPE_AMPHIBIOUS
*   constant integer PATH_TYPE_BLIGHT
*   constant integer PATH_TYPE_BUILDABILITY
*   constant integer PATH_TYPE_FLOATABILITY
*   constant integer PATH_TYPE_FLYABILITY
*   constant integer PATH_TYPE_WALKABILITY
*
*   function IsPathable takes integer x, integer y, integer pathingType returns boolean
*       -   i.e. call IsPathable(0,0,PATH_TYPE_AMPHIBIOUS)
*
************************************************************************************/
    globals
        //pathing types
        constant integer PATH_TYPE_AMPHIBIOUS=0
        constant integer PATH_TYPE_BLIGHT=1
        constant integer PATH_TYPE_BUILDABILITY=2
        constant integer PATH_TYPE_FLOATABILITY=3
        constant integer PATH_TYPE_FLYABILITY=4
        constant integer PATH_TYPE_WALKABILITY=5
        
        constant integer UNITS_PATH_unflyable='h!!!'
        constant integer UNITS_PATH_unamph='h!!"'
        constant integer UNITS_PATH_unbuildable='h!!#'
        constant integer UNITS_PATH_unwalkable='h!!$'
        constant integer UNITS_PATH_unfloat='h!!%'
        constant integer UNITS_PATH_blighted='h!!&'
        
        private pathingtype array pt
        private unit array u                                //unit pathability checkers array
    endglobals
    function GetPathingUnit takes integer pt returns unit
        return u[pt]
    endfunction
    function IsPathable takes integer x, integer y, integer p returns boolean
        local boolean b                                     //was point pathable?
        
        call SetUnitPosition(u[p],x,y)                      //use SetUnitPosition to determine if point is pathable
        set b=GetUnitX(u[p])==x and GetUnitY(u[p])==y       //if coordinates are identical, coordinate *may* be
                                                            //pathable
                                                            
        static if SAFE_PATHING then
            if (b) then
                //if the point was found as pathable, it may not be pathable
                //units are placed at the original coordinates if the closest pathable point is
                //at least 1024 units out
                set x=x+32                      //go out by 32
                call SetUnitPosition(u[p],x,y)  //set unit to new position
                set b=GetUnitX(u[p])<x          //check to see if unit shifted towards original position
                //if unit didn't shift towards original position, check second position with another unit
                
                //where all points are not pathable, place a unit at an arbitrary point
                //it will stay at that point even though it isn't pathable
                /*
                    *   *   *   *
                    *   *   *   *
                    *   U   *   *
                    *   *   *   *
                */
                
                //shift the unit over by 1 and see if it doesn't shift
                //if it did shift, then the original position was pathable
                //if it didn't shift, then both positions may or may not be pathable
                /*
                    *   *   *   *
                    *   *   *   *
                    *   *   U   *
                    *   *   *   *
                */
                
                //place a second unit on top of the first unit
                //if it didn't shift left, then the first position was not pathable
                /*
                    *   *   *   *
                    *   *   *   *
                    *   *   <-UU   *
                    *   *   *   *
                    
                    --------------------------
                    *   *   *   *
                    *   *   *   *
                    *   U   U   *
                    *   *   *   *
                */
                //the reason it will shift left is because 64 is only half a square, meaning it
                //will still be closest to the first position
                
                //the reason why two units are required
                /*
                    *   *   *   *
                    *   *   *   *
                    *           *
                    *   *   *   *
                */
                //in this case, both positions are pathable, meaning the unit will not shift
                //it would be identical to this case
                /*
                    *   *   *   *
                    *   *   *   *
                    *   *   *   *
                    *   *   *   *
                */
                //and the reason for moving right is due to this case
                /*
                    *   *   *   *
                    *   *   *   *
                    *       *   *
                    *   *   *   *
                */
                //in this case, a unit placed on top of the original unit will not shift anywhere
                //and nothing is known
                if (not b) then
                    call SetUnitPosition(u[p+6],x-32,y)
                    set b=GetUnitX(u[p+6])<x
                    call SetUnitX(u[p+6],WorldBounds.minX)
                    call SetUnitY(u[p+6],WorldBounds.minY)
                endif
            endif
        endif
        call SetUnitX(u[p],WorldBounds.minX)
        call SetUnitY(u[p],WorldBounds.minY)
        return b
    endfunction
    private module N
        private static method onInit takes nothing returns nothing
            local player p=Player(15)
            
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled = false
            endif
            
            set pt[PATH_TYPE_FLYABILITY]=PATHING_TYPE_FLYABILITY
            set pt[PATH_TYPE_AMPHIBIOUS]=PATHING_TYPE_AMPHIBIOUSPATHING
            set pt[PATH_TYPE_BUILDABILITY]=PATHING_TYPE_BUILDABILITY
            set pt[PATH_TYPE_WALKABILITY]=PATHING_TYPE_WALKABILITY
            set pt[PATH_TYPE_FLOATABILITY]=PATHING_TYPE_FLOATABILITY
            set pt[PATH_TYPE_BLIGHT]=PATHING_TYPE_BLIGHTPATHING
            
            set u[PATH_TYPE_FLYABILITY]=CreateUnit(p,UNITS_PATH_unflyable,0,0,0)
            set u[PATH_TYPE_AMPHIBIOUS]=CreateUnit(p,UNITS_PATH_unamph,0,0,0)
            set u[PATH_TYPE_BUILDABILITY]=CreateUnit(p,UNITS_PATH_unbuildable,0,0,0)
            set u[PATH_TYPE_WALKABILITY]=CreateUnit(p,UNITS_PATH_unwalkable,0,0,0)
            set u[PATH_TYPE_FLOATABILITY]=CreateUnit(p,UNITS_PATH_unfloat,0,0,0)
            set u[PATH_TYPE_BLIGHT]=CreateUnit(p,UNITS_PATH_blighted,0,0,0)
            
            set u[PATH_TYPE_FLYABILITY+6]=CreateUnit(p,UNITS_PATH_unflyable,0,0,0)
            set u[PATH_TYPE_AMPHIBIOUS+6]=CreateUnit(p,UNITS_PATH_unamph,0,0,0)
            set u[PATH_TYPE_BUILDABILITY+6]=CreateUnit(p,UNITS_PATH_unbuildable,0,0,0)
            set u[PATH_TYPE_WALKABILITY+6]=CreateUnit(p,UNITS_PATH_unwalkable,0,0,0)
            set u[PATH_TYPE_FLOATABILITY+6]=CreateUnit(p,UNITS_PATH_unfloat,0,0,0)
            set u[PATH_TYPE_BLIGHT+6]=CreateUnit(p,UNITS_PATH_blighted,0,0,0)
            
            call SetUnitX(u[PATH_TYPE_FLYABILITY],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_FLYABILITY],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_AMPHIBIOUS],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_AMPHIBIOUS],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_BUILDABILITY],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_BUILDABILITY],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_WALKABILITY],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_WALKABILITY],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_FLOATABILITY],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_FLOATABILITY],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_BLIGHT],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_BLIGHT],WorldBounds.minY)
            
            call SetUnitX(u[PATH_TYPE_FLYABILITY+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_FLYABILITY+6],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_AMPHIBIOUS+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_AMPHIBIOUS+6],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_BUILDABILITY+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_BUILDABILITY+6],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_WALKABILITY+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_WALKABILITY+6],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_FLOATABILITY+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_FLOATABILITY+6],WorldBounds.minY)
            call SetUnitX(u[PATH_TYPE_BLIGHT+6],WorldBounds.minX)
            call SetUnitY(u[PATH_TYPE_BLIGHT+6],WorldBounds.minY)
            
            call PauseUnit(u[PATH_TYPE_FLYABILITY], true)
            call PauseUnit(u[PATH_TYPE_AMPHIBIOUS], true)
            call PauseUnit(u[PATH_TYPE_BUILDABILITY], true)
            call PauseUnit(u[PATH_TYPE_WALKABILITY], true)
            call PauseUnit(u[PATH_TYPE_FLOATABILITY], true)
            call PauseUnit(u[PATH_TYPE_BLIGHT], true)
            
            call PauseUnit(u[PATH_TYPE_FLYABILITY + 6], true)
            call PauseUnit(u[PATH_TYPE_AMPHIBIOUS + 6], true)
            call PauseUnit(u[PATH_TYPE_BUILDABILITY + 6], true)
            call PauseUnit(u[PATH_TYPE_WALKABILITY + 6], true)
            call PauseUnit(u[PATH_TYPE_FLOATABILITY + 6], true)
            call PauseUnit(u[PATH_TYPE_BLIGHT + 6], true)
            
            set p=null
            
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled = true
            endif
        endmethod
    endmodule
    private struct I extends array
        implement N
    endstruct
endlibrary