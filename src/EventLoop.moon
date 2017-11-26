class EventLoop

	running: false

	new: ( @compositor ) =>
		mp.register_event 'shutdown', @\stop
		mp.add_key_binding 'ctrl+r', 'reconfigure', @\reconfigure, { repeatable: false }

	start: =>
		if @running
			return

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\redraw
		AnimationQueue.lastTime = mp.get_time!

	stop: =>
		@updateTimer\kill!
		@running = false

	reconfigure: =>
		settings\__reload!
		Window\reconfigure!
		AnimationQueue.destroyAnimationStack!

	redraw: =>
		Window\update!
		Mouse\update!
		AnimationQueue.animate mp.get_time!
		@compositor\redraw!
