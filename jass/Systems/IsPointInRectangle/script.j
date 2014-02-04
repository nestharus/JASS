library IsPointInRectangle
    //determines if point P is in rectangle ABCD
    function IsPointInRectangle takes real ax, real ay, real bx, real by, real cx, real cy, real dx, real dy, real px, real py returns boolean
        local real cross0 = (py-ay)*(bx-ax)-(px-ax)*(by-ay)
        local real cross1 = (py-cy)*(ax-cx)-(px-cx)*(ay-cy)
        local real cross4 = (py-dy)*(ax-dx)-(px-dx)*(ay-dy)
        
        return ((cross0*cross1 >= 0) and (((py-by)*(cx-bx)-(px-bx)*(cy-by))*cross1 >= 0)) or ((cross0*cross4 >= 0) and (((py-by)*(dx-bx)-(px-bx)*(dy-by))*cross4 >= 0))
    endfunction
endlibrary