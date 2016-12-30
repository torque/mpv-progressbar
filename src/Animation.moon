class Animation

	new: ( @initialValue, @endValue, @duration, @updateCb, @finishedCb, @accel = 1 ) =>
		@value = @initialValue
		@linearProgress = 0
		@lastUpdate = mp.get_time!
		@durationR = 1/@duration
		@isFinished = (@duration <= 0)
		@isRegistered = false
		@isReversed = false

	update: ( @currentTime ) =>
		now = mp.get_time!
		if @isReversed
			@linearProgress = math.max 0, math.min 1, @linearProgress + (@lastUpdate - now)*@durationR
			if @linearProgress == 0
				@isFinished = true
		else
			@linearProgress = math.max 0, math.min 1, @linearProgress + (now - @lastUpdate)*@durationR
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
