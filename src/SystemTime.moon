class SystemTime extends UIElement

	topMargin = settings['system-time-top-margin']

	@enableKey: 'enable-system-time'

	layer: 300
	lastTime: -1
	position: settings['system-time-offscreen-pos']
	format: settings['system-time-format']
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
		@position = Window.w - @animation.value
		@line[2] = ('%g,%g')\format @position, topMargin

	animate: ( value ) =>
		super!
		@position = Window.w - value
		@line[2] = ('%g,%g')\format @position, topMargin
		@needsUpdate = true

	update: =>
		if @active
			systemTime = os.time!
			if systemTime != @lastTime
				update = true
				@line[4] = os.date @format, systemTime
				@lastTime = systemTime
				@needsUpdate = true

		return @needsUpdate
