class Chapters extends Subscriber

	minHeight = settings['bar-height-inactive']*100

	new: ( @animationQueue ) =>
		super!

		@line = { }
		@markers = { }
		@animation = Animation 0, 1, 0.25, @\animateSize

	createMarkers: ( w, h ) =>
		@line = { }
		@markers = { }

		-- small number to avoid division by 0
		totalTime = mp.get_property_number 'duration', 0.01
		chapters = mp.get_property_native 'chapter-list', { }

		for chapter in *chapters
			marker = ChapterMarker chapter.time/totalTime, w, h
			table.insert @markers, marker
			table.insert @line, marker\stringify!

	stringify: =>
		return table.concat @line, '\n'

	redrawMarker: ( i ) =>
		@line[i] = @markers[i]\stringify!

	redrawMarkers: =>
		for i, marker in ipairs @markers
			@line[i] = marker\stringify!

	updateSize: ( w, h ) =>
		super w, h

		for i, marker in ipairs @markers
			marker\updateSize w, h
			@line[i] = marker\stringify!

		return true

	animateSize: ( animation, value ) =>
		for i, marker in ipairs @markers
			marker\animateSize value
			@line[i] = marker\stringify!

		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01

		for i, marker in ipairs @markers
			if marker\update currentPosition
				@redrawMarker i
				update = true

		return update
