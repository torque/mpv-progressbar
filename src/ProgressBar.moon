class ProgressBar extends Subscriber

	new: ( @animationQueue ) =>
		super!
		minHeight = settings['bar-height-inactive']*100
		maxHeight = settings['bar-height-active']*100

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]]\format settings['bar-foreground']
			0
			[[)\fscx]]
			0
			[[\fscy]]
			minHeight
			[[\p1}m 0 0 l ]]
			0
		}

		@lastPosition = 0
		@animation = Animation minHeight, maxHeight, 0.25, @\animateHeight
		mp.add_key_binding "mouse_btn0", "seek-to-mouse", @\clickUpSeek

	clickUpSeek: =>
		x, y = mp.get_mouse_pos!
		if @containsPoint x, y
			mp.commandv "seek", x*100/@w, "absolute-percent", "keyframes"

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		super w, h

		@line[2] = ([[%d,%d]])\format 0, h
		@line[8] = ([[%d 0 %d 1 0 1]])\format w, w
		return true

	animateHeight: ( animation, value ) =>
		@line[6] = ([[%g]])\format value
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		-- todo: optimize to not draw if inactive and inactive height is 0
		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition
			update = true
			@line[4] = ([[%g]])\format position
			@lastPosition = position

		return update
