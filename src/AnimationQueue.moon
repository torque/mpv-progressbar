class AnimationQueue

	animationList = {}

	@registerAnimation: ( animation ) ->
		unless animation.isRegistered
			table.insert animationList, animation
			animation.index = #animationList
			animation.isRegistered = true

	@unregisterAnimation: ( animation ) ->
		if animation.isRegistered
			AnimationQueue.unregisterAnimationByIndex animation.index

	@unregisterAnimationByIndex: ( index ) ->
		animation = table.remove animationList, index
		animation.isRegistered = false
		for i = index, #animationList
			animationList[i].index = i

	@destroyAnimationStack: ->
		for i, animation in ipairs animationList
			animation.isRegistered = false
		animationList = { }

	@animate: ->
		if #animationList == 0
			return
		currentTime = mp.get_time!
		for i = #animationList, 1, -1
			if animationList[i]\update currentTime
				AnimationQueue.unregisterAnimationByIndex i
