/*
*	Assertions
*
********************************************************************************************
*
*	DEBUG ONLY					*/static if DEBUG_MODE and LIBRARY_ErrorMessage then/*
*/
	private function AssertNull takes string operationName, integer node returns nothing
		call ThrowError(IsNull(node), 				"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_NULL)
	endfunction
	
	private function AssertAllocated takes string operationName, integer node, integer flag returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(not IsAllocated(flag), 		"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_INVALID_ELEMENT)
	endfunction

	private function AssertElement takes string operationName, integer node, integer flag returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(IsCollection(flag), 		"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_COLLECTION)
		call ThrowError(not IsElement(flag), 		"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_INVALID_ELEMENT)
	endfunction

	private function AssertCollection takes string operationName, integer node, integer flag returns nothing
		call AssertNull(operationName, node)
		
		call ThrowError(IsElement(flag), 			"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_ELEMENT)
		call ThrowError(not IsCollection(flag), 	"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_INVALID_COLLECTION)
	endfunction

	private function AssertCollectionNotEmpty takes string operationName, integer node, integer flag, integer first returns nothing
		call AssertCollection(operationName, node, flag)
		
		call ThrowError(IsNull(first), 				"ListHN", operationName, "ListHN", node, ErrorMessage.ACCESS_EMPTY)
	endfunction
/*
*******************************************************************************************/

endif