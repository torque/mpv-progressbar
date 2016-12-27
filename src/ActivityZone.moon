class ActivityZone extends Rect
	new: ( x, y, w, h, @activityCheck ) =>
		super x, y, w, h
		@active = false
		@elements = Stack!

	addUIElement: ( element ) =>
		@elements\insert element

	activityCheck: ( displayRequested ) =>
		if displayRequested
			return true

		if Mouse.inWindow or not Mouse.dead
			return @containsPoint Mouse.x, Mouse.y
		else
			return false

	update: ( displayRequested, clickPending ) =>
		nowActive = @activityCheck displayRequested

		if @active != nowActive
			@active = nowActive
			for id, element in ipairs @elements
				element\activate nowActive
				element\update!
		else
			for id, element in ipairs @elements
				if needsResize == true
					element\resize!
				element\update!

		return nowActive
