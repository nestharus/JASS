//! import "Element.j"

private struct Collection extends array
	public method operator first takes nothing returns Element
		return Element(this).next
	endmethod
	public method operator first= takes Element element returns nothing
		set Element(this).next = element
	endmethod
	
	public method operator last takes nothing returns Element
		return Element(this).prev
	endmethod
	public method operator last= takes Element element returns nothing
		set Element(this).prev = element
	endmethod
	
	public method operator isCollection takes nothing returns boolean
		return Element(this).isCollection_has
	endmethod
	public method operator isCollection= takes boolean value returns nothing
		set Element(this).isCollection = value
	endmethod
	public method isCollection_clear takes nothing returns nothing
		call Element(this).isCollection_clear()
	endmethod
	
	public method operator address takes nothing returns MemoryMonitor
		return Element(this).address
	endmethod
	public method operator address= takes MemoryMonitor memoryMonitor returns nothing
		set Element(this).address = memoryMonitor
	endmethod
	public method address_clear takes nothing returns nothing
		call Element(this).address_clear()
	endmethod
endstruct