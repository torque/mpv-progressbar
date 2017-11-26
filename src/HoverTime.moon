class HoverTime extends BarAccent

	rightMargin = settings['hover-time-right-margin']
	leftMargin = settings['hover-time-left-margin']

	@enableKey: 'enable-hover-time'

	layer: 400
	lastTime: 0
	lastX: -1
	position: settings['hover-time-offscreen-pos']
	line: {
		[[]]
		[[]]
		[[)\an2}]]
		[[????]]
	}

	reconfigure: =>
		super!
		rightMargin = settings['hover-time-right-margin']
		leftMargin = settings['hover-time-left-margin']

		@line[1] = ([[{%s%s\pos(]])\format settings['default-style'], settings['hover-time-style']
		@line[2] = ('%g,%g')\format math.min( Window.w - rightMargin, math.max( leftMargin, Mouse.x ) ), @position
		@animation = Animation settings['hover-time-offscreen-pos'],
			settings['hover-time-bottom-margin'], @animationDuration, @, 0.5

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
