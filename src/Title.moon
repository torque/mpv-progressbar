class Title extends UIElement

	@enableKey: 'enable-title'

	layer: 300
	enabled: settings['enable-title']
	position: settings['title-offscreen-pos']
	line: {
		[[{\pos(]],
		[[%g,%g]],
		[[)\an7%s%s}]],
		[[????]]
	}

	reconfigure: =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line[2] = ('%g,%g')\format settings['title-left-margin'], @animation.value
		@line[3] = [[)\an7%s%s}]]\format settings['default-style'], settings['title-style']
		@animation = Animation offscreenPos, settings['title-top-margin'], @animationDuration, @, 0.5

	resize: =>

	animate: ( value ) =>
		super!
		@line[2] = ('%g,%g')\format settings['title-left-margin'], value
		@needsRedraw = true

	updatePlaylistInfo: =>
		title = mp.get_property 'media-title', ''
		position = mp.get_property_number 'playlist-pos-1', 1
		total = mp.get_property_number 'playlist-count', 1
		playlistString = (total > 1) and '%d/%d - '\format( position, total ) or ''

		if settings['title-print-to-cli']
			log.warn "Playing: %s%q", playlistString, title

		@line[4] = ('%s%s')\format playlistString, title

		@needsRedraw = true
