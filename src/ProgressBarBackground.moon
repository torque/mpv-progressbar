class ProgressBarBackground extends BarBase

	reconfigure: =>
		super!

		if settings['bar-background-adaptive']
			for bar in *@@instantiatedBars
				@minHeight = math.max @minHeight, bar.minHeight
				@maxHeight = math.max @maxHeight, bar.maxHeight

			@_updateBarVisibility!

		@line[6] = 100
		@line[8] = @line[8]\format settings['bar-background-style']
