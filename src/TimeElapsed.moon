class TimeElapsed extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs30\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&HFC799E&\an1}]]
			0
		}

		@lastTime = -1
		@position = -100
		@animation = Animation -100, 2, 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@line[2] = ([[%g,%g]])\format @position, @y + (hover_zone-4)*bar_height
		return true

	animatePos: ( animation, value ) =>
		@position = value
		@line[2] = ([[%g,%g]])\format @position, @y + (hover_zone-4)*bar_height
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		timeElapsed = math.floor mp.get_property_number 'time-pos', 0
		if timeElapsed != @lastTime
			update = true
			@line[4] = ([[%d:%02d:%02d]])\format timeElapsed/3600, (timeElapsed/60)%60, timeElapsed%60
			@lastTime = timeElapsed

		return update
