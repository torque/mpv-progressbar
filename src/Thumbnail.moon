class Thumbnail extends BarAccent

	bottomMargin = settings['thumbnail-bottom-margin']
	borderExpansion = settings['thumbnail-border-expansion']
	rightMargin = settings['thumbnail-right-margin'] + borderExpansion
	leftMargin = settings['thumbnail-left-margin'] + borderExpansion

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
		borderExpansion = settings['thumbnail-border-expansion']
		leftMargin = settings['thumbnail-left-margin'] + borderExpansion
		bottomMargin = settings['thumbnail-bottom-margin'] + borderExpansion

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

				scaledWidth = @thumbfast.width / Window.osdScale
				thumbX = clamp @lastX, leftMargin + (scaledWidth / 2), Window.w - rightMargin - (scaledWidth / 2)
				@line[2] = [[%g,%g]]\format thumbX, Window.h - (bottomMargin - borderExpansion)

				width = scaledWidth + (2 * borderExpansion)
				height = (@thumbfast.height / Window.osdScale) + (2 * borderExpansion)
				@line[4] = [[m 0 0 l %g 0 %g %g 0 %g]]\format width, width, height, height

				mp.commandv(
					'script-message-to', 'thumbfast', 'thumb',
					hoverTime,
					clamp(
						Mouse._rawX - @thumbfast.width / 2,
						leftMargin * Window.osdScale,
						Window._rawW - @thumbfast.width - (rightMargin * Window.osdScale)
					),
					Window._rawH - @thumbfast.height - (bottomMargin * Window.osdScale)
				)

			@needsUpdate = true

		return @needsUpdate
