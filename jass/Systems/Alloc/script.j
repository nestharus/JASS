library Alloc /* v1.1.2.0
*************************************************************************************
*
*	*/uses/*
*
*		*/ ErrorMessage /*      https://github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*
*************************************************************************************
*
*	Minimizes code generation and global variables while maintaining
*   excellent performance.
*
*       local thistype this = recycler[0]
*
*       if (recycler[this] == 0) then
*           set recycler[0] = this + 1
*       else
*           set recycler[0] = recycler[this]
*       endif
*
************************************************************************************
*
*	module Alloc
*
*		static method allocate takes nothing returns thistype
*		method deallocate takes nothing returns nothing
*
*		readonly boolean isAllocated
*
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	module Alloc
        /*
        *   stack
        */
		private static integer array recycler
        
        /*
        *   list of allocated memory
        */
        debug private static integer array allocatedNext
        debug private static integer array allocatedPrev
        
        /*
        *   free memory counter
        */
        debug private static integer usedMemory = 0
		
        /*
        *   allocation
        */
		static method allocate takes nothing returns thistype
			local thistype this = recycler[0]
			
			debug call ThrowError(this == 8192, "Alloc", "allocate", "thistype", 0, "Overflow.")
            
            if (recycler[this] == 0) then
                set recycler[0] = this + 1
            else
                set recycler[0] = recycler[this]
            endif
            
            set recycler[this] = -1
            
            debug set usedMemory = usedMemory + 1
            
            debug set allocatedNext[this] = 0
            debug set allocatedPrev[this] = allocatedPrev[0]
            debug set allocatedNext[allocatedPrev[0]] = this
            debug set allocatedPrev[0] = this
			
			return this
		endmethod
		
		method deallocate takes nothing returns nothing
			debug call ThrowError(recycler[this] != -1, "Alloc", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			
			set recycler[this] = recycler[0]
			set recycler[0] = this
            
            debug set usedMemory = usedMemory - 1
            
            debug set allocatedNext[allocatedPrev[this]] = allocatedNext[this]
            debug set allocatedPrev[allocatedNext[this]] = allocatedPrev[this]
		endmethod
		
        /*
        *   analysis
        */
        method operator isAllocated takes nothing returns boolean
			return recycler[this] == -1
		endmethod
        
		static if DEBUG_MODE then
			static method calculateMemoryUsage takes nothing returns integer
				return usedMemory
			endmethod
			
			static method getAllocatedMemoryAsString takes nothing returns string
				local integer memoryCell = allocatedNext[0]
				local string memoryRepresentation = null
				
				loop
					exitwhen memoryCell == 0
                    
                    if (memoryRepresentation == null) then
                        set memoryRepresentation = I2S(memoryCell)
                    else
                        set memoryRepresentation = memoryRepresentation + ", " + I2S(memoryCell)
                    endif
                    
                    set memoryCell = allocatedNext[memoryCell]
                endloop
                    
				return memoryRepresentation
			endmethod
		endif
        
        /*
        *   initialization
        */
		private static method onInit takes nothing returns nothing
			set recycler[0] = 1
		endmethod
	endmodule
endlibrary