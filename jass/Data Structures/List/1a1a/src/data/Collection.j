/*
*	Collection extends Node
*
********************************************************************************************
*
*	API
*
*		Element first
*		Element last
*
*		readonly boolean empty
*		readonly boolean isNull
*
*		static method create takes nothing returns Collection
*		method destroy takes nothing returns nothing
*
*		method clear takes nothing returns nothing
*
*		method push takes nothing returns thistype
*		method enqueue takes nothing returns thistype
*		method pop takes nothing returns nothing
*		method dequeue takes nothing returns nothing
*		method remove takes Element element returns nothing
*
*******************************************************************************************/

private keyword isEmpty
private keyword p__first
private keyword p__last
private keyword createCollection
private keyword clearCollection
private keyword destroyCollection
private keyword pushCollection
private keyword enqueueCollection
private keyword popCollection
private keyword dequeueCollection
private keyword removeCollection

private module Collection
	static if DEBUG_MODE and LIBRARY_ErrorMessage then
		public method operator p__first takes nothing returns thistype
			return p__next
		endmethod
		public method operator p__first= takes thistype element returns nothing
			set p__next = element
		endmethod
		
		public method operator p__last takes nothing returns thistype
			return p__prev
		endmethod
		public method operator p__last= takes thistype element returns nothing
			set p__prev = element
		endmethod
	else
		public thistype p__first
		public thistype p__last
		
		private static integer instanceCount = 0
	endif

	public method isEmpty takes nothing returns boolean
		return p__first.isNull
	endmethod
	
	public static method createCollection takes nothing returns thistype
		local thistype this
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			set this = createNode()
		else
			set this = thistype(0).p__first
		
			if (this == 0) then
				set this = instanceCount + 1
				set instanceCount = this
			else
				set thistype(0).p__first = p__first
			endif
		endif
	
		set p__first = 0
		set p__last = 0
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			set p__collection = -1
		endif
		
		return this
	endmethod
	
	public method clearCollection takes nothing returns nothing
		if (not isEmpty()) then
			call destroyNodeRange(p__first, p__last)
			
			set p__first = 0
			set p__last = 0
		endif
	endmethod
	
	public method destroyCollection takes nothing returns nothing
		if (not isEmpty()) then
			call destroyNodeRange(p__first, p__last)
		endif
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			call destroyNode()
		else
			set p__first = thistype(0).p__first
			set thistype(0).p__first = this
		endif
	endmethod
	
	public method pushCollection takes nothing returns thistype
		local thistype element = createElement(this)
		
		if (isEmpty()) then
			set p__first = element
			set p__last = element
			set element.p__next = 0
			set element.p__prev = 0
		else
			set element.p__next = p__first
			set element.p__prev = 0
			set p__first.p__prev = element
			set p__first = element
		endif
		
		return element
	endmethod
	
	public method enqueueCollection takes nothing returns thistype
		local thistype element = createElement(this)
		
		if (isEmpty()) then
			set p__first = element
			set p__last = element
			set element.p__next = 0
			set element.p__prev = 0
		else
			set element.p__prev = p__last
			set element.p__next = 0
			set p__last.p__next = element
			set p__last = element
		endif
		
		return element
	endmethod
	
	public method popCollection takes nothing returns nothing
		local thistype first = p__first.p__next
		
		call p__first.destroyNode()
		set p__first = first

		if (first.isNull) then
			set p__last = 0
		else
			set first.p__prev = 0
		endif
	endmethod
	
	public method dequeueCollection takes nothing returns nothing
		local thistype last = p__last.p__prev
		
		call p__last.destroyNode()
		set p__last = last

		if (last.isNull) then
			set p__first = 0
		else
			set last.p__next = 0
		endif
	endmethod
	
	public method removeCollection takes thistype element returns nothing
		if (element.p__prev == 0) then
			set p__first = element.p__next
		else
			set element.p__prev.p__next = element.p__next
		endif
		
		if (element.p__next == 0) then
			set p__last = element.p__prev
		else
			set element.p__next.p__prev = element.p__prev
		endif
		
		call element.destroyNode()
	endmethod
endmodule