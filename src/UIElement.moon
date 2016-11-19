class UIElement

	active_height = settings['hover-zone-height']

	new: =>
		@needsUpdate = false
		@active = false

	stringify: =>
		if not @active
			return ""
		else
			return table.concat @line

	activate: ( activate ) =>
		if activate == true
			@animation\interrupt false
		else
			@animation\interrupt true
			@animation.finishedCb = ->
				@active = false

		@active = activate
