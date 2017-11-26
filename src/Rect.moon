-- Rect is the base class from which all other classes inherit. It has 4
-- instance variables: the x and y coordinates of the top left corner,
-- the width and the height.

-- Constructor arguments:
-- x (Rect): x position from left side of window. (pixels)
-- y (Rect): y position from top edge of window. (pixels)
-- w (Rect): width. (pixels)
-- h (Rect): height. (pixels)

class Rect
	x: 0
	y: 0
	w: 0
	h: 0
	xMax: 0
	yMax: 0

	new: ( ... ) =>
		@reset ...

	cacheMaxBounds: =>
		@xMax = @x + @w
		@yMax = @y + @h

	setPosition: ( x, y ) =>
		@x = x or @x
		@y = y or @y
		@cacheMaxBounds!

	setSize: ( w, h ) =>
		@w = w or @w
		@h = h or @h
		@cacheMaxBounds!

	setXYMax: ( xMax, yMax ) =>
		@xMax = xMax or @xMax
		@yMax = yMax or @yMax
		@w = @xMax - @x
		@h = @yMax - @y

	reset: ( x, y, w, h ) =>
		@x = x or @x
		@y = y or @y
		@w = w or @w
		@h = h or @h
		@cacheMaxBounds!

	move: ( x, y ) =>
		@x += x or @x
		@y += y or @y
		@cacheMaxBounds!

	stretch: ( w, h ) =>
		@w += w or @w
		@h += h or @h
		@cacheMaxBounds!

	draw: =>
		return [[{\pos(0,0)\c&H0000FF&\3c&H000000&\alpha&HBF&\bord2\shad0\an7\p1}m %g %g l %g %g %g %g %g %g{\p0}]]\format @x, @y, @xMax, @y, @xMax, @yMax, @x, @yMax

	containsPoint: ( x, y ) =>
		return (x >= @x) and (x < @xMax) and (y >= @y) and (y < @yMax)
