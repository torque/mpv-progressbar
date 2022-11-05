class Animation

	new: ( @initialValue, @endValue, @duration, @updateCb, @finishedCb, @accel = 1 ) =>
		@value = @initialValue
		@linearProgress = 0
		@lastUpdate = mp.get_time!
		@durationR = 1/@duration
		@isFinished = (@duration <= 0)
		@active = false
		@isReversed = false

	update: ( now ) =>
		if @isReversed
			@linearProgress = clamp @linearProgress + (@lastUpdate - now) * @durationR, 0, 1
			if @linearProgress == 0
				@isFinished = true
		else
			@linearProgress = clamp @linearProgress + (now - @lastUpdate) * @durationR, 0, 1
			if @linearProgress == 1
				@isFinished = true

		@lastUpdate = now

		progress = math.pow @linearProgress, @accel

		@value = (1 - progress) * @initialValue + progress * @endValue

		@.updateCb @value

		if @isFinished and @finishedCb
			@finishedCb!

		return @isFinished

	interrupt: ( reverse ) =>
		@finishedCb = nil
		@lastUpdate = mp.get_time!
		@isReversed = reverse
		unless @active
			@isFinished = false
			AnimationQueue.addAnimation @
