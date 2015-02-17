class HoverTime extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\fnSource Sans Pro Semibold\bord2\fs26\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&HFC799E&\an2\alpha&H]]
			[[FF]]
			[[&}]]
			0
		}

		@lastTime = 0
		@lastX = -1
		@lastY = -1
		@position = -100
		@animation = Animation 255, 0, 0.25, @\animateAlpha

	animateAlpha: ( animation, value ) =>
		@line[4] = ([[%02X]])\format value
		-- @line[2] = ([[%d,%d]])\format @position, @y + (hover_zone-3)*bar_height
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		-- width = 76 + 4px padding = 80
		if mouseX != @lastX or mouseY != @lastY
			@line[2] = ("%g,%g")\format math.min( @w-130, math.max( 120, mouseX ) ), @y + (hover_zone-4)*bar_height
			@lastX, @lastY = mouseX, mouseY

			hoverTime = mp.get_property_number( 'length', 0 )*mouseX/@w
			if hoverTime != @lastTime and (@hovered or @animation.isRegistered)
				update = true
				@line[6] = ([[%d:%02d:%02d]])\format hoverTime/3600, (hoverTime/60)%60, hoverTime%60
				@lastTime = hoverTime

		return update
