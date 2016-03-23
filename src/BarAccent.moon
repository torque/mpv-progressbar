class BarAccent extends Subscriber
	barSize = settings['bar-height-active']

	updateSize: ( w, h ) =>
		super w, h
		@yPos = h - barSize
		@sizeChanged = true
