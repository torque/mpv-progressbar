class HoverTime extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0

		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs26\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&FC799E&\an2\alpha&H]]
			[[FF]]
			[[&}]]
			0
		}

		@hovered = false
		@position = -100
		@needsUpdate = false
		@animationCb = @\animateAlpha
		@alphaAnimation = Animation 255, 0, 0.25, @animationCb

	__tostring: =>
		if not @hovered and not @alphaAnimation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height
		return false

	animateAlpha: ( animation, value ) =>
		@line[4] = ([[%02X]])\format value
		-- @line[2] = ([[%d,%d]])\format @position, @y + (hover_zone-3)*bar_height
		@needsUpdate = true

	lastTime = 0
	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				@alphaAnimation\interrupt false, @animationQueue

		else
			if @hovered
				update = true
				@hovered = false
				@alphaAnimation\interrupt true, @animationQueue

		-- width = 76 + 4px padding = 80
		percent = mouseX/@w
		@line[2] = ("%g,%g")\format (@w-250)*percent + 120, @y + (hover_zone-4)*bar_height

		hoverTime = (mp.get_property_number( 'length' ) or 0)*percent
		if hoverTime != lastTime and (@hovered or @alphaAnimation.isRegistered)
			update = true
			@line[6] = ([[%d:%02d:%02d]])\format hoverTime/3600, (hoverTime/60)%60, hoverTime%60
			lastTime = hoverTime

		@needsUpdate = false
		return update
