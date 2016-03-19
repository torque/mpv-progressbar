class OSDAggregator

	new: =>
		@script = { }
		@subscribers = { }
		@inputState = { mouseX: -1, mouseY: -1, mouseInWindow: true, displayRequested: false }
		@subscriberCount = 0
		@w = 0
		@h = 0

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\update

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		mp.add_forced_key_binding "mouse_leave", "mouse-leave", ->
			@inputState.mouseInWindow = false

		mp.add_forced_key_binding "mouse_enter", "mouse-enter", ->
			@inputState.mouseInWindow = true

		displayDuration = settings['request-display-duration']
		mp.add_key_binding "tab", "request-display",
			( event ) ->
				switch event.event
					when "down"
						@inputState.displayRequested = true
					when "up"
						mp.add_timeout displayDuration, ->
							@inputState.displayRequested = false,
			{ complex: true }

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

	update: ( needsRedraw ) =>
		with @inputState
			.mouseX, .mouseY = mp.get_mouse_pos!
		w, h = mp.get_osd_size!
		needsResize = false
		if w != @w or h != @h
			@w, @h = w, h
			needsResize = true

		for sub = 1, @subscriberCount
			theSub = @subscribers[sub]
			update = false
			if theSub\update @inputState
				update = true
			if (needsResize and theSub\updateSize( w, h )) or update
				needsRedraw = true
				@script[sub] = theSub\stringify!

		if needsRedraw == true
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
