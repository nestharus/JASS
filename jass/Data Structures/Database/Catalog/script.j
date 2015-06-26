library Catalog /* v1.2.1.1
*************************************************************************************
*
*   A system used to generate catalogs of objects by hashing raw code ids into indexed
*   ids. Catalogs can be used in save/load systems to save things like units and items.
*
*   Also includes catalog loops, which are used to iterate through all values in a catalog.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ Table /*         hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
************************************************************************************
*
*   Functions
*
*       function CatalogCreate takes nothing returns integer
*           -   Creates a new Catalog
*       function CatalogDestroy takes integer b returns nothing
*           -   Destroys a catalog
*       function CatalogAdd takes integer catalog, integer value returns nothing
*           -   Adds a value to the catalog
*       function CatalogAddCatalog takes integer catalog, integer catalogToAdd returns nothing
*           -   Adds a catalog to the catalog
*       function CatalogId takes integer catalog, integer value returns integer
*           -   Retrieves catalog id of raw value
*       function CatalogRaw takes integer catalog, integer value returns integer
*           -   Retrieves the raw value given catalog id
*       function CatalogCount takes integer catalog returns integer
*           -   Retrieves total items in catalog (includes added catalogs)
*
*       function CatalogLoopCreate takes Catalog catalogToLoopOver, integer startIndex returns CatalogLoop
*           -   Creates a new catalog loop for looping over all values within a catalog
*           -   Catalog loops are automatically destroyed when the loop is finished
*       function CatalogLoopDestroy takes CatalogLoop catalogLoop returns nothing
*           -   Destroys a catalog loop
*           -   Only needs to be called if the loop isn't finished
*       function CatalogLoopNext takes CatalogLoop catalogLoop, integer indexDelta returns integer
*           -   Retrieves the index+indexDelta value in the catalog loop. An indexDelta of 1 would
*           -   retrieve the next value.
*
*       function GetFirstAddedCatalog takes Catalog catalog returns integer
*           -   Get the first catalog added to catalog
*       function GetNextAddedCatalog takes Catalog catalog, Catalog addedCatalog returns integer
*           -   Get next added catalog from current added catalog
*
*           local Catalog subCatalog = GetFirstAddedCatalog(catalog)
*           loop
*               exitwhen subCatalog == catalog
*
*               //code
*
*               set subCatalog = GetNextAddedCatalog(catalog, subCatalog)
*           endloop
*
************************************************************************************
*
*   struct Catalog extends array
*
*       -   General catalog (struct API)
*
*       readonly integer count
*           -   Number of values in catalog
*
*       static method create takes nothing returns Catalog
*           -   Creates new catalog
*       method destroy takes nothing returns nothing
*           -   Destroys catalog (does all necessary cleanup)
*
*       method raw takes integer id returns integer
*           -   id->raw
*       method id takes integer raw returns integer
*           -   raw->id
*
*       method add takes integer value returns nothing
*           -   Adds new value to catalog
*       method addCatalog takes Catalog catalog returns nothing
*           -   Adds catalog to catalog
*
*       method operator firstCatalog takes nothing returns thistype
*           -   See function
*       method getNextCatalog takes Catalog addedCatalog returns thistype
*           -   See function
*
*   module Catalog
*
*       -   Implements a catalog into the struct
*
*       readonly static Catalog catalog
*           -   Retrieves the instance id of the catalog. Used for adding it to other
*           -   catalogs.
*       readonly static integer count
*           -   Retrieves the total amount of values inside of the catalog. Includes totals
*           -   of added catalogs.
*       readonly integer raw
*           -   Gets the raw value given a catalog value. Raw values are the
*           -   original values that were added.
*
*           -   Ex: integer raw = Catalog[1].raw
*       readonly integer id
*           -   Gets the catalog id given a raw value
*
*           -   Ex: integer id = Catalog['hpea'].id
*
*       static method add takes integer value returns nothing
*           -   Adds a value to the catalog. Values already inside of the catalog
*           -   or inside of any catalog that it contains are not added.
*       static method addCatalog takes Catalog catalog returns nothing
*           -   Adds a catalog and all of its inner catalogs to the catalog.
*           -   Catalogs already inside of the catalog are not added.
*
*       static method operator firstCatalog takes nothing returns thistype
*           -   See function
*       method operator getNextCatalog takes nothing returns thistype
*           -   See function
*
*   struct CatalogLoop extends array
*
*       -   General Catalog Loop (struct API)
*
*       readonly integer next
*
*       static method create takes Catalog catalog, integer startIndex returns CatalogLoop
*       method destroy takes nothing returns nothing
*
*       method skip takes integer toSkip returns integer
*
*   module CatalogLoop
*
*       -   Implements a catalog loop into a struct that has a catalog implemented in it.
*       -   Must be implemented *BELOW* the Catalog implementation.
*
*       readonly integer next
*
*       static method create takes integer startIndex returns CatalogLoop
*       method destroy takes nothing returns nothing
*
*       method skip takes integer toSkip returns integer
*
***********************************************************************************/
    globals
        private integer w=0         //catalog instance count
        private Table d             //recycler
        private Table c             //catalog count
        private Table array i       //id given rawcode
        private Table array r       //rawcode given id
        private Table array en      //extends next
        private Table array ep      //extends previous
        private Table array pn      //point back next
        private Table array pp      //point back previous
        
        private integer array clr   //catalog looper recycler
        private integer clic = 0    //catalog looper instance count
        private Table array clthv   //catalog looper has visited
        private Table array cltv    //catalog looper to be visited
        private Table array cltvp   //catalog looper to be visited parent
        private integer array cltvc //catalog looper to be visted count
        private integer array clcv  //catalog looper current visited
        private integer array clp   //catalog looper current parent
        private integer array clvi  //catalog looper visited index
    endglobals
    private module N
        private static method onInit takes nothing returns nothing
            set d=Table.create()
            set c=Table.create()
        endmethod
    endmodule
    private struct S extends array
        implement N
    endstruct
    function CatalogCreate takes nothing returns integer
        local integer t
        
        //allocate catalog
        if (0==d[0]) then
            set t=w+1
            set w=t
        else
            set t=d[0]
            set d[0]=d[t]
        endif
        
        //generate tables
        set i[t]=Table.create()     //id table
        set r[t]=Table.create()     //rawcode id table
        
        //catalog lists
        set pn[t]=Table.create()    //point back
        set pp[t]=Table.create()    //point back
        set en[t]=Table.create()    //table extensions
        set ep[t]=Table.create()    //table extensions
        
        //initialize lists
        set pn[t][t]=t
        set pp[t][t]=t
        set en[t][t]=t
        set ep[t][t]=t
        
        return t
    endfunction
    function CatalogDestroy takes integer t returns nothing
        //loop through all lists catalog is on and remove it
        local integer b=pn[t][t]
        loop
            exitwhen t==b
            set ep[b][en[b][t]]=ep[b][t]
            set en[b][ep[b][t]]=en[b][t]
            call en[b].remove(t)
            call ep[b].remove(t)
            set b=pn[t][b]
        endloop
        
        //loop through all lists of catalog and remove point backs
        set b=en[t][t]
        loop
            exitwhen t==b
            set pp[b][pn[b][t]]=pp[b][t]
            set pn[b][pp[b][t]]=pn[b][t]
            call pn[b].remove(t)
            call pp[b].remove(t)
            set b=en[t][b]
        endloop
        
        //destroy list tables
        call en[t].destroy()
        call ep[t].destroy()
        call pp[t].destroy()
        call pn[t].destroy()
        
        //destroy id tables
        call i[t].destroy()
        call r[t].destroy()
        
        //delete count
        call c.remove(t)
        
        //recycle
        set d[t]=d[0]
        set d[0]=t
    endfunction
    globals
        private integer array cntt
        private integer array cntb
    endglobals
    function CatalogCount takes integer t returns integer
        local Table cs=Table.create()
        local integer v=0
        local integer b=t
        local integer e
        local integer cntd=0
        loop
            if (not cs.boolean.has(b)) then
                set e=en[b][b]
                if (e!=b) then
                    set cntt[cntd]=b
                    set cntb[cntd]=e
                    set cntd=cntd+1
                endif
            
                set cs.boolean[b]=true
                set v=v+c[b]
            endif
            
            set b=en[t][b]
            
            if (b==t) then
                exitwhen 0==cntd
                set cntd=cntd-1
                set t=cntt[cntd]
                set b=cntb[cntd]
            endif
        endloop
        
        call cs.destroy()
        
        return v
    endfunction
    function CatalogRaw takes integer t,integer v returns integer
        local Table cs=Table.create()
        local integer b=t
        local integer e
        local integer cntd=0
        local integer y
        
        loop
            if (not cs.boolean.has(b)) then
                set y=c[b]
            
                if (v<=y) then
                    call cs.destroy()
                    return r[b][v]
                endif
                
                set e=en[b][b]
                if (e!=b) then
                    set cntt[cntd]=b
                    set cntb[cntd]=e
                    set cntd=cntd+1
                endif
            
                set cs.boolean[b]=true
                
                set v=v-y
            endif
            
            set b=en[t][b]
            
            if (b==t) then
                if (0==cntd) then
                    call cs.destroy()
                    return 0
                endif
                
                set cntd=cntd-1
                set t=cntt[cntd]
                set b=cntb[cntd]
            endif
        endloop
        
        return 0
    endfunction
    function CatalogId takes integer t,integer v returns integer
        local Table cs=Table.create()
        local integer b=t
        local integer e
        local integer cntd=0
        local integer l = 0
        
        loop
            if (not cs.boolean.has(b)) then
                if (i[b].has(v)) then
                    call cs.destroy()
                    return i[b][v]+l
                endif
                
                set l=l+c[b]
            
                set e=en[b][b]
                if (e!=b) then
                    set cntt[cntd]=b
                    set cntb[cntd]=e
                    set cntd=cntd+1
                endif
            
                set cs.boolean[b]=true
            endif
            
            set b=en[t][b]
            
            if (b==t) then
                if (0==cntd) then
                    call cs.destroy()
                    return 0
                endif
                
                set cntd=cntd-1
                set t=cntt[cntd]
                set b=cntb[cntd]
            endif
        endloop
        
        return 0
    endfunction
    
    function CatalogAdd takes integer t,integer v returns nothing
        if (not i[t].has(v)) then           //if catalog doesn't have value
            set c[t]=c[t]+1                 //increase catalog count
            set i[t][v]=c[t]                //raw->id
            set r[t][c[t]]=v                //id->raw
        endif
    endfunction
    function CatalogAddCatalog takes integer t,integer b returns nothing
        debug if (not en[t].has(b)) then
        
            //add to catalog list
            set ep[t][b]=ep[t][t]
            set en[t][b]=t
            set en[t][ep[t][t]]=b
            set ep[t][t]=b
            
            //add to point back list of catalog 2
            set pp[b][t]=pp[b][b]
            set pn[b][t]=b
            set pn[b][pp[b][b]]=t
            set pp[b][b]=t
        debug endif
    endfunction
    function GetFirstAddedCatalog takes integer t returns integer
        return en[t][t]
    endfunction
    function GetNextAddedCatalog takes integer t, integer b returns integer
        return en[t][b]
    endfunction
    
    function CatalogLoopDestroy takes integer cl returns nothing
        set clr[cl]=clr[0]
        set clr[0]=cl
        
        call cltv[cl].destroy()
        call cltvp[cl].destroy()
        call clthv[cl].destroy()
    endfunction
    
    function CatalogLoopNext takes integer cl,integer id returns integer
        local Table cs=clthv[cl]
        local integer b=clcv[cl]
        local integer t=clp[cl]
        local integer e
        local integer cntd=cltvc[cl]
        local integer y=c[b]
        local integer v=clvi[cl]
        
        if (0>=id) then
            set id=1
        endif
        
        loop
            set v=v+1
            loop
                exitwhen v>y
                set id=id-1
                if (0==id) then
                    set clvi[cl]=v
                    return r[b][v]
                endif
            endloop
            
            if (not cs.boolean.has(b)) then
                set cs.boolean[b]=true
                set clcv[cl]=b
                
                set e=en[b][b]
                if (e!=b) then
                    set cltvp[cl][cltvc[cl]]=b
                    set cltv[cl][cltvc[cl]]=e
                    set cltvc[cl]=cltvc[cl]+1
                endif
            endif
            
            set b=en[t][b]
            set clcv[cl]=b
            set y=c[b]
            set v=0
            
            if (b==t) then
                if (0==cltvc[cl]) then
                    call CatalogLoopDestroy(cl)
                    return 0
                endif
                
                set cltvc[cl]=cltvc[cl]-1
                set t=cltvp[cl][cltvc[cl]]
                set b=cltv[cl][cltvc[cl]]
                set y=c[b]
                set v=0
                
                set clp[cl]=t
                set clcv[cl]=b
            endif
        endloop
        
        return 0
    endfunction
    
    function CatalogLoopCreate takes integer t,integer si returns integer
        local integer cl
        
        if (0==clr[0]) then
            set cl=clic+1
            set clic=cl
        else
            set cl=clr[0]
            set clr[0]=clr[cl]
            
            set cltvc[cl]=0
            set clvi[cl]=0
        endif
        
        set cltv[cl]=Table.create()
        set cltvp[cl]=Table.create()
        set clthv[cl]=Table.create()
        set clcv[cl]=t
        set clp[cl]=t
        set clthv[cl].boolean[t] = true
        
        if (1<si) then
            call CatalogLoopNext(cl,si-1)
        endif
        
        return cl
    endfunction
    struct Catalog extends array
        static method create takes nothing returns thistype
            return CatalogCreate()
        endmethod
        method destroy takes nothing returns nothing
            call CatalogDestroy(this)
        endmethod
        method raw takes integer id returns integer
            return CatalogRaw(this,id)
        endmethod
        method id takes integer raw returns integer
            return CatalogId(this,raw)
        endmethod
        method add takes integer v returns nothing
            call CatalogAdd(this,v)
        endmethod
        method addCatalog takes Catalog catalog returns nothing
            call CatalogAddCatalog(this,catalog)
        endmethod
        method operator count takes nothing returns integer
            return CatalogCount(this)
        endmethod
        method operator firstCatalog takes nothing returns thistype
            return GetFirstAddedCatalog(this)
        endmethod
        method getNextCatalog takes integer catalog returns thistype
            return GetNextAddedCatalog(this, catalog)
        endmethod
    endstruct
    struct CatalogLoop extends array
        static method create takes Catalog catalog, integer startIndex returns CatalogLoop
            return CatalogLoopCreate(catalog, startIndex)
        endmethod
        method destroy takes nothing returns nothing
            call CatalogLoopDestroy(this)
        endmethod
        method operator next takes nothing returns integer
            return CatalogLoopNext(this, 1)
        endmethod
        method skip takes integer toSkip returns integer
            return CatalogLoopNext(this, toSkip+1)
        endmethod
    endstruct
    module Catalog
        readonly static Catalog catalog    //catalog instance
        method operator raw takes nothing returns integer
            return CatalogRaw(catalog,this)
        endmethod
        static method operator count takes nothing returns integer
            return CatalogCount(catalog)
        endmethod
        method operator id takes nothing returns integer
            return CatalogId(catalog,this)
        endmethod
        static method add takes integer v returns nothing
            call CatalogAdd(catalog, v)
        endmethod
        static method addCatalog takes integer catalog returns nothing
            call CatalogAddCatalog(thistype.catalog, catalog)
        endmethod
        static method operator firstCatalog takes nothing returns thistype
            return GetFirstAddedCatalog(thistype.catalog)
        endmethod
        method operator getNextCatalog takes nothing returns thistype
            return GetNextAddedCatalog(thistype.catalog, this)
        endmethod
        private static method onInit takes nothing returns nothing
            set catalog = CatalogCreate()
        endmethod
    endmodule
    module CatalogLoop
        static method create takes integer startIndex returns CatalogLoop
            return CatalogLoopCreate(catalog, startIndex)
        endmethod
        method destroy takes nothing returns nothing
            call CatalogLoopDestroy(this)
        endmethod
        method operator next takes nothing returns integer
            return CatalogLoopNext(this, 1)
        endmethod
        method skip takes integer toSkip returns integer
            return CatalogLoopNext(this, toSkip+1)
        endmethod
    endmodule
endlibrary