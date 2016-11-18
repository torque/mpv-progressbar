class ProgressBarBackground extends BarBase

	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100

	new: =>
		super!
		@line[1] = @line[1]\format settings['bar-background']

	update: ( inputState ) =>
		super inputState
