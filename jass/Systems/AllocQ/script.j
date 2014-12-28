library AllocQ /* v1.0.1.0
*************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage /*
*
*************************************************************************************
*
*	Maximizes speed by reducing local variable declarations and removing
*   if-statement.
*
*   Uses a queue instead of a stack for recycler. Using a queue requires one
*   extra variable declaration.
*
*       set alloc = recycler[0]
*       set recycler[0] = recycler[alloc]
*
************************************************************************************
*
*	module AllocQFast
*
*		Fields
*		-------------------------
*
*			readonly boolean isAllocated
*
*		Methods
*		-------------------------
*
*			static method allocate takes nothing returns thistype
*			method deallocate takes nothing returns nothing
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	module AllocQ
        /*
        *   stack
        */
		private static integer array recycler
        private static integer alloc
        private static integer last = 8191
        
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
			set alloc = recycler[0]
			
			debug call ThrowError(alloc == 0, "AllocQ", "allocate", "thistype", 0, "Overflow.")
            
            set recycler[0] = recycler[alloc]
            
            set recycler[alloc] = -1
            
            debug set usedMemory = usedMemory + 1
            
            debug set allocatedNext[alloc] = 0
            debug set allocatedPrev[alloc] = allocatedPrev[0]
            debug set allocatedNext[allocatedPrev[0]] = alloc
            debug set allocatedPrev[0] = alloc
			
			return alloc
		endmethod
		
		method deallocate takes nothing returns nothing
			debug call ThrowError(recycler[this] != -1, "AllocQ", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			
			set recycler[last] = this
            set recycler[this] = 0
			set last = this
            
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
			local integer i = 0

			set recycler[8191] = 0 //so that the array doesn't reallocate over and over again
            
			loop
				set recycler[i] = i + 1
				
				exitwhen i == 8190
				set i = i + 1
			endloop
		endmethod
	endmodule
endlibrary