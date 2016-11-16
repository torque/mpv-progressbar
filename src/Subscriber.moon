class Subscriber

	active_height = settings['hover-zone-height']

	new: =>
		@zone = Rect 0, 0, 0, 0

		@hovered = false
		@needsUpdate = false
		@active = false
		@deactivate = ->
			@active = false

	stringify: =>
		return "" if not @active
		return table.concat @line

	updateSize: ( w, h ) =>
		@zone\reset nil, h - active_height, w, h

	hoverCondition: ( inputState ) =>
		if inputState.displayRequested
			return true

		unless inputState.mouseDead
			return @zone\containsPoint inputState.mouseX, inputState.mouseY
		else
			return false

	update: ( inputState ) =>
		with inputState
			update = @needsUpdate
			@needsUpdate = false
			if (.mouseInWindow or .displayRequested) and @hoverCondition inputState
				unless @hovered
					update = true
					@hovered = true
					@animation\interrupt false
					@active = true
			else
				if @hovered
					update = true
					@hovered = false
					@animation\interrupt true
					@animation.finishedCb = @deactivate

			return update
