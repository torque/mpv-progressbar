class BarBase extends UIElement
	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100

	new: =>
		super!

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]] -- 1
			0                           -- 2
			[[)\fscy]]                  -- 3
			minHeight                   -- 4
			[[\fscx]]                   -- 5
			0.001                       -- 6
			[[\p1}m 0 0 l ]]            -- 7
			0                           -- 8
		}

		@animation = Animation minHeight, maxHeight, 0.25, @\animateHeight


	updateSize: =>
		@line[2] = [[%d,%d]]\format 0, Window.h
		@line[6] = [[%d 0 %d 1 0 1]]\format Window.w, Window.w
		return true

	animateHeight: ( animation, value ) =>
		@line[4] = ([[%g]])\format value
		@needsUpdate = true

	update: ( inputState ) =>
		super inputState
