class SystemTime extends UIElement

	topMargin = settings['system-time-top-margin']

	@enableKey: 'enable-system-time'

	layer: 300
	lastTime: -1
	position: settings['system-time-offscreen-pos']
	format: settings['system-time-format']
	animationValue: settings['remaining-offscreen-pos']
	line: {
		[[{\pos(]],
		[[]],
		[[]],
		[[????]]
	}

	reconfigure: =>
		super!
		topMargin = settings['system-time-top-margin']

		@format = settings['system-time-format']
		@line[2] = ('%g,%g')\format @position, topMargin
		@line[3] = [[)\an9%s%s}]]\format settings['default-style'], settings['system-time-style']
		@animation = Animation settings['system-time-offscreen-pos'],
			settings['system-time-right-margin'],
			@animationDuration, @, 0.5

	resize: =>
		@position = Window.w - @animationValue
		@line[2] = ('%g,%g')\format @position, topMargin
		@needsRedraw = true

	animate: ( @animationValue ) =>
		super!
		@position = Window.w - @animationValue
		@line[2] = ('%g,%g')\format @position, topMargin
		@needsRedraw = true

	update: =>
		if @active
			super!
			systemTime = os.time!
			if systemTime != @lastTime
				update = true
				@line[4] = os.date @format, systemTime
				@lastTime = systemTime
				@needsRedraw = true

		return @needsRedraw
