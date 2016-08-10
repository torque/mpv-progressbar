class Subscriber extends Rect

	active_height = settings['hover-zone-height']

	new: =>
		super 0, 0, 0, 0

		@hovered = false
		@needsUpdate = false
		@active = false
		@deactivate = ->
			@active = false

	stringify: =>
		if not @active
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - active_height
		@w, @h = w, active_height

	hoverCondition: ( inputState ) =>
		with inputState
			return ((not .mouseDead and @containsPoint( .mouseX, .mouseY )) or .displayRequested)

	update: ( inputState ) =>
		with inputState
			update = @needsUpdate
			@needsUpdate = false

			if (.mouseInWindow or .displayRequested) and @hoverCondition inputState
				unless @hovered
					update = true
					@hovered = true
					@animation\interrupt false, @animationQueue
					@active = true
			else
				if @hovered
					update = true
					@hovered = false
					@animation\interrupt true, @animationQueue
					@animation.finishedCb = @deactivate

			return update
