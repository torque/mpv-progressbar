class TimeElapsed extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0

		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs30\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&FC799E&\an1}]]
			0
		}

		@hovered = false
		@position = -100
		@needsUpdate = false
		@animationCb = @\animatePos
		@posAnimation = Animation -100, 2, 0.25, @animationCb, 0.25

	__tostring: =>
		if not @hovered and not @posAnimation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

		if @hovered
			@line[2] = ([[%g,%g]])\format @position, @y + (hover_zone-4)*bar_height
			return true

		return false

	animatePos: ( animation, value ) =>
		@position = value
		@line[2] = ([[%g,%g]])\format @position, @y + (hover_zone-4)*bar_height
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

		timeElapsed = math.floor mp.get_property_number( 'time-pos' ) or 0
		if timeElapsed != lastTime
			update = true
			@line[4] = ([[%d:%02d:%02d]])\format timeElapsed/3600, (timeElapsed/60)%60, timeElapsed%60
			lastTime = timeElapsed

		@needsUpdate = false
		return update
