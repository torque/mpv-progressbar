class ElementGroup extends MouseResponder

	new: ( elements, mouseEvents, @resize ) =>
		super mouseEvents
		@knownElements = List elements
		@reconfigure!

	resize: =>

	reconfigure: =>
		@elements = List!

		for _, element in ipairs @knownElements
			if element.enabled
				@elements\insert element

	hover: ( mouseover ) =>
		for element in @elements\loop!
			element\activate mouseover
