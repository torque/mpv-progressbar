options = { read_options: -> }
settings =  { _keys: { }, _reload: => }
setmetatable settings, { __newindex: ( key, value ) =>
	table.insert @_keys, key
	rawset @, key, value
}
