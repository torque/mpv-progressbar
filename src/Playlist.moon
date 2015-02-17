class Playlist extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\an7\fnSource Sans Pro Semibold\bord2\fs30\pos(]]
			[[4,-40]]
			[[)\3c&H2D2D2D&\c&HFC799E&}]]
			0
		}

		@topBox = Rect 0, 0, 0, hover_zone*bar_height
		@animation = Animation -40, 0, 0.25, @\animatePos, nil, 0.25

	updateSize: ( w, h ) =>
		super w, h
		@topBox.w = w

	animatePos: ( animation, value ) =>
		@line[2] = ([[4,%g]])\format value
		@needsUpdate = true

	updatePlaylistInfo: =>
		title = mp.get_property 'media-title', ''
		position = mp.get_property_number 'playlist-pos', 0
		total = mp.get_property_number 'playlist-count', 1
		@line[4] = ([[%d/%d – %s]])\format position+1, total, title

	update: ( mouseX, mouseY, mouseOver ) =>
		super mouseX, mouseY, mouseOver, (@containsPoint( mouseX, mouseY ) or @topBox\containsPoint( mouseX, mouseY ))
