class Mouse

	@LeftClick:   0
	@MiddleClick: 1
	@RightClick:  2
	@Scroll:      3
	@ScrollLeft:  4
	@ScrollRight: 5
	@ScrollUp:    6
	@ScrollDown:  7
	@Hover:       8

	@x:           -1
	@y:           -1
	@inWindow:    false
	@needsUpdate: true
	@dead:        true

	@clickHandlers:      OrderedList 'layer'
	@rightClickHandlers: OrderedList 'layer'
	@scrollHandlers:     OrderedList 'layer'
	@hoverHandlers:      OrderedList 'layer'

	scaledPosition = ->
		x, y = mp.get_mouse_pos!
		return math.floor( x/Window.osdScale ), math.floor( y/Window.osdScale )

	@registerEventHandler: ( event, responder ) =>
		switch event
			when @LeftClick
				@clickHandlers\insert responder
			when @RightClick
				@rightClickHandlers\insert responder
			when @Scroll
				@scrollHandlers\insert responder
			when @Hover
				@hoverHandlers\insert responder

	@unregisterEventHandler: ( event, responder ) =>
		switch event
			when @LeftClick
				@clickHandlers\remove responder
			when @RightClick
				@rightClickHandlers\remove responder
			when @Scroll
				@scrollHandlers\remove responder
			when @Hover
				@hoverHandlers\remove responder

	@update: =>
		if @inWindow and @needsUpdate
			x, y = scaledPosition!

			-- This iteration happens in reverse. Top layered elements are stored last
			-- in the list. Blocking hover isn't so simple as not propagating the
			-- event, however, because any underneath element that was previously
			-- hovered needs to have a mouseout event called on it.
			hitCanceled = false
			for responder in @hoverHandlers\loop!
				if hitCanceled
					-- No need to check for point containment, because hover propagation
					-- has been stopped at this point, so the only possible event is a
					-- mouseout.
					if responder.hovered
						responder\hover false
				else
					hit = responder\containsPoint x, y
					if hit and not responder.hovered
						hitCanceled = responder\hover true
					elseif not hit and responder.hovered
						-- A hover off event cannot cancel processing of lower events.
						responder\hover false

	@dispatchClick: ( flavor ) =>
		responderList, method = switch flavor
			when @LeftClick
				@clickHandlers, 'click'
			when @RightClick
				@rightClickHandlers, 'rightClick'
			else
				return

		return ( ev ) ->
			if @dead
				@dead = false
				return
			x, y = scaledPosition!
			for responder in responderList\loop!
				if responder\containsPoint( x, y ) and not responder[method] responder, x, y
					return

	@dispatchScroll: ( flavor ) =>
		x, y = switch flavor
			when @ScrollUp
				0, -1
			when @ScrollDown
				0, 1
			when @ScrollLeft
				-1, 0
			when @ScrollRight
				1, 0

		return ( ev ) ->
			mx, my = scaledPosition!
			for responder in @scrollHandlers\loop!
				if responder\containsPoint( mx, my ) and not responder\scroll x, y
					return

mp.add_key_binding "mbtn_left", "left-click", Mouse\dispatchClick( Mouse.LeftClick ), { complex: true }
-- mp.add_key_binding "mbtn_middle", "left-click", Mouse\dispatchClick( Mouse.LeftClick ), { complex: true }
mp.add_key_binding "mbtn_right", "right-click", Mouse\dispatchClick( Mouse.RightClick ), { complex: true }

mp.add_key_binding "wheel_up", "scroll-up", Mouse\dispatchScroll( Mouse.ScrollUp ), { complex: true }
mp.add_key_binding "wheel_down", "scroll-down", Mouse\dispatchScroll( Mouse.ScrollDown ), { complex: true }
mp.add_key_binding "wheel_left", "scroll-left", Mouse\dispatchScroll( Mouse.ScrollLeft ), { complex: true }
mp.add_key_binding "wheel_right", "scroll-right", Mouse\dispatchScroll( Mouse.ScrollRight ), { complex: true }

mp.observe_property 'fullscreen', 'bool', ->
	Mouse\update!
	Mouse.dead = true

mp.add_forced_key_binding "mouse_move", "mouse-move", ->
	Mouse.dead = false
	Mouse.needsUpdate = true

mp.add_forced_key_binding "mouse_leave", "mouse-leave", ->
	Mouse.inWindow = false
	for responder in @hoverHandlers\loop!
		if responder.hovered
			responder\hover false

mp.add_forced_key_binding "mouse_enter", "mouse-enter", ->
	Mouse.inWindow = true
