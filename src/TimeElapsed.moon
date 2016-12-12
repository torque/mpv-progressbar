class TimeElapsed extends BarAccent

	new: =>
		super!

		offscreenPos = settings['elapsed-offscreen-pos']
		@line = {
			[[{\fn%s\bord%g\fs%d\pos(]]\format settings.font, settings['time-font-border'], settings['time-font-size']
			[[%g,0]]\format offscreenPos
			[[)\c&H%s&\3c&H%s&\an1}]]\format settings['elapsed-foreground'], settings['elapsed-background']
			0
		}
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['elapsed-left-margin'], 0.25, @\animatePos, nil, 0.25

	updateSize: =>
		super!
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['elapsed-bottom-margin']
		@needsUpdate = true

	animatePos: ( animation, value ) =>
		@position = value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['elapsed-bottom-margin']
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
