/*
*	Collection extends Node
*
********************************************************************************************
*
*	IMPORTS
*/
	//! import "List\HtNt\data\Node.j"
	//! import "List\HtNt\data\Element.j"
/*
********************************************************************************************
*
*	API
*
*		Readonly Node node
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

struct Collection extends array
	public method operator Node takes nothing returns Node
		return this
	endmethod
	
	public method operator first takes nothing returns Element
		return Node(this).next
	endmethod
	public method operator first= takes Node element returns nothing
		set Node(this).next = element
	endmethod
	
	public method operator last takes nothing returns Element
		return Node(this).prev
	endmethod
	public method operator last= takes Node element returns nothing
		set Node(this).prev = element
	endmethod
	
	public method operator isNull takes nothing returns boolean
		return Node.isNull
	endmethod
	
	public method operator empty takes nothing returns boolean
		return first.isNull
	endmethod
	
	public static method create takes nothing returns thistype
		local thistype this = Node.create()
	
		set first = 0
		set last = 0
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			set Node.collection = -1
		endif
		
		return this
	endmethod
	
	public method clear takes nothing returns nothing
		if (not empty) then
			call Element.destroyRange(first, last)
			
			set first = 0
			set last = 0
		endif
	endmethod
	
	public method destroy takes nothing returns nothing
		if (not empty) then
			call Element.destroyRange(first, last)
		endif
		
		call Node.destroy()
	endmethod
	
	public method push takes nothing returns thistype
		local Element element = Element.create(this)
		
		if (empty) then
			set first = element
			set last = element
			set element.next = 0
			set element.prev = 0
		else
			set element.next = first
			set element.prev = 0
			set first.prev = element
			set first = element
		endif
		
		return element
	endmethod
	
	public method enqueue takes nothing returns thistype
		local Element element = Element.create(this)
		
		if (empty) then
			set first = element
			set last = element
			set element.next = 0
			set element.prev = 0
		else
			set element.prev = last
			set element.next = 0
			set last.next = element
			set last = element
		endif
		
		return element
	endmethod
	
	public method pop takes nothing returns nothing
		local Element first = this.first.next
		
		call this.first.destroy()
		set this.first = first

		if (first == 0) then
			set last = 0
		else
			set first.prev = 0
		endif
	endmethod
	
	public method dequeue takes nothing returns nothing
		local Element last = this.last.prev
		
		call this.last.destroy()
		set this.last = last

		if (last == 0) then
			set first = 0
		else
			set last.next = 0
		endif
	endmethod
	
	public method remove takes Element element returns nothing
		if (element.prev == 0) then
			set first = element.next
		else
			set element.prev.next = element.next
		endif
		
		if (element.next == 0) then
			set last = element.prev
		else
			set element.next.prev = element.prev
		endif
		
		call element.destroy()
	endmethod
endstruct