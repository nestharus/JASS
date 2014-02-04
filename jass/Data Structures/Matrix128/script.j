library Matrix128 /* v1.0.0.0
*************************************************************************************
*
*   128 bit matrix (array of 16 bytes)
*
************************************************************************************
*
*   struct Matrix128 extends array
*
*       Description
*       -----------------------
*
*           Stores 16 bytes. Used to store data blocks and cipher keys.
*
*               Byte:       0x00 through 0xff
*                              0          255
*
*               Indexes:    0    through   0xf
*                           0               15
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes nothing returns Matrix128
*           method destroy takes nothing returns nothing
*
*       Operators
*       -----------------------
*
*           static method operator [] takes Matrix128 this returns integer
*           static method operator []= takes Matrix128 this, integer byte returns nothing
*
*               -   set byte = Matrix128[data + index]
*               -   set Matrix128[data + index] = byte
*
*           method operator [] takes integer index returns integer
*           method operator []= takes integer index, integer value returns nothing
*
*               -   set byte = matrix[index]
*               -   set matrix[index] = byte
*
*       Fields
*       -----------------------
*
*           integer byte
*
*               -   set Matrix128(data + index).byte = 5
*               -   set byte = Matrix128(data + index).byte
*               -   set data.byte = 5
*               -   set byte = data.byte
*
************************************************************************************/
    struct Matrix128 extends array
        private static integer instanceCount = 1
        private static integer array recycler
        
        integer byte
        
        static method operator [] takes thistype this returns integer
            return byte
        endmethod
        
        static method operator []= takes thistype this, integer byte returns nothing
            set this.byte = byte
        endmethod
        
        method operator [] takes integer index returns integer
            return thistype(this + index).byte
        endmethod
        method operator []= takes integer index, integer value returns nothing
            set thistype(this + index).byte = value
        endmethod
    
        static method create takes nothing returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                debug if (instanceCount + 16 > 8191) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Matrix128 Overflow")
                    debug set this = 1/0
                debug endif
            
                set this = instanceCount
                set instanceCount = this + 16
            else
                set recycler[0] = recycler[this]
            endif
            
            debug set recycler[this] = -1
            
            return this
        endmethod
        method destroy takes nothing returns nothing
            debug if (recycler[this] != -1) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Matrix128 Double Free Error: " + I2S(this))
                debug set this = 1/0
            debug endif
        
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
    endstruct
endlibrary