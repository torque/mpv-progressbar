class ChapterMarker
	minWidth = settings['chapter-marker-width']*100
	maxWidth = settings['chapter-marker-width-active']*100
	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100
	maxHeightFrac = settings['chapter-marker-active-height-fraction']
	beforeColor = settings['chapter-marker-before']
	afterColor = settings['chapter-marker-after']

	new: ( @position, w, h ) =>
		@line = {
			[[{\an2\bord0\p1\pos(]]                       -- 1
			[[%d,%d]]\format math.floor( @position*w ), h -- 2
			[[)\fscx]]                                    -- 3
			minWidth                                      -- 4
			[[\fscy]]                                     -- 5
			minHeight                                     -- 6
			[[\c&H]]                                      -- 7
			beforeColor                                   -- 8
			[[&}m 0 0 l 1 0 1 1 0 1]]                     -- 9
		}

		@passed = false

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		@line[2] = [[%d,%d]]\format math.floor( @position*w ), h
		return true

	animateSize: ( value ) =>
		@line[4] = [[%g]]\format (maxWidth - minWidth)*value + minWidth
		@line[6] = [[%g]]\format (maxHeight*maxHeightFrac - minHeight)*value + minHeight

	update: ( position ) =>
		update = false

		if not @passed and (position > @position)
			@line[8] = afterColor
			@passed = true
			update = true
		elseif @passed and (position < @position)
			@line[8] = beforeColor
			@passed = false
			update = true

		return update
