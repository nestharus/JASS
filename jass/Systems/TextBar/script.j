library TextBar /* v1.0.0.2
*************************************************************************************
*
*   A bar of text using the | character. Can be used in whatever (text tags, multiboard, etc).
*   Useful for things like casting bars, health bars, and all around progress bars.
*
*************************************************************************************
*
*   */uses/*
*
*       */ StringColors /*         hiveworkshop.com/forums/jass-resources-412/snippet-string-colors-171323/
*
*************************************************************************************
*
*   struct TextBar extends array
*
*       real percent
*           -   how much of the bar is filled out as a percent (0 to 1)
*       integer width
*           -   how many characters wide the bar is (max 898)
*       Color color0
*           -   color of the bar as it approaches 0%
*           -   set to hex color aka 0xFFFFFFFF
*       Color color100
*           -   color of the bar as it approaches 100%
*           -   set to hex color aka 0xFFFFFFFF
*       readonly Color color
*           -   the current color of the bar
*
*       static method create takes integer width returns thistype
*       method destroy takes nothing returns nothing
*
*       method updateColor takes nothing returns nothing
*           -   used to update color of bar if you do something like set color properties using color objects
*
*************************************************************************************/
    struct TextBar extends array
        private static constant integer MAX_WIDTH = 898
    
        private static integer instanceCount = 0
        private static integer array recycler
        
        private static string array bars
        
        private string bar_p
        private integer width_p
        private Color color0_p
        private Color color100_p
        private Color color_p
        private real percent_p
        
        private static method allocate takes nothing returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            return this
        endmethod
        private method deallocate takes nothing returns nothing
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
        
        static method create takes integer width returns thistype
            local thistype this = allocate()
            
            set width_p = width
            set bar_p = bars[width]
            
            set color0_p = Color.create(255, 0, 0, 0)
            set color100_p = Color.create(255, 0, 0, 0)
            set color_p = Color.create(255, 0, 0, 0)
            set percent_p = 1
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call deallocate()
            call color0_p.destroy()
            call color100_p.destroy()
            call color_p.destroy()
        endmethod
        
        method operator width takes nothing returns integer
            return width_p
        endmethod
        method operator width= takes integer width returns nothing
            set width_p = width
            set bar_p = color_p.apply(bars[R2I(width_p*percent_p + .5)]) + Color.convert(0, 0, 0, 0) + bars[R2I(width_p*(1 - percent_p) + .5)] + "|r"
        endmethod
        
        method operator color0 takes nothing returns Color
            return color0_p
        endmethod
        method operator color100 takes nothing returns Color
            return color100_p
        endmethod
        method operator color takes nothing returns Color
            return color_p
        endmethod
        
        method operator color0= takes integer hex returns nothing
            local Color color = Color.createFromHex(hex)
            
            set color0_p.alpha = color.alpha
            set color0_p.red = color.red
            set color0_p.green = color.green
            set color0_p.blue = color.blue
            
            call this.color.setMix(color0_p, color100_p, percent_p)
            set bar_p = color_p.apply(bars[R2I(width_p*percent_p + .5)]) + Color.convert(0, 0, 0, 0) + bars[R2I(width_p*(1 - percent_p) + .5)] + "|r"
            
            call color.destroy()
        endmethod
        
        method operator color100= takes integer hex returns nothing
            local Color color = Color.createFromHex(hex)
            
            set color100_p.alpha = color.alpha
            set color100_p.red = color.red
            set color100_p.green = color.green
            set color100_p.blue = color.blue
            
            call this.color.setMix(color0_p, color100_p, percent_p)
            set bar_p = color_p.apply(bars[R2I(width_p*percent_p + .5)]) + Color.convert(0, 0, 0, 0) + bars[R2I(width_p*(1 - percent_p) + .5)] + "|r"
            call color.destroy()
        endmethod
        
        method updateColor takes nothing returns nothing
            call this.color.setMix(color0_p, color100_p, percent_p)
            set bar_p = color_p.apply(bars[R2I(width_p*percent_p + .5)]) + Color.convert(0, 0, 0, 0) + bars[R2I(width_p*(1 - percent_p) + .5)] + "|r"
        endmethod
        
        method operator percent takes nothing returns real
            return percent_p
        endmethod
        method operator percent= takes real percent returns nothing
            set percent_p = percent
            call this.color.setMix(color0_p, color100_p, percent_p)
            set bar_p = color_p.apply(bars[R2I(width_p*percent_p + .5)]) + Color.convert(0, 0, 0, 0) + bars[R2I(width_p*(1 - percent_p) + .5)] + "|r"
        endmethod
        
        method operator text takes nothing returns string
            return bar_p
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local string str = ""
            loop
                set i = i + 1
                set str = str + "||"
                set bars[i] = str
                exitwhen i == MAX_WIDTH
            endloop
        endmethod
    endstruct
endlibrary