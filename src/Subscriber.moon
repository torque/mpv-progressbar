class Subscriber extends Rect

	new: =>
		super 0, 0, 0, 0

		@hovered = false
		@needsUpdate = false

	stringify: =>
		if not @hovered and not @animation.isRegistered
			return ""

		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

	update: ( mouseX, mouseY, mouseOver, hoverCondition = @containsPoint( mouseX, mouseY ) ) =>
		update = @needsUpdate
		@needsUpdate = false

		if mouseOver and hoverCondition
			unless @hovered
				update = true
				@hovered = true
				@animation\interrupt false, @animationQueue
		else
			if @hovered
				update = true
				@hovered = false
				@animation\interrupt true, @animationQueue

		return update
