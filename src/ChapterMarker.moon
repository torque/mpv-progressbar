class ChapterMarker
	minWidth = settings['chapter-marker-width']*100
	maxWidth = settings['chapter-marker-width-active']*100
	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100
	maxHeightFrac = settings['chapter-marker-active-height-fraction']
	beforeStyle = settings['chapter-marker-before-style']
	afterStyle = settings['chapter-marker-after-style']

	new: ( @position ) =>
		@line = {
			[[{\an2\bord0\p1\pos(]]   -- 1
			[[%g,%g]]\format @position*Window.w, Window.h
			[[)\fscx]]                -- 3
			minWidth                  -- 4
			[[\fscy]]                 -- 5
			minHeight                 -- 6
			beforeStyle               -- 7
			'}m 0 0 l 1 0 1 1 0 1\n'  -- 8
		}

		@passed = false

	stringify: =>
		return table.concat @line

	resize: =>
		@line[2] = [[%d,%d]]\format math.floor( @position*Window.w ), Window.h

	animate: ( value ) =>
		@line[4] = [[%g]]\format (maxWidth - minWidth)*value + minWidth
		@line[6] = [[%g]]\format (maxHeight*maxHeightFrac - minHeight)*value + minHeight

	redraw: ( position ) =>
		update = false

		if not @passed and (position > @position)
			@line[7] = afterStyle
			@passed = true
			update = true
		elseif @passed and (position < @position)
			@line[7] = beforeStyle
			@passed = false
			update = true

		return update
