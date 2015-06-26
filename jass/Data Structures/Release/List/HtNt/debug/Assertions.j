//! import "Data\\Element.j"
//! import "Data\\Collection.j"
//! import "Data\\Flags.j"

//! import "ErrorMessages.j"

private function AssertNull takes string operationName, Element element returns nothing
	call ThrowError(IsNull(element), 				"ListHtNt", operationName, "ListHtNt", element, ErrorMessage.ACCESS_NULL)
endfunction

private function AssertElement takes string operationName, Element element returns nothing
	call AssertNull(operationName, element)
	
	call ThrowError(IsCollection(element), 			"ListHtNt", operationName, "ListHtNt", element, ErrorMessage.ACCESS_COLLECTION)
	call ThrowError(not IsElement(element), 		"ListHtNt", operationName, "ListHtNt", element, ErrorMessage.ACCESS_INVALID_ELEMENT)
endfunction

private function AssertCollection takes string operationName, Collection collection returns nothing
	call AssertNull(operationName, collection)
	
	call ThrowError(IsElement(collection), 			"ListHtNt", operationName, "ListHtNt", collection, ErrorMessage.ACCESS_ELEMENT)
	call ThrowError(not IsCollection(collection), 	"ListHtNt", operationName, "ListHtNt", collection, ErrorMessage.ACCESS_INVALID_COLLECTION)
endfunction

private function AssertCollectionNotEmpty takes string operationName, Collection collection returns nothing
	call AssertCollection(operationName, collection)
	
	call ThrowError(IsNull(collection.first), 		"ListHtNt", operationName, "ListHtNt", collection, ErrorMessage.ACCESS_EMPTY)
endfunction