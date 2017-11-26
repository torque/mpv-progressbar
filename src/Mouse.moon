class Mouse

	@LeftClick:  0
	@RightClick: 1
	@Scroll:     2
	@Hover:      3

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
			when @LeftClick,
				@clickHandlers\insert responder
			when @RightClick
				@rightClickHandlers\insert responder
			when @Scroll
				@scrollHandlers\insert responder
			when @Hover
				@hoverHandlers\insert responder

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
		if @dead
			@dead = false
			return

		responderList, method = switch flavor
			when @LeftClick
				@clickHandlers, 'click'
			when @RightClick
				@rightClickHandlers, 'rightClick'
			else
				return

		x, y = scaledPosition!
		for responder in responderList\loop!
			if responder\containsPoint( x, y ) and not responder[method] responder, x, y
				return

	@dispatchScroll: ->
		-- do something here

mp.add_key_binding "mbtn_left", "left-click", ->
	Mouse\dispatchClick Mouse.LeftClick

mp.add_key_binding "mbtn_right", "right-click", ->
	Mouse\dispatchClick Mouse.RightClick

mp.add_key_binding "wheel_up", "", ->
mp.add_key_binding "wheel_down", "", ->
mp.add_key_binding "wheel_left", "", ->
mp.add_key_binding "wheel_right", "", ->

mp.observe_property 'fullscreen', 'bool', ->
	Mouse\update!
	Mouse.dead = true

mp.add_forced_key_binding "mouse_move", "mouse-move" ->
	Mouse.dead = false
	Mouse.needsUpdate = true

mp.add_forced_key_binding "mouse_leave", "mouse-leave", ->
	Mouse.inWindow = false

mp.add_forced_key_binding "mouse_enter", "mouse-enter", ->
	Mouse.inWindow = true
