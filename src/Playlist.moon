class Playlist extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0

		@topBox = Rect 0, 0, 0, hover_zone*bar_height

		@line = {
			[[{\an7\fnSource Sans Pro Semibold\bord2\fs30\pos(]]
			[[4,-40]]
			[[)\3c&H2D2D2D&\c&HFC799E&}]]
			0
		}

		@hovered = false
		@position = -100
		@needsUpdate = false
		@animationCb = @\animatePos
		@posAnimation = Animation -40, 0, 0.25, @animationCb, nil, 0.25

	__tostring: =>
		if not @hovered and not @posAnimation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@topBox.w = w
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height
		return false

	animatePos: ( animation, value ) =>
		@line[2] = ([[4,%g]])\format value
		@needsUpdate = true

	updatePlaylistInfo: =>
		title = mp.get_property 'filename', ''
		position = mp.get_property_number 'playlist-pos', 0
		total = mp.get_property_number 'playlist-count', 1
		@line[4] = ([[%d/%d – %s]])\format position+1, total, title

	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint( mouseX, mouseY ) or @topBox\containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				@posAnimation\interrupt false, @animationQueue

		else
			if @hovered
				update = true
				@hovered = false
				@posAnimation\interrupt true, @animationQueue

		@needsUpdate = false
		return update
