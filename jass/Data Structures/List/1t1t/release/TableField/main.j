library TableField /* v1.0.0.3
************************************************************************************
*
*	*/ uses /*
*
*		*/ Table	/*
*		*/ Init		/*
*
************************************************************************************
*
*	//! textmacro CREATE_TABLE_FIELD takes ACCESS_MODIFIER, TYPE, NAME, RETURN_TYPE
*		-	creates a table field surrounded by method operators
*
*		name, name=, name_clear(), name_has
*
*	//! textmacro INITIALIZE_TABLE_FIELD takes NAME
*		-	initializes table field
*		-	used in onInit
*
*	//! textmacro CREATE_TABLE_FIELD_ARRAY takes TYPE, NAME, RETURN_TYPE
*		-	creates a struct that acts as an array
*		-	not used in a struct
*
*		name[index], name[index]=, name.has(index), name.clear()
*
*	//! textmacro USE_TABLE_FIELD_ARRAY takes ACCESS_MODIFIER, NAME
*		-	creates a field of a struct array
*		-	used in a struct
*
************************************************************************************/
	//! textmacro CREATE_TABLE_FIELD takes ACCESS_MODIFIER, TYPE, NAME, RETURN_TYPE
		private static Table pt__$NAME$
			
		$ACCESS_MODIFIER$ method operator $NAME$ takes nothing returns $RETURN_TYPE$
			return pt__$NAME$.$TYPE$[this]
		endmethod
		$ACCESS_MODIFIER$ method operator $NAME$= takes $RETURN_TYPE$ value returns nothing
			set pt__$NAME$.$TYPE$[this] = value
		endmethod
		$ACCESS_MODIFIER$ method $NAME$_clear takes nothing returns nothing
			call pt__$NAME$.$TYPE$.remove(this)
		endmethod
		$ACCESS_MODIFIER$ method operator $NAME$_has takes nothing returns boolean
			return pt__$NAME$.$TYPE$.has(this)
		endmethod
	//! endtextmacro
	
	//! textmacro CREATE_TABLE_FIELD_ARRAY takes TYPE, NAME, RETURN_TYPE
		private struct pt__T$NAME$ extends array
			private static Table table
			
			method operator [] takes integer index returns $RETURN_TYPE$
				return table.$TYPE$[index]
			endmethod
			method operator []= takes integer index, $RETURN_TYPE$ value returns nothing
				set table.$TYPE$[index] = value
			endmethod
			static method has takes integer index returns boolean
				call table.has(index)
			endmethod
			static method remove takes integer index returns nothing
				call table.$TYPE$.remove(index)
			endmethod
			static method clear takes nothing returns nothing
				call table.flush()
			endmethod
			
			private static method init takes nothing returns nothing
				set table = Table.create()
			endmethod
			
			implement Init
		endstruct
	//! endtextmacro
	
	//! textmacro USE_TABLE_FIELD_ARRAY takes ACCESS_MODIFIER, NAME
		$ACCESS_MODIFIER$ static pt__T$NAME$ $NAME$ = 0
	//! endtextmacro
	
	//! textmacro INITIALIZE_TABLE_FIELD takes NAME
		set pt__$NAME$ = Table.create()
	//! endtextmacro
endlibrary