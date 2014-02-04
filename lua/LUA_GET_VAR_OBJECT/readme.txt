makes object creation via lua a little easier as it does the jass portion for you

creates a variable with the name you assign it and stores a dynamically generated object id for use in your map

For example
constant integer UNITS_PEASANT='hpea' 

If the object already exists, it'll return the existing id.

LUA_OBJECT_ID
LUA_FILE_HEADER