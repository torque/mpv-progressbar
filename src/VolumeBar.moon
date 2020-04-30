class VolumeBar extends PropertyBarBase

	new: =>
		super "volume", 0, 100, 300

	updateMuteInfo: ( muted ) =>
		if muted
		    @style = settings['bar-cache-style']
		else
		    @style = settings['bar-foreground-style']

		@\updatePropertyInfo()
