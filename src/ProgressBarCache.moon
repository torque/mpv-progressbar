class ProgressBarCache extends BarBase

	new: =>
		super!
		@line[8] = @line[8]\format settings['bar-cache-style']

	redraw: =>
		super!
		-- Raw file size, bytes
		totalSize = mp.get_property_number 'file-size', 0
		if totalSize != 0
			position = mp.get_property_number 'percent-pos', 0.001
			-- Amount of cache used, kilobytes.
			-- This property does not seem to include backward cache, if I am
			-- reading the documentation correctly. Either way, there doesn't
			-- appear to be a way to distinguish cache and cache-backbuffer in
			-- the properties so the point is moot.
			cacheUsed = mp.get_property_number( 'cache-used', 0 )*1024
			networkCacheContribution = cacheUsed/totalSize
			-- Duration of the video in the demuxer cache, seconds. Manpage
			-- claims this value isn't reliable, but it gets used by the
			-- default cache display?
			demuxerCacheDuration = mp.get_property_number 'demuxer-cache-duration', 0
			-- Duration of video file, seconds. I'm not sure this property
			-- will always exist if totalSize does.
			-- Default to a small number to avoid division by zero.
			fileDuration = mp.get_property_number 'duration', 0.001
			demuxerCacheContribution = demuxerCacheDuration/fileDuration

			@line[6] = (networkCacheContribution + demuxerCacheContribution)*100 + position
			@needsUpdate = true

		return @needsUpdate
