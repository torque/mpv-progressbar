class SystemTime extends UIElement

	offscreen_position = settings['system-time-offscreen-pos']
	top_margin = settings['system-time-top-margin']
	time_format = settings['system-time-format']

	new: =>
		super!

		@line = {
			[[{\pos(]]
			[[-100,0]]
			[[)\an9%s%s}]]\format settings['default-style'], settings['system-time-style']
			0
		}
		@lastTime = -1
		@position = offscreen_position
		@animation = Animation offscreen_position, settings['system-time-right-margin'], @animationDuration, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@position = @zone.w - @animation.value
		@line[2] = ([[%g,%g]])\format @position, top_margin
		return true

	animatePos: ( animation, value ) =>
		@position = @zone.w - value
		@line[2] = ([[%g,%g]])\format @position, top_margin
		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

		if update or @hovered
			systemTime = os.time!
			if systemTime != @lastTime
				update = true
				@line[4] = os.date time_format, systemTime
				@lastTime = systemTime

		return update
