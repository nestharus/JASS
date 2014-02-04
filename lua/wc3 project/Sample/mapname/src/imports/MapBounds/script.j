library MapBounds uses Init /*
************************************************************************************
*
*   struct MapBounds extends array
*
*       readonly static integer maxX
*       readonly static integer maxY
*       readonly static integer minX
*       readonly static integer minY
*
*       readonly static integer centerX
*       readonly static integer centerY
*
*       readonly static rect rect
*       readonly static region region
*
************************************************************************************/
    struct MapBounds extends array
        readonly static integer maxX
        readonly static integer maxY
        readonly static integer minX
        readonly static integer minY
		
        readonly static integer centerX
        readonly static integer centerY
		
        readonly static rect rect
        readonly static region region
		
		private static method init takes nothing returns nothing
			set rect = GetWorldBounds()
			
			set region = CreateRegion()
			call RegionAddRect(region, rect)
			
            set maxX = R2I(GetRectMaxX(rect))
            set maxY = R2I(GetRectMaxY(rect))
            set minX = R2I(GetRectMinX(rect))
            set minY = R2I(GetRectMinY(rect))
			
            set centerX = R2I((maxX + minX)/2)
            set centerY = R2I((minY + maxY)/2)
		endmethod
		
        implement Init
    endstruct
endlibrary