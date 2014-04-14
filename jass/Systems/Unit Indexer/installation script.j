/*
*	This is for World Editor
*
*	You will need to
*
*		1.	Enable This Trigger
*		2.	Save Your Map
*		3.	Close Your Map
*		4.	Open Your Map
*		5.	Disable This Trigger
*		6.	Save Your Map
*/
//! externalblock extension=lua ObjectMerger $FILENAME$
	//! i do
		//! i dofile("GetVarObject")
		
		//! i local id = getvarobject("Adef", "abilities", "ABILITIES_UNIT_INDEXER", true)
		
		//! i createobject("Adef", id)
		//! i makechange(current, "aart", "")
		//! i makechange(current, "arac", "0")
		//! i makechange(current, "anam", "Unit Indexer")
		//! i makechange(current, "ansf", "Unit Indexer")

		//! i updateobjects()
	//! i end
//! endexternalblock

/*
*	This is for a .lua file
*
*	Can run this through command line using grimex exe
*
dofile("GetVarObject")

local id = getvarobject("Adef", "abilities", "ABILITIES_UNIT_INDEXER", true)

createobject("Adef", id)
makechange(current, "aart", "")
makechange(current, "arac", "0")
makechange(current, "anam", "Unit Indexer")
makechange(current, "ansf", "Unit Indexer")

updateobjects()
*/