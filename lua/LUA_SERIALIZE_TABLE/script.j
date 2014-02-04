//SerializeTable

/*
   lua-users.org/wiki/SaveTableToFile

   Save Table to File/Stringtable
   Load Table from File/Stringtable
   v 0.94
   
   Lua 5.1 compatible
   
   Userdata and indices of these are not saved
   Functions are saved via string.dump, so make sure it has no upvalues
   References are saved
   ----------------------------------------------------
   table.save( table [, filename] )
   
   Saves a table so it can be called via the table.load function again
   table must a object of type 'table'
   filename is optional, and may be a string representing a filename or true/1
   
   table.save( table )
      on success: returns a string representing the table (stringtable)
      (uses a string as buffer, ideal for smaller tables)
   table.save( table, true or 1 )
      on success: returns a string representing the table (stringtable)
      (uses io.tmpfile() as buffer, ideal for bigger tables)
   table.save( table, "filename" )
      on success: returns 1
      (saves the table to file "filename")
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   table.load( filename or stringtable )
   
   Loads a table that has been saved via the table.save function
   
   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   
   chillcode, lua-users.org/wiki/SaveTableToFile
   Licensed under the same terms as Lua itself.
*/

//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("SerializeTable", [[
    //////////////////////////////////////////////////////////////////
    //code

    //! i do
        //declare local variables
        //exportstring( string )
        //returns a "Lua" portable version of the string
        //! i local function exportstring( s )
            //! i s = string.format( "%q",s )
            //to replace
            //! i s = string.gsub( s,"\\\n","\\n" )
            //! i s = string.gsub( s,"\r","\\r" )
            //! i s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
            //! i return s
        //! i end
        //The Save Function
        //! i function table.save(  tbl,filename )
            //! i local charS,charE = "   ","\n"
            //! i local file,err
            // create a pseudo file that writes to a string and return the string
            //! i if not filename then
                //! i file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
                //! i charS,charE = "",""
            //write table to tmpfile
            //! i elseif filename == true or filename == 1 then
                //! i charS,charE,file = "","",io.tmpfile()
            //write table to file
            //use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
            //! i else
                //! i file,err = io.open( filename, "w" )
                //! i if err then return _,err end
            //! i end
            //initiate variables for save procedure
            //! i local tables,lookup = { tbl },{ [tbl] = 1 }
            //! i file:write( "return {"..charE )
            //! i for idx,t in ipairs( tables ) do
                //! i if filename and filename ~= true and filename ~= 1 then
                    //! i file:write( "-- Table: {"..idx.."}"..charE )
                //! i end
                //! i file:write( "{"..charE )
                //! i local thandled = {}
                //! i for i,v in ipairs( t ) do
                    //! i thandled[i] = true
                    //escape functions and userdata
                    //! i if type( v ) ~= "userdata" then
                        //only handle value
                        //! i if type( v ) == "table" then
                            //! i if not lookup[v] then
                                //! i table.insert( tables, v )
                                //! i lookup[v] = #tables
                            //! i end
                            //! i file:write( charS.."{"..lookup[v].."},"..charE )
                        //! i elseif type( v ) == "function" then
                            //! i file:write( charS.."loadstring("..exportstring(string.dump( v )).."),"..charE )
                        //! i else
                            //! i local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
                            //! i file:write(  charS..value..","..charE )
                        //! i end
                    //! i end
                //! i end
                //! i for i,v in pairs( t ) do
                    //escape functions and userdata
                    //! i if (not thandled[i]) and type( v ) ~= "userdata" then
                        //handle index
                        //! i if type( i ) == "table" then
                            //! i if not lookup[i] then
                                //! i table.insert( tables,i )
                                //! i lookup[i] = #tables
                            //! i end
                            //! i file:write( charS.."[{"..lookup[i].."}]=" )
                        //! i else
                            //! i local index = ( type( i ) == "string" and "["..exportstring( i ).."]" ) or string.format( "[%d]",i )
                            //! i file:write( charS..index.."=" )
                        //! i end
                        //handle value
                        //! i if type( v ) == "table" then
                            //! i if not lookup[v] then
                                //! i table.insert( tables,v )
                                //! i lookup[v] = #tables
                            //! i end
                            //! i file:write( "{"..lookup[v].."},"..charE )
                        //! i elseif type( v ) == "function" then
                            //! i file:write( "loadstring("..exportstring(string.dump( v )).."),"..charE )
                        //! i else
                            //! i local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
                            //! i file:write( value..","..charE )
                        //! i end
                    //! i end
                //! i end
                //! i file:write( "},"..charE )
            //! i end
            //! i file:write( "}" )
            //Return Values
            //return stringtable from string
            //! i if not filename then
                //set marker for stringtable
                //! i return file.str.."--|"
            //return stringttable from file
            //! i elseif filename == true or filename == 1 then
                //! i file:seek ( "set" )
                //no need to close file, it gets closed and removed automatically
                //set marker for stringtable
                //! i return file:read( "*a" ).."--|"
           //close file and return 1
           //! i else
              //! i file:close()
              //! i return 1
           //! i end
        //! i end

        //The Load Function
        //! i function table.load( sfile )
            //catch marker for stringtable
            //! i if string.sub( sfile,-3,-1 ) == "--|" then
                //! i tables,err = loadstring( sfile )
            //! i else
                //! i tables,err = loadfile( sfile )
            //! i end
            //! i if err then return _,err
            //! i end
            //! i tables = tables()
            //! i for idx = 1,#tables do
                //! i local tolinkv,tolinki = {},{}
                //! i for i,v in pairs( tables[idx] ) do
                    //! i if type( v ) == "table" and tables[v[1] ] then
                            //! i table.insert( tolinkv,{ i,tables[v[1] ] } )
                    //! i end
                    //! i if type( i ) == "table" and tables[i[1] ] then
                            //! i table.insert( tolinki,{ i,tables[i[1] ] } )
                    //! i end
                //! i end
                //link values, first due to possible changes of indices
                //! i for _,v in ipairs( tolinkv ) do
                    //! i tables[idx][v[1] ] = v[2]
                //! i end
                //link indices
                //! i for _,v in ipairs( tolinki ) do
                    //! i tables[idx][v[2] ],tables[idx][v[1] ] =  tables[idx][v[1] ],nil
                //! i end
            //! i end
            //! i return tables[1]
        //! i end
    //close do
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock