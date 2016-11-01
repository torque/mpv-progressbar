class AnimationQueue

	new: ( @aggregator ) =>
		@list = {}
		@animationCount = 0
		@animating = false
		@timer = mp.add_periodic_timer settings['redraw-period'], @\animate
		@timer\kill!

	registerAnimation: ( animation ) =>
		@animationCount += 1
		animation.index = @animationCount
		animation.isRegistered = true
		table.insert @list, animation

		@startAnimation!

	unregisterAnimation: ( animation ) =>
		@unregisterAnimationByIndex animation.index

	unregisterAnimationByIndex: ( index ) =>
		@animationCount -= 1
		animation = table.remove @list, index
		animation.index = nil
		animation.isRegistered = false

		if @animationCount == 0
			@stopAnimation!

	startAnimation: =>
		if @animating
			return

		@timer\resume!
		@animating = true

	stopAnimation: =>
		unless @animating
			return

		@timer\kill!
		@animating = false

	destroyAnimationStack: =>
		@stopAnimation!
		currentAnimation = @list
		for i = @animationCount, 1, -1
			@unregisterAnimationByIndex i

	animate: =>
		currentTime = mp.get_time!
		for i = @animationCount, 1, -1
			if @list[i]\update currentTime
				@unregisterAnimationByIndex i

		@aggregator\forceUpdate!
