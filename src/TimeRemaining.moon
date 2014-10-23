class TimeRemaining extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0


		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs30\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&FC799E&\an3}]]
			0
		}

		@hovered = false
		@position = -100
		@needsUpdate = false
		@animationCb = @\animatePos
		@posAnimation = Animation -100, 4, 0.25, @animationCb

	__tostring: =>
		return table.concat @line

	bar_height = 2
	hover_zone = 20
	updateSize: ( w, h ) =>
		@position += w - @w
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

		if @hovered
			@line[2] = ([[%d,%d]])\format @position, @y + (hover_zone-3)*bar_height
			return true

		return false

	animatePos: ( animation, value ) =>
		@position = @w - value
		@line[2] = ([[%d,%d]])\format @position, @y + (hover_zone-3)*bar_height
		@needsUpdate = true

	lastTime = 0
	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				@posAnimation\interrupt false, @animationQueue

		else
			if @hovered
				update = true
				@hovered = false
				@posAnimation\interrupt true, @animationQueue

		timeRemaining = math.floor mp.get_property_number( 'time-remaining' ) or 0
		if timeRemaining != lastTime
			update = true
			@line[4] = ([[-%d:%02d:%02d]])\format timeRemaining/3600, (timeRemaining/60)%60, timeRemaining%60
			lastTime = timeRemaining

		@needsUpdate = false
		return update
