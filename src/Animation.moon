class Animation

	new: ( @initialValue, @endValue, @duration, @updateCb ) =>
		@startTime = mp.get_time!
		@currentTime = @startTime
		@durationR = 1/@duration
		@isFinished = (@duration <= 0)
		@isRegistered = false
		@isReversed = false

	update: ( @currentTime ) =>
		progress = (@currentTime - @startTime)*@durationR
		if progress < 0
			progress = 0

		if progress >= 1
			progress = 1
			@isFinished = true

		value = (1 - progress) * @initialValue + progress * @endValue

		@updateCb value

		return @isFinished

	reverse: =>
		@isReversed = not @isReversed
		@initialValue, @endValue = @endValue, @initialValue
		@startTime = 2*@currentTime - @duration - @startTime

	restart: =>
		@startTime = mp.get_time!
		@currentTime = @startTime
		@isFinished = false
