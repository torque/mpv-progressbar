class OSDAggregator

	new: =>
		@script = {}
		@scriptLength = 0
		@w = 0
		@h = 0

	setDisplaySize: ( @w, @h ) =>

	addEvent: ( eventString ) =>
		@scriptLength += 1
		@script[@scriptLength] = eventString
		@needsUpdate = true
		return @scriptLength

	updateEvent: ( index, eventString ) =>
		return if index > @scriptLength
		@script[index] = eventString
		@needsUpdate = true

	removeEvent: ( index ) =>
		return if index > @scriptLength
		if index < @scriptLength
			table.remove @script, index
		else
			table[index] = nil
		@scriptLength -= 1
		@needsUpdate = true

	display: =>
		if @needsUpdate
			mp.set_osd_ass @w, @h, table.concat @script, '\n'
			@needsUpdate = false
