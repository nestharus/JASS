Functions

        function RegisterUnitIndexEvent takes boolexpr codeToRegister, Event unitIndexEvent returns nothing
        function TriggerRegisterUnitIndexEvent takes trigger triggerToRegister, Event unitIndexEvent returns nothing

        function GetUnitById takes integer index returns unit
            -   Returns unit given a unit index
        function GetUnitId takes unit u returns integer
            -   Returns unit index given a unit

        function IsUnitIndexed takes unit u returns boolean
        function IsUnitDeindexing takes unit u returns boolean

        function GetIndexedUnitId takes nothing returns integer
        function GetIndexedUnit takes nothing returns unit

module UnitIndexStructMethods
   
        static method operator [] takes unit u returns thistype
            -   Return GetUnitUserData(u)

        readonly unit unit
            -   The indexed unit of the struct

module UnitIndexStruct extends UnitIndexStructMethods

        -   A pseudo module interface that runs a set of methods if they exist and provides
        -   a few fields and operators. Runs on static ifs to minimize code.

        readonly boolean allocated
            -   Is unit allocated for the struct

        Interface:

            -   These methods don't have to exist. If they don't exist, the code
            -   that calls them won't even be in the module.

            private method index takes nothing returns nothing
                -   called when a unit is indexed and passes the filter.
                -
                -   thistype this:              Unit's index
            private method deindex takes nothing returns nothing
                -   called when a unit is deindexed and is allocated for struct
                -
                -   thistype this:              Unit's index
            private static method filter takes unit unitToIndex returns boolean
                -   Determines whether or not to allocate struct for unit
                -
                -   unit unitToIndex:           Unit being filtered

struct UnitIndexer extends array

         -    Controls the unit indexer system.

        static constant Event UnitIndexer.INDEX
        static constant Event UnitIndexer.DEINDEX
            -   Don't register functions and triggers directly to the events. Register them via
            -   RegisterUnitIndexEvent and TriggerRegisterUnitIndexEvent.

        static boolean enabled
            -   Enables and disables unit indexing. Useful for filtering out dummy units.

struct UnitIndex extends UnitIndexStructMethods

        -    Constrols specific unit indexes.

        integer locks
            -    The lock and unlock methods do not inline. This does inline.

        method lock takes nothing returns nothing
            -   Locks an index. When an index is locked, it will not be recycled
            -   when the unit is deindexed until all locks are removed. Deindex
            -   events still fire at the appropriate times, the index just doesn't
            -   get thrown into the recycler.
        method unlock takes nothing returns nothing
            -   Unlocks an index.