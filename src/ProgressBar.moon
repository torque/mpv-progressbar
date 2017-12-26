class ProgressBar extends BarBase

	layer: 502
	lastPosition: 0.1

	reconfigure: =>
		super!
		@seekString = ('absolute-percent+%s')\format settings['seek-precision']
		@barShift = settings['progress-bar-width']/2.0
		if @barShift > 0
			@line[6] = 100
		@resize!
		@line[7] = [[]]
		@line[8] = @line[8]\format settings['bar-foreground-style']

	click: ( x, y ) =>
		mp.commandv "seek", x*100/Window.w, @seekString
		return false -- stop the click from propagating.

	resize: =>
		super!
		if @barShift > 0
			@line[2] = ('%g,%g')\format @barShift, Window.h

	update: =>
		super!
		position = mp.get_property_number 'percent-pos', 0.1
		if position != @lastPosition
			if @barShift > 0
				center = position*1e-2*Window.w
				left = center - @barShift
				right = center + @barShift
				@line[9] = [[m %g 0 l %g 0 %g 1 %g 1]]\format left, right, right, left
			else
				@line[6] = position

			@lastPosition = position
			@needsRedraw = true

		return @needsRedraw
