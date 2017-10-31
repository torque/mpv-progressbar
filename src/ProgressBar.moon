class ProgressBar extends BarBase

	seekString = ('absolute-percent+%s')\format settings['seek-precision']

	new: =>
		-- super calls reconfigure which sets barShift.
		super!
		@lastPosition = 0

	reconfigure: =>
		super!
		seekString = ('absolute-percent+%s')\format settings['seek-precision']
		@barShift = settings['progress-bar-width']/2.0
		@resize!
		@line[7] = [[]]
		@line[8] = @line[8]\format settings['bar-foreground-style']

	clickHandler: =>
		mp.commandv "seek", Mouse.clickX*100/Window.w, seekString

	resize: =>
		super!
		if @barShift > 0
			@line[2] = ('%g,%g')\format @barShift, Window.h

	redraw: =>
		super!
		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition or @needsUpdate
			@line[6] = position
			if @barShift > 0
				followingEdge = Window.w*position*1e-2 - @barShift
				@line[7] = [[\clip(m %g 0 l %g 0 %g %g %g %g)]]\format followingEdge, Window.w, Window.w, Window.h, followingEdge, Window.h
			@lastPosition = position
			@needsUpdate = true

		return @needsUpdate
