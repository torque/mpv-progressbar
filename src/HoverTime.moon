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
			[[)\an8}]]
			[[????]]
		}

		@lastDuration = 0
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
		@line[2] = ('%g,%g')\format clamp( Mouse.x, leftMargin, Window.w - rightMargin ), @position
		@line[1] = ([[{%s%s\pos(]])\format settings['default-style'], settings['hover-time-style']
		@animation = Animation offScreenPos, bottomMargin, @animationDuration, @\animate, nil, 0.5

	resize: =>
		super!
		@line[2] = ("%g,%g")\format clamp( Mouse.x, leftMargin, Window.w - rightMargin ), @animation.value

	animate: ( value ) =>
		@position = value
		@line[2] = ("%g,%g")\format clamp( Mouse.x, leftMargin, Window.w - rightMargin ), @position
		@needsUpdate = true

	_setXPosition: (x) =>
		@line[2] = ("%g,%g")\format clamp( x, leftMargin, Window.w - rightMargin ), @position
		@needsUpdate = true

	_setUnknownDuration: =>
		@line[4] = "????"
		@needsUpdate = true

	_setTime: ( hoverTime ) =>
		@line[4] = ([[%d:%02d:%02d]])\format(
			math.floor( hoverTime / 3600 ),
			math.floor( (hoverTime / 60) % 60 ),
			math.floor( hoverTime % 60 )
		)
		@needsUpdate = true

	redraw: =>
		if @active
			super!

			duration = mp.get_property_number( 'duration', 0 )
			hoverTime = duration * Mouse.x / Window.w

			if Mouse.x != @lastX
				@lastX = Mouse.x
				@_setXPosition( Mouse.x )

			if duration != @lastDuration or hoverTime != @lastTime
				@lastDuration = duration
				@lastTime = hoverTime

				if duration == 0
					@_setUnknownDuration!
				else
					@_setTime( hoverTime )

		return @needsUpdate
