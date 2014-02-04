library Cmd uses StringParser
//StringParser hiveworkshop.com/forums/graveyard-418/string-parser-170574/

//Version: 1.2.0.1
//Author: Nestharus

globals
    //COMMAND character is the character a string has to start with to be regarded
    //as a command
    private constant string COMMAND = "-"
    
    //EVAL is the character coupled with a command to turn it into an evaluation statement
    //EVAL+COMMAND
    //default is !-
    private constant string EVAL = "!"
    
    //SHELL will change the current group of eval commands
    //SHELL+COMMAND with arg will change current shell to specified shell. If shell doesn't exist, just disables
    //SHELL+COMMAND alone will output current shell
    //SHELL alone will ouput list of shells
    private constant string SHELL = "#"
endglobals

//Directive API (symbols based on above settings)
//      -command args
//          runs command for trigger player
//
//      -
//          lists commands to trigger player
//
//      #
//          lists shells to trigger player
//
//      #-
//          displays current shell for trigger player to trigger player
//
//      #-shell
//          changes current shell for trigger player
//
//      !-string
//          evaluates string on trigger player's current shell
////////////////////////////////////////////////////////////////////////
//Description
//      Cmd allows you to register commands that players can type in game.
//
//      What makes Cmd unique?
//          1. Has an OO API (Command/Shell objects that implement a module and interface)
//          2. Allows command objects to be enabled/disabled while still running through
//             the same root command (2 command objects for -give and only 1 enabled)
//          3. Full access restriction for each player for each specific command object
//             (admin might get access to an extra feature on the -give command)
//          4. Many command libraries use some freaky array syntax. This one uses
//             a stack.
//          5. Has both regular commands and evaluations
//          6. Has shell support (different evaluations)
//          7. Has a more basic procedural API that does not have access restrictions
////////////////////////////////////////////////////////////////////////
//      Command Interface (auto required when implementing Command)
//          private static constant string COMMAND_NAME
//              The name of the command (cannot be null or "")
//
//          private static constant boolean AUTO_ENABLE
//              Should it auto enable?
//
//          private static constant boolean AUTO_ACCESS
//              Should players automatically be given access?
//
//          private static constant integer MIN_ARGS
//              Minimum args required to run
//
//          private static constant integer MAX_ARGS
//              Maximum args allowed for running (less than 0 is infinite)
//
//          private static method run takes player caller, integer callerId, Args args returns nothing
//              The method that runs when the command is executed
//
//      Shell Interface (auto required when implementing Shell)
//          private static constant boolean AUTO_ACCESS
//              Should players automatically be given access to shell?
//
//          private static constant string SHELL_NAME
//             The name of the shell (cannot be null or ""). Shells cannot be layered.
//
//          private static method run takes player caller, integer callerId, Args args returns nothing
//              The method that runs when the shell is executed
//
//      Command Module
//          This must be implemented into your struct to turn it into a command object
//
//          public static boolean enabled
//              enables and disables the command object
//
//          public static method operator [] takes integer playerId returns boolean
//          public static method operator []= takes integer playerId, boolean canUse returns nothing
//              Gets and sets player access to the command
//
//      Shell Module
//          public static method operator [] takes integer playerId returns boolean
//          public static method operator []= takes integer playerId, boolean canUse returns nothing
//              Gets and sets player access to the shell
//
//      struct Args extends array
//          This is the structure that contains arguments
//          StringParser is suggested for inferring argument types
//          A processing method with static fields is suggested for
//          Processing the arguments into a usable form, otherwise
//          the run method will be messy
//
//          public method operator next takes nothing returns thistype
//              Get the next argument on the stack
//
//              Demo-
//                  set args = args.next
//
//          public method operator value takes nothing returns string
//              Get the value of the argument
//              You can use StringType.typeof and StringType.compare to properly
//              determine whether your method should run or not
//
//          public method operator count takes nothing returns integer
//              Get how many arguments there are left on the stack
//              Useful if your command should only take specific arguments
//
//          public method operator type takes nothing returns integer
//              Returns the data type of the argument (integer, real, etc)
////////////////////////////////////////////////////////////////////////
    //used to create Commands
    private struct CommandX extends array
        private static trigger commandTrigger = CreateTrigger()
        private trigger command
        private trigger eval
        private static integer array curShell
        private string shellName
        private string commandName
        private static hashtable table = InitHashtable()
        
        private static integer instanceCount = 0
        private static integer shellInstanceCount = 0
        private integer cInstanceCount
        
        //public fields
        private integer playerIdX
        private player playerX
        private StringStack argsX
        
        private integer playerIdS
        private player playerS
        private string argsS
        
        public method operator playerIdShell takes nothing returns integer
            return playerIdS
        endmethod
        
        public method operator playerShell takes nothing returns player
            return playerS
        endmethod
        
        public method operator argShell takes nothing returns string
            return argsS
        endmethod
        
        private method operator playerShell= takes player p returns nothing
            set playerS = p
            set playerIdS = GetPlayerId(p)
        endmethod
        
        private method operator argShell= takes string s returns nothing
            set argsS = s
        endmethod
        
        public method operator playerId takes nothing returns integer
            return playerIdX
        endmethod
        
        public method operator player takes nothing returns player
            return playerX
        endmethod
        
        private method operator player= takes player p returns nothing
            set playerX = p
            set playerIdX = GetPlayerId(p)
        endmethod
        
        public method operator args takes nothing returns StringStack
            return argsX
        endmethod
        
        private method operator args= takes StringStack val returns nothing
            set argsX = val
        endmethod
        
        public method isEnabled takes thistype commandId returns boolean
            return HaveSavedHandle(table, commandId, this)
        endmethod
        
        public method enable takes thistype commandId, boolean b returns nothing
            if (this != 0 and HaveSavedHandle(table, commandId, this) != b) then
                if (b) then
                    call SaveTriggerConditionHandle(table, commandId, this, TriggerAddCondition(commandId.command, LoadBooleanExprHandle(table, commandId, this*-1)))
                else
                    call TriggerRemoveCondition(commandId.command, LoadTriggerConditionHandle(table, commandId, this))
                    call RemoveSavedHandle(table, commandId, this)
                endif
            endif
        endmethod
        
        private static method execute takes nothing returns boolean
            local string command
            //filter out any white space
            local string input = String.filter(GetEventPlayerChatString(), " ", true)
            local StringStack args
            local thistype commandStruct
            local integer i
            local player triggerPlayer = GetTriggerPlayer()
            local integer triggerPlayerId = GetPlayerId(triggerPlayer)
            
            //check to see if the beginning of the string is COMMAND
            if (input == SHELL) then
                set i = 1
                loop
                    exitwhen thistype(i).shellName == null
                    call DisplayTextToPlayer(triggerPlayer, 0, 0, "Shell: " + thistype(i).shellName)
                    set i = i + 1
                endloop
            elseif (input == COMMAND) then
                set i = instanceCount
                loop
                    exitwhen i == 0
                    call DisplayTextToPlayer(triggerPlayer, 0, 0, "Command: " + thistype(i).commandName)
                    set i = i - 1
                endloop
            elseif (SubString(input, 0, 1) == COMMAND) then
                //if it is, filter out all COMMAND chars at the start
                set input = String.filter(input, COMMAND, true)
                //create string stack (easier to get command out)
                set args = String.parse(input)
                //first thing on the stack is the command
                set command = StringCase(args.value, false)
                set args = args.pop() //pop off the command
                
                set commandStruct = LoadInteger(table, StringHash(command), 0)
                //if command exists and is enabled then go on
                if (commandStruct > 0) then
                    set commandStruct.player = GetTriggerPlayer()
                    set commandStruct.args = args
                    call TriggerEvaluate(commandStruct.command)
                endif
                call args.destroy()
            //otherwise check to see if it's an evaluation
            //evaluation should only be used for in-game scripting
            elseif (SubString(input, 0, 2) == EVAL+COMMAND and curShell[triggerPlayerId] != 0) then
                //as args is all one string in this case, the command cannot be deciphered
                //the root command is treated as "eval"
                set commandStruct = curShell[triggerPlayerId]
                set commandStruct.playerShell = triggerPlayer
                set commandStruct.argShell = SubString(input, 2, StringLength(input))
                call TriggerEvaluate(commandStruct.eval)
            elseif (SubString(input, 0, 2) == SHELL+COMMAND) then
                set input = String.filter(SubString(input, 2, StringLength(input)), " ", true)
                if (input == null or input == "") then
                    if (curShell[triggerPlayerId] != 0) then
                        call DisplayTextToPlayer(triggerPlayer, 0, 0, "Shell: " + thistype(curShell[triggerPlayerId]).shellName)
                    else
                        call DisplayTextToPlayer(triggerPlayer, 0, 0, "Shell: null")
                    endif
                else
                    set curShell[triggerPlayerId] = LoadInteger(table, 0, StringHash(StringCase(input, false)))
                    debug if (curShell[triggerPlayerId] != 0) then
                        debug call DisplayTextToPlayer(triggerPlayer, 0, 0, "Shell: " + thistype(curShell[triggerPlayerId]).shellName)
                    debug else
                        debug call DisplayTextToPlayer(triggerPlayer, 0, 0, "Shell: null")
                    debug endif
                endif
            endif
            
            set triggerPlayer = null
            return false
        endmethod
            
        public static method operator [] takes string commandName returns integer
            local thistype this = 0
            if (commandName != "" and commandName != null) then
                set this = LoadInteger(table, StringHash(commandName), 0)
                if (this == 0) then
                    set instanceCount = instanceCount + 1
                    set this = instanceCount
                    set command = CreateTrigger()
                    set this.commandName = commandName
                    call SaveInteger(table, StringHash(commandName), 0, this)
                endif
            endif
            return this
        endmethod
        
        public static method registerShell takes string shell, boolexpr c returns integer
            local thistype this = 0
            if (shell != "" and shell != null and not HaveSavedInteger(table, 0, StringHash(shell))) then
                set shellInstanceCount = shellInstanceCount + 1
                set this = shellInstanceCount
                set eval = CreateTrigger()
                call TriggerAddCondition(eval, c)
                call SaveInteger(table, 0, StringHash(shell), this)
                set shellName = shell
            endif
            
            return this
        endmethod
        
        public method register takes boolexpr c returns thistype
            if (this != 0) then
                set cInstanceCount = cInstanceCount + 1
                call SaveBooleanExprHandle(table, this, cInstanceCount*-1, c)
                return cInstanceCount
            endif
            return 0
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i = 12
            local player p
            debug if (COMMAND != EVAL and COMMAND != SHELL and EVAL != SHELL) then
                loop
                    set i = i - 1
                    set p = Player(i)
                    if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER) then
                        call TriggerRegisterPlayerChatEvent(commandTrigger, p, COMMAND, false)
                        call TriggerRegisterPlayerChatEvent(commandTrigger, p, SHELL, true)
                    endif
                    
                    exitwhen i == 0
                endloop
                call TriggerAddCondition(commandTrigger, Condition(function thistype.execute))
            debug else
                debug if (COMMAND == EVAL) then
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Command Library Failure: COMMAND equals EVAL")
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, COMMAND + "==" + EVAL)
                debug endif
                debug if (COMMAND == SHELL) then
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Command Library Failure: COMMAND equals SHELL")
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, COMMAND + "==" + SHELL)
                debug endif
                debug if (EVAL == SHELL) then
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Command Library Failure: EVAL equals SHELL")
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, EVAL + "==" + SHELL)
                debug endif
            debug endif
        endmethod
        
        public static method setShell takes string shell, integer playerId returns nothing
            set curShell[playerId] = LoadInteger(table, 0, StringHash(shell))
        endmethod
    endstruct
    
    struct Args extends array
        public method operator next takes nothing returns thistype
            return StringStack(this).next
        endmethod
        
        public method operator value takes nothing returns string
            return StringStack(this).value
        endmethod
        
        public method operator count takes nothing returns integer
            return StringStack(this).count
        endmethod
        
        public method operator type takes nothing returns StringType
            return StringStack(this).type
        endmethod
    endstruct
    
    module Command
        private static CommandX command
        private static CommandX root
        private static boolean array access
        
        public static method operator enabled takes nothing returns boolean
            return command.isEnabled(root)
        endmethod
        
        public static method operator enabled= takes boolean b returns nothing
            call command.enable(root, b)
        endmethod
        
        public static method operator [] takes integer id returns boolean
            return access[id]
        endmethod
        
        public static method operator []= takes integer id, boolean b returns nothing
            set access[id] = b
        endmethod
        
        private static method execute takes nothing returns boolean
            if (access[root.playerId] and root.args.count >= MIN_ARGS and (MAX_ARGS < 0 or root.args.count <= MAX_ARGS)) then
                call thistype.run(root.player, root.playerId, root.args)
            endif
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i
            
            set root = CommandX[StringCase(String.filter(String.filter(COMMAND_NAME, COMMAND, true), " ", true), false)]
            
            if (root != 0) then
                set command = root.register(Condition(function thistype.execute))
                set enabled = AUTO_ENABLE
                if AUTO_ACCESS then
                    set i = 12
                    loop
                        set i = i - 1
                        set access[i] = AUTO_ACCESS
                        exitwhen i == 0
                    endloop
                endif
            debug else
                debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Command Library Failure: Invalid Command Name")
            endif
        endmethod
    endmodule
    
    module Shell
        private static CommandX shell
        private static boolean array access
        
        public static method operator [] takes integer id returns boolean
            return access[id]
        endmethod
        
        public static method operator []= takes integer id, boolean b returns nothing
            set access[id] = b
        endmethod
        
        private static method execute takes nothing returns boolean
            if (access[shell.playerIdShell]) then
                call thistype.run(shell.playerShell, shell.playerIdShell, shell.argShell)
            endif
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i
            set shell = CommandX.registerShell(StringCase(String.filter(String.filter(SHELL_NAME, COMMAND, true), " ", true), false), Condition(function thistype.execute))
            if shell != 0 and AUTO_ACCESS then
                set i = 12
                loop
                    set i = i - 1
                    set access[i] = AUTO_ACCESS
                    exitwhen i == 0
                endloop
            debug else
                debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Command Library Failure: Invalid Shell Name")
            endif
        endmethod
    endmodule
endlibrary