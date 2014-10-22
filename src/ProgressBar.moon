class ProgressBar

	new: ( @aggregator ) =>

		@line = {
			[[{\an1\bord0\c&FC799E&\p3\pos(]]
			0
			[[)\fscx]]
			0
			[[}m 0 0 l ]]
			0
		}

		@aggregator\addSubscriber @

	__tostring: =>
		return table.concat @line

	bar_height = 2
	updateSize: ( w, h ) =>
		@line[2] = ([[%d,%d]])\format 0, h
		@line[6] = ([[%d 0 %d %d 0 %d]])\format w*4, w*4, bar_height*4, bar_height*4
		return true

	update: =>
		@line[4] = ([[%g]])\format mp.get_property_number( 'percent-pos' ) or 0
		return true
