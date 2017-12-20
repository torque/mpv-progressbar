class Animation

	new: ( @initialValue, endValue, duration, @animatable, @accel = 1 ) =>
		@deltaValue = endValue - @initialValue
		@linearProgress = 0
		@durationR = 1/duration
		@active = false
		@reversed = false

	update: ( timeDelta ) =>
		@linearProgress = math.max 0, math.min 1, @linearProgress + timeDelta*@durationR
		@animatable\animate @initialValue + math.pow( @linearProgress, @accel )*@deltaValue

		return @reversed and @linearProgress == 0 or @linearProgress == 1

	reset: =>
		@linearProgress = @reversed and 1 or 0

		unless @active
			AnimationQueue\addAnimation @

	interrupt: ( reverse ) =>
		if @reversed != reverse
			@durationR = -@durationR
			@reversed = reverse

		unless @active
			AnimationQueue\addAnimation @
