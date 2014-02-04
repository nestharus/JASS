struct UniqueQueue extends array
    implement UniqueQueue
endstruct
struct UniqueStack extends array
    implement UniqueStack
endstruct

struct TreeTester extends array
    /*
    *   readonly string string
    *   readonly integer size
    */
    implement Tree
    
    string identifier
    
    private method insertEx takes string identifier returns thistype
        local thistype node = insert()
        
        set node.identifier = identifier
        
        return node
    endmethod
    
    private method breadthfirst takes nothing returns string
        local UniqueQueue queue = UniqueQueue.create()
        local thistype node
        
        local string s = ""
        
        call queue.enqueue(this)
        
        loop
            set this = queue.first
            exitwhen this == 0
            call queue.pop()
            
            set node = children
            loop
                exitwhen node == 0

                call queue.enqueue(node)

                set node = node.next
            endloop
            
            //
            //  Code
            //
            if (s != "") then
                set s = s + ", "
            endif
            set s = s + identifier
        endloop
        
        call queue.destroy()
        
        return s
    endmethod
    
    private method depthfirsti takes nothing returns string
        local UniqueStack stack = UniqueStack.create()
        local thistype node
        
        local string s = ""
        
        call stack.push(this)
        
        loop
            set this = stack.first
            exitwhen this == 0
            call stack.pop()
            
            set node = lastChild
            loop
                exitwhen node == 0
                
                call stack.push(node)
                
                set node = node.prev
            endloop
            
            //
            //  Code
            //
            if (s != "") then
                set s = s + ", "
            endif
            set s = s + identifier
        endloop
        
        return s
    endmethod
    
    private method depthfirst takes string s, integer maxDepth returns string
        local thistype node = children
        
        //
        //  Atom Code (1, 1.1, 1.1.1, 1.1.2, 1.2, etc)
        //
        if (s != "") then
            set s = s + ", "
        endif
        set s = s + identifier
        
        if (maxDepth > 0) then
            loop
                exitwhen node == 0
                
                //
                //  Collection Joining Code
                //
                set s = node.depthfirst(s, maxDepth - 1)
                
                set node = node.next
            endloop
        endif
        
        //
        //  Atom Code (1.1.1, 1.1.2, 1.1, 1.2, 1, etc)
        //
        //      used for in-order and post-order
        //
        
        return s
    endmethod
    
    private static method init takes nothing returns nothing
        local thistype tree = create()
        
        local thistype c1 = tree.insertEx("1")
            local thistype c1_1 = c1.insertEx("1.1")
        local thistype c2 = tree.insertEx("2")
        local thistype c3 = tree.insertEx("3")
            local thistype c3_1 = c3.insertEx("3.1")
            local thistype c3_2 = c3.insertEx("3.2")
                local thistype c3_2_1 = c3_2.insertEx("3.2.1")
                    local thistype c3_2_1_1 = c3_2_1.insertEx("3.2.1.1")
        local thistype c4 = tree.insertEx("4")
        local thistype c5 = tree.insertEx("5")
        
        set tree.identifier = "root"
        
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, tree.breadthfirst())
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, tree.depthfirst("", 5000))
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, tree.depthfirsti())
        
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
        
        call c3.destroy()
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
        
        call c1_1.destroy()
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
        
        call c4.destroy()
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
        
        call c5.destroy()
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
        
        call tree.destroy()
        //call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,tree.string)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Memory Usage: " + I2S(calculateMemoryUsage()))
    endmethod
    
    private static method init0 takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        call init.execute()
    endmethod

    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init0)
    endmethod
    
    private method operator string takes nothing returns string
        local string base = identifier + "("
        local string s = base
        local thistype node = children
        
        loop
            exitwhen node == sentinel
            
            if (s != base) then
                set s = s + ", "
            endif
            
            set s = s + node.string
            
            set node = node.next
        endloop
        
        return s + ")"
    endmethod
    
    private method operator size takes nothing returns integer
        local integer sz = 0
        local thistype node = children
        
        loop
            exitwhen node == sentinel
            
            set sz = sz + node.size
            
            set node = node.next
        endloop
        
        return sz + 1
    endmethod
endstruct