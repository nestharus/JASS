/*
*	Element extends Node
*
********************************************************************************************
*
*	IMPORTS
*/
	//! import "List\HtNt\data\Node.j"
/*
********************************************************************************************
*
*	API
*
*		readonly Node node
*
*		Element next
*		Element prev
*
*		readonly Collection collection
*		readonly boolean isNull
*
*		static method create takes Collection collection returns thistype
*		method destroy takes nothing returns nothing
*		static method destroyRange takes thistype start, thistype end returns nothing
*
*******************************************************************************************/

struct Element extends array
	public method operator Node takes nothing returns Node
		return this
	endmethod

	public method operator next takes nothing returns Element
		return Node.next
	endmethod
	public method operator next= takes Element element returns nothing
		set Node.next = element
	endmethod
	
	public method operator prev takes nothing returns Element
		return Node.prev
	endmethod
	public method operator prev= takes Element element returns nothing
		set Node.prev = element
	endmethod
	
	public method operator collection takes nothing returns Collection
		return Node.collection
	endmethod
	
	public method operator isNull takes nothing returns boolean
		return Node.isNull
	endmethod
	
	public static method create takes Collection collection returns thistype
		local thistype this = Node.create()
	
		set Node.collection = collection
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			call Node(collection).address.monitor("Element", Node.address)
		endif
		
		return this
	endmethod
	
	public method destroy takes nothing returns nothing
		call Node.destroy()
	endmethod
	
	public static method destroyRange takes thistype start, thistype end returns nothing
		call Node.destroyRange(start, end)
	endmethod
endstruct