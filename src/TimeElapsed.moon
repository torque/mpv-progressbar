class TimeElapsed extends BarAccent

	bottomMargin = settings['elapsed-bottom-margin']

	@enableKey: 'enable-elapsed-time'

	layer: 300
	enabled: settings['enable-elapsed-time']
	lastTime: -1
	position: settings['elapsed-offscreen-pos']
	line: {
		[[{\pos(]],
		[[]],
		[[]],
		[[????]]
	}

	reconfigure: =>
		super!
		bottomMargin = settings['elapsed-bottom-margin']
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin
		@line[3] = ([[)\an1%s%s}]])\format settings['default-style'], settings['elapsed-style']
		@animation = Animation settings['elapsed-offscreen-pos'],
			settings['elapsed-left-margin'],
			@animationDuration, @, 0.5

	resize: =>
		super!
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin

	animate: ( value ) =>
		super!
		@position = value
		@line[2] = ('%g,%g')\format value, @yPos - bottomMargin
		@needsRedraw = true

	update: =>
		if @active
			super!
			timeElapsed = math.floor mp.get_property_number 'time-pos', 0
			if timeElapsed != @lastTime
				update = true
				@line[4] = ('%d:%02d:%02d')\format math.floor( timeElapsed/3600 ), math.floor( (timeElapsed/60)%60 ), math.floor( timeElapsed%60 )
				@lastTime = timeElapsed
				@needsRedraw = true

		return @needsRedraw
