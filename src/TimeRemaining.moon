class TimeRemaining extends BarAccent

	new: ( @animationQueue ) =>
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
		@animation = Animation offscreenPos, 4, 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@line[2] = ([[%g,%g]])\format @position, @yPos
		return true

	animatePos: ( animation, value ) =>
		@position = @w - value
		@line[2] = ([[%g,%g]])\format @position, @yPos
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		if update or @hovered
			timeRemaining = math.floor mp.get_property_number 'playtime-remaining', 0
			if timeRemaining != @lastTime
				update = true
				@line[4] = ([[–%d:%02d:%02d]])\format math.floor( timeRemaining/3600 ), math.floor( (timeRemaining/60)%60 ), math.floor( timeRemaining%60 )
				@lastTime = timeRemaining

		return update
