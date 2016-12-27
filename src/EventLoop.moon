class EventLoop

	new: =>
		@script = { }
		@uiElements = Stack!
		@activityZones = Stack!
		@displayRequested = false

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\redraw

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		displayDuration = settings['request-display-duration']
		displayRequestTimer = mp.add_timeout 0, ->
		mp.add_key_binding "tab", "request-display",
			( event ) ->
				-- The "press" event happens when a simulated keypress happens through
				-- the JSON IPC, the client API and through the mpv command interface. I
				-- don't know if it will ever happen with an actual key event.
				if event.event == "down" or event.event == "press"
					displayRequestTimer\kill!
					@displayRequested = true
				if event.event == "up" or event.event == "press"
					displayRequestTimer = mp.add_timeout displayDuration, ->
						@displayRequested = false,
			{ complex: true }

	addZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\insert zone

	removeZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\remove zone

	addUIElement: ( uiElement ) =>
		if uiElement == nil
			return
		@uiElements\insert uiElement
		table.insert @script, ''

	removeUIElement: ( uiElement ) =>
		if uiElement == nil
			return
		-- this is kind of janky as it relies on an implementation detail of Stack
		-- (i.e. that it stores the element index in the under the hashtable key of
		-- the stack instance itself)
		table.remove @script, uiElement[@uiElements]
		@uiElements\remove uiElement

	redraw: ( forceRedraw ) =>
		clickPending = Mouse\update!
		needsResize = Window\update!

		for index, zone in @activityZones
			if zone\update( @displayRequested, clickPending ) and not forceRedraw
				forceRedraw = true

		if forceRedraw or AnimationQueue.active!
			AnimationQueue.animate!
			for index, uiElement in ipairs @uiElements
				if uiElement.active and uiElement\redraw!
					if needsResize
						uiElement\resize!
					@script[index] = uiElement\stringify!
			mp.set_osd_ass Window.w, Window.h, table.concat @script, '\n'
