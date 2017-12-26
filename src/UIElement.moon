class UIElement extends MouseResponder

	@enableKey: nil

	enabled: true
	layer: 0
	line: {}
	active: false
	needsRedraw: false
	animationDuration: settings['animation-duration']

	new: =>
		-- Because they are stored in the class metatable as a reference type, the
		-- instance line needs to be copied into a unique table in the constructor
		-- to avoid being shared across all instances. This is a really fragile hack
		-- that I hate.
		newLine = { }
		for _, v in ipairs @line
			table.insert newLine, v
		@line = newLine

		@reconfigure!

	draw: =>
		@needsRedraw = false
		if not @active
			return ''
		else
			return table.concat @line

	activate: ( activate ) =>
		if activate == true
			@active = true
			@animation\interrupt false
		else
			@animation\interrupt true

	animate: =>
		if @animation.linearProgress == 0
			@active = false

	reconfigure: =>
		@needsRedraw = true
		@active = false
		@animationDuration = settings['animation-duration']
		@enable settings[@@enableKey]

	enable: ( enable ) =>
		@enabled = enable

	resize: => error 'UIElement resize called'

	update: => return @needsRedraw
