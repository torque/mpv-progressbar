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
		if activate == true
			@animation\interrupt false
			@active = true
		else
			@animation\interrupt true
			@animation.finishedCb = ->
				@active = false

	resize: => error 'UIElement updateSize called'

	redraw: => return @needsUpdate
