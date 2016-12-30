class TimeElapsed extends BarAccent

	new: =>
		super!

		offscreenPos = settings['elapsed-offscreen-pos']
		@line = {
			[[{\pos(]]
			[[%g,0]]\format offscreenPos
			[[)\an1%s%s}]]\format settings['default-style'], settings['elapsed-style']
			0
		}
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['elapsed-left-margin'], @animationDuration, @\animate, nil, 0.25

	resize: =>
		super!
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['elapsed-bottom-margin']

	animate: ( value ) =>
		@position = value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['elapsed-bottom-margin']
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			timeElapsed = math.floor mp.get_property_number 'time-pos', 0
			if timeElapsed != @lastTime
				update = true
				@line[4] = ([[%d:%02d:%02d]])\format math.floor( timeElapsed/3600 ), math.floor( (timeElapsed/60)%60 ), math.floor( timeElapsed%60 )
				@lastTime = timeElapsed
				@needsUpdate = true

		return @needsUpdate
