library StringColors /* v2.0.0.2
*************************************************************************************
*
*   Used for creating Color objects that have alpha, red, green, and blue channels.
*
*************************************************************************************
*
*   struct Color extends array
*       integer alpha
*       integer red
*       integer green
*       integer blue
*       readonly string color
*           -   The color as a string "|c + color"
*
*       static method create takes integer alpha, integer red, integer green, integer blue returns Color
*       static method createEx takes integer red, integer green, integer blue returns Color
*       static method createFromHex takes integer hex returns Color
*       static method createFromHexEx takes integer hex returns Color
*       static method createFromMix takes Color color, Color gradient, real weight returns Color
*
*       method destroy takes nothing returns nothing
*
*       method reset takes nothing returns nothing
*           -   Resets color to white with no fade
*
*       static method convert takes integer alpha, integer red, integer green, integer blue returns string
*           -   Converts alpha, red, green, blue to color string
*           ->  "|cffffffff"
*
*       static method convertHex takes integer hex returns string
*           -   Converts alpha, red, green, blue to color string
*           ->  "|cffffffff"
*
*       method apply takes string toBeColored returns string
*           -   Applies color to string
*
*       method setMix takes Color color, Color gradient, real weight returns nothing
*           -   Sets color to mixture between target color and gradient given a weight
*           -   Weight is how much to apply the gradient to the color. A weight of 1 means apply the gradient fully.
*           -   A weight of 0 means don't apply the gradient at all.
*
*   struct Color.Gradient extends array
*       static method apply takes string toBeColored, Color color, Color gradient, integer segments, boolean reverses returns string
*       static method applyHex takes string toBeColored, integer colorHex, integer gradientHex, integer segments, boolean reverses returns string
*
*************************************************************************************/
    public keyword ColorGradient
    
    globals
        private string array hexChars
    endglobals
    
    struct Color extends array
        private static integer instanceCount = 0
        private static integer array recycler
        
        private integer redX
        private integer greenX
        private integer blueX
        private integer alphaX
        private string colorX
        
        public static method operator Gradient takes nothing returns ColorGradient
            return 0
        endmethod
        
        public static method convert takes integer alpha, integer red, integer green, integer blue returns string
            return "|c" + hexChars[alpha] + hexChars[red] + hexChars[green] + hexChars[blue]
        endmethod
        static method convertHex takes integer hex returns string
            local integer alpha
            local integer red
            local integer green
            local integer blue
            
            if (0 > hex) then
                set hex = -(-hex + 2147483648)
                set alpha = 128 + hex/16777216
                set hex = hex - (alpha - 128)*16777216
            else
                set alpha = hex/16777216
                set hex = hex - alpha*16777216
            endif
            
            set red = hex/65536
            
            set hex = hex - red*65536
            set green = hex/256
            set blue = hex - green*256
            
            return convert(alpha, red, green, blue)
        endmethod
        
        public method apply takes string toBeColored returns string
            return colorX + toBeColored + "|r"
        endmethod
        
        public method operator red takes nothing returns integer
            return redX
        endmethod
        
        public method operator red= takes integer val returns nothing
            set redX = val
            set colorX = convert(alphaX, redX, greenX, blueX)
        endmethod
        
        public method operator green takes nothing returns integer
            return greenX
        endmethod
        
        public method operator green= takes integer val returns nothing
            set greenX = val
            set colorX = convert(alphaX, redX, greenX, blueX)
        endmethod
        
        public method operator blue takes nothing returns integer
            return blueX
        endmethod
        
        public method operator blue= takes integer val returns nothing
            set blueX = val
            set colorX = convert(alphaX, redX, greenX, blueX)
        endmethod
        
        method operator alpha takes nothing returns integer
            return alphaX
        endmethod
        
        method operator alpha= takes integer val returns nothing
            set alphaX = val
            set colorX = convert(alphaX, redX, greenX, blueX)
        endmethod
        
        public method operator color takes nothing returns string
            return colorX
        endmethod
        
        method reset takes nothing returns nothing
            set alphaX = 255
            set redX = 255
            set greenX = 255
            set blueX = 255
            set colorX = convert(alphaX, redX, greenX, blueX)
        endmethod
        
        public static method create takes integer alpha, integer red, integer green, integer blue returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            set redX = red
            set greenX = green
            set blueX = blue
            set alphaX = alpha
            set colorX = convert(alpha, red, green, blue)
            
            return this
        endmethod
        
        static method createEx takes integer red, integer green, integer blue returns thistype
            return create(255, red, green, blue)
        endmethod
        
        static method createFromHex takes integer hex returns thistype
            local integer alpha
            local integer red
            local integer green
            local integer blue
        
            if (0 > hex) then
                set hex = -(-hex + 2147483648)
                set alpha = 128 + hex/16777216
                set hex = hex - (alpha - 128)*16777216
            else
                set alpha = hex/16777216
                set hex = hex - alpha*16777216
            endif
            
            set red = hex/65536
            
            set hex = hex - red*65536
            set green = hex/256
            set blue = hex - green*256
            
            return create(alpha, red, green, blue)
        endmethod
        
        static method createFromHexEx takes integer hex returns thistype
            return createFromHex(4278190080 + hex)
        endmethod
        
        public static method createFromMix takes Color color, Color gradient, real weight returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            set this.red = R2I(color.red-(color.red-gradient.red)*weight+.5)
            set this.green = R2I(color.green-(color.green-gradient.green)*weight+.5)
            set this.blue = R2I(color.blue-(color.blue-gradient.blue)*weight+.5)
            set this.alpha = R2I(color.alpha-(color.alpha-gradient.alpha)*weight+.5)
            
            return this
        endmethod
        
        public method destroy takes nothing returns nothing
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer d0 = 16
            local integer d1
            set hexChars[0] = "0"
            set hexChars[1] = "1"
            set hexChars[2] = "2"
            set hexChars[3] = "3"
            set hexChars[4] = "4"
            set hexChars[5] = "5"
            set hexChars[6] = "6"
            set hexChars[7] = "7"
            set hexChars[8] = "8"
            set hexChars[9] = "9"
            set hexChars[10] = "A"
            set hexChars[11] = "B"
            set hexChars[12] = "C"
            set hexChars[13] = "D"
            set hexChars[14] = "E"
            set hexChars[15] = "F"
            
            loop
                set d0 = d0 - 1
                set d1 = 16
                loop
                    set d1 = d1 - 1
                    set hexChars[d0*16+d1] = hexChars[d0]+hexChars[d1]
                    exitwhen d1 == 0
                endloop
                exitwhen d0 == 0
            endloop
        endmethod
        
        public method setMix takes Color color, Color gradient, real weight returns nothing
            set this.red = R2I(color.red-(color.red-gradient.red)*weight+.5)
            set this.green = R2I(color.green-(color.green-gradient.green)*weight+.5)
            set this.blue = R2I(color.blue-(color.blue-gradient.blue)*weight+.5)
            set this.alpha = R2I(color.alpha-(color.alpha-gradient.alpha)*weight+.5)
            set this.colorX = convert(this.alpha, this.red, this.green, this.blue)
        endmethod
    endstruct
    
    public struct ColorGradient extends array
        public static method apply takes string toBeColored, Color color, Color gradient, integer segments, boolean reverses returns string
            local string colored        //the colored string
            local integer length        //length of string to color
            local integer position      //current character position of string to color
            
            local real addRed           //how much red to add
            local real addGreen         //how much green to add
            local real addBlue          //how much blue to add
            local real addAlpha         //how much alpha to add
            local real red              //current red
            local real green            //current green
            local real blue             //current blue
            local real alpha            //current alpha
            
            local integer segment       //current coloring segment
            local integer subPosition   //sub position of segment
            local integer subLength     //length of current segment (needed if string can't be split entirely)
            local real percent          //percent of color to use
            local integer flag          //neg flag
            
            //if the string exists, go on
            if (toBeColored != null and toBeColored != "") then
                set length = StringLength(toBeColored)
                set colored = ""
                set flag = 0
                set red = color.red
                set green = color.green
                set blue = color.blue
                set alpha = color.alpha
                set position = 0
                //if result is a single character or micro segments
                //return the string as base color
                if (length == 1 or segments >= length or segments <= 0) then
                    set colored = color.color + toBeColored
                elseif (segments > 1) then
                    //because subPosition starts at 0
                    //decrease by 1
                    set subLength = length/segments-1
                    //set sub position
                    set subPosition = 0
                    //all of the adders are just the complete as percents
                    //are used instead
                    set addRed = gradient.red - color.red
                    set addGreen = gradient.green - color.green
                    set addBlue = gradient.blue - color.blue
                    set addAlpha = gradient.alpha - color.alpha
                    //flag starts positive
                    set flag = 1
                    //segment starts at 0
                    set segment = 0
                    
                    loop
                        //add colored character to colored string
                        set colored = colored + Color.convert(R2I(alpha+.5), R2I(red+.5), R2I(green+.5), R2I(blue+.5))+SubString(toBeColored, position, position+1)
                        set position = position + 1
                        exitwhen position == length
                        
                        //if hit end of sub, reverse direction of gradient
                        if (subPosition == subLength or (subPosition == 0 and flag < 1)) then
                            set segment = segment + 1
                            set subLength = (length-position)/(segments-segment)
                            if (reverses) then
                                set flag = flag * -1
                                if (subPosition != 0) then
                                    set subPosition = subLength
                                endif
                            else
                                set subPosition = 0
                            endif
                        endif
                        
                        //move ahead the sub sub string
                        set subPosition = subPosition + flag
                        //get current percentage of movement
                        set percent = (subPosition +0.)/subLength
                        //set colors by percent
                        set red = color.red+addRed*percent
                        set green = color.green+addGreen*percent
                        set blue = color.blue+addBlue*percent
                        set alpha = color.alpha+addAlpha*percent
                    endloop
                //process single segment gradient
                else
                    //because this starts on 0, set length to length-1
                    set subLength = length-1
                    
                    //adders are based on total length
                    set addRed = (gradient.red - color.red + 0.)/subLength
                    set addGreen = (gradient.green - color.green + 0.)/subLength
                    set addBlue = (gradient.blue - color.blue + 0.)/subLength
                    set addAlpha = (gradient.alpha - color.alpha + 0.)/subLength
                    
                    loop
                        set colored = colored + Color.convert(R2I(alpha+.5), R2I(red+.5), R2I(green+.5), R2I(blue+.5))+SubString(toBeColored, position, position+1)
                        
                        set position = position + 1
                        exitwhen position == length
                        
                        set red = red + addRed
                        set green = green + addGreen
                        set blue = blue + addBlue
                        set alpha = alpha + addAlpha
                    endloop
                endif
                return colored + "|r"
            endif
            return null
        endmethod
        public static method applyHex takes string toBeColored, integer colorHex, integer gradientHex, integer segments, boolean reverses returns string
            local Color color = Color.createFromHex(colorHex)
            local Color gradient = Color.createFromHex(gradientHex)
            local string colored = apply(toBeColored, color, gradient, segments, reverses)
            
            call color.destroy()
            call gradient.destroy()
            
            return colored
        endmethod
    endstruct
endlibrary