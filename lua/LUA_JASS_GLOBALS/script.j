//JassGlobals 1.0.0.0
//! externalblock extension=lua FileExporter $FILENAME$
    //! runtextmacro LUA_FILE_HEADER()
    //! i writelua("JassGlobals", [[
    //////////////////////////////////////////////////////////////////
    //code
    
    //! i dofile("StringFindLine")
    //! i dofile("StringTrim")
    //! i dofile("StringExplode")
    
    //! i if (jass == nil) then
        //! i jass = {}
    //! i end
    
    //! i function jass.create(str)
        //! i local jass = {}
        //! i jass.codes = str:trim()
        
        //! i jass.code = function(val)
            //! i if (val == nil) then
                //! i return jass.codes
            //! i else
                //! i jass.codes = val
            //! i end
        //! i end

        //! i return jass
    //! i end
    
    //! i jass.variable = {}
    //! i function jass.variable.create(type, name, value)
        //! i return {type=type, name=name, value=value, tostring=jass.variable.tostring}
    //! i end

    //! i function string:tovariable()
        //! i local indexstart,indexend = self:find("=")

        //! i local val
        //! i local name
        //! i local types = ""

        //! i local t
        //! i local i

        //! i if (indexstart ~= nil) then
            //! i val = self:sub(indexend+1, self:len()):trim(true)
            //! i self = self:sub(1, indexstart-1):trim()
        //! i end

        //! i t = self:explode(" ")

        //! i if (#t > 2) then
            //! i i = 1
            //! i name = t[#t]

            //! i while (true) do
                //! i types = types .. t[i]
                //! i i = i + 1
                //! i if (i == #t) then
                    //! i break
                //! i else
                    //! i types = types .. " "
                //! i end
            //! i end
        //! i else
            //! i return nil
        //! i end
        //! i return jass.variable.create(types, name, val)
    //! i end

    //! i function jass.variable:tostring()
        //! i local s = ""
        //! i if (self ~= nil and type(self) == "table" and self.type ~= nil) then
            //! i s = self.type .. " " .. self.name
            //! i if (self.value ~= nil) then
                //! i s = s .. "=" .. self.value
            //! i end
        //! i end
        //! i return s
    //! i end

    //! i jass.globals = {}
    //! i function jass.globals.create(self)
        //! i if (self ~= nil and type(self) == "string") then
            //! i self = jass.create(self)
        //! i else
            //! i self = self or jass.create("")
        //! i end

        //! i self.globals = {}
        //! i self.globals.jass = self

        //! i self = self.globals

        //! i self.code = function(val)
            //! i return self.jass.code(val)
        //! i end

        //! i function self:rip()
            //! i local code = self.code()

            //! i indexstart,indexend = code:find("globals\/\/globals.+\nendglobals\/\/endglobals")
            //! i return code:sub(indexstart+string.len("globals\/\/globals\n"), indexend-string.len("\nendglobals\/\/endglobals")), code:sub(indexend+1)
        //! i end

        //! i function self:read(name)
            //! i local line
            //! i local indexstart
            //! i local indexend = 1

            //! i local linet
            //! i local indexstartt
            //! i local indexendt
            //! i local indexstart2
            //! i local indexend2
            //! i local code = self.code()

            //! i indexstart2,indexend2 = code:find("globals\/\/globals.+endglobals\/\/endglobals")

            //! i local val
            //! i local types

            //! i local var

            //! i while(true) do
                //! i line, indexstart, indexend = code:findline(name, false, indexend)
                //! i if (line == nil) then
                    //! i types = nil
                    //! i name = nil
                    //! i val = nil
                    //! i indexstart = nil
                    //! i indexend = nil
                    //! i break
                //! i end

                //! i if (indexstart > indexstart2 and indexend < indexend2) then
                    //! i indexstartt,indexendt = line:find(name)
                    //! i linet = line:sub(indexstartt, indexendt)

                    //! i if (linet:match("=") == nil) then
                        //! i if (line:match("=") ~= nil) then
                            //! i val = line:match("=.+"):sub(2):trim(true)
                        //! i end
                        //! i types = line:sub(1, indexstartt-2):trim(true)
                        //! i break
                    //! i end
                //! i end
            //! i end

            //! i return jass.variable.create(types, name, val), indexstart, indexend
        //! i end

        //! i function self:write(name, var)
            //! i if (var ~= nil and type(var) == "string") then
                //! i var = var:tovariable()
            //! i end

            //! i local code = self.code()
            //! i local indexstart
            //! i local indexend
            //! i local str

            //! i if (name ~= nil) then
                //! i _, indexstart, indexend = self:read(name)
            //! i end

            //! i if (indexstart == nil) then
                //! i indexstart,indexend = code:find("endglobals\/\/endglobals")
                //! i indexend = indexstart
                //! i indexstart = indexend - 1
            //! i else
                //! i indexstart = indexstart - 1
            //! i end

            //! i if (var ~= nil) then
                //! i str = var:tostring()
            //! i else
                //! i str = ""
            //! i end

            //! i self.code(code:sub(1, indexstart) .. str .. "\n" .. code:sub(indexend))
            //! i self.code(self.code():trim())
        //! i end

        //! i local code = self.code()

        //! i if (code:match("globals\/\/globals") == nil) then
            //! i self.code("globals\/\/globals\nendglobals\/\/endglobals\n" .. self.code())
        //! i end

        //! i return self
    //! i end

    //end code
    //////////////////////////////////////////////////////////////////
    //! i ]])
//! endexternalblock