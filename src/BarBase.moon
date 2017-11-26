class BarBase extends UIElement
	minHeight = settings['bar-height-inactive']*100
	hideInactive = settings['bar-hide-inactive']

	@animationMinHeight: minHeight
	@maxHeight: settings['bar-height-active']*100
	@enableKey: 'enable-bar'

	@toggleInactiveVisibility: ->
		hideInactive = not hideInactive
		if hideInactive
			BarBase.animationMinHeight = 0
		else
			BarBase.animationMinHeight = minHeight

	lineBaseTemplate = [[\an1%s%s%s\p1}m 0 0 l ]]

	line: {
		[[{\pos(]] -- 1
		0          -- 2
		[[)\fscy]] -- 3
		minHeight  -- 4
		[[\fscx]]  -- 5
		0.001      -- 6
		[[]]       -- 7
		lineBaseTemplate
		0          -- 9
	}

	reconfigure: =>
		super!
		minHeight = settings['bar-height-inactive']*100
		@@maxHeight = settings['bar-height-active']*100
		hideInactive = settings['bar-hide-inactive']
		if hideInactive
			@@animationMinHeight = 0
		else
			@@animationMinHeight = minHeight
		@line[4] = minHeight
		@line[8] = lineBaseTemplate\format settings['default-style'], settings['bar-default-style'], '%s'

		@animation = Animation 0, 1, @animationDuration, @

	stringify: =>
		@needsUpdate = false
		if hideInactive and not @active
			return ""
		else
			return table.concat @line

	resize: =>
		@line[2] = [[%d,%d]]\format 0, Window.h
		@line[9] = [[%d 0 %d 1 0 1]]\format Window.w, Window.w
		@needsUpdate = true

	animate: ( value ) =>
		@line[4] = ([[%g]])\format (@@maxHeight - @@animationMinHeight)*value + @@animationMinHeight, value
		@needsUpdate = true

	redraw: =>
		if @hideInactive != hideInactive
			@hideInactive = hideInactive
			unless @active
				@animate 0

		return @needsUpdate
