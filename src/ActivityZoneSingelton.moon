-- Only one element can be simultaneously displayed
class ActivityZoneSingelton extends ActivityZone
	addUIElement: ( element ) =>
		element\setActivator self
		super element

	update: ( displayRequested, clickPending ) =>
		nowActive = @displayedElement != nil

		if @active != nowActive or displayRequested
			@active = nowActive

			for _, element in ipairs @elements
				element\activate element == self.displayedElement

		if clickPending
			@clickHandler!

		return nowActive

	-- Called by the element
	activate: ( element, duration ) =>
		elementChanged = @displayedElement != element
		@displayedElement = element

		if @displayedElement and elementChanged
			@update true

		if duration > 0
			if @displayRequestTimer
				@displayRequestTimer\kill!

			@displayRequestTimer = mp.add_timeout duration, ->
				@displayedElement = nil
