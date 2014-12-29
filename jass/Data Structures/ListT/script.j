library ListT /* v1.0.1.0
************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*
*
************************************************************************************
*
*	module ListT
*
*		Description
*		-------------------------
*
*			NA
*
*		Fields
*		-------------------------
*
*			debug readonly boolean isList
*			debug readonly boolean isElement
*
*			readonly static integer sentinel
*
*			readonly thistype list
*
*			readonly thistype first
*			readonly thistype last
*
*			readonly thistype next
*			readonly thistype prev
*
*		Methods
*		-------------------------
*
*			static method create takes nothing returns thistype
*			method destroy takes nothing returns nothing
*				-	May only destroy lists
*
*			method push takes nothing returns thistype
*			method enqueue takes nothing returns thistype
*
*			method pop takes nothing returns nothing
*			method dequeue takes nothing returns nothing
*
*			method remove takes nothing returns nothing
*
*			method clear takes nothing returns nothing
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	private keyword isNode
	private keyword isCollection
	private keyword pp_list
	private keyword pp_next
	private keyword pp_prev
	private keyword pp_first
	private keyword pp_last

	module ListT
		private static thistype collectionCount = 0
		private static thistype nodeCount = 0
		
		debug private static Table p_isNode
		debug method operator isNode takes nothing returns boolean
			debug return p_isNode.boolean[this]
		debug endmethod
		debug method operator isNode= takes boolean value returns nothing
			debug set p_isNode.boolean[this] = value
		debug endmethod
		
		debug private static Table p_isCollection
		debug method operator isCollection takes nothing returns boolean
			debug return p_isCollection.boolean[this]
		debug endmethod
		debug method operator isCollection= takes boolean value returns nothing
			debug set p_isCollection.boolean[this] = value
		debug endmethod
		
		debug method operator isList takes nothing returns boolean
			debug return isCollection
		debug endmethod
		
		debug method operator isElement takes nothing returns boolean
			debug return isNode
		debug endmethod
		
		private static Table p_list
		method operator pp_list takes nothing returns thistype
			return p_list[this]
		endmethod
		method operator pp_list= takes thistype value returns nothing
			set p_list[this] = value
		endmethod
		method operator list takes nothing returns thistype
			debug call ThrowError(this == 0,	"List", "list", "thistype", this, "Attempted To Read Null Node.")
			debug call ThrowError(not isNode,	"List", "list", "thistype", this, "Attempted To Read Invalid Node.")
			return pp_list
		endmethod
		
		private static Table p_next
		method operator pp_next takes nothing returns thistype
			return p_next[this]
		endmethod
		method operator pp_next= takes thistype value returns nothing
			set p_next[this] = value
		endmethod
		method operator next takes nothing returns thistype
			debug call ThrowError(this == 0,	"List", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
			debug call ThrowError(not isNode,	"List", "next", "thistype", this, "Attempted To Read Invalid Node.")
			return pp_next
		endmethod
		
		private static Table p_prev
		method operator pp_prev takes nothing returns thistype
			return p_prev[this]
		endmethod
		method operator pp_prev= takes thistype value returns nothing
			set p_prev[this] = value
		endmethod
		method operator prev takes nothing returns thistype
			debug call ThrowError(this == 0,	"List", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
			debug call ThrowError(not isNode,	"List", "prev", "thistype", this, "Attempted To Read Invalid Node.")
			return pp_prev
		endmethod
		
		private static Table p_first
		method operator pp_first takes nothing returns thistype
			return p_first[this]
		endmethod
		method operator pp_first= takes thistype value returns nothing
			set p_first[this] = value
		endmethod
		method operator first takes nothing returns thistype
			debug call ThrowError(this == 0,		"List", "first", "thistype", this, "Attempted To Read Null List.")
			debug call ThrowError(not isCollection,	"List", "first", "thistype", this, "Attempted To Read Invalid List.")
			return pp_first
		endmethod
		
		private static Table p_last
		method operator pp_last takes nothing returns thistype
			return p_last[this]
		endmethod
		method operator pp_last= takes thistype value returns nothing
			set p_last[this] = value
		endmethod
		method operator last takes nothing returns thistype
			debug call ThrowError(this == 0,		"List", "last", "thistype", this, "Attempted To Read Null List.")
			debug call ThrowError(not isCollection,	"List", "last", "thistype", this, "Attempted To Read Invalid List.")
			return pp_last
		endmethod
		
		static method operator sentinel takes nothing returns integer
			return 0
		endmethod
		
		private static method allocateCollection takes nothing returns thistype
			local thistype this = thistype(0).pp_first
			
			if (0 == this) then
				debug call ThrowError(collectionCount == 8191, "List", "allocateCollection", "thistype", 0, "Overflow.")
				
				set this = collectionCount + 1
				set collectionCount = this
			else
				set thistype(0).pp_first = pp_first
			endif
			
			return this
		endmethod
		
		private static method allocateNode takes nothing returns thistype
			local thistype this = thistype(0).pp_next
			
			if (0 == this) then
				debug call ThrowError(nodeCount == 8191, "List", "allocateNode", "thistype", 0, "Overflow.")
				
				set this = nodeCount + 1
				set nodeCount = this
			else
				set thistype(0).pp_next = pp_next
			endif
			
			return this
		endmethod
		
		static method create takes nothing returns thistype
			local thistype this = allocateCollection()
			
			debug set isCollection = true
			
			set pp_first = 0
			
			return this
		endmethod
		method push takes nothing returns thistype
			local thistype node = allocateNode()
			
			debug call ThrowError(this == 0,		"List", "push", "thistype", this, "Attempted To Push On To Null List.")
			debug call ThrowError(not isCollection,	"List", "push", "thistype", this, "Attempted To Push On To Invalid List.")
			
			debug set node.isNode = true
			
			set node.pp_list = this
		
			if (pp_first == 0) then
				set pp_first = node
				set pp_last = node
				set node.pp_next = 0
			else
				set pp_first.pp_prev = node
				set node.pp_next = pp_first
				set pp_first = node
			endif
			
			set node.pp_prev = 0
			
			return node
		endmethod
		method enqueue takes nothing returns thistype
			local thistype node = allocateNode()
			
			debug call ThrowError(this == 0,		"List", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
			debug call ThrowError(not isCollection,	"List", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
			
			debug set node.isNode = true
			
			set node.pp_list = this
		
			if (pp_first == 0) then
				set pp_first = node
				set pp_last = node
				set node.pp_prev = 0
			else
				set pp_last.pp_next = node
				set node.pp_prev = pp_last
				set pp_last = node
			endif
			
			set node.pp_next = 0
			
			return node
		endmethod
		method pop takes nothing returns nothing
			local thistype node = pp_first
			
			debug call ThrowError(this == 0,		"List", "pop", "thistype", this, "Attempted To Pop Null List.")
			debug call ThrowError(not isCollection,	"List", "pop", "thistype", this, "Attempted To Pop Invalid List.")
			debug call ThrowError(node == 0,		"List", "pop", "thistype", this, "Attempted To Pop Empty List.")
			
			debug set node.isNode = false
			
			set pp_first.pp_list = 0
			
			set pp_first = pp_first.pp_next
			if (pp_first == 0) then
				set pp_last = 0
			else
				set pp_first.pp_prev = 0
			endif
			
			set node.pp_next = thistype(0).pp_next
			set thistype(0).pp_next = node
		endmethod
		method dequeue takes nothing returns nothing
			local thistype node = pp_last
			
			debug call ThrowError(this == 0,		"List", "dequeue", "thistype", this, "Attempted To Dequeue Null List.")
			debug call ThrowError(not isCollection,	"List", "dequeue", "thistype", this, "Attempted To Dequeue Invalid List.")
			debug call ThrowError(node == 0,		"List", "dequeue", "thistype", this, "Attempted To Dequeue Empty List.")
			
			debug set node.isNode = false
			
			set pp_last.pp_list = 0
		
			set pp_last = pp_last.pp_prev
			if (pp_last == 0) then
				set pp_first = 0
			else
				set pp_last.pp_next = 0
			endif
			
			set node.pp_next = thistype(0).pp_next
			set thistype(0).pp_next = node
		endmethod
		method remove takes nothing returns nothing
			local thistype node = this
			set this = node.pp_list
			
			debug call ThrowError(node == 0,		"List", "remove", "thistype", this, "Attempted To Remove Null Node.")
			debug call ThrowError(not node.isNode,	"List", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
			
			debug set node.isNode = false
			
			set node.pp_list = 0
		
			if (0 == node.pp_prev) then
				set pp_first = node.pp_next
			else
				set node.pp_prev.pp_next = node.pp_next
			endif
			if (0 == node.pp_next) then
				set pp_last = node.pp_prev
			else
				set node.pp_next.pp_prev = node.pp_prev
			endif
			
			set node.pp_next = thistype(0).pp_next
			set thistype(0).pp_next = node
		endmethod
		method clear takes nothing returns nothing
			debug local thistype node = pp_first
		
			debug call ThrowError(this == 0,		"List", "clear", "thistype", this, "Attempted To Clear Null List.")
			debug call ThrowError(not isCollection,	"List", "clear", "thistype", this, "Attempted To Clear Invalid List.")
			
			static if DEBUG_MODE then
				loop
					exitwhen node == 0
					set node.isNode = false
					set node = node.pp_next
				endloop
			endif
			
			if (pp_first == 0) then
				return
			endif
			
			set pp_last.pp_next = thistype(0).pp_next
			set thistype(0).pp_next = pp_first
			
			set pp_first = 0
			set pp_last = 0
		endmethod
		method destroy takes nothing returns nothing
			debug call ThrowError(this == 0,		"List", "destroy", "thistype", this, "Attempted To Destroy Null List.")
			debug call ThrowError(not isCollection,	"List", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
			
			static if DEBUG_MODE then
				debug call clear()
				
				debug set isCollection = false
			else
				if (pp_first != 0) then
					set pp_last.pp_next = thistype(0).pp_next
					set thistype(0).pp_next = pp_first
					
					set pp_last = 0
				endif
			endif
			
			set pp_first = thistype(0).pp_first
			set thistype(0).pp_first = this
		endmethod
		
		private static method onInit takes nothing returns nothing
			static if DEBUG_MODE then
				set p_isNode = Table.create()
				set p_isCollection = Table.create()
			endif
			set p_list = Table.create()
			set p_next = Table.create()
			set p_prev = Table.create()
			set p_first = Table.create()
			set p_last = Table.create()
		endmethod
		
		static if DEBUG_MODE then
			static method calculateMemoryUsage takes nothing returns integer
				local thistype start = 1
				local thistype end = 8191
				local integer count = 0
				
				loop
					exitwhen integer(start) > integer(end)
					if (integer(start) + 500 > integer(end)) then
						return count + checkRegion(start, end)
					else
						set count = count + checkRegion(start, start + 500)
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