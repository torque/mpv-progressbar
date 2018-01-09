class MouseResponder extends Rect

	layer: 0
	_mouse_hovered: false

	new: ( eventList ) =>
		for _, event in ipairs eventList
			Mouse\register event, @

	click: ( x, y ) =>
		return true

	rightClick: ( x, y ) =>
		return true

	scroll: ( x, y ) =>
		return true

	hover: ( mouseover ) =>
		return true
