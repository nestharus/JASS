struct MyListOfStoppedFootmen extends array
    private method filter takes nothing returns boolean
        return GetUnitTypeId(GetUnitById(this))=='hfoo'
    endmethod
    implement StationaryUnitsFileredList
endstruct