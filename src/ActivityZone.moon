class ActivityZone extends Rect
	new: ( @resize, @activityCheck ) =>
		super!
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

		return nowActive
