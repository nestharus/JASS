library List1a1a /*
************************************************************************************
*
*	*/ uses /*
*
*		*/ optional ErrorMessage	/*
*		*/ optional MemoryAnalysis	/*
*
************************************************************************************
*
*	module List1a1a
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
	//! import ".\debug\ErrorMessages.j"

	//! import ".\data\Node.j"
	//! import ".\data\Element.j"
	//! import ".\data\Collection.j"
	
	//! import ".\debug\Assertions.j"
	
	// Assertion Logic
	module List1a1a
		implement Node
		implement Element
		implement Collection
	
		public method operator sentinel takes nothing returns boolean
			return isNull
		endmethod
		
		public method operator empty takes nothing returns boolean
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("empty", this, p__collection)
			endif
			
			return p__first.isNull
		endmethod
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			public method operator address takes nothing returns MemoryMonitor
				call AssertAllocated("address", this, p__collection)
				
				return p__address
			endmethod
		endif
		
		public method operator collection takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("collection", this, p__collection)
			endif
			
			return p__collection
		endmethod
		
		public method operator next takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("next", this, p__collection)
			endif
			
			return p__next
		endmethod
		
		public method operator prev takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("prev", this, p__collection)
			endif
			
			return p__prev
		endmethod
		
		public method operator first takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("first", this, p__collection)
			endif
			
			return p__first
		endmethod
		
		public method operator last takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("last", this, p__collection)
			endif
			
			return p__last
		endmethod
		
		public static method create takes nothing returns thistype
			return createCollection()
		endmethod
		
		public method destroy takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("destroy", this, p__collection)
			endif
			
			call destroyCollection()
		endmethod
		
		method push takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("push", this, p__collection)
			endif
			
			return pushCollection()
		endmethod
		
		method enqueue takes nothing returns thistype
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("enqueue", this, p__collection)
			endif
			
			return enqueueCollection()
		endmethod
		
		method pop takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollectionNotEmpty("pop", this, p__collection, p__first)
			endif
		
			call popCollection()
		endmethod
		
		method dequeue takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollectionNotEmpty("dequeue", this, p__collection, p__first)
			endif
			
			call dequeueCollection()
		endmethod
		
		method remove takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertElement("remove", this, p__collection)
			endif
			
			call p__collection.removeCollection(this)
		endmethod

		method clear takes nothing returns nothing
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call AssertCollection("clear", this, p__collection)
			endif
			
			call clearCollection()
		endmethod
	endmodule
endlibrary