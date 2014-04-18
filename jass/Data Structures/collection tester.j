module CollectionToTest
    implement Stack
endmodule
globals
    constant boolean IS_CIRCULAR = false
    constant boolean IS_UNIQUE = false
    constant boolean IS_NX = false
    constant boolean IS_SHARED = false
    constant boolean IS_STATIC = false
    constant boolean IS_LIST = false
    constant boolean DISPLAY_OPERATIONS = false
    constant boolean DISPLAY_STATISTICS = false
    constant integer WATCH_COLLECTION = 0
    constant integer WATCH_NODE = 0
endglobals

static if IS_STATIC then
    static if IS_UNIQUE then
        struct Node extends array
            implement Alloc
        endstruct
    endif
elseif IS_SHARED then
    static if IS_UNIQUE then
        struct Node extends array
            implement Alloc
        endstruct
        struct Collection extends array
            static method allocate takes nothing returns thistype
                return Node.allocate()
            endmethod
            method deallocate takes nothing returns nothing
                call Node(this).deallocate()
            endmethod
        endstruct
    elseif IS_NX then
        struct Node extends array
            implement Alloc
        endstruct
        struct Collection extends array
            static method allocate takes nothing returns thistype
                return Node.allocate()
            endmethod
            method deallocate takes nothing returns nothing
                call Node(this).deallocate()
            endmethod
        endstruct
    endif
else
    static if IS_UNIQUE then
        struct Node extends array
            implement Alloc
        endstruct
    endif

    static if IS_NX then
        struct Collection extends array
            implement Alloc
        endstruct
    endif
endif

