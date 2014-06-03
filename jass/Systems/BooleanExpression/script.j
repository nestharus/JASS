library BooleanExpression /* v1.1.0.0
************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*
*		*/ ListT		/*
*		*/ NxStackT		/*
*		*/ AllocT		/*
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
*				-	rebuilds expression if expression was modified
*				-	will break triggers unless the expression is removed/added again
*
*				Examples:	call booleanExpression.register(myCode)
*							call TriggerRemoveCondition(thisTrigger, theOneCondition)
*							set theOneCondition = TriggerAddCondition(thisTrigger, booleanExpression.expression)
*
*		Methods
*		-------------------------
*
*			static method create takes boolean reversed returns BooleanExpression
*				-	when reverse is true, the entire expression is run in reverse
*
*			method destroy takes nothing returns nothing
* 
*			method register takes boolexpr expression returns BooleanExpression
*			method unregister takes nothing returns nothing
*
*			method replace takes boolexpr expression returns nothing
*				-	replaces the boolexpr inside of the registered expression
*				-	useful for updating expressions without breaking order
*
*			method clear takes nothing returns nothing
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	globals
		private constant boolean DEBUG_LOG = false
	endglobals
	
	static if DEBUG_LOG then
		private function print takes string m returns nothing
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, m)
		endfunction
	endif
	
	private keyword ListExpression
	private keyword NodeExpression
	
	scope NodeExpressionScope
		private struct Node extends array
			static if DEBUG_LOG then
				private static integer idCount = 0
				private integer id
			endif
		
			/*
			*	Tree Fields
			*/
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "root", "thistype")
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "left", "thistype")
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "right", "thistype")
			
			/*
			*	List Fields
			*/
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "next", "thistype")
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "prev", "thistype")
			
			/*
			*	Standard Fields
			*/
			//! runtextmacro CREATE_TABLE_FIELD("public", "boolexpr", "expression", "boolexpr")
			//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "canDestroy", "boolean")
			
			//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "reversed", "boolean")
			//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "list", "ListExpression")
			
			/*
			*	static method allocate takes nothing returns thistype
			*	method deallocate takes nothing returns nothing
			*/
			implement AllocT
			
			static method create takes ListExpression list, boolean reversed returns thistype
				local thistype this = allocate()
				
				set this.reversed = reversed
				set this.list = list
			
				static if DEBUG_LOG then
					set idCount = idCount + 1
					set id = idCount
				endif
				
				return this
			endmethod
			
			/*
			*	Destroy all nodes within tree, clears, only used for complete tree destruction
			*/
			method destroySub takes nothing returns nothing
				/*
				*	Destroy/Clear List Node
				*/
				if (left == 0) then
					set root = 0
					set next = 0
					set prev = 0
				/*
				*	Destroy/Clear Tree Node
				*/
				else
					if (canDestroy) then
						set canDestroy = false
						call DestroyBoolExpr(expression)
					endif
				
					set left.root = 0
					call left.destroySub()
					set left = 0
					
					set right.root = 0
					call right.destroySub()
					set right = 0
				endif
				
				call expression_clear()
				
				call deallocate()
			endmethod
			
			/*
			*	Joins two trees under a new root
			*	Returns new root
			*/
			static method join takes Node left, Node right returns Node
				local Node this = Node.create(left.list, left.reversed)
				
				set this.left = left
				set this.right = right
				set left.root = this
				set right.root = this
				
				if (right.expression == null) then
					if (left.expression == null) then
						call expression_clear()
					else
						set expression = left.expression
					endif
				elseif (left.expression == null) then
					set expression = right.expression
				else
					set canDestroy = true
					set expression = Or(left.expression, right.expression)
				endif
				
				return this
			endmethod
			
			static method joinReverse takes Node left, Node right returns Node
				local Node this = Node.create(left.list, left.reversed)
				
				static if DEBUG_LOG then
					call print("joinReverse: (" + I2S(left.id) + ")R(" + I2S(right.id) + ")")
				endif
				
				set this.left = left
				set this.right = right
				set left.root = this
				set right.root = this
				
				if (right.expression == null) then
					if (left.expression == null) then
						call expression_clear()
					else
						set expression = left.expression
					endif
				elseif (left.expression == null) then
					set expression = right.expression
				else
					set canDestroy = true
					set expression = Or(right.expression, left.expression)
				endif
				
				static if DEBUG_LOG then
					call print("joinReverse Result: (" + this.toString())
				endif
				
				return this
			endmethod
			
			/*
			*	Joins the list nodes of
			*
			*		Tree/Node
			*		Node/Node
			*/
			static method listJoin takes Node tree, Node node returns nothing
				debug call ThrowError(tree == 0, "BooleanExpression.NodeExpressionScope", "listJoin", "Node", 0, "Attempted To Join With Null Tree " + "(" + I2S(tree) + ").")
				debug call ThrowError(node == 0, "BooleanExpression.NodeExpressionScope", "listJoin", "Node", 0, "Attempted To Join With Null Node " + "(" + I2S(node) + ").")
				
				loop
					exitwhen tree.right == 0
					set tree = tree.right
				endloop
				
				set tree.next = node
				set node.prev = tree
			endmethod
			
			/*
			*	Splits a tree, returning the left piece
			*/
			method splitLeft takes nothing returns Node
				local thistype left = this.left
				
				debug call ThrowError(left == 0, "BooleanExpression.NodeExpressionScope", "splitLeft", "Node", this, "Attempted To Split Node, Expecting Tree.")
				debug call ThrowError(root != 0, "BooleanExpression.NodeExpressionScope", "splitLeft", "Node", this, "Attempted To Split Child Tree, Expecting Tree.")
				
				if (canDestroy) then
					set canDestroy = false
					call DestroyBoolExpr(expression)
				endif
				
				call expression_clear()
				
				set right.root = 0
				set left.root = 0
				set this.left = 0
				set right = 0
				
				call deallocate()
				
				return left
			endmethod
			
			/*
			*	Returns malformed tree or 0
			*	Takes a node
			*/
			method remove takes nothing returns Node
				local thistype node = next
				
				local thistype nextRoot = next.root
				local thistype currentRoot = root
				
				local boolean isRight = currentRoot.right == this
				
				local thistype lastNode = 0
				
				local thistype replacer
				
				debug call ThrowError(left != 0 or right != 0, "BooleanExpression.NodeExpressionScope", "remove", "Node", this, "Attempted To Remove Tree, Expecting Node.")
				
				if (node != 0) then
					loop
						set lastNode = node
						
						set node.root = currentRoot
						
						/*
						*	Set new child of root
						*/
						if (currentRoot != 0) then
							if (isRight) then
								set currentRoot.right = node
							else
								set currentRoot.left = node
							endif
							
							set isRight = not isRight
						endif
						
						/*
						*	Replace boolean expressions along tree
						*/
						set replacer = node.root
						loop
							exitwhen replacer == 0
							
							if (replacer.canDestroy) then
								set replacer.canDestroy = false
								call DestroyBoolExpr(replacer.expression)
							endif
							
							if (replacer.right.expression == null) then
								if (replacer.left.expression == null) then
									call replacer.expression_clear()
								else
									set replacer.expression = replacer.left.expression
								endif
							elseif (replacer.left.expression == null) then
								set replacer.expression = replacer.right.expression
							else
								set replacer.canDestroy = true
								set replacer.expression = Or(replacer.left.expression, replacer.right.expression)
							endif
							
							set replacer = replacer.root
						endloop
						
						set currentRoot = nextRoot
						set node = node.next
						exitwhen node == 0
						set nextRoot = node.root
					endloop
					
					/*
					*	Clear Last Position If There Is One
					*/
					if (currentRoot != 0) then
						if (isRight) then
							set currentRoot.right = 0
						else
							set currentRoot.left = 0
						endif
					endif
					
					/*
					*	Remove from list
					*/
					set next.prev = prev
					
					if (prev != 0) then
						set prev.next = next
						set prev = 0
					endif
					
					set next = 0
				elseif (prev != 0) then
					/*
					*	Remove from list partial
					*/
					set prev.next = next
					set prev = 0
				endif
				
				/*
				*	Get last added tree (may be removed null)
				*/
				if (lastNode == 0) then
					set lastNode = root
				endif
				loop
					exitwhen lastNode.root == 0
					set lastNode = lastNode.root
				endloop
				
				/*
				*	Remove from tree
				*/
				if (root.left == this) then
					set root.left = 0
				elseif (root.right == this) then
					set root.right = 0
				endif
				set root = 0
				
				/*
				*	Destroy removed node
				*/
				call expression_clear()
				
				call deallocate()
				
				/*
				*	Return last added tree
				*/
				return lastNode
			endmethod
			
			method removeReverse takes nothing returns Node
				local thistype node = next
				
				local thistype nextRoot = next.root
				local thistype currentRoot = root
				
				local boolean isRight = currentRoot.right == this
				
				local thistype lastNode = 0
				
				local thistype replacer
				
				debug call ThrowError(left != 0 or right != 0, "BooleanExpression.NodeExpressionScope", "remove", "Node", this, "Attempted To Remove Tree, Expecting Node.")
				
				static if DEBUG_LOG then
					call print("removeReverse: " + I2S(id))
				endif
				
				if (node != 0) then
					loop
						set lastNode = node
						
						set node.root = currentRoot
						
						/*
						*	Set new child of root
						*/
						if (currentRoot != 0) then
							if (isRight) then
								set currentRoot.right = node
							else
								set currentRoot.left = node
							endif
							
							set isRight = not isRight
						endif
						
						/*
						*	Replace boolean expressions along tree
						*/
						set replacer = node.root
						loop
							exitwhen replacer == 0
							
							if (replacer.canDestroy) then
								set replacer.canDestroy = false
								call DestroyBoolExpr(replacer.expression)
							endif
							
							if (replacer.right.expression == null) then
								if (replacer.left.expression == null) then
									call replacer.expression_clear()
								else
									set replacer.expression = replacer.left.expression
								endif
							elseif (replacer.left.expression == null) then
								set replacer.expression = replacer.right.expression
							else
								set replacer.canDestroy = true
								set replacer.expression = Or(replacer.right.expression, replacer.left.expression)
							endif
							
							set replacer = replacer.root
						endloop
						
						set currentRoot = nextRoot
						set node = node.next
						exitwhen node == 0
						set nextRoot = node.root
					endloop
					
					/*
					*	Clear Last Position If There Is One
					*/
					if (currentRoot != 0) then
						if (isRight) then
							set currentRoot.right = 0
						else
							set currentRoot.left = 0
						endif
					endif
					
					/*
					*	Remove from list
					*/
					set next.prev = prev
					
					if (prev != 0) then
						set prev.next = next
						set prev = 0
					endif
					
					set next = 0
				elseif (prev != 0) then
					/*
					*	Remove from list partial
					*/
					set prev.next = next
					set prev = 0
				endif
				
				/*
				*	Get last added tree (may be removed null)
				*/
				if (lastNode == 0) then
					set lastNode = root
				endif
				loop
					exitwhen lastNode.root == 0
					set lastNode = lastNode.root
				endloop
				
				/*
				*	Remove from tree
				*/
				if (root.left == this) then
					set root.left = 0
				elseif (root.right == this) then
					set root.right = 0
				endif
				set root = 0
				
				/*
				*	Destroy removed node
				*/
				call expression_clear()
				
				call deallocate()
				
				/*
				*	Return last added tree
				*/
				
				static if DEBUG_LOG then
					call print("removeReverse Result: " + lastNode.toString())
				endif
				
				return lastNode
			endmethod
			
			method replace takes boolexpr expression returns nothing
				if (expression == null) then
					call this.expression_clear()
				else
					set this.expression = expression
				endif
				loop
					exitwhen root == 0
					set this = root
					
					if (this.canDestroy) then
						set this.canDestroy = false
						call DestroyBoolExpr(this.expression)
					endif
					if (right.expression == null) then
						if (left.expression == null) then
							call this.expression_clear()
						else
							set this.expression = left.expression
						endif
					elseif (left.expression == null) then
						set this.expression = right.expression
					else
						set this.canDestroy = true
						set this.expression = Or(left.expression, right.expression)
					endif
				endloop
			endmethod
			
			method replaceReverse takes boolexpr expression returns nothing
				static if DEBUG_LOG then
					call print("replaceReverse: " + I2S(id))
				endif
			
				if (expression == null) then
					call this.expression_clear()
				else
					set this.expression = expression
				endif
				loop
					exitwhen root == 0
					set this = root
					
					if (this.canDestroy) then
						set this.canDestroy = false
						call DestroyBoolExpr(this.expression)
					endif
					if (right.expression == null) then
						if (left.expression == null) then
							call this.expression_clear()
						else
							set this.expression = left.expression
						endif
					elseif (left.expression == null) then
						set this.expression = right.expression
					else
						set this.canDestroy = true
						set this.expression = Or(right.expression, left.expression)
					endif
				endloop
			endmethod
			
			private static method init takes nothing returns nothing
				//! runtextmacro INITIALIZE_TABLE_FIELD("root")
				//! runtextmacro INITIALIZE_TABLE_FIELD("left")
				//! runtextmacro INITIALIZE_TABLE_FIELD("right")
				//! runtextmacro INITIALIZE_TABLE_FIELD("next")
				//! runtextmacro INITIALIZE_TABLE_FIELD("prev")
				//! runtextmacro INITIALIZE_TABLE_FIELD("expression")
				//! runtextmacro INITIALIZE_TABLE_FIELD("canDestroy")
				//! runtextmacro INITIALIZE_TABLE_FIELD("reversed")
				//! runtextmacro INITIALIZE_TABLE_FIELD("list")
			endmethod
			
			static if DEBUG_LOG then
				method toString takes nothing returns string
					if (this == 0) then
						return ""
					endif
					
					if (left != 0 or right != 0) then
						return "(" + left.toString() + ")" + I2S(id) + "R(" + right.toString() + ")"
					else
						return "(" + left.toString() + ")" + I2S(id) + "C(" + right.toString() + ")"
					endif
				endmethod
			endif
			
			implement Init
		endstruct
		
		struct NodeExpression extends array
			method operator root takes nothing returns thistype
				return Node(this).root
			endmethod
			method operator left takes nothing returns thistype
				return Node(this).left
			endmethod
			method operator right takes nothing returns thistype
				return Node(this).right
			endmethod
			method operator next takes nothing returns thistype
				return Node(this).next
			endmethod
			method operator prev takes nothing returns thistype
				return Node(this).prev
			endmethod
			method operator expression takes nothing returns boolexpr
				return Node(this).expression
			endmethod
			method operator expression= takes boolexpr expression returns nothing
				set Node(this).expression = expression
			endmethod
			
			static method create takes ListExpression list, boolean reversed, boolexpr expression returns thistype
				local Node node = Node.create(list, reversed)
				set node.expression = expression
				return node
			endmethod
			method destroy takes nothing returns nothing
				call Node(this).destroySub()
			endmethod
			
			static method join takes Node left, Node right returns thistype
				return Node.join(left, right)
			endmethod
			static method joinReverse takes Node left, Node right returns thistype
				return Node.joinReverse(left, right)
			endmethod
			static method listJoin takes Node prev, Node next returns nothing
				call Node.listJoin(prev, next)
			endmethod
			
			method splitLeft takes nothing returns thistype
				return Node(this).splitLeft()
			endmethod
			
			method remove takes nothing returns thistype
				return Node(this).remove()
			endmethod
			method removeReverse takes nothing returns thistype
				return Node(this).removeReverse()
			endmethod
			
			method operator top takes nothing returns thistype
				loop
					exitwhen Node(this).root == 0
					set this = Node(this).root
				endloop
				
				return this
			endmethod
			method replace takes boolexpr expression returns nothing
				call Node(this).replace(expression)
			endmethod
			method replaceReverse takes boolexpr expression returns nothing
				call Node(this).replaceReverse(expression)
			endmethod
			
			static if DEBUG_MODE then
				static method calculateMemoryUsage takes nothing returns integer
					return Node.calculateMemoryUsage()
				endmethod
				
				static method getAllocatedMemoryAsString takes nothing returns string
					return Node.getAllocatedMemoryAsString()
				endmethod
			endif
		endstruct
		
		scope ListExpressionScope
			private keyword List_P
			//! runtextmacro CREATE_TABLE_FIELD_ARRAY("integer", "expressionOwner", "List_P")
			
			private struct List_P extends array
				//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "expression", "NodeExpression")
				//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "reversed", "boolean")
				//! runtextmacro USE_TABLE_FIELD_ARRAY("public", "expressionOwner")
				
				implement ListT
				
				private static method init takes nothing returns nothing
					//! runtextmacro INITIALIZE_TABLE_FIELD("expression")
					//! runtextmacro INITIALIZE_TABLE_FIELD("reversed")
				endmethod
				
				implement Init
			endstruct
			
			struct ListExpression extends array
				static method operator sentinel takes nothing returns integer
					return List_P.sentinel
				endmethod
				method operator list takes nothing returns thistype
					return List_P(this).list
				endmethod
				method operator first takes nothing returns thistype
					return List_P(this).first
				endmethod
				method operator last takes nothing returns thistype
					return List_P(this).last
				endmethod
				method operator next takes nothing returns thistype
					return List_P(this).next
				endmethod
				method operator prev takes nothing returns thistype
					return List_P(this).prev
				endmethod
				method operator expression takes nothing returns boolexpr
					return List_P(this).expression.expression
				endmethod
				method operator reversed takes nothing returns boolean
					return List_P(this).reversed
				endmethod
				
				/*
				*	Destroy all trees in list
				*/
				private method clearExpressions takes nothing returns nothing
					local thistype node = first
					
					loop
						exitwhen node == 0
						
						if (List_P(node).expression != 0) then
							call List_P(node).expression.destroy()
							set List_P(node).expression = 0
						endif
						
						set node = node.next
					endloop
				endmethod
				
				static method create takes boolean reverse returns thistype
					local thistype this = List_P.create()
					set List_P(this).reversed = reverse
					call List_P(this).enqueue()
					
					return this
				endmethod
				
				method destroy takes nothing returns nothing
					call clearExpressions()
					set List_P(this).reversed = false
					call List_P(this).destroy()
				endmethod
				
				method clear takes nothing returns nothing
					call clearExpressions()
					call List_P(this).clear()
					call List_P(this).enqueue()
				endmethod
				
				private method operator firstExpression takes nothing returns NodeExpression
					loop
						exitwhen this == 0 or List_P(this).expression != 0
						set this = next
					endloop
					
					return List_P(this).expression
				endmethod
				
				private method insertRegular takes boolexpr expression returns thistype
					local List_P node = first
					local NodeExpression nodeExpression = NodeExpression.create(this, false, expression)
					local NodeExpression firstExpression = thistype(node).firstExpression
					
					if (firstExpression != 0) then
						call NodeExpression.listJoin(firstExpression, nodeExpression)
					endif
					
					/*
					*	If the first node on the list has no expression put expression in node
					*/
					if (node.expression == 0) then
						set node.expression = nodeExpression
						set List_P.expressionOwner[nodeExpression] = node
					/*
					*	If it does have an expression, join expressions
					*/
					else
						set node.expression = NodeExpression.join(node.expression, nodeExpression)
						
						loop
							exitwhen node.next == 0 or node.next.expression == 0
							
							set node.next.expression = NodeExpression.join(node.next.expression, node.expression)
							set node.expression = 0
							
							set node = node.next
						endloop
						
						if (node.next == 0) then
							set List_P(this).enqueue().expression = node.expression
						else
							set node.next.expression = node.expression
						endif
						
						set node.expression = 0
					endif
					
					/*
					*	Used to remove expressions
					*/
					set List_P.expressionOwner[node.next.expression] = node.next
					
					return nodeExpression
				endmethod
				
				private method insertReverse takes boolexpr expression returns thistype
					local List_P node = first
					local NodeExpression nodeExpression = NodeExpression.create(this, true, expression)
					local NodeExpression firstExpression = thistype(node).firstExpression
					
					if (firstExpression != 0) then
						call NodeExpression.listJoin(firstExpression, nodeExpression)
					endif
					
					/*
					*	If the first node on the list has no expression put expression in node
					*/
					if (node.expression == 0) then
						set node.expression = nodeExpression
						set List_P.expressionOwner[nodeExpression] = node
					/*
					*	If it does have an expression, join expressions
					*/
					else
						set node.expression = NodeExpression.joinReverse(node.expression, nodeExpression)
						
						loop
							exitwhen node.next == 0 or node.next.expression == 0
							
							set node.next.expression = NodeExpression.joinReverse(node.next.expression, node.expression)
							set node.expression = 0
							
							set node = node.next
						endloop
						
						if (node.next == 0) then
							set List_P(this).enqueue().expression = node.expression
						else
							set node.next.expression = node.expression
						endif
						
						set node.expression = 0
					endif
					
					/*
					*	Used to remove expressions
					*/
					set List_P.expressionOwner[node.next.expression] = node.next
					
					return nodeExpression
				endmethod
				
				method insert takes boolexpr expression returns thistype
					if (List_P(this).reversed) then
						return insertReverse(expression)
					endif
					
					return insertRegular(expression)
				endmethod
				
				/*
				*	Return owning list
				*/
				private method removeRegular takes nothing returns thistype
					local NodeExpression node = this
					local NodeExpression tree = node.top
					local List_P listNode = List_P.expressionOwner[tree]
					local List_P owner = listNode.list
					
					local boolean isOdd = listNode.list.first.expression != 0	//no need to decompose when odd
					
					set node = node.remove()
					
					if (isOdd) then
						set listNode.list.first.expression = 0
					
						return owner
					else
						/*
						*	Decompose the tree
						*/
						set listNode = List_P.expressionOwner[node.top]
						set listNode.expression = 0
						
						loop
							exitwhen node.left == 0
							set tree = node.right
							set node = node.splitLeft()
							set listNode = listNode.prev
							set listNode.expression = node
							set List_P.expressionOwner[node] = listNode
							set node = tree
						endloop
						
						if (node != 0) then
							set listNode = listNode.prev
							set listNode.next.expression = node
							set List_P.expressionOwner[node] = listNode
						endif
					endif
					
					return owner
				endmethod
				
				private method removeReverse takes nothing returns thistype
					local NodeExpression node = this
					local NodeExpression tree = node.top
					local List_P listNode = List_P.expressionOwner[tree]
					local List_P owner = listNode.list
					
					local boolean isOdd = listNode.list.first.expression != 0	//no need to decompose when odd
					
					set node = node.removeReverse()
					
					if (isOdd) then
						set listNode.list.first.expression = 0
					
						return owner
					else
						/*
						*	Decompose the tree
						*/
						set listNode = List_P.expressionOwner[node.top]
						set listNode.expression = 0
						
						loop
							exitwhen node.left == 0
							set tree = node.right
							set node = node.splitLeft()
							set listNode = listNode.prev
							set listNode.expression = node
							set List_P.expressionOwner[node] = listNode
							set node = tree
						endloop
						
						if (node != 0) then
							set listNode = listNode.prev
							set listNode.next.expression = node
							set List_P.expressionOwner[node] = listNode
						endif
					endif
					
					return owner
				endmethod
				
				method remove takes nothing returns thistype
					if (Node(this).reversed) then
						return removeReverse()
					endif
					
					return removeRegular()
				endmethod
				
				private method replaceRegular takes boolexpr expression returns thistype
					call NodeExpression(this).replace(expression)
					return Node(this).list
					//return List_P.expressionOwner[NodeExpression(this).top].list
				endmethod
				private method replaceReverse takes boolexpr expression returns thistype
					call NodeExpression(this).replaceReverse(expression)
					return Node(this).list
					//return List_P.expressionOwner[NodeExpression(this).top].list
				endmethod
				method replace takes boolexpr expression returns thistype
					if (Node(this).reversed) then
						return replaceReverse(expression)
					endif
					
					return replaceRegular(expression)
				endmethod
				
				static if DEBUG_MODE then
					static method calculateMemoryUsage takes nothing returns integer
						return List_P.calculateMemoryUsage()
					endmethod
					
					static method getAllocatedMemoryAsString takes nothing returns string
						return List_P.getAllocatedMemoryAsString()
					endmethod
				endif
				
				static if DEBUG_LOG then
					method toString takes nothing returns string
						local thistype node = first
						local string s = ""
						
						loop
							exitwhen node == 0
							
							if (s != "") then
								set s = s + " , "
							endif
							
							if (List_P(node).expression == 0) then
								set s = s + "D"
							else
								set s = s + Node(List_P(node).expression).toString()
							endif
							
							set node = node.next
						endloop
						
						return s
					endmethod
				endif
			endstruct
		endscope
	endscope
	
	//! runtextmacro CREATE_TABLE_FIELD_ARRAY("boolexpr", "buffer", "boolexpr")
	private struct BooleanExpressionContainer extends array
		implement NxStackT
		
		//! runtextmacro CREATE_TABLE_FIELD("private", "boolexpr", "expression", "boolexpr")
		//! runtextmacro CREATE_TABLE_FIELD("public", "boolexpr", "top", "boolexpr")
		
		/*
		*	Move the list to an array
		*
		*	Merge slots on the array in pairs
		*/
		//! runtextmacro USE_TABLE_FIELD_ARRAY("private", "buffer")
		private method buildRegular takes nothing returns nothing
			local ListExpression node = ListExpression(this).last
			
			local integer length = 0
			local integer positionStart = 0
			local integer positionEnd
			
			/*
			*	Get length
			*/
			loop
				exitwhen node == 0
				if (node.expression != null) then
					set length = length + 1
				endif
				set node = node.prev
			endloop
			if (length == 0) then
				call top_clear()
			
				return
			endif
			set positionEnd = length
			
			/*
			*	Copy to array
			*/
			set node = ListExpression(this).last
			loop
				exitwhen positionStart == positionEnd
				
				loop
					exitwhen node.expression != null
					set node = node.prev
				endloop
				set buffer[positionStart] = node.expression
				set positionStart = positionStart + 1
				
				
				exitwhen positionStart == positionEnd
				loop
					set node = node.prev
					exitwhen node.expression != null
				endloop
				set positionEnd = positionEnd - 1
				set buffer[positionEnd] = node.expression
				
				set node = node.prev
			endloop
			
			/*
			*	Merge
			*/
			loop
				exitwhen length < 2
				
				set positionStart = 0
				set positionEnd = length - 1
				loop
					set buffer[positionStart] = Or(buffer[positionStart], buffer[positionEnd])
					set push().expression = buffer[positionStart]
					set positionStart = positionStart + 1
					set positionEnd = positionEnd - 1
					
					exitwhen positionStart >= positionEnd
				endloop
				
				if (length - length/2*2 == 0) then
					set length = length/2
				else
					set length = length/2 + 1
				endif
			endloop
			
			set top = buffer[0]
			
			call buffer.clear()
		endmethod
		
		private method buildReverse takes nothing returns nothing
			local ListExpression node = ListExpression(this).last
			
			local integer length = 0
			local integer positionStart = 0
			local integer positionEnd
			
			/*
			*	Get length
			*/
			loop
				exitwhen node == 0
				if (node.expression != null) then
					set length = length + 1
				endif
				set node = node.prev
			endloop
			if (length == 0) then
				call top_clear()
			
				return
			endif
			set positionEnd = length
			
			/*
			*	Copy to array
			*/
			set node = ListExpression(this).last
			loop
				exitwhen positionStart == positionEnd
				
				loop
					exitwhen node.expression != null
					set node = node.prev
				endloop
				set buffer[positionStart] = node.expression
				set positionStart = positionStart + 1
				
				
				exitwhen positionStart == positionEnd
				loop
					set node = node.prev
					exitwhen node.expression != null
				endloop
				set positionEnd = positionEnd - 1
				set buffer[positionEnd] = node.expression
				
				set node = node.prev
			endloop
			
			/*
			*	Merge
			*/
			loop
				exitwhen length < 2
				
				set positionStart = 0
				set positionEnd = length - 1
				loop
					set buffer[positionStart] = Or(buffer[positionEnd], buffer[positionStart])
					set push().expression = buffer[positionStart]
					set positionStart = positionStart + 1
					set positionEnd = positionEnd - 1
					
					exitwhen positionStart >= positionEnd
				endloop
				
				if (length - length/2*2 == 0) then
					set length = length/2
				else
					set length = length/2 + 1
				endif
			endloop
			
			set top = buffer[0]
			
			call buffer.clear()
		endmethod
		
		method build takes nothing returns nothing
			if (ListExpression(this).reversed) then
				call buildReverse()
			else
				call buildRegular()
			endif
		endmethod
		
		method destruct takes nothing returns nothing
			local thistype stack = this
			
			call top_clear()
			set this = first
			
			loop
				exitwhen this == 0
				call DestroyBoolExpr(expression)
				call expression_clear()
				set this = next
			endloop
			
			call stack.clear()
		endmethod
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("expression")
			//! runtextmacro INITIALIZE_TABLE_FIELD("top")
		endmethod
		
		implement Init
	endstruct
	
	struct BooleanExpression extends array
		//! runtextmacro CREATE_TABLE_FIELD("private", "boolean", "modified", "boolean")
		
		static if DEBUG_MODE then
			//! runtextmacro CREATE_TABLE_FIELD("private", "boolean", "isAllocated", "boolean")
		endif
		
		/*
		*	Only rebuild the expression when it is needed, otherwise leave it alone
		*	Rebuilding the expression will break triggers using it plus has a bit of overhead
		*/
		method operator expression takes nothing returns boolexpr
			debug call ThrowError(this == 0,		"BooleanExpression", "expression", "BooleanExpression", this, "Attempted To Read Null Boolean Expression.")
			debug call ThrowError(not isAllocated,	"BooleanExpression", "expression", "BooleanExpression", this, "Attempted To Read Invalid Boolean Expression.")
		
			if (modified) then
				set modified = false
				call BooleanExpressionContainer(this).destruct()
				call BooleanExpressionContainer(this).build()
			endif
			
			return BooleanExpressionContainer(this).top
		endmethod
	
		static method create takes boolean reversed returns thistype
			local thistype this = ListExpression.create(reversed)
			
			call BooleanExpressionContainer(this).clear()
			
			debug set isAllocated = true
			
			return this
		endmethod
		method destroy takes nothing returns nothing
			debug call ThrowError(this == 0,		"BooleanExpression", "destroy", "BooleanExpression", this, "Attempted To Destroy Null Boolean Expression.")
			debug call ThrowError(not isAllocated,	"BooleanExpression", "destroy", "BooleanExpression", this, "Attempted To Destroy Invalid Boolean Expression.")
		
			debug set isAllocated = false
			set modified = false
			call BooleanExpressionContainer(this).destruct()
			call BooleanExpressionContainer(this).destroy()
			call ListExpression(this).destroy()
		endmethod
		
		method clear takes nothing returns nothing
			debug call ThrowError(this == 0,		"BooleanExpression", "clear", "BooleanExpression", this, "Attempted To Clear Null Boolean Expression.")
			debug call ThrowError(not isAllocated,	"BooleanExpression", "clear", "BooleanExpression", this, "Attempted To Clear Invalid Boolean Expression.")
		
			set modified = false
			call BooleanExpressionContainer(this).destruct()
			call ListExpression(this).clear()
		endmethod
		
		method register takes boolexpr expression returns thistype
			debug call ThrowError(this == 0,		"BooleanExpression", "register", "BooleanExpression", this, "Attempted To Register To Null Boolean Expression.")
			debug call ThrowError(not isAllocated,	"BooleanExpression", "register", "BooleanExpression", this, "Attempted To Register To Invalid Boolean Expression.")
			
			set modified = true
			return ListExpression(this).insert(expression)
		endmethod
		method unregister takes nothing returns nothing
			/*
			*	No easy way to do error checking here, will have to let internal resources do it
			*/
			set thistype(ListExpression(this).remove()).modified= true
		endmethod
		
		method replace takes boolexpr expression returns nothing
			set thistype(ListExpression(this).replace(expression)).modified = true
		endmethod
		
		static if DEBUG_MODE then
			static method calculateMemoryUsage takes nothing returns integer
				return NodeExpression.calculateMemoryUsage() + BooleanExpressionContainer.calculateMemoryUsage() + ListExpression.calculateMemoryUsage()
			endmethod
			
			static method getAllocatedMemoryAsString takes nothing returns string
				return "(Node Expression)[" + NodeExpression.getAllocatedMemoryAsString() + "], (List Expression)[" + ListExpression.getAllocatedMemoryAsString() + "], (Boolean Expression Container)[" + BooleanExpressionContainer.getAllocatedMemoryAsString() + "]"
			endmethod
		endif
		
		static if DEBUG_LOG then
			method toString takes nothing returns string
				return ListExpression(this).toString()
			endmethod
			
			method dump takes nothing returns nothing
				call print(toString())
			endmethod
		endif
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("modified")
			
			static if DEBUG_MODE then
				//! runtextmacro INITIALIZE_TABLE_FIELD("isAllocated")
			endif
		endmethod
		
		implement Init
	endstruct
endlibrary