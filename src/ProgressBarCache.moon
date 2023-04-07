class ProgressBarCache extends BarBase

	timestamp = os.time!

	new: =>
		super!

		@cacheKey = nil
		@coordinateRemap = 0
		mp.observe_property 'duration', 'number', ( name,  value ) ->
			if value and (value > 0)
				@fileDuration = value
				@coordinateRemap = Window.w/value

	reconfigure: =>
		super 'bar-cache-'
		@line[6] = 100
		@line[9] = ''
		-- TODO: this is a hack
		@line[10] = '\n'
		for idx = 1, 9
			@line[idx + 10] = @line[idx]

		@line[8] = @line[8]\format( settings['bar-cache-style'] )
		@line[18] = @line[18]\format( settings['bar-cache-background-style'] )
		@fileDuration = mp.get_property_number 'duration', nil

	resize: =>
		super!
		if @fileDuration
			@coordinateRemap = Window.w/@fileDuration

		-- map position onto background bar
		@line[12] = @line[2]
		-- undo BarBase size update
		@clobber!

	animate: ( value ) =>
		super value
		-- map scale onto background bar
		@line[14] = @line[4]

	clobber: =>
		@line[9] = ""
		@line[19] = ""

	redraw: =>
		super!

		if @hideInactive and not @active
			return @needsUpdate

		if @fileDuration and (@fileDuration > 0)
			barDrawing = { past: { },  future: { } }
			-- TODO: figure out how to cache this properly. Using
			-- mp.observe_property doesn't actually work (callback never gets
			-- called after the initial call). Also, directly trying to get
			-- demuxer-cache-state/seekable-ranges does not work either,
			-- mysteriously.

			-- the ranges returned here are not necessarily in chronological order.
			{'seekable-ranges': ranges} = mp.get_property_native 'demuxer-cache-state', {}

			if ranges and (#ranges > 0)

				-- TODO: be more smart about caching chunks of this.
				position = mp.get_property_number 'percent-pos', 0
				cacheKeyAggregator = { Window.w, position }
				for {start: rangeStart, end: rangeEnd} in *ranges
					table.insert cacheKeyAggregator, rangeStart
					table.insert cacheKeyAggregator, rangeEnd

				cacheKey = table.concat cacheKeyAggregator, '_'

				if cacheKey == @cacheKey
					return @needsUpdate

				progressPosition = mp.get_property_number('percent-pos', 0)*Window.w*0.01
				for {start: rangeStart, end: rangeEnd} in *ranges
					rangeStart *= @coordinateRemap
					rangeEnd *= @coordinateRemap

					-- we could branch here and only perform this more complex cache
					-- splitting logic if bar-cache-background-style is not an empty
					-- string, but I'd rather not have an extra code path to worry about
					-- unless this turns out to be really bad for performance.
					if rangeEnd < progressPosition
						rect = 'm %g 0 l %g 1 %g 1 %g 0'\format rangeStart, rangeStart, rangeEnd, rangeEnd
						table.insert barDrawing.past, rect
					elseif rangeStart > progressPosition
						rect = 'm %g 0 l %g 1 %g 1 %g 0'\format rangeStart, rangeStart, rangeEnd, rangeEnd
						table.insert barDrawing.future, rect
					else
						rectPast = 'm %g 0 l %g 1 %g 1 %g 0'\format rangeStart, rangeStart, progressPosition, progressPosition
						rectFuture = 'm %g 0 l %g 1 %g 1 %g 0'\format progressPosition, progressPosition, rangeEnd, rangeEnd
						table.insert barDrawing.past, rectPast
						table.insert barDrawing.future, rectFuture

				@line[9] = table.concat barDrawing.past, ' '
				@line[19] = table.concat barDrawing.future, ' '

				@cacheKey = cacheKey
				@needsUpdate = true
			else
				@clobber!

		return @needsUpdate
