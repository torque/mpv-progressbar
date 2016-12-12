class ProgressBar extends BarBase

	new: =>
		super!
		@line[1] = @line[1]\format settings['bar-foreground']
		@lastPosition = 0

	update: ( inputState ) =>
		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition
			@line[6] = [[%g]]\format position
			@lastPosition = position
			@needsUpdate = true

