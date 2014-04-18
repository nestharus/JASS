library StaticUniqueList /* v1.0.0.2
************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*
*
************************************************************************************
*
*	module StaticUniqueList
*
*		Description
*		-------------------------
*
*			Node Properties:
*
*				Unique
*				Not 0
*
*		Fields
*		-------------------------
*
*			readonly static integer sentinel
*
*			readonly static thistype first
*			readonly static thistype last
*
*			readonly thistype next
*			readonly thistype prev
*
*		Methods
*		-------------------------
*
*			static method push takes thistype node returns nothing
*			static method enqueue takes thistype node returns nothing
*
*			static method pop takes nothing returns nothing
*			static method dequeue takes nothing returns nothing
*
*			method remove takes nothing returns nothing
*
*			static method clear takes nothing returns nothing
*
************************************************************************************/
	module StaticUniqueList
		debug private boolean isNode
		
		private thistype _next
		method operator next takes nothing returns thistype
			debug call ThrowError(this == 0,	"StaticUniqueList", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
			debug call ThrowError(not isNode,	"StaticUniqueList", "next", "thistype", this, "Attempted To Read Invalid Node.")
			
			return _next
		endmethod
		
		private thistype _prev
		method operator prev takes nothing returns thistype
			debug call ThrowError(this == 0,	"StaticUniqueList", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
			debug call ThrowError(not isNode,	"StaticUniqueList", "prev", "thistype", this, "Attempted To Read Invalid Node.")
			
			return _prev
		endmethod
		
		static method operator first takes nothing returns thistype
			return thistype(0)._next
		endmethod
		static method operator last takes nothing returns thistype
			return thistype(0)._prev
		endmethod
		
		private static method setFirst takes thistype node returns nothing
			set thistype(0)._next = node
		endmethod
		
		private static method setLast takes thistype node returns nothing
			set thistype(0)._prev = node
		endmethod
		
		static constant integer sentinel = 0
		
		static method push takes thistype node returns nothing
			debug call ThrowError(node == 0,	"StaticUniqueList", "push", "thistype", 0, "Attempted To Push Null Node.")
			debug call ThrowError(node.isNode,	"StaticUniqueList", "push", "thistype", 0, "Attempted To Push Owned Node (" + I2S(node) + ").")
			
			debug set node.isNode = true
			
			set first._prev = node
			set node._next = first
			call setFirst(node)
				
			set node._prev = 0
		endmethod
		static method enqueue takes thistype node returns nothing
			debug call ThrowError(node == 0,	"StaticUniqueList", "enqueue", "thistype", 0, "Attempted To Enqueue Null Node.")
			debug call ThrowError(node.isNode,	"StaticUniqueList", "enqueue", "thistype", 0, "Attempted To Enqueue Owned Node (" + I2S(node) + ").")
			
			debug set node.isNode = true
			
			set last._next = node
			set node._prev = last
			call setLast(node)
			
			set node._next = 0
		endmethod
		static method pop takes nothing returns nothing
			debug call ThrowError(first == 0,	"StaticUniqueList", "pop", "thistype", 0, "Attempted To Pop Empty List.")
			
			debug set first.isNode = false
			
			call setFirst(first._next)
			set first._prev = 0
		endmethod
		static method dequeue takes nothing returns nothing
			debug call ThrowError(last == 0,	"StaticUniqueList", "dequeue", "thistype", 0, "Attempted To Dequeue Empty List.")
			
			debug set last.isNode = false
			
			call setLast(last._prev)
			set last._next = 0
		endmethod
		method remove takes nothing returns nothing
			debug call ThrowError(this == 0,	"StaticUniqueList", "remove", "thistype", 0, "Attempted To Remove Null Node.")
			debug call ThrowError(not isNode,	"StaticUniqueList", "remove", "thistype", 0, "Attempted To Remove Invalid Node (" + I2S(this) + ").")
			
			debug set isNode = false
			
			set _prev._next = _next
			set _next._prev = _prev
		endmethod
		static method clear takes nothing returns nothing
			static if DEBUG_MODE then
				local thistype node = first
			
				loop
					exitwhen node == 0
					set node.isNode = false
					set node = node._next
				endloop
			endif
			
			call setFirst(0)
			call setLast(0)
		endmethod
	endmodule
endlibrary