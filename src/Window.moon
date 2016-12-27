class Window
	osdScale = settings['display-scale-factor']

	@@w, @@h = 0, 0

	@update: =>
		w, h = mp.get_osd_size!
		w, h = math.floor( w/osdScale ), math.floor( h/osdScale )
		if w != @w or h != @h
			@w, @h = w, h
			return true
		else
			return false
