class TimeRemaining extends BarAccent

	new: =>
		super!

		@line = {
			[[{\fn%s\bord2\fs%d\pos(]]\format settings.font, settings['time-font-size']
			[[-100,0]]
			[[)\c&H%s&\3c&H%s&\an3}]]\format settings['remaining-foreground'], settings['remaining-background']
			0
		}
		offscreenPos = settings['remaining-offscreen-pos']
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['remaining-right-margin'], 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@position = @zone.w - @animation.value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['remaining-bottom-margin']
		return true

	animatePos: ( animation, value ) =>
		@position = @zone.w - value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['remaining-bottom-margin']
		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

		if update or @hovered
			timeRemaining = math.floor mp.get_property_number 'playtime-remaining', 0
			if timeRemaining != @lastTime
				update = true
				@line[4] = ([[–%d:%02d:%02d]])\format math.floor( timeRemaining/3600 ), math.floor( (timeRemaining/60)%60 ), math.floor( timeRemaining%60 )
				@lastTime = timeRemaining

		return update
