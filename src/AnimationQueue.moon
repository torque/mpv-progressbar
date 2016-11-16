-- This is now an ugly singleton thing.
class AnimationQueue

	list = {}
	animationCount = 0

	@registerAnimation: ( animation ) ->
		@animationCount += 1
		animation.index = @animationCount
		animation.isRegistered = true
		table.insert @list, animation

	@unregisterAnimation: ( animation ) ->
		@unregisterAnimationByIndex animation.index

	@unregisterAnimationByIndex: ( index ) ->
		@animationCount -= 1
		animation = table.remove @list, index
		animation.index = nil
		animation.isRegistered = false

	@destroyAnimationStack: ->
		currentAnimation = @list
		for i = @animationCount, 1, -1
			@unregisterAnimationByIndex i

	@animate: ->
		if @animationCount == 0
			return
		currentTime = mp.get_time!
		for i = @animationCount, 1, -1
			if @list[i]\update currentTime
				@unregisterAnimationByIndex i
