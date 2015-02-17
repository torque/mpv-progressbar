class AnimationQueue

	new: ( @aggregator ) =>
		-- doubly-linked list.
		@list = nil
		@animationCount = 0
		@animating = false
		@timer = mp.add_periodic_timer 0.05, @\animate
		@timer\kill!

	registerAnimation: ( animation ) =>
		if @list
			@list.next = animation

		animation.prev = @list
		animation.isRegistered = true
		@list = animation
		@animationCount += 1

		@startAnimation!

	unregisterAnimation: ( animation ) =>
		prev = animation.prev
		next = animation.next

		if prev
			prev.next = next
		if next
			next.prev = prev

		if @list == animation
			@list = prev

		animation.next = nil
		animation.prev = nil
		animation.isRegistered = false
		@animationCount -= 1

		if 0 == @animationCount
			@stopAnimation!

		return prev

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
		while currentAnimation
			currentAnimation = @list.prev
			@list.prev = nil
			@list.next = nil
			@list = currentAnimation

	animate: =>
		currentAnimation = @list
		currentTime = mp.get_time!
		while currentAnimation
			-- Animation::update returns true if an animation completes
			if currentAnimation\update currentTime
				currentAnimation = @unregisterAnimation currentAnimation
			else
				currentAnimation = currentAnimation.prev

		@aggregator\forceUpdate!


