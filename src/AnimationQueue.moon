class AnimationQueue

	animationList = Stack 'isRegistered'
	deletionQueue = { }

	@registerAnimation: ( animation ) ->
		unless animation.isRegistered
			animationList\insert animation

	@unregisterAnimation: ( animation ) ->
		if animation.isRegistered
			animationList\remove animation

	@destroyAnimationStack: ->
		animationList\clear!

	@animate: ->
		if #animationList == 0
			return
		currentTime = mp.get_time!
		for _, animation in ipairs animationList
			if animation\update currentTime
				table.insert deletionQueue, animation

		animationList\removeSortedList deletionQueue

	@active: ->
		return #animationList > 0
