class Thumbnail extends BarAccent

	rightMargin = settings['thumbnail-right-margin']
	leftMargin = settings['thumbnail-left-margin']
	bottomMargin = settings['thumbnail-bottom-margin']

	thumbfast = {
		width: 0,
		height: 0,
		disabled: false
	}

	new: =>
		super!

		@line = {}
		@lastX = -1
		@animation = Animation bottomMargin, bottomMargin, @animationDuration, @\animate, nil, 0.5

		mp.register_script_message('thumbfast-info', (json) ->
			data = utils.parse_json(json)
			if type(data) ~= 'table' or not data.width or not data.height then
				msg.error('thumbfast-info: received json didn\'t produce a table with thumbnail information')
			else
				thumbfast = data
		)

	reconfigure: =>
		super!
		rightMargin = settings['thumbnail-right-margin']
		leftMargin = settings['thumbnail-left-margin']
		bottomMargin = settings['thumbnail-bottom-margin']
		@animation = Animation bottomMargin, bottomMargin, @animationDuration, @\animate, nil, 0.5

	animate: ( value ) =>
		@needsUpdate = true

		if @active and Mouse.x != @lastX
			@lastX = Mouse.x
			if not thumbfast.disabled and thumbfast.width ~= 0 and thumbfast.height ~= 0
				hoverTime = mp.get_property_number( 'duration', 0 )*Mouse.x/Window.w
				mp.commandv( 'script-message-to', 'thumbfast', 'thumb',
					hoverTime,
					math.min(Window.w - thumbfast.width - 10, math.max(10, Mouse.x - thumbfast.width / 2)),
					Window.h - bottomMargin - thumbfast.height
				)

	redraw: =>
		if @active
			super!
			if not thumbfast.disabled and thumbfast.width ~= 0 and thumbfast.height ~= 0
				hoverTime = mp.get_property_number( 'duration', 0 )*Mouse.x/Window.w
				mp.commandv( 'script-message-to', 'thumbfast', 'thumb',
					hoverTime,
					math.min(Window.w - thumbfast.width - rightMargin, math.max(leftMargin, Mouse.x - thumbfast.width / 2)),
					Window.h - bottomMargin - thumbfast.height
				)
		elseif thumbfast.width ~= 0 and thumbfast.height ~= 0 then
		    mp.commandv( 'script-message-to', 'thumbfast', 'clear' )

		return @needsUpdate
