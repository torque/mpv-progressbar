class OSDAggregator

	new: =>
		@script = { }
		@subscribers = { }
		@subscriberCount = 0
		@mouseOver = false
		@w = 0
		@h = 0

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\update

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		mp.add_key_binding "MOUSE_LEAVE", ->
			@mouseOver = false
		mp.add_key_binding "MOUSE_ENTER", ->
			@mouseOver = true

	addSubscriber: ( subscriber ) =>
		return if not subscriber
		@subscriberCount += 1
		subscriber.aggregatorIndex = @subscriberCount
		@subscribers[@subscriberCount] = subscriber
		@script[@subscriberCount] = subscriber\stringify!

	removeSubscriber: ( index ) =>
		table.remove @subscribers, index
		table.remove @script, index
		@subscriberCount -= 1

		for i = index, @subscriberCount
			@subscribers[i].aggregatorIndex = i

	update: ( force = false ) =>
		needsRedraw = force
		x, y = mp.get_mouse_pos!
		w, h = mp.get_osd_size!
		needsResize = false
		if w != @w or h != @h
			@w, @h = w, h
			needsResize = true

		for sub = 1, @subscriberCount
			theSub = @subscribers[sub]
			update = false
			if theSub\update x, y, @mouseOver
				update = true
			if (needsResize and theSub\updateSize( w, h )) or update
				needsRedraw = true
				@script[sub] = theSub\stringify!

		if true == needsRedraw
			mp.set_osd_ass @w, @h, table.concat @script, '\n'

	pause: ( event, @paused ) =>
		if @paused
			@updateTimer\stop!
		else
			@updateTimer\resume!

	forceUpdate: =>
		@updateTimer\kill!
		@update true
		unless @paused
			@updateTimer\resume!
