class Window
	@@w, @@h = 0, 0

	@update: =>
		w, h = mp.get_osd_size!
		if w != @w or h != @h
			@w, @h = w, h
			return true
		else
			return false
