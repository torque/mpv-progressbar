class Window
	@@osdScale = mp.get_property_number("display-hidpi-scale", 1)

	@@w, @@h = 0, 0
	@@_rawW, @@_rawH = 0, 0

	@update: =>
		w, h = mp.get_osd_size!
		osdScale = mp.get_property_number("display-hidpi-scale", 1)

		@_rawW, @_rawH = w, h
		w, h = math.floor( w/osdScale ), math.floor( h/osdScale )

		if w != @w or h != @h or osdScale != @osdScale
			@w, @h, @osdScale = w, h, osdScale
			return true
		else
			return false
