class ProgressBar extends BarBase

	seekString = ('absolute-percent+%s')\format settings['seek-precision']

	new: =>
		super!
		@lastPosition = 0

	reconfigure: =>
		super!
		seekString = ('absolute-percent+%s')\format settings['seek-precision']
		@barWidth = settings['progress-bar-width']
		@line[7] = [[]]
		@line[8] = @line[8]\format settings['bar-foreground-style']

	clickHandler: =>
		mp.commandv "seek", Mouse.clickX*100/Window.w, seekString

	redraw: =>
		super!
		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition
			@line[6] = position
			if @barWidth > 0
				followingEdge = Window.w*position*1e-2 - @barWidth
				@line[7] = [[\clip(m %g 0 l %g 0 %g %g %g %g)]]\format followingEdge, Window.w, Window.w, Window.h, followingEdge, Window.h
			@lastPosition = position
			@needsUpdate = true

		return @needsUpdate
