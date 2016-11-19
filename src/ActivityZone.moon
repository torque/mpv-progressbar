class ActivityZone extends Rect

	addSubscriber: ( subscriber ) =>
		table.insert @subscribers, subscriber

	activityCheck: ( inputState ) =>
		if inputState.displayRequested
			return true

		if inputState.mouseInWindow or not inputState.mouseDead
			return @containsPoint inputState.mouseX, inputState.mouseY
		else
			return false

	update: ( inputState, needsResize ) =>
		nowActive = @activityCheck inputState

		if @active != nowActive
			@active = nowActive
			for id, element in ipairs @elements
				if needsResize == true
					@element.resize!
				@element.activate nowActive
				@element.update!
		else
			for id, element in ipairs @elements
				if needsResize == true
					@element.resize!
				@element.update!

