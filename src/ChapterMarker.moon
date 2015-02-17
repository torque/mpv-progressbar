class ChapterMarker extends Subscriber

	new: ( @animationQueue, title, @position, w, h ) =>
		super!
		@x = math.floor( w*@position ) - 10
		@y = h - hover_zone*bar_height
		@w = 20
		@h = hover_zone*bar_height

		@line = {
			{
				[[{\an2\bord2\c&H7A77F2&\3c&H2D2D2D\fs30\pos(]]
				[[%d,%d]]\format @x + 10, h - hover_zone - 10
				[[)\alpha&H]]
				[[FF]]
				[[&}%s]]\format title
			},
			{
				[[{\an2\bord0\p1\pos(]]
				[[%d,%d]]\format @x + 10, h
				[[)\fscx]]
				100
				[[\fscy]]
				100
				[[\c&H7A77F2&]]
				[[}m 0 0 l 2 0 2 2 0 2]]
			}
		}

		@passed = false
		@animation = Animation 255, 0, 0.25, @\animateAlpha

	stringify: =>
		if @passed
			@line[2][7] = [[\c&H2D2D2D&]]
		else
			@line[2][7] = [[\c&H7A77F2&]]

		if @hovered or @animation.isRegistered
			return table.concat {
				table.concat @line[1]
				table.concat @line[2]
			}, '\n'
		else
			return table.concat @line[2]

	updateSize: ( w, h ) =>
		@x = math.floor( w*@position )
		@y = h - hover_zone*bar_height
		@line[1][2] = [[%d,%d]]\format @x + 10, h - hover_zone - 10
		@line[2][2] = [[%d,%d]]\format @x + 10, h
		return true

	animateAlpha: ( animation, value ) =>
		@line[1][4] = ([[%02X]])\format value
		@needsUpdate = true

	animateSize: ( value ) =>
		@line[2][4] = [[%g]]\format value * 100 + 100
		@line[2][6] = [[%g]]\format value * 300 + 100

	update: ( mouseX, mouseY, mouseOver, position ) =>
		update = super mouseX, mouseY, mouseOver

		changed = @passed
		@passed = position > @position
		update = update or changed != @passed

		return update
