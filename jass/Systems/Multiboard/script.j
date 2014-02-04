library Multiboard /* v2.0.0.1
*************************************************************************************
*
*   Multiboard Struct API that actually works and is actually easy to use.
*
*************************************************************************************
*
*   */uses/*
*
*       */ Table /*         hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
************************************************************************************
*
*   struct Multiboard
*
*       string title
*       boolean display
*       boolean minimize
*       boolean suppress
*
*       real width=  (set only)
*       string icon= (set only)
*       string text= (set only)
*
*       readonly MultiboardRow row
*       readonly MultiboardColumn column
*
*       this[row][column] -> MultiboardItem
*
*       static method create takes integer rowCount, integer columnCount returns Multiboard
*       method destroy takes nothing returns nothing
*
*       method clear takes nothing returns nothing
*
*       method setTitleColor takes integer red, integer green, integer blue, integer alpha returns nothing
*       method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
*       method setStyle takes boolean showValues, boolean showIcons returns nothing
*
************************************************************************************
*
*   struct MultiboardRow extends array
*   struct MultiboardColumn extends array
*
*       integer count
*           -   row.count
*
*       string text
*       string icon=
*       real width=
*           -   row[0].width
*
*       method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
*       method setStyle takes boolean showValue, boolean showIcon returns nothing
*           -   row[0].setStyle
*
************************************************************************************
*
*   struct MultiboardItem extends array
*
*       string text= (set only)
*       string icon= (set only)
*       real width=  (set only)
*
*       method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
*       method setStyle takes boolean showValue, boolean showIcon returns nothing
*
************************************************************************************/
    globals
        private Table table
        private Table table2
        private integer array r
        private integer ic = 0
        private multiboard array boardp
        private integer array rc
        private integer array cc
        private boolean array suppressed
    endglobals
    
    private module Init
        private static method onInit takes nothing returns nothing
            set table = Table.create()
            set table2 = Table.create()
        endmethod
    endmodule
    
    struct MultiboardItem extends array
        method operator text= takes string value returns nothing
            call MultiboardSetItemValue(table.multiboarditem[this], value)
        endmethod
        method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
            call MultiboardSetItemValueColor(table.multiboarditem[this], red, green, blue, alpha)
        endmethod
        method setStyle takes boolean showValue, boolean showIcon returns nothing
            call MultiboardSetItemStyle(table.multiboarditem[this], showValue, showIcon)
        endmethod
        method operator icon= takes string str returns nothing
            call MultiboardSetItemIcon(table.multiboarditem[this], str)
        endmethod
        method operator width= takes real percent returns nothing
            call MultiboardSetItemWidth(table.multiboarditem[this], percent)
        endmethod
    
        implement Init
    endstruct
    
    //! textmacro MULTIBOARD_LOOPER takes ROW, TABLE, CODE
        local multiboarditem mb
        loop
            exitwhen 0 == $ROW$
            set mb = $TABLE$.multiboarditem[this]
            call $CODE$
            set this = this + 1
            set $ROW$ = $ROW$ - 1
        endloop
        
        set mb = null
    //! endtextmacro
    
    private keyword Multiboard2D
    private keyword getItems
    private keyword clearItems
    struct Multiboard extends array
        method getItems takes nothing returns nothing
            local integer row = rc[this]
            local integer column
            local multiboarditem mb
            loop
                set column = cc[this]
                loop
                    set mb = MultiboardGetItem(boardp[this], row, column)
                    set table.multiboarditem[(this*500+row)*500+column] = mb
                    set table2.multiboarditem[(this*500+column)*500+row] = mb
                    exitwhen 0 == column
                    set column = column - 1
                endloop
                exitwhen 0 == row
                set row = row - 1
            endloop
            set mb = null
        endmethod
        method clearItems takes nothing returns nothing
            local integer row = rc[this]
            local integer column
            loop
                set column = cc[this]
                loop
                    call MultiboardReleaseItem(table.multiboarditem[(this*500+row)*500+column])
                    call table.handle.remove((this*500+row)*500+column)
                    call table2.handle.remove((this*500+column)*500+row)
                    exitwhen 0 == column
                    set column = column - 1
                endloop
                exitwhen 0 == row
                set row = row - 1
            endloop
        endmethod
        
        static method create takes integer rowCount, integer columnCount returns thistype
            local thistype this = r[0]
            
            if (0 == this) then
                set this = ic + 1
                set ic = this
            else
                set suppressed[this] = false
                set r[0] = r[this]
            endif
            
            set boardp[this] = CreateMultiboard()
            call MultiboardSetColumnCount(boardp[this], columnCount)
            call MultiboardSetRowCount(boardp[this], rowCount)
            
            set rc[this] = rowCount
            set cc[this] = columnCount
            
            call getItems()
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set r[this] = r[0]
            set r[0] = this
            
            call clearItems()
            
            call DestroyMultiboard(boardp[this])
            set boardp[this] = null
        endmethod
        
        method clear takes nothing returns nothing
            call MultiboardClear(boardp[this])
        endmethod
        
        method operator display takes nothing returns boolean
            return IsMultiboardDisplayed(boardp[this])
        endmethod
        method operator display= takes boolean b returns nothing
            call MultiboardDisplay(boardp[this], b)
        endmethod
        method operator minimize takes nothing returns boolean
            return IsMultiboardMinimized(boardp[this])
        endmethod
        method operator minimize= takes boolean b returns nothing
            call MultiboardMinimize(boardp[this], b)
        endmethod
        method operator title takes nothing returns string
            return MultiboardGetTitleText(boardp[this])
        endmethod
        method operator title= takes string txt returns nothing
            call MultiboardSetTitleText(boardp[this], txt)
        endmethod
        method setTitleColor takes integer red, integer green, integer blue, integer alpha returns nothing
            call MultiboardSetTitleTextColor(boardp[this], red, green, blue, alpha)
        endmethod
        method operator suppress takes nothing returns boolean
            return suppressed[this]
        endmethod
        method operator suppress= takes boolean b returns nothing
            set suppressed[this] = b
            call MultiboardSuppressDisplay(b)
        endmethod
        method operator width= takes real percent returns nothing
            call MultiboardSetItemsWidth(boardp[this], percent)
        endmethod
        method operator row takes nothing returns MultiboardRow
            return this
        endmethod
        method operator column takes nothing returns MultiboardColumn
            return this
        endmethod
        method operator [] takes integer row returns Multiboard2D
            return this*500+row
        endmethod
        method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
            call MultiboardSetItemsValueColor(boardp[this], red, green, blue, alpha)
        endmethod
        method setStyle takes boolean showValues, boolean showIcons returns nothing
            call MultiboardSetItemsStyle(boardp[this], showValues, showIcons)
        endmethod
        method operator icon= takes string txt returns nothing
            call MultiboardSetItemsIcon(boardp[this], txt)
        endmethod
        method operator text= takes string txt returns nothing
            call MultiboardSetItemsValue(boardp[this], txt)
        endmethod
    endstruct
    
    private struct MultiboardSet extends array
        method text takes string v, integer c, Table t returns nothing
            //! runtextmacro MULTIBOARD_LOOPER("c", "t", "MultiboardSetItemValue(mb, v)")
        endmethod
        method color takes integer red, integer green, integer blue, integer alpha, integer c, Table t returns nothing
            //! runtextmacro MULTIBOARD_LOOPER("c", "t", "MultiboardSetItemValueColor(mb, red, green, blue, alpha)")
        endmethod
        method style takes boolean v, boolean i, integer c, Table t returns nothing
            //! runtextmacro MULTIBOARD_LOOPER("c", "t", "MultiboardSetItemStyle(mb, v, i)")
        endmethod
        method icon takes string s, integer c, Table t returns nothing
            //! runtextmacro MULTIBOARD_LOOPER("c", "t", "MultiboardSetItemIcon(mb, s)")
        endmethod
        method width takes real p, integer c, Table t returns nothing
            //! runtextmacro MULTIBOARD_LOOPER("c", "t", "MultiboardSetItemWidth(mb, p)")
        endmethod
    endstruct
    struct MultiboardColumn extends array
        method operator count takes nothing returns integer
            return MultiboardGetColumnCount(boardp[this])
        endmethod
        method operator count= takes integer columns returns nothing
            call Multiboard(this).clearItems()
            call MultiboardSetColumnCount(boardp[this], columns)
            set cc[this] = columns
            call Multiboard(this).getItems()
        endmethod
        method operator text= takes string value returns nothing
            call MultiboardSet(this).text(value, rc[this/250000], table2)
        endmethod
        method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
            call MultiboardSet(this).color(red, green, blue, alpha, rc[this/250000], table2)
        endmethod
        method setStyle takes boolean showValue, boolean showIcon returns nothing
            call MultiboardSet(this).style(showValue, showIcon, rc[this/250000], table2)
        endmethod
        method operator icon= takes string str returns nothing
            call MultiboardSet(this).icon(str, rc[this/250000], table2)
        endmethod
        method operator width= takes real percent returns nothing
            call MultiboardSet(this).width(percent, rc[this/250000], table2)
        endmethod
        method operator [] takes integer column returns thistype
            return (this*500+column)*500
        endmethod
    endstruct
    struct MultiboardRow extends array
        method operator count takes nothing returns integer
            return MultiboardGetRowCount(boardp[this])
        endmethod
        method operator count= takes integer rows returns nothing
            call Multiboard(this).clearItems()
            call MultiboardSetRowCount(boardp[this], rows)
            set rc[this] = rows
            call Multiboard(this).getItems()
        endmethod
        method operator text= takes string value returns nothing
            call MultiboardSet(this).text(value, cc[this/250000], table)
        endmethod
        method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
            call MultiboardSet(this).color(red, green, blue, alpha, cc[this/250000], table)
        endmethod
        method setStyle takes boolean showValue, boolean showIcon returns nothing
            call MultiboardSet(this).style(showValue, showIcon, cc[this/250000], table)
        endmethod
        method operator icon= takes string str returns nothing
            call MultiboardSet(this).icon(str, cc[this/250000], table)
        endmethod
        method operator width= takes real percent returns nothing
            call MultiboardSet(this).width(percent,cc[this/250000], table)
        endmethod
        method operator [] takes integer row returns thistype
            return (this*500+row)*500
        endmethod
    endstruct
    private struct Multiboard2D extends array
        method operator [] takes integer column returns MultiboardItem
            return this*500+column
        endmethod
    endstruct
endlibrary