class Chapters extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = { }
		@markers = { }
		@animation = Animation 0, 1, 0.25, @\animateSize

	createMarkers: ( w, h ) =>
		@markers = { }

		totalTime = mp.get_property_number 'length', 0
		chapters = mp.get_property_native 'chapter-list', { }

		for chapter in *chapters
			table.insert @markers, ChapterMarker @animationQueue, chapter.title, chapter.time/totalTime, w, h

	stringify: =>
		return table.concat @line, '\n'

	redrawMarkers: =>
		@line = {	}
		for marker in *@markers
			table.insert @line, marker\stringify!

	updateSize: ( w, h ) =>
		super w, h

		for marker in *@markers
			marker\updateSize w, h

		@redrawMarkers!

		return true

	animateSize: ( animation, value ) =>
		for marker in *@markers
			marker\animateSize value
		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01

		for marker in *@markers
			if marker\update inputState, currentPosition
				update = true

		if update
			@redrawMarkers!

		return update
