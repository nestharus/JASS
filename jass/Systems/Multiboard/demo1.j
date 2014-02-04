struct Tester extends array
    private static method init takes nothing returns nothing
        local Multiboard board = Multiboard.create(2,2)
        
        call board.setStyle(true, false)
        
        set board[0][0].text = "00"
        set board[0][1].text = "01"
        set board[1][0].text = "10"
        set board[1][1].text = "11"
        
        set board.display = true
        
        set board.row.count = 3
        set board[2][0].text = "20"
        set board[2][1].text = "21"
        
        set board.row.count = 2
        set board.row.count = 3
        
        call DestroyTimer(GetExpiredTimer())
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init)
    endmethod
endstruct