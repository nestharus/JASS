library ListHtNt /* v2.0.0.0
************************************************************************************
*
*	*/ uses /*
*
*		*/ optional ErrorMessage	/*		github.com/nestharus/JASS/blob/master/jass/Systems/ErrorMessage/script.j
*		*/ optional MemoryAnalysis	/*
*		*/ TableField				/*
*		*/ Table					/*		hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
************************************************************************************
*
*	module ListHtNt
*
*		Description
*		-------------------------
*
*			NA
*
*		Fields
*		-------------------------
*
*			debug readonly boolean isCollection
*			debug readonly boolean isElement
*			debug readonly integer address
*			-	MemoryMonitor address
*
*			readonly static integer sentinel
*
*			readonly thistype collection
*
*			readonly thistype first
*			readonly thistype last
*
*			readonly thistype next
*			readonly thistype prev
*
*		Methods
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

	//! import "debug\\main.j"

	module ListHtNt
		public static constant integer sentinel = 0

		/* memory tracking */
		static if LIBRARY_MemoryAnalysis then
			public method operator address takes nothing returns MemoryMonitor
				return ListHtNt(this).address
			endmethod
		endif
		
		/* fields */
		public method operator allocated takes nothing returns boolean
			return ListHtNt(this).allocated
		endmethod
		
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
		
		/* operations */
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
		
		public static method calculateMemoryUsage takes nothing returns integer
			return Allocator.calculateMemoryUsage()
		endmethod
		
		public static method getAllocatedMemoryAsString takes nothing returns string
			return Allocator.getAllocatedMemoryAsString()
			return Allocator.getAllocatedMemoryAsString()
		endmethod
	endmodule

	struct ListHtNt extends array
		//! runtextmacro P_ListHtNtDebug()
	endstruct
endlibrary