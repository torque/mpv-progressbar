class BarAccent extends Subscriber
	barSize = settings['bar-height-active']

	updateSize: ( w, h ) =>
		super w, h
		@yPos = h - barSize
		@sizeChanged = true

	-- this is really weird because barSize is a local property of this
	-- class, which means that if this method is called on a single
	-- instance of a child of this class, it affects all instances of all
	-- children of this class. Really good programming technique here, and
	-- I'm sure this won't come back to bite me.
	changeBarSize: ( size ) =>
		barSize = size
