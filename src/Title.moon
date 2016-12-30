class Title extends UIElement

	new: =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line = {
			[[{\pos(]]
			[[%g,%g]]\format settings['title-left-margin'], offscreenPos
			[[)\an7%s%s}]]\format settings['default-style'], settings['title-style']
			0
		}
		@animation = Animation offscreenPos, settings['title-top-margin'], @animationDuration, @\animate, nil, 0.5

	resize: =>

	animate: ( value ) =>
		@line[2] = [[%g,%g]]\format settings['title-left-margin'], value
		@needsUpdate = true

	updatePlaylistInfo: =>
		title = mp.get_property 'media-title', ''
		position = mp.get_property_number 'playlist-pos-1', 1
		total = mp.get_property_number 'playlist-count', 1
		playlistString = (total > 1) and '%d/%d - '\format( position, total ) or ''
		if settings['title-print-to-cli']
			log.warn "Playing: %s%q", playlistString, title
		@line[4] = [[%s%s]]\format playlistString, title
		@needsUpdate = true
