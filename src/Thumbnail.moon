class Thumbnail extends BarAccent

	rightMargin = settings['thumbnail-right-margin']
	leftMargin = settings['thumbnail-left-margin']
	bottomMargin = settings['thumbnail-bottom-margin']
	borderExpansion = settings['thumbnail-border-expansion']

	boxStyle = [[)\an2%s%s\p1}]]

	new: ( thumbfastInfo ) =>
		@line = {
			[[{\pos(]] -- 1
			0          -- 2
			boxStyle\format settings['default-style'], settings['thumbnail-border-style']
			0          -- 4
		}

		super!

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
		borderExpansion = settings['thumbnail-border-expansion']

		@line[3] = boxStyle\format settings['default-style'], settings['thumbnail-border-style']

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

				@line[2] = [[%d,%d]]\format @lastX, Window.h - (bottomMargin - borderExpansion)

				width = (@thumbfast.width / Window.osdScale) + (2 * borderExpansion)
				height = (@thumbfast.height / Window.osdScale) + (2 * borderExpansion)
				@line[4] = [[m 0 0 l %d 0 %d %d 0 %d]]\format width, width, height, height

				mp.commandv(
					'script-message-to', 'thumbfast', 'thumb',
					hoverTime,
					clamp( Mouse._rawX - @thumbfast.width / 2, leftMargin, Window._rawW - @thumbfast.width - rightMargin ),
					Window._rawH - bottomMargin*Window.osdScale - @thumbfast.height
				)

			@needsUpdate = true

		return @needsUpdate
