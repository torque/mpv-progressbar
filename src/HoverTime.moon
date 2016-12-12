class HoverTime extends BarAccent

	rightMargin = settings['hover-time-right-margin']
	leftMargin = settings['hover-time-left-margin']

	new: =>
		super!

		@line = {
			[[{\fn%s\bord%g\fs%d\pos(]]\format settings.font, settings['hover-time-font-border'], settings['hover-time-font-size']
			[[-100,0]]
			[[)\c&H%s&\3c&H%s&\an2\alpha&H]]\format settings['hover-time-foreground'], settings['hover-time-background']
			[[FF]]
			[[&}]]
			0
		}

		@lastTime = 0
		@lastX = -1
		@position = -100
		@animation = Animation 255, 0, 0.25, @\animateAlpha

	animateAlpha: ( animation, value ) =>
		@line[4] = ([[%02X]])\format value
		@needsUpdate = true

	hoverCondition: ( inputState ) =>
		with inputState
			return .mouseInWindow and not .mouseDead and @zone\containsPoint .mouseX, .mouseY

	update: ( inputState ) =>
		with inputState
			update = super inputState

			if update or @hovered
				if .mouseX != @lastX or @sizeChanged
					@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, .mouseX ) ), @yPos - settings['hover-time-bottom-margin']
					@sizeChanged = false

					@lastX = .mouseX
					hoverTime = mp.get_property_number( 'duration', 0 )*.mouseX/@zone.w
					if hoverTime != @lastTime and (@hovered or @animation.isRegistered)
						update = true
						@line[6] = ([[%d:%02d:%02d]])\format math.floor( hoverTime/3600 ), math.floor( (hoverTime/60)%60 ), math.floor( hoverTime%60 )
						@lastTime = hoverTime

			return update
