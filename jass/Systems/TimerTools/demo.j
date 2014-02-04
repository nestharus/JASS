implement TimerHead

private Timer timer
private static boolexpr onExpireC
private static integer onExpireI

method destroy takes nothing returns nothing
    //whenever you destroy a timer, remove it
    call remove(timer)
    call timer.destroy()
endmethod

static method create takes nothing returns thistype
    local thistype this = allocate()

    set timer = Timer.create(1, onExpireC, onExpireI)

    //whenever you create a timer, add it
    call add(timer)

    return this
endmethod

private static method onExpire takes nothing returns boolean
    local thistype this = thistype(Timer.expired).first

    loop
        //code
        call destroy()  //destroy the timer?


        //iteration
        set this = Timer(this).next
        exitwhen this == 0
    endloop

    return false
endmethod

//in a module
private static method onInit takes nothing returns nothing
    set onExpireC = Condition(function thistype.onExpire)
    set onExpireI = onExpire
endmethod