class PauseIndicator
	new: ( @eventLoop, paused ) =>
		w, h = 0.5*Window.w, 0.5*Window.h
		@line = {
			[[{\fscx0\fscy0]]          --  1
			[[\alpha&H]]               --  2
			0                          --  3
			[[&\pos(]]                 --  4
			[[%g,%g]]\format w, h      --  5
			[[)\an5\bord0%s\p1}]]\format settings['pause-indicator-background-style']
			0                          --  7
			[[{\fscx0\fscy0]]          --  8
			[[\alpha&H]]               --  9
			0                          -- 10
			[[&\pos(]]                 -- 11
			[[%g,%g]]\format w, h      -- 12
			[[)\an5\bord0%s\p1}]]\format settings['pause-indicator-foreground-style']
			0                          -- 14
		}
		if paused
			@line[7]  = 'm 75 37.5 b 75 58.21 58.21 75 37.5 75 16.79 75 0 58.21 0 37.5 0 16.79 16.79 0 37.5 0 58.21 0 75 16.79 75 37.5 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20\n'
			@line[14] = 'm 0 0 m 75 75 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20'
		else
			@line[7]  = 'm 75 37.5 b 75 58.21 58.21 75 37.5 75 16.79 75 0 58.21 0 37.5 0 16.79 16.79 0 37.5 0 58.21 0 75 16.79 75 37.5 m 25.8333 17.18 l 25.8333 57.6 60.8333 37.39\n'
			@line[14] = 'm 0 0 m 75 75 m 25.8333 17.18 l 25.8333 57.6 60.8333 37.39'

		@animationCb = @\animate
		@finishedCb = @\destroy

		AnimationQueue.registerAnimation Animation 0, 1, 0.3, @animationCb, @finishedCb
		@eventLoop\addSubscriber @

	stringify: =>
		return table.concat @line

	updateSize: =>
		w, h = 0.5*Window.w, 0.5*Window.h
		@line[5]  = [[%g,%g]]\format w, h
		@line[12] = [[%g,%g]]\format w, h
		return true

	update: ->
		return true

	animate: ( animation, value ) =>
		scale = value*50 + 100
		scaleStr = [[{\fscx%g\fscy%g]]\format scale, scale
		-- I think this nonlinear behavior looks a little nicer.
		alphaStr = '%02X'\format value*value*255
		@line[1]  = scaleStr
		@line[8] = scaleStr
		@line[3]  = alphaStr
		@line[10] = alphaStr

	destroy: ( animation ) =>
		@eventLoop\removeSubscriber @eventLoopIndex
