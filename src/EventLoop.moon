class EventLoop

	running: false

	new: ( @compositor ) =>
		mp.register_event 'shutdown', @\stop

	start: =>
		if @running
			return

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\pump
		AnimationQueue.lastTime = mp.get_time!

	stop: =>
		if @updateTimer
			@updateTimer\kill!
		@running = false

	reconfigure: =>
		settings\__reload!
		Window\reconfigure!
		AnimationQueue\destroyAnimationStack!

	pump: =>
		Window\update!
		Mouse\update!
		AnimationQueue\animate!
		@compositor\redraw!
