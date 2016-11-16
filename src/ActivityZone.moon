class ActivityZone extends Rect

	addSubscriber: ( subscriber ) =>
		table.insert @subscribers, subscriber

	hitCheck: ( inputState ) =>
		if inputState.displayRequested
			return true

		if inputState.mouseInWindow or not inputState.mouseDead
			return @containsPoint inputState.mouseX, inputState.mouseY
		else
			return false


