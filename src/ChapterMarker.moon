class ChapterMarker

	new: ( @title, @position, w, h ) =>
		@passed = false
		@line = {
			[[{\an2\bord0\p1\pos(]]
			[[%d,%d]]\format w*@position, h
			[[)\fscx]]
			100
			[[\fscy]]
			100
			[[\c&H7A77F2&]]
			[[}m 0 0 l 2 0 2 2 0 2]]
		}

	__tostring: =>
		if @passed
			@line[7] = [[\c&H2D2D2D&]]
		else
			@line[7] = [[\c&H7A77F2&]]

		return table.concat @line

	updateSize: ( w, h ) =>
		@line[2] = [[%d,%d]]\format w*@position, h
		return true

	animateSize: ( value ) =>
		@line[4] = [[%g]]\format value*0.5
		@line[6] = [[%g]]\format value

	update: ( position ) =>
		changed = @passed
		@passed = position > @position
		return changed != @passed
