class EventLoop

	new: =>
		@script = { }
		@subscribers = { }
		@inputState = {
			mouseX: -1, mouseY: -1, mouseInWindow: false, mouseDead: true,
			displayRequested: false, hideInactive: settings['hide-inactive']
		}
		@subscriberCount = 0
		@w = 0
		@h = 0

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\update

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		mp.observe_property 'fullscreen', 'bool', ->
			with @inputState
				.mouseX, .mouseY = mp.get_mouse_pos!
				.mouseDead = true

		mp.add_forced_key_binding "mouse_leave", "mouse-leave", ->
			@inputState.mouseInWindow = false

		mp.add_forced_key_binding "mouse_enter", "mouse-enter", ->
			@inputState.mouseInWindow = true

		displayDuration = settings['request-display-duration']
		displayRequestTimer = mp.add_timeout 0, ->
		mp.add_key_binding "tab", "request-display",
			( event ) ->
				-- "press" event happens when a simulated keypress happens
				-- through JSON IPC, the client API and through the mpv command
				-- interface. Don't know if it will ever happen with an actual
				-- key event.
				if event.event == "down" or event.event == "press"
					displayRequestTimer\kill!
					@inputState.displayRequested = true
				if event.event == "up" or event.event == "press"
					displayRequestTimer = mp.add_timeout displayDuration, ->
						@inputState.displayRequested = false,
			{ complex: true }

	addSubscriber: ( subscriber ) =>
		return if not subscriber
		@subscriberCount += 1
		subscriber.index = @subscriberCount
		@subscribers[@subscriberCount] = subscriber
		@script[@subscriberCount] = subscriber\stringify!

	removeSubscriber: ( index ) =>
		table.remove @subscribers, index
		table.remove @script, index
		@subscriberCount -= 1

		for i = index, @subscriberCount
			@subscribers[i].index = i

	forceResize: =>
		for index, subscriber in ipairs @subscribers
			subscriber\updateSize @w, @h

	update: ( needsRedraw ) =>
		with @inputState
			oldX, oldY = .mouseX, .mouseY
			.mouseX, .mouseY = mp.get_mouse_pos!
			if .mouseDead and (oldX != .mouseX or oldY != .mouseY)
				.mouseDead = false

		needsResize = Window\update!

		for index, subscriber in ipairs @subscribers
			if subscriber.needsUpdate
				@script[sub] = subscriber\stringify!
				unless needsRedraw
					needsRedraw = true
		-- for sub = 1, @subscriberCount
		-- 	theSub = @subscribers[sub]
		-- 	update = false
		-- 	if theSub\update @inputState
		-- 		update = true
		-- 	if (needsResize and theSub\updateSize( w, h )) or update or @needsRedrawAll
		-- 		needsRedraw = true
		-- 		if @hideInactive and not theSub.active
		-- 			@script[sub] = ""
		-- 		else
		-- 			@script[sub] = theSub\stringify!

		if needsRedraw
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

	toggleInactiveVisibility: =>
		@inputState.hideInactive = not @inputState.hideInactive
