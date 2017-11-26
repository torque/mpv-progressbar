class ElementGroup extends MouseResponder

	new: ( elements, mouseEvents, @resize ) =>
		super mouseEvents
		@knownElements = List elements
		@reconfigure!

	resize: =>

	reconfigure: =>
		super!
		@elements = List!

		for _, element in ipairs @knownElements
			if element.enabled
				@elements\insert element
