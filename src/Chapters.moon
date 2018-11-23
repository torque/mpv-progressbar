class Chapters extends BarBase
	minWidth = settings['chapter-marker-width']*100
	maxWidth = settings['chapter-marker-width-active']*100
	maxHeight = settings['bar-height-active']*100
	maxHeightFrac = settings['chapter-marker-active-height-fraction']

	new: =>
		super!
		@line = { }
		@markers = { }
		@animation = Animation 0, 1, @animationDuration, @\animate

	createMarkers: =>
		@line = { }
		@markers = { }

		-- small number to avoid division by 0
		totalTime = mp.get_property_number 'duration', 0.01
		chapters = mp.get_property_native 'chapter-list', { }

		markerHeight = @active and maxHeight*maxHeightFrac or BarBase.instantiatedBars[1].animationMinHeight
		markerWidth = @active and maxWidth or minWidth
		for chapter in *chapters
			marker = ChapterMarker chapter.time/totalTime, markerWidth, markerHeight
			table.insert @markers, marker
			table.insert @line, marker\stringify!
		@needsUpdate = true

	reconfigure: =>
		-- Need to call the UIElement reconfigure implementation, but can't use
		-- super because calling the BarBase reconfigure on this class would break a
		-- lot. This should probably not be a subclass of BarBase.
		UIElement.reconfigure @
		minWidth = settings['chapter-marker-width']*100
		maxWidth = settings['chapter-marker-width-active']*100
		maxHeight = settings['bar-height-active']*100
		maxHeightFrac = settings['chapter-marker-active-height-fraction']
		ChapterMarker\reconfigure!
		@createMarkers!
		@animation = Animation 0, 1, @animationDuration, @\animate

	resize: =>
		for i, marker in ipairs @markers
			marker\resize!
			@line[i] = marker\stringify!
		@needsUpdate = true

	animate: ( value ) =>
		width = (maxWidth - minWidth)*value + minWidth
		height = (maxHeight*maxHeightFrac - BarBase.instantiatedBars[1].animationMinHeight)*value + BarBase.instantiatedBars[1].animationMinHeight
		for i, marker in ipairs @markers
			marker\animate width, height
			@line[i] = marker\stringify!

		@needsUpdate = true

	redraw: =>
		super!
		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01
		update = false
		for i, marker in ipairs @markers
			if marker\redraw currentPosition
				@line[i] = marker\stringify!
				update = true

		return @needsUpdate or update
