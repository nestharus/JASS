static if DEBUG_MODE and LIBRARY_ErrorMessage then
	//! import "Data\\Element.j"
	//! import "Data\\Collection.j"
	//! import "Data\\Flags.j"
	//! import "Data\\Allocator.j"
	
	//! import "ErrorMessages.j"
	//! import "Assertions.j"
endif

//! textmacro P_ListHtNtDebug
	static if DEBUG_MODE and LIBRARY_ErrorMessage then
		public static constant integer sentinel = 0
		
		private method operator Element takes nothing returns Element
			return this
		endmethod
		
		private method operator Collection takes nothing returns Collection
			return this
		endmethod
		
		/* memory tracking */
		static if LIBRARY_MemoryAnalysis then
			public method operator address takes nothing returns MemoryMonitor
				call AssertCollection("address", this)
				
				return Collection.address
			endmethod
		endif
		
		/* fields */
		public method operator allocated takes nothing returns boolean
			return IsAllocated(this)
		endmethod
		
		public method operator collection takes nothing returns thistype
			call AssertElement("collection", this)
			
			return Element.toCollection
		endmethod
		
		public method operator next takes nothing returns thistype
			call AssertElement("next", this)
	
			return Element.next
		endmethod
		
		public method operator prev takes nothing returns thistype
			call AssertElement("prev", this)
		
			return Element.prev
		endmethod
		
		public method operator first takes nothing returns thistype
			call AssertCollection("first", this)
		
			return Collection.first
		endmethod
		
		public method operator last takes nothing returns thistype
			call AssertCollection("last", this)
		
			return Collection.last
		endmethod
		
		/* allocators */
		private static method allocate takes nothing returns thistype
			return Allocator.allocate()
		endmethod
		
		private method deallocate takes nothing returns nothing
			call Allocator.deallocate(this)
		endmethod
		
		private static method deallocateRange takes thistype start, thistype end returns nothing
			call Allocator.deallocateRange(start, end)
		endmethod
		
		/* constructors */
		static method create takes nothing returns thistype
			local Collection collection = allocate()
		
			set collection.isCollection = true
	
			set collection.first = 0
			set collection.last = 0
			
			static if LIBRARY_MemoryAnalysis then
				set collection.address = MemoryMonitor.create("collection")
			endif
			
			return collection
		endmethod
		
		private method createElement takes string operationName returns Element
			local Element element = allocate()
		
			call AssertCollection(operationName, this)
			set element.toCollection = this
			
			static if LIBRARY_CollectionTest and LIBRARY_MemoryAnalysis then
				set element.address = MemoryMonitor.create("element")
				call Collection.address.monitor("element", element.address)
			endif
			
			return element
		endmethod
		
		/* destructors */
		static if LIBRARY_MemoryAnalysis then
			private method destroyAddress takes nothing returns nothing
				call Element.address.destroy()
				call Element.address_clear()
			endmethod
		endif
		
		private method clearCollection takes nothing returns nothing
			call Collection.isCollection_clear()
		
			static if LIBRARY_MemoryAnalysis then
				call destroyAddress()
			endif
		endmethod

		private method clearElement takes nothing returns nothing
			call Element.toCollection_clear()
			
			static if LIBRARY_CollectionTest and LIBRARY_MemoryAnalysis then
				call destroyAddress()
			endif
		endmethod

		private method clearElementRange takes Element start, Element end returns nothing
			loop
				call thistype(start).clearElement()
			
				exitwhen integer(start) == integer(end)
				set start = start.next
			endloop
		endmethod

		private method destroyElement takes nothing returns nothing
			call clearElement()
			call deallocate()
		endmethod

		private method destroyElementRange takes Element start, Element end returns nothing
			call clearElementRange(start, end)
			call deallocateRange(start, end)
		endmethod

		private method destroyCollection takes nothing returns nothing
			local thistype last = Collection.last
			
			if (IsNull(last)) then
				call clearCollection()
				call deallocate()
			else
				call clearElementRange(Collection.first, last)
				call clearCollection()
				call deallocateRange(this, last)
			endif
		endmethod
		
		public method destroy takes nothing returns nothing
			call AssertCollection("destroy", this)
	
			call destroyCollection()
		endmethod
		
		/* operation helper methods */
		private method addEmpty takes Element element returns boolean
			if (Collection.first == 0) then
				set Collection.first = element
				set Collection.last = element
				
				set element.next = 0
				set element.prev = 0
				
				return true
			endif
			
			return false
		endmethod
		
		/* operations */
		method push takes nothing returns thistype
			local Element element = createElement("push")
		
			if (not addEmpty(element)) then
				set element.next = Collection.first
				set element.prev = 0
				
				set Collection.first.prev = element
				set Collection.first = element
			endif
			
			return element
		endmethod
		
		method enqueue takes nothing returns thistype
			local Element element = createElement("enqueue")
		
			if (not addEmpty(element)) then
				set element.prev = Collection.last
				set element.next = 0
				
				set Collection.last.next = element
				set Collection.last = element
			endif
			
			return element
		endmethod
		
		method pop takes nothing returns nothing
			local Element first = Collection.first.next
			
			call AssertCollectionNotEmpty("pop", this)
			call thistype(Collection.first).destroyElement()
			
			set Collection.first = first
			
			if (first == 0) then
				set Collection.last = 0
			else
				set first.prev = 0
			endif
		endmethod
		
		method dequeue takes nothing returns nothing
			local Element last = Collection.last.prev
			
			call AssertCollectionNotEmpty("dequeue", this)
			call thistype(Collection.last).destroyElement()
			
			set Collection.last = last
			
			if (last == 0) then
				set Collection.first = 0
			else
				set last.next = 0
			endif
		endmethod
		
		method remove takes nothing returns nothing
			local Collection collection = Element.toCollection

			call AssertElement("remove", this)
			call AssertCollection("remove", collection)
			
			if (Element.prev == 0) then
				set collection.first = Element.next
			else
				set Element.prev.next = Element.next
			endif
			
			if (Element.next == 0) then
				set collection.last = Element.prev
			else
				set Element.next.prev = Element.prev
			endif
			
			call destroyElement()
		endmethod
	
		method clear takes nothing returns nothing
			call AssertCollection("clear", this)
	
			if (Collection.first != 0) then
				call destroyElementRange(Collection.first, Collection.last)
				
				set Collection.first = 0
				set Collection.last = 0
			endif
		endmethod
	endif
//! endtextmacro