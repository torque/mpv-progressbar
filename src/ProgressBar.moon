class ProgressBar extends Rect

	bar_height = 2

	new: ( width, height ) =>
		super 0, height - bar_height, width, bar_height

		-- File length in seconds.
		length = mp.get_property_number 'length'

		-- Redrawing twice a second gives pretty good results here.
		redrawFrequency = 0.5

		@drawTimer = mp.add_periodic_timer redrawFrequency, @\draw
		mp.observe_property 'fullscreen', 'bool', @\manualDraw
		mp.observe_property 'pause', 'bool', @\pause
		mp.register_event 'seek', @\manualDraw

		-- Trying to avoid using a callback each tick (currently we're
		-- rendering ~10x less frequently for 24fps video than we would be
		-- using `tick`). However, there are some disadvantages, like
		-- (relatively) large lag time between e.g. when fullscreen is
		-- entered and its observe_property callback is fired.
		-- mp.register_event 'tick', @\draw
		mp.set_osd_ass width, height, ([[{\an7\pos(%d,%d)\bord0\shad0\c&H2D2D2D&\p1}m 0 0 l %d 0 %d %d 0 %d]])\format @x, @y, @w, @w, bar_height, bar_height

	draw: =>
		width, height = mp.get_screen_size!
		@setPosition 0, height - bar_height
		@setDimensions width
		pos = mp.get_property_number 'percent-pos'
		position = 0.04 * @w * mp.get_property_number 'percent-pos'

		mp.set_osd_ass width, height, ([[{\an7\pos(%d,%d)\bord0\shad0\c&H2D2D2D&\p1}m 0 0 l %d 0 %d %d 0 %d%s{\an7\pos(%d,%d)\bord0\shad0\c&FC799E&\p3}m 0 0 l %d 0 %d %d 0 %d]])\format @x, @y, @w, @w, bar_height, bar_height, '\n', @x, @y, position, position, bar_height*4, bar_height*4

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
