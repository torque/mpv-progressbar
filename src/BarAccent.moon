class BarAccent extends UIElement
	barSize = settings['bar-height-active']

	resize: =>
		@yPos = Window.h - barSize

	-- This is still weird although perhaps somewhat less semantically confusing.
	-- Moonscript subclasses do inherit class methods.
	@changeBarSize: ( size ) ->
		barSize = size