struct CollectionTester extends array
    implement CollectionToTest
    
    private static integer collectionCount = 0
    private static integer array collections
    private integer count_test
    
    private static boolean removedToEmpty = true
    private static boolean poppedToEmpty = true
    private static boolean dequeuedToEmpty = true
    private static boolean cleared = true
    private static boolean destroyed = IS_STATIC
    private static integer destructionCount = 0
    private static boolean created = IS_STATIC
    private static boolean crashed = false
    
    private static integer testCount = 0
    
    private method operator size takes nothing returns integer
        local integer sz = 0
        local integer sz2 = 0
        local thistype node = first
        
        static if DISPLAY_OPERATIONS then
            local string str = "{"
            static if IS_LIST then
                local string str2 = "{"
            endif
        endif
        
        loop
            static if IS_CIRCULAR then
                exitwhen node.sentinel
            else
                exitwhen node == sentinel
            endif
            
            set sz = sz + 1
            
            static if DISPLAY_OPERATIONS then
                if (str != "{") then
                    set str = str + ", "
                endif
                set str = str + I2S(node)
            endif
            
            set node = node.next
        endloop
        
        static if IS_LIST then
            set node = last
            loop
                static if IS_CIRCULAR then
                    exitwhen node.sentinel
                else
                    exitwhen node == sentinel
                endif
                
                set sz2 = sz2 + 1
                
                static if DISPLAY_OPERATIONS then
                    if (str2 != "{") then
                        set str2 = str2 + ", "
                    endif
                    set str2 = str2 + I2S(node)
                endif
                
                set node = node.prev
            endloop
        else
            set sz2 = sz
        endif
        
        static if DISPLAY_OPERATIONS then
            set str = str + "}"
            if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,str)
                static if IS_LIST then
                    set str2 = str2 + "}"
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,str2)
                endif
            endif
        endif
        
        if (sz != sz2) then
            return -1
        endif
        
        return sz
    endmethod
    
    private static method run takes nothing returns nothing
        static if not IS_STATIC then
            local boolean createCollection = GetRandomInt(1, 100) <= 75 and collectionCount < 500
            local boolean destroyCollection = GetRandomInt(1, 100) <= 25 and collectionCount > 100
        endif
        local integer operations = 25
        local thistype this
        local integer collectionIndex
        local thistype node
        
        if (crashed) then
            call PauseTimer(GetExpiredTimer())
            call DestroyTimer(GetExpiredTimer())
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Corrupt Collection")
            
            return
        endif
        
        set crashed = true
        
        static if not IS_STATIC then
            if (destroyCollection) then
                set collectionCount = collectionCount - 1
                set collectionIndex = GetRandomInt(0, collectionCount)
                
                set this = collections[collectionIndex]
                set collections[collectionIndex] = collections[collectionCount]
                
                static if IS_UNIQUE then
                    set node = first
                    loop
                        static if IS_CIRCULAR then
                            exitwhen node.sentinel
                        else
                            exitwhen node == sentinel
                        endif
                        
                        call Node(node).deallocate()
                        
                        static if DISPLAY_OPERATIONS then
                            if (node == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Destroy) Freed Node " + I2S(node))
                            endif
                        endif
                        
                        set node = node.next
                    endloop
                endif
            
                static if IS_NX then
                    call Collection(this).deallocate()
                    
                    static if DISPLAY_OPERATIONS then
                        if (this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Destroy) Freed Collection " + I2S(this))
                        endif
                    endif
                endif
                
                call destroy()
                
                set count_test = 0
                
                set destroyed = destructionCount > 100
                set destructionCount = destructionCount + 1
            endif
            
            if (createCollection or collectionCount == 0) then
                static if IS_NX then
                    set this = Collection.allocate()
                    call clear()
                    
                    static if DISPLAY_OPERATIONS then
                        if (this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Create) Allocated Collection " + I2S(this))
                        endif
                    endif
                else
                    set this = create()
                endif
                set collections[collectionCount] = this
                set collectionCount = collectionCount + 1
                
                set created = true
                
                set node = first
            endif
        
            set collectionIndex = GetRandomInt(0, collectionCount - 1)
            set this = collections[collectionIndex]
        else
            set this = 0
        endif
        
        call ClearTextMessages()
        static if DISPLAY_STATISTICS then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Collection Count: " + I2S(collectionCount))
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Collection: " + I2S(this))
        endif
        
        loop
            exitwhen 0 == operations
            set operations = operations - 1
            
            static if thistype.clear.exists then
                if (count_test >= 10) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Clear")
                        endif
                    endif
                    
                    static if IS_UNIQUE then
                        set node = first
                        loop
                            static if IS_CIRCULAR then
                                exitwhen node.sentinel
                            else
                                exitwhen node == sentinel
                            endif
                            
                            call Node(node).deallocate()
                            
                            static if DISPLAY_OPERATIONS then
                                if (node == WATCH_NODE) then
                                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Clear) Freed Node " + I2S(node))
                                endif
                            endif
                            
                            set node = node.next
                        endloop
                    endif
                    call clear()
                    set count_test = 0
                    
                    set cleared = true
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
            
            static if thistype.push.exists then
                if (GetRandomInt(1, 100) <= 50) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Push")
                        endif
                    endif
                    
                    static if IS_UNIQUE then
                        call push(Node.allocate())
                    
                        static if DISPLAY_OPERATIONS then
                            if (first == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Push) Allocated Node " + I2S(first))
                            endif
                        endif
                    else
                        call push()
                    endif
                    set count_test = count_test + 1
                    
                    set node = first.next
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
            
            static if thistype.enqueue.exists then
                if (GetRandomInt(1, 100) <= 50) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Enqueue")
                        endif
                    endif
                    
                    static if IS_UNIQUE then
                        call enqueue(Node.allocate())
                    
                        static if DISPLAY_OPERATIONS then
                            static if IS_LIST then
                                set node = last.prev
                            
                                if (last == WATCH_NODE) then
                                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Enqueue) Allocated Node " + I2S(last))
                                endif
                            endif
                        endif
                    else
                        call enqueue()
                    endif
                    set count_test = count_test + 1
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
            
            static if thistype.pop.exists then
                if (GetRandomInt(1, 100) <= 50 and count_test > 0) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Pop")
                        endif
                    endif
                    
                    static if IS_UNIQUE then
                        static if DISPLAY_OPERATIONS then
                            if (first == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Pop) Freed Node " + I2S(first))
                            endif
                        endif
                        
                        set node = first
                        call Node(node).deallocate()
                        call pop()
                    else
                        call pop()
                    endif
                    set count_test = count_test - 1
                    if (count_test == 0) then
                        set poppedToEmpty = true
                    endif
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
            
            static if thistype.dequeue.exists then
                if (GetRandomInt(1, 100) <= 50 and count_test > 0) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Dequeue")
                        endif
                    endif
                    
                    static if IS_UNIQUE then
                        static if DISPLAY_OPERATIONS then
                            if (last == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Dequeue) Freed Node " + I2S(last))
                            endif
                        endif
                        
                        set node = last
                        call Node(node).deallocate()
                        call dequeue()
                    else
                        call dequeue()
                    endif
                    set count_test = count_test - 1
                    if (count_test == 0) then
                        set dequeuedToEmpty = true
                    endif
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
            
            static if thistype.remove.exists then
                if (GetRandomInt(1, 100) <= 50 and count_test > 6) then
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Remove")
                        endif
                    endif
                    
                    set collectionIndex = GetRandomInt(3, 5)
                    set node = first
                    loop
                        set collectionIndex = collectionIndex - 1
                        exitwhen collectionIndex == 0
                        set node = node.next
                    endloop
                    
                    static if IS_UNIQUE then
                        static if DISPLAY_OPERATIONS then
                            if (WATCH_NODE == 0 or node == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Remove) Freed Node " + I2S(node))
                            endif
                        endif
                        
                        call Node(node).deallocate()
                        call node.remove()
                    else
                        call node.remove()
                    endif
                    
                    set count_test = count_test - 1
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                elseif (GetRandomInt(1, 100) <= 10 and count_test > 0) then
                    if (GetRandomInt(1, 100) <= 50) then
                        set node = first
                    else
                        set node = last
                    endif
                    
                    static if IS_UNIQUE then
                        static if DISPLAY_OPERATIONS then
                            if (WATCH_NODE == 0 or node == WATCH_NODE) then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"    (Remove) Freed Node " + I2S(node))
                            endif
                        endif
                        
                        call Node(node).deallocate()
                        call node.remove()
                    else
                        call node.remove()
                    endif
                
                    set count_test = count_test - 1
                    if (count_test == 0) then
                        set removedToEmpty = true
                    endif
                    
                    static if DISPLAY_OPERATIONS then
                        if (WATCH_COLLECTION == 0 or this == WATCH_COLLECTION) then
                            if (size != count_test) then
                                call PauseTimer(GetExpiredTimer())
                                call DestroyTimer(GetExpiredTimer())
                                
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
                                
                                return
                            endif
                        endif
                    endif
                endif
            endif
        endloop
        
        if (size != count_test) then
            call PauseTimer(GetExpiredTimer())
            call DestroyTimer(GetExpiredTimer())
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"Size Error")
        endif
        
        if (removedToEmpty and poppedToEmpty and dequeuedToEmpty and cleared and destroyed and created and testCount > 6000) then
            call PauseTimer(GetExpiredTimer())
            call DestroyTimer(GetExpiredTimer())
            
            call ClearTextMessages()
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Test Success")
        endif
        
        set testCount = testCount + 1
        
        set crashed = false
    endmethod

    private static method onInit takes nothing returns nothing
        static if thistype.clear.exists then
            set cleared = false
        endif
        static if thistype.remove.exists then
            set removedToEmpty = false
        endif
        static if thistype.pop.exists then
            set poppedToEmpty = false
        endif
        static if thistype.dequeue.exists then
            set dequeuedToEmpty = false
        endif
    
        call TimerStart(CreateTimer(),.00115,true,function thistype.run)
    endmethod
endstruct