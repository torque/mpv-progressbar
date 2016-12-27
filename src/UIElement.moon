class UIElement

	new: =>
		@animationDuration = settings['animation-duration']
		@needsUpdate = false
		@active = false

	stringify: =>
		@needsUpdate = false
		if not @active
			return ''
		else
			return table.concat @line

	activate: ( activate ) =>
		if @animationDuration > 0
			if activate == true
				@animation\interrupt false
			else
				@animation\interrupt true
				@animation.finishedCb = ->
					@active = false
				return

		@active = activate

	resize: => error 'UIElement updateSize called'

	redraw: => return @needsUpdate
