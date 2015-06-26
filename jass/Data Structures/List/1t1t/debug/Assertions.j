/*
*	Assertions
*
********************************************************************************************
*
*	IMPORTS
*/
	//! import "List\HtNt\data\Node.j"
	//! import "List\HtNt\data\Element.j"
	//! import "List\HtNt\data\Collection.j"
	
	//! import "List\HtNt\debug\ErrorMessages.j"
/*
********************************************************************************************
*
*	DEBUG ONLY					*/static if DEBUG_MODE and LIBRARY_ErrorMessage then/*
*/
	private function AssertNull takes string operationName, Node node returns nothing
		call ThrowError(node.isNull, 				"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_NULL)
	endfunction
	
	private function AssertAllocated takes string operationName, Node node returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(not node.allocated, 		"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_INVALID_ELEMENT)
	endfunction

	private function AssertElement takes string operationName, Node node returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(node.isCollection, 			"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_COLLECTION)
		call ThrowError(not node.isElement, 		"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_INVALID_ELEMENT)
	endfunction

	private function AssertCollection takes string operationName, Node node returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(node.isElement, 			"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_ELEMENT)
		call ThrowError(not node.isCollection, 		"ListHtNt", operationName, "ListHtNt", node, ErrorMessage.ACCESS_INVALID_COLLECTION)
	endfunction

	private function AssertCollectionNotEmpty takes string operationName, Collection collection returns nothing
		call AssertCollection(operationName, collection)
		
		call ThrowError(collection.first.isNull, 	"ListHtNt", operationName, "ListHtNt", collection, ErrorMessage.ACCESS_EMPTY)
	endfunction
/*
*******************************************************************************************/

endif