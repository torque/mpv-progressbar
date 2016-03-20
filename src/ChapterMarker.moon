class ChapterMarker
	minWidth = settings['chapter-marker-width']*100
	minHeight = settings['bar-height-inactive']*100
	maxHeight = settings['bar-height-active']*100
	beforeColor = settings['chapter-marker-before']
	afterColor = settings['chapter-marker-after']
	new: ( @position, w, h ) =>
		@line = {
			[[{\an2\bord0\p1\pos(]]                       -- 1
			[[%d,%d]]\format math.floor( @position*w ), h -- 2
			[[)\fscx]]                                    -- 3
			[[%g]]\format minWidth                        -- 4
			[[\fscy]]                                     -- 5
			[[%g]]\format minHeight                       -- 6
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
		@line[6] = [[%g]]\format (maxHeight - minHeight)*value + minHeight

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
