class ProgressBar extends Subscriber

	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]]\format settings['bar-foreground'] -- 1
			0                                                             -- 2
			[[)\fscx]]                                                    -- 3
			0                                                             -- 4
			[[\fscy]]                                                     -- 5
			minHeight                                                     -- 6
			[[\p1}m 0 0 l ]]                                              -- 7
			0                                                             -- 8
		}

		@lastPosition = 0
		@animation = Animation minHeight, maxHeight, 0.25, @\animateHeight

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

	update: ( inputState ) =>
		update = super inputState

		-- todo: optimize to not draw if inactive and inactive height is 0
		position = mp.get_property_number 'percent-pos', 0
		if position != @lastPosition
			update = true
			@line[4] = ([[%g]])\format position
			@lastPosition = position

		return update
