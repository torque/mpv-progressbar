class HoverChapter

	new: ( @animationQueue, @chapters ) =>
		super 0, 0, 0, 0

		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs26\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&HFC799E&\an2\alpha&H]]
			[[FF]]
			[[&}]]
			0
		}

		@hovered = false
		@position = -100
		@needsUpdate = false
		@animationCb = @\animateAlpha
		@alphaAnimation = Animation 255, 0, 0.25, @animationCb

	stringify: =>
		if not @hovered and not @alphaAnimation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		return false

	animateAlpha: ( animation, value ) =>
		@line[4] = ([[%02X]])\format value
		@needsUpdate = true

	lastTime = 0
	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		title, position = @chapters\pointInMarker mouseX, mouseY
		if title
			unless @hovered
				update = true
				@hovered = true
				@alphaAnimation\interrupt false, @animationQueue

			@line[2] = ("%g,%g")\format math.min( @w-130, math.max( 120, mouseX ) ), @y + (hover_zone-4)*bar_height

		else
			if @hovered
				update = true
				@hovered = false
				@alphaAnimation\interrupt true, @animationQueue

		-- width = 76 + 4px padding = 80

		hoverTime = mp.get_property_number( 'length', 0 )*mouseX/@w
		if hoverTime != lastTime and (@hovered or @alphaAnimation.isRegistered)
			update = true
			@line[6] = ([[%d:%02d:%02d]])\format hoverTime/3600, (hoverTime/60)%60, hoverTime%60
			lastTime = hoverTime

		@needsUpdate = false
		return update
