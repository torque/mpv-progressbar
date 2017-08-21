options = { read_options: -> }
settings =  { __keys: { }, reload: => }
setmetatable settings, __newindex: ( key, value ) =>
	table.insert @__keys, key
	rawset @, key, value
