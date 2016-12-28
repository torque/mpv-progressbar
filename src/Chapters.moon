class Chapters extends BarBase

	minHeight = settings['bar-height-inactive']*100

	new: =>
		super!
		@animation = Animation 0, 1, @animationDuration, @\animate

	createMarkers: =>
		@line = { }
		@markers = { }

		-- small number to avoid division by 0
		totalTime = mp.get_property_number 'duration', 0.01
		chapters = mp.get_property_native 'chapter-list', { }

		for chapter in *chapters
			marker = ChapterMarker chapter.time/totalTime
			table.insert @markers, marker
			table.insert @line, marker\stringify!

	stringify: =>
		return table.concat @line, '\n'

	redrawMarker: ( i ) =>
		@line[i] = @markers[i]\stringify!

	redrawMarkers: =>
		for i, marker in ipairs @markers
			@line[i] = marker\stringify!

	resize: =>
		for i, marker in ipairs @markers
			marker\resize w, h
			@line[i] = marker\stringify!

	animate: ( animation, value ) =>
		for i, marker in ipairs @markers
			marker\animate value
			@line[i] = marker\stringify!

		@needsUpdate = true

	redraw: =>
		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01

		for i, marker in ipairs @markers
			if marker\redraw currentPosition
				@redrawMarker i
				update = true

		return @needsUpdate or update
