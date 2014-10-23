-- Rect is the base class from which all other classes inherit. It has 4
-- instance variables: the x and y coordinates of the top left corner,
-- the width and the height.

-- Constructor arguments:
-- x (Rect): x position from left side of window. (pixels)
-- y (Rect): y position from left side of window. (pixels)
-- w (Rect): width. (pixels)
-- h (Rect): height. (pixels)

class Rect
	new: ( @x, @y, @w, @h ) =>

	setPosition: ( x, y ) =>
		@x = x or @x
		@y = y or @y

	setDimensions: ( w, h ) =>
		@w = w or @w
		@h = h or @h

	move: ( x, y ) =>
		@x += x or 0
		@y += y or 0

	stretch: ( w, h ) =>
		@w += w or 0
		@h += h or 0

	containsPoint: ( x, y ) =>
		return ((x >= @x) and (y >= @y) and (x < @x + @w) and (y < @y + @h))
