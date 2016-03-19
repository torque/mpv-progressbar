class TimeElapsed extends BarAccent

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\fn%s\bord2\fs%d\pos(]]\format settings.font, settings['time-font-size']
			[[-100,0]]
			[[)\c&H%s&\3c&H%s&\an1}]]\format settings['elapsed-foreground'], settings['elapsed-background']
			0
		}
		offscreenPos = settings['elapsed-offscreen-pos']
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, 2, 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@line[2] = ([[%g,%g]])\format @position, @yPos
		return true

	animatePos: ( animation, value ) =>
		@position = value
		@line[2] = ([[%g,%g]])\format @position, @yPos
		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

		if update or @hovered
			timeElapsed = math.floor mp.get_property_number 'time-pos', 0
			if timeElapsed != @lastTime
				update = true
				@line[4] = ([[%d:%02d:%02d]])\format math.floor( timeElapsed/3600 ), math.floor( (timeElapsed/60)%60 ), math.floor( timeElapsed%60 )
				@lastTime = timeElapsed

		return update
