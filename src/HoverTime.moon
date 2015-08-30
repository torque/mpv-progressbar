class HoverTime extends Subscriber

	new: ( @animationQueue ) =>
		super!

		@line = {
			[[{\fnSource Sans Pro Semibold\bord0\fs26\pos(]]
			[[-100,0]]
			[[)\3c&H2D2D2D&\c&HFC799E&\an2\alpha&H]]
			[[FF]]
			[[&}]]
			0
		}
		@bgLine = {
			[[{\bord0\pos(]]
			[[-100,0]]
			[[)\an2\c&H2D2D2D&\alpha&H]]
			[[FF]]
			[[&\p1}]]
			[[]]
		}

		@lastX = -1
		@lastTime = -1
		@position = -100
		@lastSize = -1
		@sizeCache = {}
		@animation = Animation 255, 0, 0.25, @\animateAlpha

	stringify: =>
		if not @hovered and not @animation.isRegistered
			return ""

		return table.concat {table.concat( @bgLine ), table.concat( @line )}, '\n'

	animateAlpha: ( animation, value ) =>
		alpha = ([[%02X]])\format value
		@line[4] = alpha
		@bgLine[4] = alpha
		@needsUpdate = true

	nibHeight = 6
	genBackground: ( idx, size ) =>
		width  = size.w + 10
		height = size.h + 8
		coords = {
			width,
			width, height,
			math.floor(width*0.5) + nibHeight, height,
			math.floor(width*0.5), height + nibHeight,
			math.floor(width*0.5) - nibHeight, height,
			height
		}
		@sizeCache[idx] = {
			drawing: ("m 0 0 l %d 0 %d %d %d %d %d %d %d %d 0 %d")\format unpack coords
			width: width
		}

	update: ( mouseX, mouseY, mouseOver ) =>
		update = super mouseX, mouseY, mouseOver

		-- width = 76 + 4px padding = 80
		if @hovered or @animation.isRegistered
			if mouseX != @lastX
				hoverTime = mp.get_property_number( 'length', 0 )*mouseX/@w
				update = true
				hours = hoverTime/3600
				if hours >= 1
					@line[6] = ([[%d:%02d:%02d]])\format hours, (hoverTime/60)%60, hoverTime%60
				else
					@line[6] = ([[%d:%02d]])\format (hoverTime/60)%60, hoverTime%60
				size = #@line[6]
				if size != @lastSize
					unless @sizeCache[size]
						lineSize = Bounds\instance!\sizeOf {table.concat @line}
						@genBackground size, lineSize

					@bgLine[6] = @sizeCache[size].drawing
					@width = @sizeCache[size].width
					@lastSize = size
					@lastTime = hoverTime

				lb, rb = @leftBound.current.w, @rightBound.current.w
				xpos = math.min( @w - (rb + @width/2), math.max( lb + @width/2, mouseX ) )
				ypos = @y + (hover_zone-4)*bar_height
				@line[2] = ("%g,%g")\format xpos, ypos - nibHeight + 1
				@bgLine[2] = ("%g,%g")\format xpos, ypos
				@lastX = mouseX

		return update
