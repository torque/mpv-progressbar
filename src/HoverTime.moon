class HoverTime extends BarAccent

	rightMargin = settings['hover-time-right-margin']
	leftMargin = settings['hover-time-left-margin']
	bottomMargin = settings['hover-time-bottom-margin']
	offScreenPos = settings['hover-time-offscreen-pos']

	new: =>
		super!

		@line = {
			[[{%s%s\pos(]]\format settings['default-style'], settings['hover-time-style']
			[[-100,0]]
			[[)\an2}]]
			[[????]]
		}

		@lastTime = 0
		@lastX = -1
		@position = offScreenPos
		@animation = Animation offScreenPos, bottomMargin, @animationDuration, @\animate, nil, 0.5

	reconfigure: =>
		super!
		rightMargin = settings['hover-time-right-margin']
		leftMargin = settings['hover-time-left-margin']
		bottomMargin = settings['hover-time-bottom-margin']
		offScreenPos = settings['hover-time-offscreen-pos']
		@line[2] = ('%g,%g')\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @position
		@line[1] = ([[{%s%s\pos(]])\format settings['default-style'], settings['hover-time-style']
		@animation = Animation offScreenPos, bottomMargin, @animationDuration, @\animate, nil, 0.5

	resize: =>
		super!
		@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @yPos - @animation.value

	animate: ( value ) =>
		@position = @yPos - value
		@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @position
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			if Mouse.x != @lastX
				@line[2] = ("%g,%g")\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @position
				@lastX = Mouse.x

				hoverTime = mp.get_property_number( 'duration', 0 )*Mouse.x/Window.w
				if hoverTime != @lastTime
					@line[4] = ([[%d:%02d:%02d]])\format math.floor( hoverTime/3600 ), math.floor( (hoverTime/60)%60 ), math.floor( hoverTime%60 )
					@lastTime = hoverTime

				@needsUpdate = true

		return @needsUpdate
