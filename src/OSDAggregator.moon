class OSDAggregator

	new: =>
		@script = { }
		@subscribers = { }
		@subscriberCount = 0
		@w = 0
		@h = 0

		redrawFrequency = 0.05
		@updateTimer = mp.add_periodic_timer redrawFrequency, @\update

		mp.register_event 'seek', @\forceUpdate
		mp.register_event 'shutdown', ->
			@updateTimer\kill!


	addSubscriber: ( subscriber ) =>
		return if not subscriber
		@subscriberCount += 1
		subscriber.aggregatorIndex = @subscriberCount
		@subscribers[@subscriberCount] = subscriber
		@script[@subscriberCount] = tostring subscriber

	removeSubscriber: ( index ) =>
		for i = index+1, @subscriberCount
			@subscribers[i].aggregatorIndex -= 1

		table.remove @subscribers, index
		table.remove @script, index

		@subscriberCount -= 1

	update: ( force = false ) =>
		needsRedraw = force
		x, y = mp.get_mouse_pos!
		w, h = mp.get_screen_size!
		needsResize = false
		if w != @w or h != @h
			@w, @h = w, h
			needsResize = true

		for sub = 1, @subscriberCount
			theSub = @subscribers[sub]
			update = false
			if theSub\update x, y
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
