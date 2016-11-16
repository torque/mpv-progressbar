class Animation

	new: ( @initialValue, @endValue, @duration, @updateCb, @finishedCb, @accel = 1 ) =>
		@value = @initialValue
		@startTime = mp.get_time!
		@currentTime = @startTime
		@durationR = 1/@duration
		@isFinished = (@duration <= 0)
		@isRegistered = false
		@isReversed = false

	update: ( @currentTime ) =>
		progress = math.max 0, math.min 1, (@currentTime - @startTime)*@durationR
		if progress == 1
			@isFinished = true

		if @accel
			progress = math.pow progress, @accel

		if @isReversed
			@value = (1 - progress) * @endValue + progress * @initialValue
		else
			@value = (1 - progress) * @initialValue + progress * @endValue

		@updateCb @value

		if @isFinished and @finishedCb
			@finishedCb!

		return @isFinished

	interrupt: ( reverse ) =>
		@finishedCb = nil
		if reverse != @isReversed
			@reverse!
		unless @isRegistered
			@restart!
			AnimationQueue.registerAnimation @

	reverse: =>
		@isReversed = not @isReversed
		@startTime = 2*@currentTime - @duration - @startTime
		@accel = 1/@accel

	restart: =>
		@startTime = mp.get_time!
		@currentTime = @startTime
		@isFinished = false
