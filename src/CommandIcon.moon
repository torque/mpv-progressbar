class CommandIcon extends UIElement

	-- The icon is clipped from the background by using the nonzero winding rule.
	-- This means that all icons are wound counterclockwise, while the background
	-- is wound clockwise. These icons will be tiny until they are scaled upward,
	-- due to normalization. The icon templates will have 'm 0 0 m 1 1'
	-- automatically prepended to them, as this forces them to become properly
	-- centered.
	@BackgroundTemplate = 'm 1 0.5 b 1 0.776 0.776 1 0.5 1 0.224 1 0 0.776 0 0.5 0 0.224 0.224 0 0.5 0 0.776 0 1 0.224 1 0.5 '
	@PauseIconTemplate: 'm 0 0 l 0 0.4 0.133 0.4 0.133 0 m 0.267 0 l 0.267 0.4 0.4 0.4 0.4 0'
	@PlayIconTemplate: 'm 0.344 0.229 l 0.344 0.768 0.811 0.499'

	scale: settings['command-indicator-size']*100
	line: {
		[[{\fscx]]   -- 1
		0            -- 2
		[[\fscy]]    -- 3
		0            -- 4
		[[\alpha&H]] -- 5
		[[00]]       -- 6
		[[&\pos(]]   -- 7
		[[0,0]]      -- 8
		[[)}]]       -- 9
		[[]]         -- 10
		'\n{\\fscx'  -- 11
		0            -- 12
		[[\fscy]]    -- 13
		0            -- 14
		[[\alpha&H]] -- 15
		[[00]]       -- 16
		[[&\pos(]]   -- 17
		[[0,0]]      -- 18
		[[)}]]       -- 19
		[[]]         -- 20
	}

	_setScale: ( scale ) =>
		@line[2]  = scale
		@line[4]  = scale
		@line[12] = scale
		@line[14] = scale

	reconfigure: =>
		@scale = settings['command-indicator-size']*100
		@_setScale @scale

		@line[9]  = [[)\an5\bord0%s\p1}%s]]\format settings['command-indicator-background-style'], @@BackgroundTemplate
		@line[19] = [[)\an5\bord0%s\p1}m 0 0 m 1 1 ]]\format settings['command-indicator-foreground-style']

		@animation = Animation 0, 1, settings['command-indicator-animation-duration'], @\animate, ->
			@active = false

	resize: =>
		w, h = 0.5*Window.w, 0.5*Window.h
		pos = '%g,%g'\format w, h
		@line[8]  = pos
		@line[18] = pos

	animate: ( value ) =>
		@_setScale value*@scale*0.5 + @scale
		-- I think this nonlinear behavior looks a little nicer.
		alphaStr = '%02X'\format value*value*255
		@line[6]  = alphaStr
		@line[16] = alphaStr

	showIcon: ( iconName ) =>
		switch iconName
			when 'pause'
				@line[10] = @@PauseIconTemplate
				@line[20] = @@PauseIconTemplate
			when 'play'
				@line[10] = @@PlayIconTemplate
				@line[20] = @@PlayIconTemplate

		unless @active
			@activate true
		else
			@animation\reset!
