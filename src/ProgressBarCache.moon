-- percent-pos
-- file-size -- bytes
-- cache-used -- kilobytes, symmetric cache

-- duration
-- demuxer-cache-time

-- paused-for-cache
-- cache-buffering-state
class ProgressBarCache extends Subscriber

	new: ( @animationQueue ) =>
		super!
		minHeight = settings['bar-height-inactive']*50
		maxHeight = settings['bar-height-active']*50

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]]\format settings['bar-cache-color'] -- 1
			0                                                              -- 2
			[[)\fscx]]                                                     -- 3
			0.001                                                          -- 4
			[[\fscy]]                                                      -- 5
			minHeight                                                      -- 6
			[[\p1}m 0 0 l ]]                                               -- 7
			0                                                              -- 8
		}

		@animation = Animation minHeight, maxHeight, 0.25, @\animateHeight

	stringify: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		super w, h

		@line[2] = ([[%d,%d]])\format 0, h
		@line[8] = ([[%d 0 %d 1 0 1]])\format w, w
		return true

	animateHeight: ( animation, value ) =>
		@line[6] = ([[%g]])\format value
		@needsUpdate = true

	update: ( inputState ) =>
		update = super inputState

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

			update = true
			@line[4] = (networkCacheContribution + demuxerCacheContribution)*100 + position

		return update
