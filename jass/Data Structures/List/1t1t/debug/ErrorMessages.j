/*
*	Assertions
*
********************************************************************************************
*
*	DEBUG ONLY					*/static if DEBUG_MODE and LIBRARY_ErrorMessage then/*
*/
	private struct ErrorMessage extends array
		public static constant string ACCESS_NULL 				= "Attempted To Access Null Element."
		public static constant string ACCESS_COLLECTION 		= "Attempted To Access Collection, Expecting Element."
		public static constant string ACCESS_ELEMENT 			= "Attempted To Access Element, Expecting Collection."
		public static constant string ACCESS_INVALID_ELEMENT 	= "Attempted To Access Invalid Element."
		public static constant string ACCESS_INVALID_COLLECTION	= "Attempted To Access Invalid Collection."
		public static constant string ACCESS_EMPTY				= "Attempted To Access Empty Collection."
	endstruct
/*
*******************************************************************************************/

endif