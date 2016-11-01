class TopSubscriber extends Subscriber

	top_height = settings['top-hover-zone-height']

	new: =>
		super!
		@topZone = Rect 0, 0, 0, top_height

	updateSize: ( w, h ) =>
		super w, h
		@topZone\setSize w

	hoverCondition: ( inputState ) =>
		if inputState.displayRequested
			return true

		unless inputState.mouseDead
			return @zone\containsPoint( inputState.mouseX, inputState.mouseY ) or @topZone\containsPoint inputState.mouseX, inputState.mouseY
		else
			return false
