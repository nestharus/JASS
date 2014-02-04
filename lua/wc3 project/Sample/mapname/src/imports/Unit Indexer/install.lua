--require "GetVarObject"

--local id = getvarobject("Adef", "abilities", "ABILITIES_UNIT_INDEXER", true)

setobjecttype("abilities")
createobject("Adef", "test")
makechange(current, "aart", " ")
makechange(current, "arac", "0")
makechange(current, "anam", "Unit Indexer")
resetobject(current)

--updateobjects()
