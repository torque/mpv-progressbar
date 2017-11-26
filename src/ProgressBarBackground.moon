class ProgressBarBackground extends BarBase

	layer: 500

	reconfigure: =>
		super!
		@line[6] = 100
		@line[8] = @line[8]\format settings['bar-background-style']
