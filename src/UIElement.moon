class UIElement

	new: =>
		@animationDuration = settings['animation-duration']
		@needsUpdate = false
		@active = false

	stringify: =>
		if not @active
			return ""
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

		@active = activate
