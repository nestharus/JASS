//! import "Table\main.j"
//! import "TableField\main.j"
//! import "Init\main.j"

library ListHtNt /*
************************************************************************************
*
*	*/ uses /*
*
*		*/ optional ErrorMessage	/*		github.com/nestharus/JASS/blob/master/jass/Systems/ErrorMessage/script.j
*		*/ optional MemoryAnalysis	/*
*		*/ TableField				/*
*		*/ Table					/*		hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*		*/ Init						/*
*
************************************************************************************
*
*	struct/module ListHtNt
*
*		Description
*		-------------------------
*
*			NA
*
*		Fields
*		-------------------------
*
*			debug readonly MemoryMonitor address
*
*			readonly thistype collection
*
*			readonly thistype first
*			readonly thistype last
*
*			readonly thistype next
*			readonly thistype prev
*
*			readonly boolean sentinel
*			-	exit loop when this becomes true
*
*			readonly boolean isNull
*			readonly boolean empty
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
	//! import "List\HtNt\data\Node.j"
	//! import "List\HtNt\data\Element.j"
	//! import "List\HtNt\data\Collection.j"
	
	//! import "List\HtNt\debug\ErrorMessages.j"
	//! import "List\HtNt\debug\Assertions.j"
	
	// Assertion Logic
	struct ListHtNt extends array
		private method operator Node takes nothing returns Node
			return this
		endmethod
	
		private method operator Element takes nothing returns Element
			return this
		endmethod
		
		private method operator Collection takes nothing returns Collection
			return this
		endmethod
		
		public method operator isNull takes nothing returns boolean
			return Node.isNull
		endmethod
		
		public method operator sentinel takes nothing returns boolean
			return isNull
		endmethod
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			public method operator address takes nothing returns MemoryMonitor
				call AssertAllocated("address", this)
				
				return Node.address
			endmethod
		endif
		
		public method operator empty takes nothing returns boolean
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("empty", this)
			endif
			
			return Collection.empty
		endmethod
		
		public method operator collection takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("collection", this)
			endif
			
			return Element.collection
		endmethod
		
		public method operator next takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("next", this)
			endif
			
			return Element.next
		endmethod
		
		public method operator prev takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("prev", this)
			endif
			
			return Element.prev
		endmethod
		
		public method operator first takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("first", this)
			endif
			
			return Collection.first
		endmethod
		
		public method operator last takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("last", this)
			endif
			
			return Collection.last
		endmethod
		
		public static method create takes nothing returns thistype
			return Collection.create()
		endmethod
		
		public method destroy takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("destroy", this)
			endif
			
			call Collection.destroy()
		endmethod
		
		method push takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("push", this)
			endif
			
			return Collection.push()
		endmethod
		
		method enqueue takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("enqueue", this)
			endif
			
			return Collection.enqueue()
		endmethod
		
		method pop takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollectionNotEmpty("pop", this)
			endif
		
			call Collection.pop()
		endmethod
		
		method dequeue takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollectionNotEmpty("dequeue", this)
			endif
			
			call Collection.dequeue()
		endmethod
		
		method remove takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("remove", this)
			endif
			
			call Element.collection.remove(this)
		endmethod

		method clear takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("clear", this)
			endif
			
			call Collection.clear()
		endmethod
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			public static method calculateMemoryUsage takes nothing returns integer
				return Node.calculateMemoryUsage()
			endmethod
			
			public static method getAllocatedMemoryAsString takes nothing returns string
				return Node.getAllocatedMemoryAsString()
			endmethod
		endif
	endstruct
	
	module ListHtNt
		public method operator sentinel takes nothing returns boolean
			return ListHtNt(this).sentinel
		endmethod
	
		public method operator isNull takes nothing returns boolean
			return ListHtNt(this).isNull
		endmethod
		
		public method operator empty takes nothing returns boolean
			return ListHtNt(this).empty
		endmethod
	
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			public method operator address takes nothing returns MemoryMonitor
				return ListHtNt(this).address
			endmethod
		endif
		
		public method operator collection takes nothing returns thistype
			return ListHtNt(this).collection
		endmethod
		
		public method operator next takes nothing returns thistype
			return ListHtNt(this).next
		endmethod
		
		public method operator prev takes nothing returns thistype
			return ListHtNt(this).prev
		endmethod
		
		public method operator first takes nothing returns thistype
			return ListHtNt(this).first
		endmethod
		
		public method operator last takes nothing returns thistype
			return ListHtNt(this).last
		endmethod
		
		static method create takes nothing returns thistype
			return ListHtNt.create()
		endmethod
		
		public method destroy takes nothing returns nothing
			call ListHtNt(this).destroy()
		endmethod
		
		method push takes nothing returns thistype
			return ListHtNt(this).push()
		endmethod
		
		method enqueue takes nothing returns thistype
			return ListHtNt(this).enqueue()
		endmethod
		
		method pop takes nothing returns nothing
			call ListHtNt(this).pop()
		endmethod
		
		method dequeue takes nothing returns nothing
			call ListHtNt(this).dequeue()
		endmethod
		
		method remove takes nothing returns nothing
			call ListHtNt(this).remove()
		endmethod

		method clear takes nothing returns nothing
			call ListHtNt(this).clear()
		endmethod
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			public static method calculateMemoryUsage takes nothing returns integer
				return ListHtNt.calculateMemoryUsage()
			endmethod
			
			public static method getAllocatedMemoryAsString takes nothing returns string
				return ListHtNt.getAllocatedMemoryAsString()
			endmethod
		endif
	endmodule
endlibrary