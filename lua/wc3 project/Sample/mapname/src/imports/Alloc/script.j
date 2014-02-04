library Alloc /* v1.1.0.1
*************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module Alloc
*
*       static method allocate takes nothing returns thistype
*       method deallocate takes nothing returns nothing
*
*		debug boolean isAllocated
*
*       debug static method calculateMemoryUsage takes nothing returns integer
*       debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module Alloc
        private static integer array recycler
		
		debug method operator isAllocated takes nothing returns boolean
			return recycler[this] == -1
		endmethod
        
        static method allocate takes nothing returns thistype
            local thistype this = recycler[0]
            
            debug call ThrowError(this == 0, "Alloc", "allocate", "thistype", 0, "Overflow.")
            
            set recycler[0] = recycler[this]
            debug set recycler[this] = -1
            
            return this
        endmethod
        
        method deallocate takes nothing returns nothing
            debug call ThrowError(recycler[this] != -1, "Alloc", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
            
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i = 0

            set recycler[8191] = 0 //so that the array doesn't reallocate over and over again
            
            loop
                set recycler[i] = i + 1
                
                exitwhen i == 8190
                set i = i + 1
            endloop
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local integer start = 1
                local integer end = 8191
                local integer count = 0
                
                loop
                    exitwhen start > end
                    if (start + 500 > end) then
                        set count = count + checkRegion(start, end)
                        set start = end + 1
                    else
                        set count = checkRegion(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return count
            endmethod
              
            private static method checkRegion takes integer start, integer end returns integer
                local integer count = 0
            
                loop
                    exitwhen start > end
                    if (recycler[start] == -1) then
                        set count = count + 1
                    endif
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local integer start = 1
                local integer end = 8191
                local string memory = null
                
                loop
                    exitwhen start > end
                    if (start + 500 > end) then
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, end)
                        set start = end + 1
                    else
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return memory
            endmethod
              
            private static method checkRegion2 takes integer start, integer end returns string
                local string memory = null
            
                loop
                    exitwhen start > end
                    if (recycler[start] == -1) then
                        if (memory == null) then
                            set memory = I2S(start)
                        else
                            set memory = memory + ", " + I2S(start)
                        endif
                    endif
                    set start = start + 1
                endloop
                
                return memory
            endmethod
        endif
    endmodule
endlibrary