class Window

	@w: 0
	@h: 0
	@resizables: List!
	@osdScale: settings['display-scale-factor']

	@reconfigure: =>
		@osdScale = settings['display-scale-factor']

	@registerResizable: ( resizable ) =>
		@resizables\insert resizable

	@update: =>
		w, h = mp.get_osd_size!
		w, h = math.floor( w/@osdScale ), math.floor( h/@osdScale )
		if w != @w or h != @h
			@w, @h = w, h
			for resizable in @resizables\loop!
				resizable\resize!
