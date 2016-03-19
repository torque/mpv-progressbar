class HoverTime extends BarAccent

	rightMargin = settings['hover-time-right-margin']
	leftMargin = settings['hover-time-left-margin']

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\fn%s\bord2\fs%d\pos(]]\format settings.font, settings['hover-time-font-size']
			[[-100,0]]
			[[)\c&H%s&\3c&H%s&\an2\alpha&H]]\format settings['hover-time-foreground'], settings['hover-time-background']
			[[FF]]
			[[&}]]
			0
		}

		@lastTime = 0
		@lastX = -1
		@lastY = -1
		@position = -100
		@animation = Animation 255, 0, 0.25, @\animateAlpha

	animateAlpha: ( animation, value ) =>
		@line[4] = ([[%02X]])\format value
		-- @line[2] = ([[%d,%d]])\format @position, @y + (hover_zone-3)*bar_height
		@needsUpdate = true

	update: ( inputState ) =>
		with inputState
			update = super inputState, @containsPoint( .mouseX, .mouseY )

			if update or @hovered
				if .mouseX != @lastX or .mouseY != @lastY
					@line[2] = ("%g,%g")\format math.min( @w - rightMargin, math.max( leftMargin, .mouseX ) ), @yPos
					@lastX, @lastY = .mouseX, .mouseY

					hoverTime = mp.get_property_number( 'length', 0 )*.mouseX/@w
					if hoverTime != @lastTime and (@hovered or @animation.isRegistered)
						update = true
						@line[6] = ([[%d:%02d:%02d]])\format math.floor( hoverTime/3600 ), math.floor( (hoverTime/60)%60 ), math.floor( hoverTime%60 )
						@lastTime = hoverTime

			return update
