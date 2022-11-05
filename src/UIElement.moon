class UIElement

	new: =>
		@needsUpdate = false
		@active = false
		@animationDuration = settings['animation-duration']

	stringify: =>
		@needsUpdate = false
		if not @active
			return ''
		else
			return table.concat @line

	activate: ( activate ) =>
		if activate == true
			if @animation
				@animation\interrupt false

			@active = true
		else
			if @animation
				@animation\interrupt true
				@animation.finishedCb = ->
					@active = false
			else
				@active = false

	reconfigure: =>
		@needsUpdate = true
		@animationDuration = settings['animation-duration']

	resize: => error 'UIElement updateSize called'

	redraw: => return @needsUpdate
