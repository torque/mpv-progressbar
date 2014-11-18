class Chapters extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0

		@line = { }
		@markers = { }
		@hovered = false
		@needsUpdate = false
		@animationCb = @\animateSize
		@heightAnimation = Animation 0, 1, 0.25, @animationCb

	createMarkers: ( w, h ) =>
		@markers = { }

		totalTime = mp.get_property_number 'length', 0
		chapters = mp.get_property_native 'chapter-list', { }

		for chapter in *chapters
			table.insert @markers, ChapterMarker chapter.title, chapter.time/totalTime, w, h

	__tostring: =>
		return table.concat @line, '\n'

	redrawMarkers: =>
		@line = {	}
		for marker in *@markers
			table.insert @line, tostring marker

	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

		for marker in *@markers
			marker\updateSize w, h

		@redrawMarkers!

		return true

	animateSize: ( animation, value ) =>
		for marker in *@markers
			marker\animateSize value
		@needsUpdate = true

	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				@heightAnimation\interrupt false, @animationQueue
		else
			if @hovered
				update = true
				@hovered = false
				@heightAnimation\interrupt true, @animationQueue

		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01

		for marker in *@markers
			update = update or marker\update currentPosition

		if update
			@redrawMarkers!

		@needsUpdate = false
		return update
