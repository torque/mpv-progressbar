class Thumbnail extends BarAccent

	rightMargin = settings['thumbnail-right-margin']
	leftMargin = settings['thumbnail-left-margin']
	bottomMargin = settings['thumbnail-bottom-margin']

	new: ( thumbfastInfo ) =>
		super!

		@line = {}
		@lastX = -1
		@updateInfo thumbfastInfo

	updateInfo: ( thumbfastInfo ) =>
		@thumbfast = thumbfastInfo
		@lastX = -1
		@needsUpdate = true

	reconfigure: =>
		super!
		rightMargin = settings['thumbnail-right-margin']
		leftMargin = settings['thumbnail-left-margin']
		bottomMargin = settings['thumbnail-bottom-margin']

	activate: ( activate ) =>
		super activate
		if not activate
			mp.commandv( 'script-message-to', 'thumbfast', 'clear' )
			@needsUpdate = true

	redraw: =>
		if @active
			super!
			if Mouse.x != @lastX and not @thumbfast.disabled
				@lastX = Mouse.x

				hoverTime = mp.get_property_number( 'duration', 0 ) * Mouse.x / Window.w

				mp.commandv(
					'script-message-to', 'thumbfast', 'thumb',
					hoverTime,
					clamp( Mouse._rawX - @thumbfast.width / 2, leftMargin, Window._rawW - @thumbfast.width - rightMargin ),
					Window._rawH - bottomMargin*Window.osdScale - @thumbfast.height
				)

			@needsUpdate = true

		return @needsUpdate
