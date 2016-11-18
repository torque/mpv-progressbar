class Title extends TopSubscriber

	new: =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line = {
			[[{\fn%s\bord2\fs%d\pos(]]\format settings.font, settings['title-font-size']
			[[%g,%g]]\format settings['title-left-margin'], offscreenPos
			[[)\c&H%s&\3c&H%s&\an7}]]\format settings['title-foreground'], settings['title-background']
			0
		}

		@animation = Animation offscreenPos, settings['title-top-margin'], 0.25, @\animatePos, nil, 0.25

	animatePos: ( animation, value ) =>
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
