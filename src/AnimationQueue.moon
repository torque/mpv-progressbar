class AnimationQueue

	@animationList: List!

	@addAnimation: ( animation ) =>
		unless animation.active
			animation.active = true
			@animationList\insert animation

	@removeAnimation: ( animation ) =>
		if animation.active
			@animationList\remove animation
			animation.active = false

	@destroyAnimationStack: =>
		animationList\clear!

	@animate: =>
		if #@animationList == 0
			@lastTime = mp.get_time!
			return

		now = mp.get_time!
		delta = now - @lastTime
		@lastTime = now

		for animation, idx in @animationList\loop!
			if animation\update delta
				animation.active = false
				@animationList\pop idx

	@active: =>
		return #@animationList > 0
