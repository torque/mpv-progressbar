class Subscriber extends Rect

	active_height = settings['hover-zone-height']

	new: =>
		super 0, 0, 0, 0

		@hovered = false
		@needsUpdate = false

	stringify: =>
		if not @hovered and not @animation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - active_height
		@w, @h = w, active_height

	update: ( inputState, hoverCondition ) =>
		with inputState
			if hoverCondition == nil
				hoverCondition = ((not .mouseDead and @containsPoint( .mouseX, .mouseY )) or .displayRequested)
			update = @needsUpdate
			@needsUpdate = false

			if (.mouseInWindow or .displayRequested) and hoverCondition
				unless @hovered
					update = true
					@hovered = true
					@animation\interrupt false, @animationQueue
			else
				if @hovered
					update = true
					@hovered = false
					@animation\interrupt true, @animationQueue

			return update
