class ProgressBar extends Rect

	bar_height = 2

	new: ( width, height, @aggregator ) =>
		super 0, height - bar_height, width, height

		@aggregator\setDisplaySize width, height

		-- File length in seconds.
		@length = mp.get_property_number 'length'


		@background = {
			[[{\an7\bord0\c&H2D2D2D&\p1\pos(]]
			[[%d,%d]]
			[[)}m 0 0 l ]]
			[[%d 0 %d %d 0 %d]]
		}

		@foreground = {
			[[{\an7\bord0\c&FC799E&\p3\pos(]]
			[[%d,%d]]
			[[)}m 0 0 l ]]
			[[%d 0 %d %d 0 %d]]
		}

		@redrawBackground!
		@redrawForeground 0
		@backgroundHandle = @aggregator\addEvent table.concat @background
		@foregroundHandle = @aggregator\addEvent table.concat @foreground
		@postRedraw!

		@aggregator\display!

		-- Trying to avoid using a callback each tick (currently we're
		-- rendering ~10x less frequently for 24fps video than we would be
		-- using `tick`). However, there are some disadvantages, like
		-- (relatively) large lag time between e.g. when fullscreen is
		-- entered and its observe_property callback is fired.
		-- mp.register_event 'tick', @\draw

		-- Redrawing twice a second gives pretty good results here.
		redrawFrequency = 0.5
		@drawTimer = mp.add_periodic_timer redrawFrequency, @\draw
		mp.observe_property 'fullscreen', 'bool', @\manualDraw
		mp.observe_property 'pause', 'bool', @\pause
		mp.register_event 'seek', @\manualDraw
		mp.register_event 'shutdown', ->
			@drawTimer\kill!

	redrawBackground: =>
		@background[2] = @background[2]\format 0, @y
		@background[4] = @background[4]\format @w, @w, bar_height, bar_height

	redrawForeground: ( position ) =>
		@foreground[2] = @foreground[2]\format 0, @y
		@foreground[4] = @foreground[4]\format position, position, bar_height*4, bar_height*4

	postRedraw: =>
		@background[2] = [[%d,%d]]
		@background[4] = [[%d 0 %d %d 0 %d]]
		@foreground[2] = [[%d,%d]]
		@foreground[4] = [[%d 0 %d %d 0 %d]]

	draw: =>
		width, height = mp.get_screen_size!
		if @h != height or @w != width
			@setPosition 0, height - bar_height
			@setDimensions width, height
			@aggregator\setDisplaySize width, height
			@redrawBackground!
			@aggregator\updateEvent @backgroundHandle, table.concat @background

		@redrawForeground (0.04 * @w * mp.get_property_number 'percent-pos')
		@aggregator\updateEvent @foregroundHandle, table.concat @foreground
		@postRedraw!

		@aggregator\display!

	pause: ( event, @paused ) =>
		if @paused
			@drawTimer\stop!
		else
			@drawTimer\resume!

	manualDraw: ( event, value ) =>
		@drawTimer\kill!
		@draw!
		unless @paused
			@drawTimer\resume!
