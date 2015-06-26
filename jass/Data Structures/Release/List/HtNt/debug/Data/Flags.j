//! import "Element.j"
//! import "Collection.j"

private function IsElement takes Element element returns boolean
	return element.toCollection != 0
endfunction

private function IsCollection takes Collection collection returns boolean
	return collection.isCollection
endfunction

private constant function IsNull takes Element element returns boolean
	return element == 0
endfunction

private function IsAllocated takes Element element returns boolean
	return IsElement(element) or IsCollection(element)
endfunction