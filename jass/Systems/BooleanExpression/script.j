library BooleanExpression /* v1.2.0.0
************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*
*		*/ ListT		/*
*		*/ Table		/*
*		*/ Init			/*
*		*/ TableField	/*
*
************************************************************************************
*
*	struct BooleanExpression extends array
*
*		Description
*		-------------------------
*
*			Creates a single boolean expression via Or's
*
*			Provides a slight speed boost
*
*			Allows the for the safe usage of TriggerRemoveCondition given that the only boolexpr on the trigger
*			is the one from this struct
*
*			To put multiple boolean expressions on to one trigger, combine them with Or. Be sure to destroy later.
*
*			Alternatively, they can be wrapped with another BooleanExpression, but this will add overhead. Only use
*			if more than three are planned to be on one trigger.
*
*		Fields
*		-------------------------
*
*			readonly boolexpr expression
*
*				Examples:	call booleanExpression.register(myCode)
*							call TriggerRemoveCondition(thisTrigger, theOneCondition)
*							set theOneCondition = TriggerAddCondition(thisTrigger, booleanExpression.expression)
*
*			boolean reversed
*			-	if this is true, the expression will run in reverse
*
*		Methods
*		-------------------------
*
*			static method create takes boolean reversed returns BooleanExpression
*			-	if reversed is true, the expression will run in reverse
*
*			method destroy takes nothing returns nothing
*			-	only use .destroy with BooleanExpression from .create, not .register
* 
*			method register takes boolexpr expression returns BooleanExpression
*			-	the returned BooleanExpression is a subtype to be used with
*			-	.unregister and .replace
*			method unregister takes nothing returns nothing
*			-	unregisters a BooleanExpression
*			-	only use BooleanExpression from .register, not .create
*
*			method replace takes boolexpr expression returns nothing
*			-	replaces the boolexpr inside of the registered expression
*			-	useful for updating expressions without breaking order
*			-	null expressions take no space and have no overhead, so use them
*			-	only use BooleanExpression from .register, not .create
*
*			method clear takes nothing returns nothing
*			-	only use .clear with BooleanExpression from .create, not .register
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			-	calculates how many instances are currently active
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*			-	returns a list of all active instances as a string
*
************************************************************************************/
	private struct List extends array
		//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "reversed", "boolean")
		
		implement ListT
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("reversed")
		endmethod
		
		implement Init
	endstruct

	private struct TreeNode extends array
		/*
		*	Tree Fields
		*/
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "root", "thistype")
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "left", "thistype")
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "right", "thistype")
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "height", "integer")
		
		/*
		*	Standard Fields
		*/
		//! runtextmacro CREATE_TABLE_FIELD("public", "boolexpr", "expression", "boolexpr")
		//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "canDestroy", "boolean")
		
		///! runtextmacro CREATE_TABLE_FIELD("public", "integer", "list", "ListExpression")
		
		public method operator isData takes nothing returns boolean
			return height == 1
		endmethod
		
		public method operator isNode takes nothing returns boolean
			return height != 1
		endmethod
		
		public method join takes nothing returns nothing
			if (canDestroy) then
				call DestroyBoolExpr(expression)
			endif
			
			if (left.expression == null) then
				set canDestroy = false
				
				if (right.expression == null) then
					call expression_clear()
				else
					set expression = right.expression
				endif
			elseif (right.expression == null) then
				set canDestroy = false
				
				set expression = left.expression
			elseif (List(this).list.reversed) then
				set canDestroy = true
				
				set expression = Or(right.expression, left.expression)
			else
				set canDestroy = true
				
				set expression = Or(left.expression, right.expression)
			endif
		endmethod
		
		public method rebuild takes nothing returns nothing
			if (isNode) then
				call left.rebuild()
				call right.rebuild()
				
				call join()
			endif
		endmethod
		
		public method replace takes boolexpr expression returns nothing
			if (this.expression == expression) then
				return
			endif
		
			if (expression == null) then
				call this.expression_clear()
			else
				set this.expression = expression
			endif
			
			loop
				set this = root
				exitwhen this == 0
				
				call join()
			endloop
		endmethod
		
		public static method create takes List parent returns thistype
			local thistype this = parent.enqueue()
			
			set canDestroy = false
			set height = 1
			
			return this
		endmethod
		
		public static method createData takes List parent returns thistype
			local thistype this = parent.push()
			
			set canDestroy = false
			
			return this
		endmethod
		
		method clean takes nothing returns nothing
			if (canDestroy) then
				call DestroyBoolExpr(expression)
			endif
			
			call expression_clear()
		endmethod
		
		method destroy takes nothing returns nothing
			call clean()
			
			call List(this).remove()
		endmethod
		
		public method operator sibling takes nothing returns thistype
			if (root != 0) then
				if (root.left == this) then
					return root.right
				else
					return root.left
				endif
			endif
			
			return 0
		endmethod
		
		method updateHeight takes nothing returns nothing
			if (left.height > right.height) then
				set height = left.height + 1
			else
				set height = right.height + 1
			endif
		endmethod
		
		method operator factor takes nothing returns integer
			return left.height - right.height
		endmethod
		
		method setRoot takes thistype newNode returns nothing
			local thistype root = this.root
		
			if (root != 0) then
				if (this == root.left) then
					set root.left = newNode
				else
					set root.right = newNode
				endif
			endif
			
			set newNode.root = root
		endmethod
	
		method rotateRight takes nothing returns thistype
			local thistype newRoot = left
			
			call setRoot(newRoot)
			set root = newRoot
			
			set left = newRoot.right
			set left.root = this
			set newRoot.right = this
			
			call updateHeight()
			call newRoot.updateHeight()
			
			call join()
			call newRoot.join()
			
			return newRoot
		endmethod
		
		method rotateLeft takes nothing returns thistype
			local thistype newRoot = right
			
			call setRoot(newRoot)
			set root = newRoot
			
			set right = newRoot.left
			set right.root = this
			set newRoot.left = this
			
			call updateHeight()
			call newRoot.updateHeight()
			
			call join()
			call newRoot.join()
			
			return newRoot
		endmethod
		
		method balance takes nothing returns thistype
			local integer factor
			local thistype node
			
			loop
				call updateHeight()
				
				set factor = this.factor
				
				if (factor > 1) then
					if (left.factor < 0) then
						call left.rotateLeft()
					endif

					set this = rotateRight()

					exitwhen true
				elseif (factor < -1) then
					if (right.factor > 0) then
						call right.rotateRight()
					endif

					set this = rotateLeft()

					exitwhen true
				else
					call join()
				endif
			
				set this = root
				exitwhen this == 0
			endloop
			
			if (this != 0) then
				set node = root
				
				loop
					exitwhen node == 0
					
					call node.updateHeight()
					call node.join()
					set node = node.root
				endloop
			endif
		
			return this
		endmethod
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("root")
			//! runtextmacro INITIALIZE_TABLE_FIELD("left")
			//! runtextmacro INITIALIZE_TABLE_FIELD("right")
			//! runtextmacro INITIALIZE_TABLE_FIELD("height")
			//! runtextmacro INITIALIZE_TABLE_FIELD("expression")
			//! runtextmacro INITIALIZE_TABLE_FIELD("canDestroy")
		endmethod
		
		implement Init
	endstruct
	
	private struct Tree extends array
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "root", "TreeNode")
		
		public static method create takes boolean reversed returns thistype
			local thistype this = List.create()
			
			set List(this).reversed = reversed
			
			return this
		endmethod
		
		method clear takes nothing returns nothing
			local List node = List(this).first
			
			loop
				exitwhen node == 0
				
				call TreeNode(node).clean()
				
				set node = node.next
			endloop
			
			call List(this).clear()
			
			call root_clear()
		endmethod
		
		method destroy takes nothing returns nothing
			call clear()
			
			call List(this).destroy()
		endmethod
		
		method operator reversed takes nothing returns boolean
			return List(this).reversed
		endmethod
		
		method operator reversed= takes boolean b returns nothing
			if (b == reversed) then
				return
			endif
			
			set List(this).reversed = b
			
			if (root != 0) then
				call root.rebuild()
			endif
		endmethod
		
		method updateRoot takes TreeNode node returns nothing
			if (node != 0 and node.root == 0) then
				set this.root = node
			endif
		endmethod
		
		method insert takes boolexpr expression returns TreeNode
			local TreeNode sibling = List(this).last
			local TreeNode node = TreeNode.create(this)
			local TreeNode root = 0
			local TreeNode grandroot = 0
			
			if (expression != null) then
				set node.expression = expression
			endif
			
			if (sibling != 0) then
				set root = TreeNode.createData(this)
				set grandroot = sibling.root
				
				set root.left = sibling
				set root.right = node
				set node.root = root
				set sibling.root = root
				set root.height = 2
				set root.root = grandroot
				
				call root.join()
				
				if (grandroot != 0) then
					set grandroot.right = root
					
					call updateRoot(grandroot.balance())
				else
					set this.root = root
				endif
			else
				set this.root = node
				call node.root_clear()
			endif
			
			call node.left_clear()
			call node.right_clear()
			
			return node
		endmethod
		
		method delete takes TreeNode node returns nothing
			local TreeNode sibling = node.sibling
			local TreeNode root = node.root
			local TreeNode grandroot
			
			if (root != 0) then
				set grandroot = root.root
			endif
			
			if (sibling != 0) then
				if (sibling.isData) then
					set sibling.root = grandroot
					
					if (grandroot != 0) then
						if (grandroot.left == root) then
							set grandroot.left = sibling
						else
							set grandroot.right = sibling
						endif
						
						call updateRoot(grandroot.balance())
					else
						set this.root = sibling
					endif
					
					call root.destroy()
				else
					set root.left = sibling.left
					set root.right = sibling.right
					call root.updateHeight()
					call root.join()
					
					if (sibling.left != 0) then
						set sibling.left.root = root
					endif
					if (sibling.right != 0) then
						set sibling.right.root = root
					endif
					
					call sibling.destroy()
					
					if (grandroot != 0) then
						call updateRoot(grandroot.balance())
					endif
				endif
			else
				set this.root = 0
			endif
			
			call node.destroy()
		endmethod
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("root")
		endmethod
		
		implement Init
	endstruct
	
	struct BooleanExpression extends array
		method operator expression takes nothing returns boolexpr
			debug call ThrowError(not List(this).isList,	"BooleanExpression", "expression", "BooleanExpression", this, "Attempted To Read Null Boolean Expression.")
			
			if (Tree(this).root != 0) then
				return Tree(this).root.expression
			endif
			
			return null
		endmethod
		
		method operator reversed takes nothing returns boolean
			debug call ThrowError(not List(this).isList,	"BooleanExpression", "reversed", "BooleanExpression", this, "Attempted To Read Null Boolean Expression.")
			
			return Tree(this).reversed
		endmethod
		
		method operator reversed= takes boolean b returns nothing
			debug call ThrowError(not List(this).isList,	"BooleanExpression", "reversed", "BooleanExpression", this, "Attempted To Set Null Boolean Expression.")
			
			set Tree(this).reversed = b
		endmethod
		
		static method create takes boolean reversed returns thistype
			return Tree.create(reversed)
		endmethod
		
		method destroy takes nothing returns nothing
			debug call ThrowError(not List(this).isList,	"BooleanExpression", "reversed", "BooleanExpression", this, "Attempted To Destroy Null Boolean Expression.")
			call Tree(this).destroy()
		endmethod
		
		method register takes boolexpr expression returns BooleanExpression
			return Tree(this).insert(expression)
		endmethod
		
		method unregister takes nothing returns nothing
			debug call ThrowError(not TreeNode(this).isData,	"BooleanExpression", "unregister", "BooleanExpression", this, "Attempted To Unregister Null Boolean Expression.")
			call Tree(List(this).list).delete(this)
		endmethod
		
		method replace takes boolexpr expression returns nothing
			debug call ThrowError(not TreeNode(this).isData,	"BooleanExpression", "replace", "BooleanExpression", this, "Attempted To Replace Null Boolean Expression.")
			call TreeNode(this).replace(expression)
		endmethod
		
		method clear takes nothing returns nothing
			debug call ThrowError(not List(this).isList,	"BooleanExpression", "clear", "BooleanExpression", this, "Attempted To Clear Null Boolean Expression.")
			call Tree(this).clear()
		endmethod
		
		private static string indentation = "            "

		static method printEx takes TreeNode node, string indent, boolean height returns nothing
			if (node != 0) then
				call printEx(node.right, indent + indentation, height)
				
				if (height) then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, indent + I2S(node.height))
				else
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, indent + I2S(node))
				endif
				
				call printEx(node.left, indent + indentation, height)
			endif
		endmethod
		
		method print takes boolean height returns nothing
			call printEx(Tree(this).root, "", height)
			call DisplayTimedTextFromPlayer(GetLocalPlayer(), 0, 0, 60000, "------------------------------------")
		endmethod
		
		debug static method calculateMemoryUsage takes nothing returns integer
			debug return List.calculateMemoryUsage()
		debug endmethod
		
		debug static method getAllocatedMemoryAsString takes nothing returns string
			debug return List.getAllocatedMemoryAsString()
		debug endmethod
	endstruct
endlibrary