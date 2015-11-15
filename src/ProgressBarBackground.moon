class ProgressBarBackground extends Subscriber

	new: ( @animationQueue ) =>
		super!
		minHeight = settings['bar-height-inactive']*100
		maxHeight = settings['bar-height-active']*100

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]]\format settings['bar-background']
			0
			[[)\fscy]]
			minHeight
			[[\p1}m 0 0 l ]]
			0
		}

		@animation = Animation minHeight, maxHeight, 0.25, @\animateHeight

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		super w, h

		@line[2] = [[%d,%d]]\format 0, h
		@line[6] = [[%d 0 %d 1 0 1]]\format w, w
		return true

	animateHeight: ( animation, value ) =>
		@line[4] = ([[%g]])\format value
		@needsUpdate = true

	update: ( mouseX, mouseY, mouseOver ) =>
		super mouseX, mouseY, mouseOver
