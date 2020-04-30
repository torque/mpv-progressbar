class Title extends UIElement

	new: =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line = {
			[[{\pos(]]
			[[%g,%g]]\format settings['title-left-margin'], offscreenPos
			[[)\an7%s%s}]]\format settings['default-style'], settings['title-style']
			[[????]]
		}
		@position = offscreenPos
		@animation = Animation offscreenPos, settings['title-top-margin'], @animationDuration, @\animate, nil, 0.5
		@_forceUpdatePlaylistInfo!

		updatePlaylistInfo = @\updatePlaylistInfo
		mp.observe_property 'media-title',    'string', updatePlaylistInfo
		mp.observe_property 'playlist-pos-1', 'number', updatePlaylistInfo
		mp.observe_property 'playlist-count', 'number', updatePlaylistInfo

	reconfigure: =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line[2] = ('%g,%g')\format settings['title-left-margin'], @animation.value
		@line[3] = [[)\an7%s%s}]]\format settings['default-style'], settings['title-style']
		@animation = Animation offscreenPos, settings['title-top-margin'], @animationDuration, @\animate, nil, 0.5

	resize: =>

	animate: ( value ) =>
		@line[2] = ('%g,%g')\format settings['title-left-margin'], value
		@needsUpdate = true

	_forceUpdatePlaylistInfo: =>
		@playlistInfo = {
			'media-title':    mp.get_property 'media-title', '????'
			'playlist-pos-1': mp.get_property_number 'playlist-pos-1', 1
			'playlist-count': mp.get_property_number 'playlist-count', 1
		}

	generateTitleString: (quote=false) =>
		{'media-title': title, 'playlist-pos-1': position, 'playlist-count': total} = @playlistInfo
		prefix = (total > 1) and '%d/%d - '\format( position, total ) or ''
		if quote
			return prefix .. '%q'\format title
		else
			return prefix .. title

	updatePlaylistInfo: (changedProp, newValue) =>
		if newValue
			@playlistInfo[changedProp] = newValue
			@line[4] = @generateTitleString!

			@needsUpdate = true

	print: =>
		if settings['title-print-to-cli']
			log.warn "Playing: %s", @generateTitleString true
