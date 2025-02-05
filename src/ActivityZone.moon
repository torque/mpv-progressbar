class ActivityZone extends Rect
	new: ( @resize, @activityCheck ) =>
		super!
		@active = false
		@elements = Stack!

	reconfigure: =>
		@active = false

	addUIElementBefore: ( new, existing ) =>
		@elements\insertBefore new, existing

	addUIElement: ( element ) =>
		@elements\insert element
		element\activate @active

	removeUIElement: ( element ) =>
		@elements\remove element

	-- bottom-up click propagation does not deal with mouse down/up events.
	clickHandler: ( button ) =>
		unless @containsPoint Mouse.clickX, Mouse.clickY
			return

		for _, element in ipairs @elements
			-- if clickHandler returns false, the click stops propagating.
			if element.clickHandler and element\clickHandler( button ) == false
				break

	activityCheck: ( displayRequested ) =>
		if displayRequested == true
			return true
		unless Mouse.inWindow
			return false
		if Mouse.dead
			return false
		return @containsPoint Mouse.x, Mouse.y

	update: ( displayRequested, clickPending ) =>
		nowActive = @activityCheck displayRequested

		if @active != nowActive
			@active = nowActive
			for id, element in ipairs @elements
				element\activate nowActive

		if clickPending != false
			@clickHandler clickPending

		return nowActive
