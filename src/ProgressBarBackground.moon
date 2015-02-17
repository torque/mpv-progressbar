class ProgressBarBackground extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\an1\bord0\c&H2D2D2D&\p1\pos(]]
			0
			[[)\fscy]]
			100
			[[}m 0 0 l ]]
			0
		}

		@animation = Animation 100, 400, 0.25, @\animateHeight

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		super w, h

		@line[2] = [[%d,%d]]\format 0, h
		@line[6] = [[%d 0 %d %d 0 %d]]\format w, w, bar_height, bar_height
		return true

	animateHeight: ( animation, value ) =>
		@line[4] = ([[%g]])\format value
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		super mouseX, mouseY, mouseOver
