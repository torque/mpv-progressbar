class HoverTime extends BarAccent

	rightMargin = settings['hover-time-right-margin']
	leftMargin = settings['hover-time-left-margin']
	bottomMargin = settings['hover-time-bottom-margin']

	new: =>
		super!

		@line = {
			[[{%s%s\pos(]]\format settings['default-style'], settings['hover-time-style']
			[[-100,0]]
			[[)\alpha&H]]
			[[FF]]
			[[&\an2}]]
			[[????]]
		}

		@lastTime = 0
		@lastX = -1
		@position = -100
		@animation = Animation 255, 0, @animationDuration, @\animate

	reconfigure: =>
		super!
		rightMargin = settings['hover-time-right-margin']
		leftMargin = settings['hover-time-left-margin']
		bottomMargin = settings['hover-time-bottom-margin']
		@line[2] = ('%g,%g')\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @yPos - bottomMargin
		@line[1] = ([[{%s%s\pos(]])\format settings['default-style'], settings['hover-time-style']
		@animation = Animation 255, 0, @animationDuration, @\animate

	resize: =>
		super!
		@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @yPos - bottomMargin

	animate: ( value ) =>
		@line[4] = ([[%02X]])\format value
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			if Mouse.x != @lastX
				@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @yPos - bottomMargin
				@lastX = Mouse.x

				hoverTime = mp.get_property_number( 'duration', 0 )*Mouse.x/Window.w
				if hoverTime != @lastTime
					@line[6] = ([[%d:%02d:%02d]])\format math.floor( hoverTime/3600 ), math.floor( (hoverTime/60)%60 ), math.floor( hoverTime%60 )
					@lastTime = hoverTime

				@needsUpdate = true

		return @needsUpdate
