class TimeRemaining extends BarAccent

	bottomMargin = settings['remaining-bottom-margin']

	@enableKey: 'enable-remaining-time'

	layer: 300
	enabled: settings['enable-remaining-time']
	lastTime: -1
	position: settings['remaining-offscreen-pos']
	line: {
		[[{\pos(]],
		[[]],
		[[]],
		[[????]]
	}

	reconfigure: =>
		super!
		bottomMargin = settings['remaining-bottom-margin']
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin
		@line[3] = ([[)\an3%s%s}]])\format settings['default-style'], settings['remaining-style']
		@animation = Animation settings['remaining-offscreen-pos'],
			settings['remaining-right-margin'],
			@animationDuration, @, 0.5

	resize: =>
		super!
		@position = Window.w - @animation.value
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin

	animate: ( value ) =>
		@position = Window.w - value
		@line[2] = ('%g,%g')\format @position, @yPos - bottomMargin
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			timeRemaining = math.floor mp.get_property_number 'playtime-remaining', 0
			if timeRemaining != @lastTime
				update = true
				@line[4] = ('–%d:%02d:%02d')\format math.floor( timeRemaining/3600 ), math.floor( (timeRemaining/60)%60 ), math.floor( timeRemaining%60 )
				@lastTime = timeRemaining
				@needsUpdate = true

		return @needsUpdate
