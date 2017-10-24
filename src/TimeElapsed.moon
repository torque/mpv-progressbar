class TimeElapsed extends BarAccent

	bottomMargin = settings['elapsed-bottom-margin']

	new: =>
		super!

		offscreenPos = settings['elapsed-offscreen-pos']

		@line = {
			[[{\pos(]]
			[[%g,0]]\format offscreenPos
			[[)\an1%s%s}]]\format settings['default-style'], settings['elapsed-style']
			[[????]]
		}
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['elapsed-left-margin'], @animationDuration, @\animate, nil, 0.5

	reconfigure: =>
		super!
		bottomMargin = settings['elapsed-bottom-margin']
		offscreenPos = settings['elapsed-offscreen-pos']
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin
		@line[3] = ([[)\an1%s%s}]])\format settings['default-style'], settings['elapsed-style']
		@animation = Animation offscreenPos, settings['elapsed-left-margin'], @animationDuration, @\animate, nil, 0.5

	resize: =>
		super!
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin

	animate: ( value ) =>
		@position = value
		@line[2] = ('%g,%g')\format value, @yPos - bottomMargin
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			timeElapsed = math.floor mp.get_property_number 'time-pos', 0
			if timeElapsed != @lastTime
				update = true
				@line[4] = ('%d:%02d:%02d')\format math.floor( timeElapsed/3600 ), math.floor( (timeElapsed/60)%60 ), math.floor( timeElapsed%60 )
				@lastTime = timeElapsed
				@needsUpdate = true

		return @needsUpdate
