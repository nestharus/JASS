library IndexedArray /* v1.0.0.1
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   //! textmacro INDEXED_ARRAY takes SCOPE, NAME, TYPE
*
*       Description
*       -------------------------
*
*           Creates indexed array of TYPE
*
*       Fields
*       -------------------------
*
*           readonly static integer count
*
*       Operators
*       -------------------------
*
*           static method operator [] takes integer index returns $TYPE$
*           static method operator []= takes integer index, $TYPE$ value returns nothing
*
*       Methods
*       -------------------------
*
*           static method enqueue takes $TYPE$ value returns nothing
*
*           static method pop takes nothing returns nothing
*           static method dequeue takes nothing returns nothing
*           static method remove takes integer index returns nothing
*
*           static method clear takes nothing returns nothing
*
************************************************************************************/
    //! textmacro INDEXED_ARRAY takes SCOPE, NAME, TYPE
        $SCOPE$ struct $NAME$ extends array
            readonly static integer count = 0
            private static $TYPE$ array arr
            
            static method enqueue takes $TYPE$ value returns nothing
                debug call ThrowError(count == 8191, "IndexedArray", "enqueue", "thistype", 0, "Overflow.")
                set arr[count] = value
                set count = count + 1
            endmethod
            static method pop takes nothing returns nothing
                debug call ThrowError(count == 0, "IndexedArray", "pop", "thistype", this, "Attempted To Pop Empty thistype.")
                set count = count - 1
                set arr[0] = arr[count]
            endmethod
            static method dequeue takes nothing returns nothing
                debug call ThrowError(count == 0, "IndexedArray", "dequeue", "thistype", this, "Attempted To Dequeue Empty thistype.")
                set count = count - 1
            endmethod
            static method remove takes integer index returns nothing
                debug call ThrowError(index >= count, "IndexedArray", "remove", "thistype", 0, "Attempted To Remove Out Of Bounds Index (" + I2S(index) + ").")
                set count = count - 1
                set arr[index] = arr[count]
            endmethod
            static method operator [] takes integer index returns $TYPE$
                debug call ThrowWarning(index >= count, "IndexedArray", "[]", "thistype", 0, "Read Out Of Bounds Index (" + I2S(index) + ").")
                return arr[index]
            endmethod
            static method operator []= takes integer index, $TYPE$ value returns nothing
                debug call ThrowWarning(index >= count, "IndexedArray", "[]=", "thistype", 0, "Set Out Of Bounds Index (" + I2S(index) + ").")
                set arr[index] = value
            endmethod
            static method clear takes nothing returns nothing
                set count = 0
            endmethod
        endstruct
    //! endtextmacro
endlibrary