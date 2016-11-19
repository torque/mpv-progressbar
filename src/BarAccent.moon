class BarAccent extends UIElement
	barSize = settings['bar-height-active']

	updateSize: =>
		@yPos = Window.h - barSize

	-- this is really weird because barSize is a local property of this
	-- class, which means that if this method is called on a single
	-- instance of a child of this class, it affects all instances of all
	-- children of this class. Really good programming technique here, and
	-- I'm sure this won't come back to bite me.
	changeBarSize: ( size ) =>
		barSize = size
