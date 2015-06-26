library NxStack /* v1.0.0.1
************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*
*
************************************************************************************
*
*	module NxStack
*
*		Description
*		-------------------------
*
*			Collection Properties:
*
*				Unique to Collection
*				Allocated
*				Not 0
*
*		Fields
*		-------------------------
*
*			readonly static integer sentinel
*
*			readonly thistype first
*			readonly thistype next
*
*		Methods
*		-------------------------
*
*			method destroy takes nothing returns nothing
*
*			method push takes nothing returns thistype
*			method pop takes nothing returns nothing
*
*			method clear takes nothing returns nothing
*				-	Initializes stack, use instead of create
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	module NxStack
		private static thistype nodeCount = 0
		debug private boolean isCollection
		debug private boolean isNode
		
		private thistype _next
		method operator next takes nothing returns thistype
			debug call ThrowError(this == 0,	"NxStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
			debug call ThrowError(not isNode,	"NxStack", "next", "thistype", this, "Attempted To Read Invalid Node.")
			return _next
		endmethod
		
		private thistype _first
		method operator first takes nothing returns thistype
			debug call ThrowError(this == 0,		"NxStack", "first", "thistype", this, "Attempted To Read Null Stack.")
			debug call ThrowError(not isCollection,	"NxStack", "first", "thistype", this, "Attempted To Read Invalid Stack.")
			return _first
		endmethod
		
		static method operator sentinel takes nothing returns integer
			return 0
		endmethod
		
		private static method allocateNode takes nothing returns thistype
			local thistype this = thistype(0)._next
			
			if (0 == this) then
				debug call ThrowError(nodeCount == 8191, "NxStack", "allocateNode", "thistype", 0, "Overflow.")
				
				set this = nodeCount + 1
				set nodeCount = this
			else
				set thistype(0)._next = _next
			endif
			
			return this
		endmethod
		
		method push takes nothing returns thistype
			local thistype node = allocateNode()
			
			debug call ThrowError(this == 0,		"NxStack", "push", "thistype", this, "Attempted To Push On To Null Stack.")
			debug call ThrowError(not isCollection,	"NxStack", "push", "thistype", this, "Attempted To Push On To Invalid Stack.")
			
			debug set node.isNode = true
			
			set node._next = _first
			set _first = node
			
			return node
		endmethod
		method pop takes nothing returns nothing
			local thistype node = _first
			
			debug call ThrowError(this == 0,		"NxStack", "pop", "thistype", this, "Attempted To Pop Null Stack.")
			debug call ThrowError(not isCollection,	"NxStack", "pop", "thistype", this, "Attempted To Pop Invalid Stack.")
			debug call ThrowError(node == 0,		"NxStack", "pop", "thistype", this, "Attempted To Pop Empty Stack.")
			
			debug set node.isNode = false
			
			set _first = node._next
			
			set node._next = thistype(0)._next
			set thistype(0)._next = node
		endmethod
		private method getBottom takes nothing returns thistype
			set this = _first
		
			loop
				exitwhen _next == 0
				set this = _next
			endloop
			
			return this
		endmethod
		method clear takes nothing returns nothing
			debug local thistype node = _first
		
			debug call ThrowError(this == 0, "NxStack", "clear", "thistype", this, "Attempted To Clear Null Stack.")
			
			debug if (not isCollection) then
				debug set isCollection = true
				
				debug set _first = 0
				
				debug return
			debug endif
			
			static if DEBUG_MODE then
				loop
					exitwhen node == 0
					set node.isNode = false
					set node = node._next
				endloop
			endif
			
			if (_first == 0) then
				return
			endif
			
			set getBottom()._next = thistype(0)._next
			set thistype(0)._next = _first
			set _first = 0
		endmethod
		method destroy takes nothing returns nothing
			debug call ThrowError(this == 0,		"NxStack", "destroy", "thistype", this, "Attempted To Destroy Null Stack.")
			debug call ThrowError(not isCollection,	"NxStack", "destroy", "thistype", this, "Attempted To Destroy Invalid Stack.")
			
			call clear()
				
			debug set isCollection = false
		endmethod
		
		static if DEBUG_MODE then
			static method calculateMemoryUsage takes nothing returns integer
				local thistype start = 1
				local thistype end = 8191
				local integer count = 0
				
				loop
					exitwhen integer(start) > integer(end)
					if (integer(start) + 500 > integer(end)) then
						set count = checkRegion(start, end)
						set start = end + 1
					else
						set count = checkRegion(start, start + 500)
						set start = start + 501
					endif
				endloop
				
				return count
			endmethod
			
			private static method checkRegion takes thistype start, thistype end returns integer
				local integer count = 0
			
				loop
					exitwhen integer(start) > integer(end)
					if (start.isNode) then
						set count = count + 1
					endif
					if (start.isCollection) then
						set count = count + 1
					endif
					set start = start + 1
				endloop
				
				return count
			endmethod
			
			static method getAllocatedMemoryAsString takes nothing returns string
				local thistype start = 1
				local thistype end = 8191
				local string memory = null
				
				loop
					exitwhen integer(start) > integer(end)
					if (integer(start) + 500 > integer(end)) then
						set memory = memory + checkRegion2(start, end)
						set start = end + 1
					else
						set memory = memory + checkRegion2(start, start + 500)
						set start = start + 501
					endif
				endloop
				
				return memory
			endmethod
			
			private static method checkRegion2 takes thistype start, thistype end returns string
				local string memory = null
			
				loop
					exitwhen integer(start) > integer(end)
					if (start.isNode) then
						if (memory == null) then
							set memory = I2S(start)
						else
							set memory = memory + ", " + I2S(start) + "N"
						endif
					endif
					if (start.isCollection) then
						if (memory == null) then
							set memory = I2S(start)
						else
							set memory = memory + ", " + I2S(start) + "C"
						endif
					endif
					set start = start + 1
				endloop
				
				return memory
			endmethod
		endif
	endmodule
endlibrary