class EventLoop

	new: =>
		@script = { }
		@uiElements = Stack!
		@activityZones = Stack!
		@displayRequested = false

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\redraw
		@updateTimer\stop!

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		local displayRequestTimer
		displayDuration = settings['request-display-duration']

		mp.add_key_binding "tab", "request-display",
			( event ) ->
				-- Complex bindings will always fire repeat events and the best we can
				-- do is to quickly return.
				if event.event == "repeat"
					return
				-- The "press" event happens when a simulated keypress happens through
				-- the JSON IPC, the client API and through the mpv command interface. I
				-- don't know if it will ever happen with an actual key event.
				if event.event == "down" or event.event == "press"
					if displayRequestTimer
						displayRequestTimer\kill!
					@displayRequested = true
				if event.event == "up" or event.event == "press"
					if displayDuration == 0
						@displayRequested = false
					else
						displayRequestTimer = mp.add_timeout displayDuration, ->
							@displayRequested = false,
			{ complex: true }

		mp.add_key_binding 'ctrl+r', 'reconfigure', @\reconfigure, { repeatable: false }

	reconfigure: =>
		settings\_reload!
		AnimationQueue.destroyAnimationStack!
		for _, zone in ipairs @activityZones
			zone\reconfigure!
		for _, element in ipairs @uiElements
			element\reconfigure!

	addZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\insert zone

	removeZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\remove zone

	generateUIFromZones: =>
		seenUIElements = { }
		@script = { }
		@uiElements\clear!
		AnimationQueue.destroyAnimationStack!
		for _, zone in ipairs @activityZones
			for _, uiElement in ipairs zone.elements
				unless seenUIElements[uiElement]
					@addUIElement uiElement
					seenUIElements[uiElement] = true

		@updateTimer\resume!

	addUIElement: ( uiElement ) =>
		if uiElement == nil
			error 'nil UIElement added.'
		@uiElements\insert uiElement
		table.insert @script, ''

	removeUIElement: ( uiElement ) =>
		if uiElement == nil
			error 'nil UIElement removed.'
		-- this is kind of janky as it relies on an implementation detail of Stack
		-- (i.e. that it stores the element index in the under the hashtable key of
		-- the stack instance itself)
		table.remove @script, uiElement[@uiElements]
		@uiElements\remove uiElement

	resize: =>
		for _, zone in ipairs @activityZones
			zone\resize!
		for _, uiElement in ipairs @uiElements
			uiElement\resize!

	redraw: ( forceRedraw ) =>
		clickPending = Mouse\update!
		if Window\update!
			@resize!

		for index, zone in ipairs @activityZones
			zone\update @displayRequested, clickPending

		AnimationQueue.animate!
		for index, uiElement in ipairs @uiElements
			if uiElement\redraw!
				@script[index] = uiElement\stringify!
		mp.set_osd_ass Window.w, Window.h, table.concat @script, '\n'
