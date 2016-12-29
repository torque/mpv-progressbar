class ProgressBarBackground extends BarBase

	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100

	new: =>
		super!
		@line[6] = 100
		@line[7] = @line[7]\format settings['bar-background-style']
