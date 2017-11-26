class Compositor

	new: ( @knownElements ) =>
		@reconfigure!

	reconfigure: =>
		-- Elements need to be reconfigured before the compositor so they are
		-- properly (en|dis)abled. General configuration order: elements, element
		-- groups, compositor, and event loop
		@lines = List!
		@elements = List!

		-- need to iterate forward in this case
		for _, element in ipairs @knownElements
			if element.enabled
				@lines\insert element\stringify!
				@elements\insert element

	redraw: =>
		for element, idx in @elements\loop!
			if element\redraw!
				@lines[idx] = element\stringify!

		mp.set_osd_ass Window.w, Window.h, table.concat @lines, '\n'
