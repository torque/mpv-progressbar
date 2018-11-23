class ProgressBarCache extends BarBase

	timestamp = os.time!

	new: =>
		super!

		@coordinateRemap = 0
		mp.observe_property 'duration', 'number', ( name,  value ) ->
			if value and (value > 0)
				@fileDuration = value
				@coordinateRemap = Window.w/value

	reconfigure: =>
		super 'bar-cache-'
		@line[6] = 100
		@line[8] = @line[8]\format settings['bar-cache-style']
		@fileDuration = mp.get_property_number 'duration', nil

	resize: =>
		super!
		if @fileDuration
			@coordinateRemap = Window.w/@fileDuration

	redraw: =>
		super!

		if @fileDuration and (@fileDuration > 0)
			barDrawing = { }
			-- TODO: figure out how to cache this properly. Using
			-- mp.observe_property doesn't actually work (callback never gets
			-- called after the initial call). Also, directly trying to get
			-- demuxer-cache-state/seekable-ranges does not work either,
			-- mysteriously.
			{'seekable-ranges': ranges} = mp.get_property_native 'demuxer-cache-state', {}

			if ranges
				for {start: rangeStart, end: rangeEnd} in *ranges
					rangeStart, rangeEnd = rangeStart*@coordinateRemap, rangeEnd*@coordinateRemap
					rect = 'm %g 0 l %g 1 %g 1 %g 0'\format rangeStart, rangeStart, rangeEnd, rangeEnd
					table.insert barDrawing, rect

				@line[9] = table.concat barDrawing, ' '
				@needsUpdate = true

		return @needsUpdate
