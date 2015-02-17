class ProgressBar extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\an1\bord0\c&HFC799E&\p3\pos(]]
			0
			[[)\fscx]]
			0
			[[\fscy]]
			100
			[[}m 0 0 l ]]
			0
		}

		@lastPosition = 0
		@animation = Animation 100, 400, 0.25, @\animateHeight
		mp.add_key_binding "MOUSE_BTN0", @\clickUpSeek

	clickUpSeek: =>
		x, y = mp.get_mouse_pos!
		if @containsPoint x, y
			mp.commandv "seek", x*100/@w, "absolute-percent", "keyframes"

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		super w, h

		@line[2] = ([[%d,%d]])\format 0, h
		@line[8] = ([[%d 0 %d %d 0 %d]])\format w*4, w*4, bar_height*4, bar_height*4
		return true

	animateHeight: ( animation, value ) =>
		@line[6] = ([[%g]])\format value
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition
			update = true
			@line[4] = ([[%g]])\format position
			@lastPosition = position

		return update
