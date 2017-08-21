class ActivityZone extends Rect
	new: ( @resize, @activityCheck ) =>
		super!
		@active = false
		@elements = Stack!

	reconfigure: =>

	addUIElement: ( element ) =>
		@elements\insert element
		element\activate @active

	removeUIElement: ( element ) =>
		@elements\remove element

	-- bottom-up click propagation does not deal with mouse down/up events.
	clickHandler: =>
		unless @containsPoint Mouse.clickX, Mouse.clickY
			return

		for _, element in ipairs @elements
			-- if clickHandler returns false, the click stops propagating.
			if element.clickHandler and not element\clickHandler!
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

		if clickPending
			@clickHandler!

		return nowActive
