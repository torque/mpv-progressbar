class Mouse
	@@x, @@y = -1, -1
	@@_rawX, @@_rawY = -1, -1
	@@inWindow, @@dead = false, true
	@@clickX, @@clickY = -1, -1
	@@clickPending = false

	scaledPosition = =>
		x, y = mp.get_mouse_pos!
		@_rawX, @_rawY = x, y
		return math.floor( x/Window.osdScale ), math.floor( y/Window.osdScale )

	@update: =>
		oldX, oldY = @x, @y
		@x, @y = scaledPosition @
		if @dead and (oldX != @x or oldY != @y)
			@dead = false
		if not @dead and @clickPending
			@clickPending = false
			return true
		return false

	@cacheClick: =>
		if not @dead
			@clickX, @clickY = scaledPosition @
			@clickPending = true
		else
			@dead = false

mp.add_key_binding "mouse_btn0", "left-click", ->
	Mouse\cacheClick!

mp.observe_property 'fullscreen', 'bool', ->
	Mouse\update!
	Mouse.dead = true

mp.add_forced_key_binding "mouse_leave", "mouse-leave", ->
	Mouse.inWindow = false

mp.add_forced_key_binding "mouse_enter", "mouse-enter", ->
	Mouse.inWindow = true
