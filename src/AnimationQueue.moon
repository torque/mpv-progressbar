class AnimationQueue

	animationList = {}

	@registerAnimation: ( animation ) ->
		table.insert animationList, animation
		animation.index = #animationList
		animation.isRegistered = true

	@unregisterAnimation: ( animation ) ->
		AnimationQueue.unregisterAnimationByIndex animation.index

	@unregisterAnimationByIndex: ( index ) ->
		animation = table.remove animationList, index
		animation.index = nil
		animation.isRegistered = false
		for i = index, #animationList
			animationList[i].index = i

	@destroyAnimationStack: ->
		for i = #animationList, 1, -1
			AnimationQueue.unregisterAnimationByIndex i

	@animate: ->
		if #animationList == 0
			return
		currentTime = mp.get_time!
		for i = #animationList, 1, -1
			if animationList[i]\update currentTime
				AnimationQueue.unregisterAnimationByIndex i
