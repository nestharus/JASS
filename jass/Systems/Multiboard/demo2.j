struct Tester extends array
    private static method init takes nothing returns nothing
        local Multiboard board = Multiboard.create(19,4)
        
        call board.setStyle(true, false)
        
        set board.row[0].text = "row 1"
        set board.column[0].text = "column 1"
        set board[0][0].text = "X"
        
        set board.column[0].width = .15
        set board.column[1].width = .05
        set board.column[2].width = .05
        
        set board.display = true
        
        call DestroyTimer(GetExpiredTimer())
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init)
    endmethod
endstruct