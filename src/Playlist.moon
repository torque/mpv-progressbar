class Playlist extends Subscriber

	new: ( @animationQueue ) =>
		super!
		offscreenPos = settings['title-offscreen-pos']
		@line = {
			[[{\an7\fn%s\bord2\fs%d\pos(]]\format settings.font, settings['title-font-size']
			[[%g,%g]]\format settings['title-left-margin'], offscreenPos
			[[)\c&H%s&\3c&H%s&}]]\format settings['title-foreground'], settings['title-background']
			0
		}

		@topBox = Rect 0, 0, 0, settings['top-hover-zone-height']
		@animation = Animation offscreenPos, settings['title-top-margin'], 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@topBox.w = w

	animatePos: ( animation, value ) =>
		@line[2] = [[%g,%g]]\format settings['title-left-margin'], value
		@needsUpdate = true

	updatePlaylistInfo: =>
		title = mp.get_property 'media-title', ''
		position = mp.get_property_number 'playlist-pos', 0
		total = mp.get_property_number 'playlist-count', 1
		@line[4] = ([[%d/%d – %s]])\format position+1, total, title
		@needsUpdate = true

	update: ( inputState ) =>
		with inputState
			super inputState, (@containsPoint( .mouseX, .mouseY ) or @topBox\containsPoint( .mouseX, .mouseY ) or .displayRequested)
