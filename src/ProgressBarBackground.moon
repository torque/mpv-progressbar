class ProgressBarBackground extends BarBase

	reconfigure: =>
		super!
		@line[6] = 100
		@line[8] = @line[8]\format settings['bar-background-style']
