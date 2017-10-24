class ChapterMarker
	beforeStyle = settings['chapter-marker-before-style']
	afterStyle = settings['chapter-marker-after-style']

	@reconfigure: =>
		beforeStyle = settings['chapter-marker-before-style']
		afterStyle = settings['chapter-marker-after-style']

	new: ( @position, minWidth, minHeight ) =>
		@line = {
			[[{\an2\bord0\p1\pos(]]   -- 1
			[[%g,%g]]\format @position*Window.w, Window.h
			[[)\fscx]]                -- 3
			minWidth
			[[\fscy]]                 -- 5
			minHeight
			beforeStyle               -- 7
			'}m 0 0 l 1 0 1 1 0 1\n'  -- 8
		}

		@passed = false

	stringify: =>
		return table.concat @line

	resize: =>
		@line[2] = ('%d,%d')\format math.floor( @position*Window.w ), Window.h

	animate: ( width, height ) =>
		@line[4] = ('%g')\format width
		@line[6] = ('%g')\format height

	redraw: ( position, update = false ) =>
		if not @passed and (position > @position)
			@line[7] = afterStyle
			@passed = true
			update = true
		elseif @passed and (position < @position)
			@line[7] = beforeStyle
			@passed = false
			update = true

		return update
