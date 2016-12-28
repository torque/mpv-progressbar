-- Rect is the base class from which all other classes inherit. It has 4
-- instance variables: the x and y coordinates of the top left corner,
-- the width and the height.

-- Constructor arguments:
-- x (Rect): x position from left side of window. (pixels)
-- y (Rect): y position from left side of window. (pixels)
-- w (Rect): width. (pixels)
-- h (Rect): height. (pixels)

class Rect
	new: ( @x = -1, @y = -1, @w = -1, @h = -1 ) =>
		@cacheMaxBounds!

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

	containsPoint: ( x, y ) =>
		return (x >= @x) and (x < @xMax) and (y >= @y) and (y < @yMax)
