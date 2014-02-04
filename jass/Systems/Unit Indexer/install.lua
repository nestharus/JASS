require "GetVarObject"

local id = getvarobject("Adef", "abilities", "ABILITIES_UNIT_INDEXER", true)

createobject("Adef", id)
makechange(current, "aart", "")
makechange(current, "arac", "0")
makechange(current, "anam", "Unit Indexer")

updateobjects()