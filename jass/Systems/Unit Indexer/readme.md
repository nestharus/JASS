Details

        Assigns unique indexes to units via unit user data.

        This is an extremely optimal unit indexing system. If you've ever heard of AIDS or AutoIndex, you
        know that there are at least two other unit indexing systems.

        AutoIndex is the most cumbersome and slowest of all of the indexing systems, but it comes with a poorly
        coupled AutoEvent and nice modules unlike AIDS, which is why many people prefer it. It also allows units
        to be retrieved before going out of scope. It also has static ifs in the module to make code more optimal.
        It also hooks RemoveUnit in order to catch unit removal.

        AIDS is an indexing system created by jesus4lyf that provides locks and is much faster than AutoIndex.
        However, AIDS can't retrieve units before they go out of scope and has textmacro API rather than a module one.
        It also has no static ifs in the module, making the code rather sloppy.

        Both run on the undefend ability in order to work. Undefend runs twice, once for death and once for removal.

        UnitIndexer uses the fact that undefend is removed from a unit at removal. This means that rather than running
        a timer to see if a unit is null or not, it just checks to see if the undefend ability level is 0. It is the
        only system that does this, and as a result, it can retrieve units before going out of scope without hooking
        RemoveUnit. It can also detect deindexing units w/o timers, loops, and all sorts of other trinkets.

        UnitIndexer has the tightest struct code of all 3, using intense static ifs to absolutely minimize the code.
        If none of the events are used in the module, then onInit won't even be written.

        UnitIndexer is coupled nicely (easy to read code) with UnitEvent so as to provide the most optimal unit event
        detection possible. Unit event detection runs off of undefend as well, meaning that they both must run through
        the same core to make detection fast. Furthermore, UnitEvent uses timestamps to determine whether a unit was
        removed or decayed, unlike AutoEvent. If UnitIndexer is the only system present, then only UnitIndexer code
        will be present. AutoIndex has a lot of code that's only ever useful when AutoEvent is present.

        UnitIndexer is the fastest and easiest to use of the three unit indexing systems. It is also currently
        the only 100% stable unit indexing system (much was looked into on initialization to ensure that early
        index events were registered for all early indexed units) (much was done with lua to ensure 0% chance of
        object id collision).

        UnitIndexer and UnitEvent have been thoroughly tested and work brilliantly.
        
Known Issues

        If you pause a non hero unit that is currently in a transport, be sure to unpause it before removing it
        or deindex will not fire.

Status

        Finished

Requirements

        Event
                
                https://github.com/HiveWorkshop/JASS-Code/tree/master/Event
                
        World Bounds
                
                
                https://github.com/HiveWorkshop/JASS-Code/tree/master/World%20Bounds