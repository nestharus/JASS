library Trigger /* v1.1.0.2
************************************************************************************
*
*   */ uses /*
*   
*       */ ErrorMessage         /*
*       */ BooleanExpression    /*
*       */ NxListT              /*
*		*/ UniqueNxListT		/*
*       */ Init                 /*
*		*/ AllocT				/*
*
************************************************************************************
*
*   struct Trigger extends array
*           
*       Fields
*       -------------------------
*
*           readonly trigger trigger
*               -   use to register events, nothing else
*               -   keep in mind that triggers referencing this trigger won't fire when events fire
*               -   this trigger will fire when triggers referencing this trigger are fired
*
*           boolean enabled
*
*       Methods
*       -------------------------
*
*           static method create takes boolean reversed returns Trigger
*				-	when reverse is true, the entire expression is run in reverse
*
*           method destroy takes nothing returns nothing
*
*           method register takes boolexpr expression returns TriggerCondition
*
*           method reference takes Trigger trig returns TriggerReference
*               -   like register, but for triggers instead
*
*           method fire takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*               -   clears expressions
*           method clearReferences takes nothing returns nothing
*               -   clears trigger references
*           method clearBackReferences takes nothing returns nothing
*               -   removes references for all triggers referencing this trigger
*           method clearEvents takes nothing returns nothing
*               -   clears events
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************
*
*   struct TriggerReference extends array
*           
*       Methods
*       -------------------------
*
*           method destroy takes nothing returns nothing
*
*           method replace takes Trigger trigger returns nothing
*
************************************************************************************
*
*   struct TriggerCondition extends array
*
*       Methods
*       -------------------------
*
*           method destroy takes nothing returns nothing
*
*           method replace takes boolexpr expr returns nothing
*
************************************************************************************/
    private struct TriggerMemory extends array
        //! runtextmacro CREATE_TABLE_FIELD("public", "trigger", "trig", "trigger")
        //! runtextmacro CREATE_TABLE_FIELD("public", "triggercondition", "tc", "triggercondition")
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "expression", "BooleanExpression")                 //the trigger's expression
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "enabled", "boolean")
        
        method updateTrigger takes nothing returns nothing
            if (tc != null) then
                call TriggerRemoveCondition(trig, tc)
            endif
        
            if (enabled and expression.expression != null) then
                set tc = TriggerAddCondition(trig, expression.expression)
            else
				call tc_clear()
            endif
        endmethod
        
        private static method init takes nothing returns nothing
            //! runtextmacro INITIALIZE_TABLE_FIELD("trig")
            //! runtextmacro INITIALIZE_TABLE_FIELD("tc")
            
            //! runtextmacro INITIALIZE_TABLE_FIELD("expression")
            
            //! runtextmacro INITIALIZE_TABLE_FIELD("enabled")
        endmethod
        
        implement Init
    endstruct

    private struct TriggerAllocator extends array
        implement AllocT
    endstruct
    
    private keyword TriggerReferencedList
    
    private struct TriggerReferenceListData extends array
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "trig", "TriggerMemory")           //the referenced trigger
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "ref", "TriggerReferencedList")    //the TriggerReferencedList data for that trigger (relationship in 2 places)
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "expr", "BooleanExpression")
    
        implement NxListT
        
        private static method init takes nothing returns nothing
            //! runtextmacro INITIALIZE_TABLE_FIELD("trig")
            //! runtextmacro INITIALIZE_TABLE_FIELD("ref")
            //! runtextmacro INITIALIZE_TABLE_FIELD("expr")
        endmethod
        
        implement Init
    endstruct

    /*
    *   List of triggers referencing current trigger
    */
    private struct TriggerReferencedList extends array
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "trig", "TriggerMemory")               //the trigger referencing this trigger
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "ref", "TriggerReferenceListData")     //the ref 
    
        implement NxListT
        
        method updateExpression takes nothing returns nothing
            local thistype node
            local boolexpr expr
            
            /*
            *   Retrieve the expression of the referenced trigger
            */
            if (TriggerMemory(this).enabled) then
                set expr = TriggerMemory(this).expression.expression
            else
                set expr = null
            endif
            
            /*
            *   Iterate over all triggers referencing this trigger
            */
            set node = first
            loop
                exitwhen node == 0
                
                /*
                *   Replace expression and then update the target trigger
                */
                call node.ref.expr.replace(expr)
                call node.trig.updateTrigger()
                call TriggerReferencedList(node.trig).updateExpression()
                
                set node = node.next
            endloop
            
            set expr = null
        endmethod
        
        method purge takes nothing returns nothing
            local thistype node = first
            
            loop
                exitwhen node == 0
                
                /*
                *   Unregister the expression from the referencing trigger
                *   Update that trigger
                */
                call node.ref.expr.unregister()
                call node.trig.updateTrigger()
                call node.ref.remove()
                call TriggerReferencedList(node.trig).updateExpression()
                
                set node = node.next
            endloop
            
            call destroy()
        endmethod
        
        method clearReferences takes nothing returns nothing
            local thistype node = first
            
            loop
                exitwhen node == 0
                
                /*
                *   Unregister the expression from the referencing trigger
                *   Update that trigger
                */
                call node.ref.expr.unregister()
                call node.trig.updateTrigger()
                call node.ref.remove()
                call TriggerReferencedList(node.trig).updateExpression()
                
                set node = node.next
            endloop
            
            call clear()
        endmethod
        
        private static method init takes nothing returns nothing
            //! runtextmacro INITIALIZE_TABLE_FIELD("trig")
            //! runtextmacro INITIALIZE_TABLE_FIELD("ref")
        endmethod
        
        implement Init
    endstruct
    
    /*
    *   List of triggers current trigger references
    */
    private struct TriggerReferenceList extends array
        method add takes TriggerReferencedList trig returns thistype
            local TriggerReferenceListData node = TriggerReferenceListData(this).enqueue()
            
            /*
            *   Register the trigger as a reference
            */
            set node.trig = trig
            set node.ref = TriggerReferencedList(trig).enqueue()
            set node.ref.trig = this
            set node.ref.ref = node
            
            /*
            *   Add the reference's expression
            *
            *   Add even if null to ensure correct order
            */
            if (TriggerMemory(trig).enabled) then
                set node.expr = TriggerMemory(this).expression.register(TriggerMemory(trig).expression.expression)
            else
				set node.expr = TriggerMemory(this).expression.register(null)
            endif
            
            call TriggerMemory(this).updateTrigger()
            
            /*
            *   Update the expressions of triggers referencing this trigger
            */
            call TriggerReferencedList(this).updateExpression()
            
            /*
            *   Return the reference
            */
            return node
        endmethod
        
        method erase takes nothing returns nothing
            local TriggerReferenceListData node = this          //the node
            set this = node.ref.trig                            //this trigger        
            
            call node.expr.unregister()
            call TriggerMemory(this).updateTrigger()
            call TriggerReferencedList(this).updateExpression()
            
            call node.ref.remove()
            call node.remove()
        endmethod
        
        method replace takes TriggerMemory trig returns nothing
            local TriggerReferenceListData node = this
            set this = node.list
            
            call node.ref.remove()
            
            set node.trig = trig
            set node.ref = TriggerReferencedList(trig).enqueue()
            set node.ref.trig = this
            set node.ref.ref = node
            
            if (trig.enabled) then
                call node.expr.replace(trig.expression.expression)
            else
                call node.expr.replace(null)
            endif
            
            call TriggerMemory(this).updateTrigger()
            
            call TriggerReferencedList(this).updateExpression()
        endmethod
        
        /*
        *   Purges all references
        */
        method purge takes nothing returns nothing
            local TriggerReferenceListData node = TriggerReferenceListData(this).first
            
            loop
                exitwhen node == 0
                
                /*
                *   Removes the reference from the referenced list
                *   (triggers no longer referenced by this)
                */
                call node.ref.remove()
                
                set node = node.next
            endloop
            
            /*
            *   Destroy all references by triggers referencing this
            */
            call TriggerReferencedList(this).purge()
            
            call TriggerReferenceListData(this).destroy()
        endmethod
        
        method clearReferences takes nothing returns nothing
            local TriggerReferenceListData node = TriggerReferenceListData(this).first
            
            loop
                exitwhen node == 0
                
                /*
                *   Removes the reference from the referenced list
                *   (triggers no longer referenced by this)
                */
                call node.ref.remove()
				
				/*
				*	unregisters code
				*/
				call node.expr.unregister()
                
                set node = node.next
            endloop
            
            call TriggerReferenceListData(this).clear()
        endmethod
    endstruct
    
    private struct TriggerReferenceData extends array
        static if DEBUG_MODE then
            //! runtextmacro CREATE_TABLE_FIELD("private", "boolean", "isTriggerReference", "boolean")
        endif
        
        static method create takes TriggerReferenceList origin, TriggerMemory ref returns thistype
            local thistype this = origin.add(ref)
            
            debug set isTriggerReference = true
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,                "Trigger", "destroy", "TriggerReferenceData", this, "Attempted To Destroy Null TriggerReferenceData.")
            debug call ThrowError(not isTriggerReference,   "Trigger", "destroy", "TriggerReferenceData", this, "Attempted To Destroy Invalid TriggerReferenceData.")
            
            debug set isTriggerReference = false
            
            call TriggerReferenceList(this).erase()
        endmethod
        
        method replace takes Trigger trig returns nothing
            debug call ThrowError(this == 0,                "Trigger", "destroy", "TriggerReferenceData", this, "Attempted To Destroy Null TriggerReferenceData.")
            debug call ThrowError(not isTriggerReference,   "Trigger", "destroy", "TriggerReferenceData", this, "Attempted To Destroy Invalid TriggerReferenceData.")
            
            call TriggerReferenceList(this).replace(trig)
        endmethod
        
        private static method init takes nothing returns nothing
            static if DEBUG_MODE then
                //! runtextmacro INITIALIZE_TABLE_FIELD("isTriggerReference")
            endif
        endmethod
        
        implement Init
    endstruct
    
	private struct TriggerConditionDataCollection extends array
		implement UniqueNxListT
	endstruct
	
    private struct TriggerConditionData extends array
        static if DEBUG_MODE then
            //! runtextmacro CREATE_TABLE_FIELD("private", "boolean", "isCondition", "boolean")
        endif
        
        //! runtextmacro CREATE_TABLE_FIELD("private", "integer", "trig", "TriggerMemory")
        
        private static method updateTrigger takes TriggerMemory trig returns nothing
            call trig.updateTrigger()
            call TriggerReferencedList(trig).updateExpression()
        endmethod
    
        static method create takes TriggerMemory trig, boolexpr expression returns thistype
            local thistype this = trig.expression.register(expression)
            
            set this.trig = trig
            
            debug set isCondition = true
			
			call TriggerConditionDataCollection(trig).enqueue(this)
            
            call updateTrigger(trig)
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,        "Trigger", "destroy", "TriggerConditionData", this, "Attempted To Destroy Null TriggerConditionData.")
            debug call ThrowError(not isCondition,  "Trigger", "destroy", "TriggerConditionData", this, "Attempted To Destroy Invalid TriggerConditionData.")
            
            call BooleanExpression(this).unregister()
			
			call TriggerConditionDataCollection(this).remove()
            
            debug set isCondition = false
            
            /*
            *   Update the expression
            */
            call updateTrigger(trig)
        endmethod
        
        method replace takes boolexpr expr returns nothing
            debug call ThrowError(this == 0,        "Trigger", "destroy", "TriggerConditionData", this, "Attempted To Destroy Null TriggerConditionData.")
            debug call ThrowError(not isCondition,  "Trigger", "destroy", "TriggerConditionData", this, "Attempted To Destroy Invalid TriggerConditionData.")
            
            call BooleanExpression(this).replace(expr)
            
            call updateTrigger(trig)
        endmethod
		
        private static method init takes nothing returns nothing
            static if DEBUG_MODE then
                //! runtextmacro INITIALIZE_TABLE_FIELD("isCondition")
            endif
            
            //! runtextmacro INITIALIZE_TABLE_FIELD("trig")
        endmethod
        
        implement Init
    endstruct
    
    struct TriggerReference extends array
        method destroy takes nothing returns nothing
            call TriggerReferenceData(this).destroy()
        endmethod
        method replace takes Trigger trig returns nothing
            call TriggerReferenceData(this).replace(trig)
        endmethod
    endstruct
    
    struct TriggerCondition extends array
        method destroy takes nothing returns nothing
            call TriggerConditionData(this).destroy()
        endmethod
        method replace takes boolexpr expr returns nothing
            call TriggerConditionData(this).replace(expr)
        endmethod
    endstruct
    
    struct Trigger extends array
        static if DEBUG_MODE then
            //! runtextmacro CREATE_TABLE_FIELD("private", "boolean", "isTrigger", "boolean")
        endif
    
        static method create takes boolean reversed returns thistype
            local thistype this = TriggerAllocator.allocate()
            
            debug set isTrigger = true
            
            set TriggerMemory(this).enabled = true
            
            call TriggerReferencedList(this).clear()
            call TriggerReferenceListData(this).clear()
			call TriggerConditionDataCollection(this).clear()
            
            set TriggerMemory(this).expression = BooleanExpression.create(reversed)
            
            set TriggerMemory(this).trig = CreateTrigger()
            
            return this
        endmethod
		
		static if DEBUG_MODE then
			method destroy takes nothing returns nothing
				call destroy_p()
			endmethod
		
			private method destroy_p takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "destroy", "Trigger", this, "Attempted To Destroy Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "destroy", "Trigger", this, "Attempted To Destroy Invalid Trigger.")
				
				debug set isTrigger = false
			
				call TriggerReferenceList(this).purge()
				call TriggerConditionDataCollection(this).destroy()
				
				if (TriggerMemory(this).tc != null) then
					call TriggerRemoveCondition(TriggerMemory(this).trig, TriggerMemory(this).tc)
				endif
				call TriggerMemory(this).tc_clear()
				call DestroyTrigger(TriggerMemory(this).trig)
				call TriggerMemory(this).trig_clear()
				
				call TriggerMemory(this).expression.destroy()
				
				call TriggerAllocator(this).deallocate()
			endmethod
		else
			method destroy takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "destroy", "Trigger", this, "Attempted To Destroy Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "destroy", "Trigger", this, "Attempted To Destroy Invalid Trigger.")
				
				debug set isTrigger = false
			
				call TriggerReferenceList(this).purge()
				call TriggerConditionDataCollection(this).destroy()
				
				if (TriggerMemory(this).tc != null) then
					call TriggerRemoveCondition(TriggerMemory(this).trig, TriggerMemory(this).tc)
				endif
				call TriggerMemory(this).tc_clear()
				call DestroyTrigger(TriggerMemory(this).trig)
				call TriggerMemory(this).trig_clear()
				
				call TriggerMemory(this).expression.destroy()
				
				call TriggerAllocator(this).deallocate()
			endmethod
		endif

		static if DEBUG_MODE then
			method register takes boolexpr expression returns TriggerCondition
				return register_p(expression)
			endmethod
			private method register_p takes boolexpr expression returns TriggerCondition
				debug call ThrowError(this == 0,            "Trigger", "register", "Trigger", this, "Attempted To Register To Null Trigger.")
				debug call ThrowError(not isTrigger,        "Trigger", "register", "Trigger", this, "Attempted To Register To Invalid Trigger.")
			
				/*
				*   Register the expression
				*/
				return TriggerConditionData.create(this, expression)
			endmethod
		else
			method register takes boolexpr expression returns TriggerCondition
				debug call ThrowError(this == 0,            "Trigger", "register", "Trigger", this, "Attempted To Register To Null Trigger.")
				debug call ThrowError(not isTrigger,        "Trigger", "register", "Trigger", this, "Attempted To Register To Invalid Trigger.")
			
				/*
				*   Register the expression
				*/
				return TriggerConditionData.create(this, expression)
			endmethod
		endif
        
		static if DEBUG_MODE then
			method clear takes nothing returns nothing
				call clear_p()
			endmethod
			private method clear_p takes nothing returns nothing
				local TriggerConditionDataCollection node = TriggerConditionDataCollection(this).first
			
				debug call ThrowError(this == 0,        "Trigger", "clear", "Trigger", this, "Attempted To Clear Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clear", "Trigger", this, "Attempted To Clear Invalid Trigger.")
				
				loop
					exitwhen node == 0
					
					call BooleanExpression(node).unregister()
					
					set node = node.next
				endloop
				
				call TriggerConditionDataCollection(this).clear()
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		else
			method clear takes nothing returns nothing
				local TriggerConditionDataCollection node = TriggerConditionDataCollection(this).first
			
				debug call ThrowError(this == 0,        "Trigger", "clear", "Trigger", this, "Attempted To Clear Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clear", "Trigger", this, "Attempted To Clear Invalid Trigger.")
				
				loop
					exitwhen node == 0
					
					call BooleanExpression(node).unregister()
					
					set node = node.next
				endloop
				
				call TriggerConditionDataCollection(this).clear()
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		endif
		
		static if DEBUG_MODE then
			method clearReferences takes nothing returns nothing
				call clearReferences_p()
			endmethod
			private method clearReferences_p takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear References Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear References Of Invalid Trigger.")
				
				call TriggerReferenceList(this).clearReferences()
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		else
			method clearReferences takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear References Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear References Of Invalid Trigger.")
				
				call TriggerReferenceList(this).clearReferences()
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		endif
        
		static if DEBUG_MODE then
			method clearBackReferences takes nothing returns nothing
				call clearBackReferences_p()
			endmethod
			
			private method clearBackReferences_p takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear Back References Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear Back References Of Invalid Trigger.")
				
				call TriggerReferencedList(this).clearReferences()
			endmethod
		else
			method clearBackReferences takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear Back References Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearReferences", "Trigger", this, "Attempted To Clear Back References Of Invalid Trigger.")
				
				call TriggerReferencedList(this).clearReferences()
			endmethod
		endif
        
		static if DEBUG_MODE then
			method reference takes thistype trig returns TriggerReference
				return reference_p(trig)
			endmethod
			
			private method reference_p takes thistype trig returns TriggerReference
				debug call ThrowError(this == 0,            "Trigger", "reference", "Trigger", this, "Attempted To Make Null Trigger Reference Trigger.")
				debug call ThrowError(not isTrigger,        "Trigger", "reference", "Trigger", this, "Attempted To Make Invalid Trigger Reference Trigger.")
				debug call ThrowError(trig == 0,            "Trigger", "reference", "Trigger", this, "Attempted To Reference Null Trigger (" + I2S(trig) + ").")
				debug call ThrowError(not trig.isTrigger,   "Trigger", "reference", "Trigger", this, "Attempted To Reference Invalid Trigger (" + I2S(trig) + ").")
				
				return TriggerReferenceData.create(this, trig)
			endmethod
		else
			method reference takes thistype trig returns TriggerReference
				debug call ThrowError(this == 0,            "Trigger", "reference", "Trigger", this, "Attempted To Make Null Trigger Reference Trigger.")
				debug call ThrowError(not isTrigger,        "Trigger", "reference", "Trigger", this, "Attempted To Make Invalid Trigger Reference Trigger.")
				debug call ThrowError(trig == 0,            "Trigger", "reference", "Trigger", this, "Attempted To Reference Null Trigger (" + I2S(trig) + ").")
				debug call ThrowError(not trig.isTrigger,   "Trigger", "reference", "Trigger", this, "Attempted To Reference Invalid Trigger (" + I2S(trig) + ").")
				
				return TriggerReferenceData.create(this, trig)
			endmethod
		endif
		
		static if DEBUG_MODE then
			method clearEvents takes nothing returns nothing
				call clearEvents_p()
			endmethod
			
			private method clearEvents_p takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearEvents", "Trigger", this, "Attempted To Clear Events Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearEvents", "Trigger", this, "Attempted To Clear Events Of Invalid Trigger.")
			
				if (TriggerMemory(this).tc != null) then
					call TriggerRemoveCondition(TriggerMemory(this).trig, TriggerMemory(this).tc)
				endif
				call DestroyTrigger(TriggerMemory(this).trig)
				
				set TriggerMemory(this).trig = CreateTrigger()
				if (TriggerMemory(this).enabled) then
					set TriggerMemory(this).tc = TriggerAddCondition(TriggerMemory(this).trig, TriggerMemory(this).expression.expression)
				else
					call TriggerMemory(this).tc_clear()
				endif
			endmethod
		else
			method clearEvents takes nothing returns nothing
				debug call ThrowError(this == 0,        "Trigger", "clearEvents", "Trigger", this, "Attempted To Clear Events Of Null Trigger.")
				debug call ThrowError(not isTrigger,    "Trigger", "clearEvents", "Trigger", this, "Attempted To Clear Events Of Invalid Trigger.")
			
				if (TriggerMemory(this).tc != null) then
					call TriggerRemoveCondition(TriggerMemory(this).trig, TriggerMemory(this).tc)
				endif
				call DestroyTrigger(TriggerMemory(this).trig)
				
				set TriggerMemory(this).trig = CreateTrigger()
				if (TriggerMemory(this).enabled) then
					set TriggerMemory(this).tc = TriggerAddCondition(TriggerMemory(this).trig, TriggerMemory(this).expression.expression)
				else
					call TriggerMemory(this).tc_clear()
				endif
			endmethod
		endif
        
        method fire takes nothing returns nothing
            debug call ThrowError(this == 0,        "Trigger", "fire", "Trigger", this, "Attempted To Fire Null Trigger.")
            debug call ThrowError(not isTrigger,    "Trigger", "fire", "Trigger", this, "Attempted To Fire Invalid Trigger.")
        
            call TriggerEvaluate(TriggerMemory(this).trig)
        endmethod
        
        method operator trigger takes nothing returns trigger
            debug call ThrowError(this == 0,        "Trigger", "trigger", "Trigger", this, "Attempted To Read Null Trigger.")
            debug call ThrowError(not isTrigger,    "Trigger", "trigger", "Trigger", this, "Attempted To Read Invalid Trigger.")
        
            return TriggerMemory(this).trig
        endmethod
        
        method operator enabled takes nothing returns boolean
            debug call ThrowError(this == 0,                                "Trigger", "enabled", "Trigger", this, "Attempted To Read Null Trigger.")
            debug call ThrowError(not isTrigger,                            "Trigger", "enabled", "Trigger", this, "Attempted To Read Invalid Trigger.")
            
            return TriggerMemory(this).enabled
        endmethod
		
		static if DEBUG_MODE then
			method operator enabled= takes boolean enable returns nothing
				set enabled_p = enable
			endmethod
			private method operator enabled_p= takes boolean enable returns nothing
				debug call ThrowError(this == 0,                                "Trigger", "enabled=", "Trigger", this, "Attempted To Set Null Trigger.")
				debug call ThrowError(not isTrigger,                            "Trigger", "enabled=", "Trigger", this, "Attempted To Set Invalid Trigger.")
				debug call ThrowWarning(TriggerMemory(this).enabled == enable,  "Trigger", "enabled=", "Trigger", this, "Setting Enabled To Its Value.")
			
				set TriggerMemory(this).enabled = enable
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		else
			method operator enabled= takes boolean enable returns nothing
				debug call ThrowError(this == 0,                                "Trigger", "enabled=", "Trigger", this, "Attempted To Set Null Trigger.")
				debug call ThrowError(not isTrigger,                            "Trigger", "enabled=", "Trigger", this, "Attempted To Set Invalid Trigger.")
				debug call ThrowWarning(TriggerMemory(this).enabled == enable,  "Trigger", "enabled=", "Trigger", this, "Setting Enabled To Its Value.")
			
				set TriggerMemory(this).enabled = enable
				
				call TriggerMemory(this).updateTrigger()
				call TriggerReferencedList(this).updateExpression()
			endmethod
		endif
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                return /*
				*/	TriggerAllocator.calculateMemoryUsage() + /*
				*/	TriggerConditionDataCollection.calculateMemoryUsage() + /*
				*/	TriggerReferenceListData.calculateMemoryUsage() + /*
				*/	TriggerReferencedList.calculateMemoryUsage() + /*
				*/	BooleanExpression.calculateMemoryUsage()
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                return /*
				*/	"(Trigger)[" + TriggerAllocator.getAllocatedMemoryAsString() + "], " + /*
				*/	"(Trigger TriggerConditionDataCollection)[" + TriggerConditionDataCollection.getAllocatedMemoryAsString() + "], " + /*
				*/	"(Trigger Reference)[" + TriggerReferenceListData.getAllocatedMemoryAsString() + "], " + /*
				*/	"(Trigger Reference Back)[" + TriggerReferencedList.getAllocatedMemoryAsString() + "], " + /*
				*/	"(Boolean Expression (all))[" + BooleanExpression.getAllocatedMemoryAsString() + "]"
            endmethod
        endif
        
        private static method init takes nothing returns nothing
            static if DEBUG_MODE then
                //! runtextmacro INITIALIZE_TABLE_FIELD("isTrigger")
            endif
        endmethod
        
        implement Init
    endstruct
endlibrary