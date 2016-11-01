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
		minHeight = settings['bar-height-inactive']*100
		maxHeight = settings['bar-height-active']*100

		@line = {
			[[{\an1\bord0\c&H%s&\pos(]]\format settings['bar-cache-color'] -- 1
			0                                                              -- 2
			[[)\fscx]]                                                     -- 3
			0                                                              -- 4
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

		totalSize = mp.get_property_number 'file-size', 0 -- bytes
		if totalSize != 0
			pos = mp.get_property_number 'stream-pos', 0
			duration = mp.get_property_number 'duration', 0
			demuxerCacheTime = mp.get_property_number 'demuxer-cache-time', 0
			cacheUsed = mp.get_property_number( 'cache-used', 0 )*1000 -- kilobytes, symmetric cache
			percentCached = (cacheUsed + pos)/totalSize

			update = true
			@line[4] = ([[%g]])\format (demuxerCacheTime/duration + percentCached)*100

		return update
