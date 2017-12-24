class BarAccent extends UIElement
	barSize = settings['bar-height-active']

	new: =>
		super!
		@yPos = Window.h - barSize

	reconfigure: =>
		super!
		barSize = settings['bar-height-active']

	resize: =>
		@yPos = Window.h - barSize
		@needsUpdate = true

	update: =>
		if @barSize != barSize
			@barSize = barSize
			@resize!

	-- This is still weird although perhaps somewhat less semantically confusing.
	-- Moonscript subclasses do inherit class methods.
	@changeBarSize: ( size ) ->
		barSize = size
