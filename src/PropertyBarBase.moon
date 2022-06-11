class PropertyBarBase extends UIElement

	displayDuration = settings['property-bar-display-duration']
	barWidth = settings['property-bar-width'] * 100
	height = settings['property-bar-height'] * 100
	markerWidth = settings['property-bar-marker-width'] * 100

	new: ( @propertyName, lowerBoundary, markerBoundary, upperBoundary ) =>
		super!

		@lowerBoundary = lowerBoundary or -100
		@upperBoundary = upperBoundary or 100
		@markerBoundary = markerBoundary or 0
		@style = settings['bar-foreground-style']
		@line = {
			[[{\pos(]],				--  1
			0,						--  2
			[[)\fscy]],				--  3
			height,					--  4

			-- background
			[[\fscx]],				--  5
			1,						--  6
			[[{\alpha&H]],			--  7
			[[FF]],					--  8
			([[\an1%s%s%s\p1}m 0 0 l ]])\format settings['default-style'], settings['bar-default-style'], settings['bar-background-style'],
			0,						-- 10

			-- foreground
			[[\fscx]],				-- 11
			0,						-- 12
			[[{\alpha&H]],			-- 13
			[[FF]],					-- 14
			0,						-- 15
			0,						-- 16

			-- marker
			[[\fscx]],				-- 17
			1,						-- 18
			[[{\alpha&H]],			-- 19
			[[FF]],					-- 20
			0,						-- 21
			0						-- 22
		}

		@animation = Animation 0, 1, @animationDuration, @\animate, nil, 0.5

		mp.observe_property propertyName, 'number', (event, value) ->
			@updatePropertyInfo value

	resize: =>
		@x0 = Window.w - settings['property-bar-right-margin'] - settings['property-bar-width']
		@y0 = settings['property-bar-top-margin']
		@line[2] = ([[%d,%d]])\format @x0, @y0

	animate: ( value ) =>
		alphaStr = ('%02X')\format 255 - value * 255
		@line[8] = alphaStr
		@line[14] = alphaStr
		@line[20] = alphaStr
		@needsUpdate = true

	-- Called by ActivityZoneSingelton
	setActivator: ( activityZone ) =>
		@activityZone = activityZone

	updatePropertyInfo: ( value ) =>
		if value
			if value > @upperBoundary
				@value = @upperBoundary
			elseif value < @lowerBoundary
				@value = @lowerBoundary
			else
				@value = value

		if @value <= @markerBoundary
			@markerStyle = settings['chapter-marker-before-style']
		else
			@markerStyle = settings['chapter-marker-after-style']

		-- Don't execute this branch since the function resize wasn't called yet
		if @x0
			limit = @upperBoundary - @lowerBoundary
			percent = (@value - @lowerBoundary) / limit
			followingEdge = percent * barWidth - barWidth
			markerEdge = ((@markerBoundary - @lowerBoundary) * barWidth / limit) - (2 * barWidth + followingEdge)
			markerEdgeBegin = markerEdge - markerWidth / 2
			markerEdgeEnd = markerEdgeBegin + markerWidth

			-- background
			@line[10] = ([[%d 0 %d 1 0 1]])\format barWidth, barWidth

			-- foreground
			@line[12] = percent
			@line[15] = ([[\an1%s%s%s\p1}m -%d 0 l ]])\format settings['default-style'], settings['bar-default-style'], @style, barWidth
			@line[16] = ([[-%d 1 %d 1 %d 0]])\format barWidth, followingEdge, followingEdge

			-- marker
			@line[21] = ([[\an1%s%s%s\p1}m -%d 0 l ]])\format settings['default-style'], settings['bar-default-style'], @markerStyle, markerEdgeBegin
			@line[22] = ([[-%d 1 %d 1 %d 0]])\format markerEdgeBegin, markerEdgeEnd, markerEdgeEnd

			@needsUpdate = true
			@activityZone\activate @, displayDuration

		return @needsUpdate
