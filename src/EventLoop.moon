class EventLoop

	new: =>
		@script = { }
		@subscribers = Stack!
		@activityZones = Stack!
		@inputState = {
			mouseX: -1, mouseY: -1, mouseInWindow: false, mouseDead: true,
			displayRequested: false
		}

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

	addZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\insert zone

	removeZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\remove zone

	addSubscriber: ( subscriber ) =>
		if subscriber == nil
			return
		@subscribers\insert subscriber
		table.insert @script, ''

	removeSubscriber: ( subscriber ) =>
		if subscriber == nil
			return
		-- this is kind of janky as it relies on an implementation detail of Stack
		-- (i.e. that it stores the element index in the under the hashtable key of
		-- the stack instance itself)
		table.remove @script, subscriber[@subscribers]
		@subscribers\remove subscriber

	update: ( needsRedraw ) =>
		with @inputState
			oldX, oldY = .mouseX, .mouseY
			.mouseX, .mouseY = mp.get_mouse_pos!
			if .mouseDead and (oldX != .mouseX or oldY != .mouseY)
				.mouseDead = false

		needsResize = Window\update!

		needsRedraw = false
		for index, zone in @activityZones
			if zone\update( @inputState, needsResize ) and not needsRedraw
				needsRedraw = true

		if needsRedraw
			AnimationQueue.animate!
			for index, subscriber in ipairs @subscribers
				if subscriber.needsUpdate
					@script[index] = subscriber\stringify!
			mp.set_osd_ass Window.w, Window.h, table.concat @script, '\n'

		-- 		@script[sub] = subscriber\stringify!
		-- for index, subscriber in ipairs @subscribers
		-- 	if subscriber.needsUpdate
		-- 		@script[sub] = subscriber\stringify!
		-- 		unless needsRedraw
		-- 			needsRedraw = true
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

	-- pause: ( event, @paused ) =>
	-- 	if @paused
	-- 		@updateTimer\stop!
	-- 	else
	-- 		@updateTimer\resume!

	-- forceUpdate: =>
	-- 	@updateTimer\kill!
	-- 	@update true
	-- 	unless @paused
	-- 		@updateTimer\resume!
