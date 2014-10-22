class ProgressBarBackground

	new: ( @aggregator ) =>

		@line = {
			[[{\an1\bord0\c&H2D2D2D&\p1\pos(]]
			0
			[[)}m 0 0 l ]]
			0
		}

		@aggregator\addSubscriber @

	__tostring: =>
		return table.concat @line

	bar_height = 2
	updateSize: ( w, h ) =>
		@line[2] = [[%d,%d]]\format 0, h
		@line[4] = [[%d 0 %d %d 0 %d]]\format w, w, bar_height, bar_height
		return true

	update: ->
		return false

