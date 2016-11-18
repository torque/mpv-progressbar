class UIElement

	active_height = settings['hover-zone-height']

	new: =>
		@needsUpdate = false
		@active = false
		@deactivate = ->
			@active = false

	stringify: =>
		return "" if not @active
		return table.concat @line

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
