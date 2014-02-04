library GetTriangleCentroid
    //get centroid x,y of triangle ABC
    
    function GetTriangleCentroidX takes real ax, real bx, real cx returns real
        return (ax+bx+cx)/3
    endfunction
    
    function GetTriangleCentroidY takes real ay, real by, real cy returns real
        return (ay+by+cy)/3
    endfunction
endlibrary