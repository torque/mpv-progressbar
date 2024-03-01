class BarAccent extends UIElement
	barSize = settings['bar-height-active']

	new: =>
		super!
		@yPos = barSize

	reconfigure: =>
		super!
		barSize = settings['bar-height-active']

	resize: =>
		@yPos = barSize
		@needsUpdate = true

	redraw: =>
		if @barSize != barSize
			@barSize = barSize
			@resize!

	-- This is still weird although perhaps somewhat less semantically confusing.
	-- Moonscript subclasses do inherit class methods.
	@changeBarSize: ( size ) ->
		barSize = size
