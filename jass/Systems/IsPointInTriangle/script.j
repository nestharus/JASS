library IsPointInTriangle
	//check to see if a point P is in triangle ABC
	function IsPointInTriangle takes real ax, real ay, real bx, real by, real cx, real cy, real px, real py returns boolean
		local real cross0 = (py-ay)*(bx-ax)-(px-ax)*(by-ay)
		local real cross1 = (py-cy)*(ax-cx)-(px-cx)*(ay-cy)
		return (cross0*cross1 >= 0) and (((py-by)*(cx-bx)-(px-bx)*(cy-by))*cross1 >= 0)
	endfunction
endlibrary