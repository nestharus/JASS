[jass]
library TextTag /* v2.0.0.7
*************************************************************************************
*
*   Struct wrapper for text tags
*
*   TextTags start out visible and not permanent
*
*   When there are too many text tags, non permanent text tags will be destroyed prematurely
*   so that new text tags can be created. In the case where there are no non permanent
*   text tags to destroy, the system will crash and display an error (error + crash + check in debug mode only)
*
*************************************************************************************
*
*   */uses/*
*
*       */ StringColors /*         hiveworkshop.com/forums/jass-resources-412/snippet-string-colors-171323/
*       */ Table        /*         hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*       */ CTL          /*         hiveworkshop.com/forums/jass-resources-412/snippet-constant-timer-loop-32-a-201381/
*       */ Position     /*         hiveworkshop.com/forums/jass-resources-412/snippet-position-184578/
*
*************************************************************************************
*
*   struct TextTag extends array
*
*       string text
*       real size
*       boolean visible
*       TextTagColor : Color color
*           -   set to hex integer, aka 0xFFFFFFFF
*           -   doesn't inherit static methods***
*
*       real x
*       real y
*       real z
*       real relativeX
*       real relativeY
*           -   position relative to anchor
*       Position anchor
*
*       real age
*       real lifespan
*       boolean suspended
*       boolean permanent
*       real fadepoint
*
*       real dx
*           -   x velocity
*       real dy
*           -   y velocity
*       real angle
*       real speed
*
*       static method createLocal takes boolean createForPlayer returns thistype
*       static method create takes nothing returns TextTag
*       method destroy takes nothing returns nothing
*
*       method setText takes string text, real size returns nothing
*
*       method setPosition takes real x, real y, real z returns nothing
*       method setAnchor takes Position anchor, real relativeX, real relativeY, real z returns nothing
*
*       method setVelocityXY takes real x, real y returns nothing
*       method setVelocity takes real speed, real angle returns nothing
*
*************************************************************************************/
    private struct TextTagPointer extends array
        public texttag tag_p
    endstruct
    
    private keyword update
    struct TextTagColor extends array
        private delegate TextTagPointer tagPointer_p
        
        method update takes nothing returns nothing
            call SetTextTagColor(tag_p, Color(this).red, Color(this).green, Color(this).blue, Color(this).alpha)
        endmethod
        
        method reset takes nothing returns nothing
            call Color(this).reset()
            call update()
        endmethod
        
        method operator alpha takes nothing returns integer
            return Color(this).alpha
        endmethod
        method operator alpha= takes integer i returns nothing
            set Color(this).alpha = i
            call update()
        endmethod
        method operator red takes nothing returns integer
            return Color(this).red
        endmethod
        method operator red= takes integer i returns nothing
            set Color(this).red = i
            call update()
        endmethod
        method operator green takes nothing returns integer
            return Color(this).green
        endmethod
        method operator green= takes integer i returns nothing
            set Color(this).green = i
            call update()
        endmethod
        method operator blue takes nothing returns integer
            return Color(this).blue
        endmethod
        method operator blue= takes integer i returns nothing
            set Color(this).blue = i
            call update()
        endmethod
        method operator color takes nothing returns string
            return Color(this).color
        endmethod
        method apply takes string toBeColored returns string
            return Color(this).apply(toBeColored)
        endmethod
        method setMix takes Color color, Color gradient, real weight returns nothing
            call Color(this).setMix(color, gradient, weight)
            call update()
        endmethod
        
        static method create takes TextTagPointer tagPointer, integer alpha, integer red, integer green, integer blue returns thistype
            local thistype this = Color.create(alpha, red, green, blue)
        
            set this.tagPointer_p = tagPointer
            
            call update()
            
            return this
        endmethod
    endstruct
    
    struct TextTag extends array
        private static constant integer MAX_INSTANCE_COUNT = 100
        
        private static thistype instanceCount = 0
        private static integer array recycler
        
        private static integer localRemaining = MAX_INSTANCE_COUNT
        private static integer array recyclerPointer
        
        private thistype next
        private thistype prev
        
        private static Table table
        
        private delegate TextTagPointer tagPointer_p
        private static thistype array tagPointerParent_p
        
        private timer textTagTimer_p
        private real lifespan_p
        private TextTagColor color_p
        private real fadePoint_p
        private boolean suspended_p
        
        private Position position_p
        private real posX_p
        private real posY_p
        private real posZ_p
        private real posOffX_p
        private real posOffY_p
        
        private string text_p
        
        private real height_p
        private real size_p
        
        private boolean visible_p
        private boolean permanent_p
        
        private real xvel_p
        private real yvel_p
        private real angle_p
        private real speed_p
        
        private thistype next2
        private thistype prev2
        
        private static TimerGroup32 timerGroup
        private static integer timerInstanceCount = 0
        
        private method enqueue2 takes nothing returns nothing
            set next2 = 0
            set prev2 = thistype(0).prev2
            set thistype(0).prev2.next2 = this
            set thistype(0).prev2 = this
            if (0 == timerInstanceCount) then
                call timerGroup.start()
            endif
            set timerInstanceCount = timerInstanceCount + 1
        endmethod
        private method remove2 takes nothing returns nothing
            set prev2.next2 = next2
            set next2.prev2 = prev2
            set timerInstanceCount = timerInstanceCount - 1
            if (0 == timerInstanceCount) then
                call timerGroup.stop()
            endif
        endmethod
        
        private static method update takes nothing returns nothing
            local thistype this = thistype(0).next2
            loop
                exitwhen 0 == this
                call SetTextTagPos(tag_p, position_p.x + posOffX_p, position_p.y + posOffY_p, posZ_p)
                set this = next2
            endloop
        endmethod
        
        private method enqueue takes nothing returns nothing
            set this = tagPointer_p
            if (0 == this) then
                return
            endif
            
            set next = 0
            set prev = thistype(0).prev
            set thistype(0).prev.next = this
            set thistype(0).prev = this
        endmethod
        private method remove takes nothing returns nothing
            set this = tagPointer_p
            if (0 == this) then
                return
            endif
            
            set prev.next = next
            set next.prev = prev
        endmethod
        
        method destroy takes nothing returns nothing
            call DestroyTextTag(tag_p)
            call PauseTimer(textTagTimer_p)
            
            set tag_p = null
            set recycler[this] = recycler[0]
            set recycler[0] = this
            
            if (0 != tagPointer_p) then
                set recyclerPointer[tagPointer_p] = recyclerPointer[0]
                set recyclerPointer[0] = tagPointer_p
            endif
            
            if (not permanent_p) then
                call remove()
            endif
            if (0 != position_p) then
                call remove2()
                call position_p.unlock()
                set position_p = 0
            endif
            
            set tagPointerParent_p[tagPointer_p] = 0
            set tagPointer_p = 0
        endmethod
        
        private static method allocate takes boolean createLocal returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            if (createLocal) then
                set tagPointer_p = recyclerPointer[0]
                if (0 == tagPointer_p) then
                    set tagPointer_p = localRemaining
                    if (0 == tagPointer_p) then
                        set tagPointer_p = thistype(0).next
                        
                        debug if (0 == tagPointer_p) then
                            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "Text Tag Overload: Too Many Permanent Text Tags")
                            debug set tagPointer_p = 1/0
                        debug endif
                        
                        call remove()
                        call DestroyTextTag(tag_p)
                        set tag_p = null
                        set tagPointerParent_p[tagPointer_p].tagPointer_p = 0
                    else
                        set localRemaining = tagPointer_p - 1
                    endif
                else
                    set recyclerPointer[0] = recyclerPointer[tagPointer_p]
                endif
                set tagPointerParent_p[tagPointer_p] = this
                set tag_p = CreateTextTag()
            else
                set tagPointer_p = 0
                set tag_p = null
            endif
            
            if (0 == color_p) then
                set textTagTimer_p = CreateTimer()
                set table[GetHandleId(textTagTimer_p)] = this
                set color_p = TextTagColor.create(tagPointer_p, 255, 255, 255, 255)
            else
                call color_p.reset()
                
                set fadePoint_p = 0
                
                set position_p = 0
                
                set posX_p = 0
                set posY_p = 0
                set posZ_p = 0
                set posOffX_p = 0
                set posOffY_p = 0
                
                set suspended_p = false
                
                set text_p = null
                
                set height_p = 0
                set size_p = 0
                
                set visible_p = true
                set permanent_p = false
                
                set xvel_p = 0
                set yvel_p = 0
                set angle_p = 0
                set speed_p = 0
            endif
            
            return this
        endmethod
        
        private static method destroyTag takes nothing returns nothing
            call thistype(table[GetHandleId(GetExpiredTimer())]).destroy()
        endmethod
        
        static method createLocal takes boolean createForPlayer returns thistype
            local thistype this = allocate(createForPlayer)
            
            set lifespan_p = 604800
            call SetTextTagVisibility(tag_p, true)
            call SetTextTagPermanent(tag_p, false)
            call TimerStart(textTagTimer_p, 604800, false, function thistype.destroyTag)
            call enqueue()
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            return createLocal(true)
        endmethod
        
        method operator age takes nothing returns real
            return lifespan_p - TimerGetRemaining(textTagTimer_p)
        endmethod
        method operator age= takes real age returns nothing
            if (lifespan_p <= age and not permanent_p) then
                call destroy()
                return
            endif
            
            call SetTextTagAge(tag_p, age)
            call TimerStart(textTagTimer_p, lifespan_p - age, false, function thistype.destroyTag)
        endmethod
        method operator color takes nothing returns TextTagColor
            return color_p
        endmethod
        method operator color= takes integer hex returns nothing
            local Color color = Color.createFromHex(hex)
            
            set Color(this.color_p).red = color.red
            set Color(this.color_p).green = color.green
            set Color(this.color_p).blue = color.blue
            set Color(this.color_p).alpha = color.alpha
            
            call this.color_p.update()
            
            call color.destroy()
        endmethod
        method operator fadepoint takes nothing returns real
            return fadePoint_p
        endmethod
        method operator fadepoint= takes real fadePoint returns nothing
            set fadePoint_p = fadePoint
            call SetTextTagFadepoint(tag_p, fadePoint)
        endmethod
        method operator lifespan takes nothing returns real
            return lifespan_p
        endmethod
        method operator lifespan= takes real newLifeSpan returns nothing
            if (newLifeSpan <= age and not permanent_p) then
                call destroy()
                return
            endif
            call SetTextTagLifespan(tag_p, newLifeSpan - age + .001)
            call TimerStart(textTagTimer_p, newLifeSpan - age, false, function thistype.destroyTag)
            set lifespan_p = newLifeSpan
        endmethod
        method setPosition takes real x, real y, real z returns nothing
            set posX_p = x
            set posY_p = y
            set posZ_p = z
            if (0 != position_p) then
                call remove2()
                call position_p.unlock()
                set position_p = 0
            endif
            call SetTextTagPos(tag_p, x, y, z)
        endmethod
        method operator x takes nothing returns real
            return posX_p
        endmethod
        method operator y takes nothing returns real
            return posY_p
        endmethod
        method operator z takes nothing returns real
            return posZ_p
        endmethod
        method operator x= takes real x returns nothing
            set posX_p = x
            if (0 != position_p) then
                call remove2()
                call position_p.unlock()
                set position_p = 0
            endif
            call SetTextTagPos(tag_p, posX_p, posY_p, posZ_p)
        endmethod
        method operator y= takes real y returns nothing
            set posY_p = y
            if (0 != position_p) then
                call remove2()
                call position_p.unlock()
                set position_p = 0
            endif
            call SetTextTagPos(tag_p, posX_p, posY_p, posZ_p)
        endmethod
        method operator z= takes real z returns nothing
            set posZ_p = z
            if (0 == position_p) then
                call SetTextTagPos(tag_p, posX_p, posY_p, posZ_p)
            else
                call SetTextTagPos(tag_p, position_p.x + posOffX_p, position_p.y + posOffY_p, posZ_p)
            endif
        endmethod
        method setAnchor takes Position anchor, real relativeX, real relativeY, real z returns nothing
            set posX_p = 0
            set posY_p = 0
            set posZ_p = z
            set posOffX_p = relativeX
            set posOffY_p = relativeY
            
            if (position_p != anchor) then
                if (0 != position_p) then
                    call position_p.unlock()
                    if (0 == anchor) then
                        call remove2()
                    endif
                elseif (0 != anchor) then
                    call enqueue2()
                endif
                set position_p = anchor
                if (0 != anchor) then
                    call anchor.lock()
                endif
            endif
            
            if (0 != anchor) then
                call SetTextTagPos(tag_p, position_p.x + posOffX_p, position_p.y + posOffY_p, posZ_p)
            endif
        endmethod
        method operator anchor takes nothing returns Position
            return position_p
        endmethod
        method operator anchor= takes Position anchor returns nothing
            set posX_p = 0
            set posY_p = 0
            
            if (position_p != anchor) then
                if (0 != position_p) then
                    call position_p.unlock()
                    if (0 == anchor) then
                        call remove2()
                    endif
                elseif (0 != anchor) then
                    call enqueue2()
                endif
                set position_p = anchor
                if (0 != anchor) then
                    call anchor.lock()
                    call SetTextTagPos(tag_p, position_p.x + posOffX_p, position_p.y + posOffY_p, posZ_p)
                endif
            endif
        endmethod
        method operator suspended takes nothing returns boolean
            return suspended_p
        endmethod
        method operator suspended= takes boolean suspended returns nothing
            set suspended_p = suspended
            
            if (suspended) then
                call PauseTimer(textTagTimer_p)
            else
                call ResumeTimer(textTagTimer_p)
            endif
            
            call SetTextTagSuspended(tag_p, suspended)
        endmethod
        method operator text takes nothing returns string
            return text_p
        endmethod
        method operator text= takes string text returns nothing
            set text_p = text
            call SetTextTagText(tag_p, text, height_p)
        endmethod
        method operator size takes nothing returns real
            return size_p
        endmethod
        method operator size= takes real size returns nothing
            set size_p = size
            set height_p = size * .0023
            call SetTextTagText(tag_p, text_p, height_p)
        endmethod
        method setText takes string text, real size returns nothing
            set text_p = text
            set size_p = size
            set height_p = size * .0023
            call SetTextTagText(tag_p, text_p, height_p)
        endmethod
        method operator visible takes nothing returns boolean
            return visible_p
        endmethod
        method operator visible= takes boolean visible returns nothing
            set visible_p = visible
            call SetTextTagVisibility(tag_p, visible)
        endmethod
        method operator permanent takes nothing returns boolean
            return permanent_p
        endmethod
        method operator permanent= takes boolean permanent returns nothing
            if (permanent != permanent_p) then
                if (lifespan_p <= age and not permanent) then
                    call destroy()
                    return
                endif
                
                set permanent_p = permanent
                call SetTextTagPermanent(tag_p, permanent)
                
                if (permanent) then
                    call remove()
                    call TimerStart(textTagTimer_p, 604800 - age, false, function thistype.destroyTag)
                else
                    call enqueue()
                    call TimerStart(textTagTimer_p, lifespan_p - age, false, function thistype.destroyTag)
                endif
            endif
        endmethod
        method operator dx takes nothing returns real
            return xvel_p
        endmethod
        method operator dy takes nothing returns real
            return yvel_p
        endmethod
        method operator angle takes nothing returns real
            return angle_p
        endmethod
        method operator speed takes nothing returns real
            return speed_p
        endmethod
        method operator dx= takes real dx returns nothing
            set xvel_p = dx
            set angle_p = Atan2(yvel_p, xvel_p)
            set speed_p = SquareRoot(xvel_p*xvel_p + yvel_p*yvel_p)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method operator dy= takes real dy returns nothing
            set yvel_p = dy
             set angle_p = Atan2(yvel_p, xvel_p)
            set speed_p = SquareRoot(xvel_p*xvel_p + yvel_p*yvel_p)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method operator angle= takes real angle returns nothing
            set angle_p = angle
            set xvel_p = speed_p*Cos(angle)
            set yvel_p = speed_p*Sin(angle)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method operator speed= takes real speed returns nothing
            set speed_p = speed
            set xvel_p = speed_p*Cos(angle)
            set yvel_p = speed_p*Sin(angle)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method setVelocityXY takes real x, real y returns nothing
            set xvel_p = x
            set yvel_p = y
            set angle_p = Atan2(y, x)
            set speed_p = SquareRoot(x*x + y*y)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method setVelocity takes real speed, real angle returns nothing
            set angle_p = angle
            set speed_p = speed
            set xvel_p = speed*Cos(angle)
            set yvel_p = speed*Sin(angle)
            call SetTextTagVelocity(tag_p, xvel_p, yvel_p)
        endmethod
        method operator relativeX takes nothing returns real
            return posOffX_p
        endmethod
        method operator relativeY takes nothing returns real
            return posOffY_p
        endmethod
        method operator relativeX= takes real relativeX returns nothing
            set posOffX_p = relativeX
        endmethod
        method operator relativeY= takes real relativeY returns nothing
            set posOffY_p = relativeY
        endmethod
        
        private static method onInit takes nothing returns nothing
            set table = Table.create()
            set timerGroup = TimerGroup32.create(function thistype.update)
        endmethod
    endstruct
endlibrary
[/jass]