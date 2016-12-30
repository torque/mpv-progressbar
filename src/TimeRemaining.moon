class TimeRemaining extends BarAccent

	new: =>
		super!

		offscreenPos = settings['remaining-offscreen-pos']
		@line = {
			[[{\pos(]]
			[[%g,0]]\format offscreenPos
			[[)\an3%s%s}]]\format settings['default-style'], settings['remaining-style']
			0
		}
		@lastTime = -1
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['remaining-right-margin'], @animationDuration, @\animate, nil, 0.25

	resize: =>
		super!
		@position = Window.w - @animation.value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['remaining-bottom-margin']

	animate: ( value ) =>
		@position = Window.w - value
		@line[2] = ([[%g,%g]])\format @position, @yPos - settings['remaining-bottom-margin']
		@needsUpdate = true

	redraw: =>
		if @active
			super!
			timeRemaining = math.floor mp.get_property_number 'playtime-remaining', 0
			if timeRemaining != @lastTime
				update = true
				@line[4] = ([[–%d:%02d:%02d]])\format math.floor( timeRemaining/3600 ), math.floor( (timeRemaining/60)%60 ), math.floor( timeRemaining%60 )
				@lastTime = timeRemaining
				@needsUpdate = true

		return @needsUpdate
