convertToComment = ( text ) ->
	result = { }
	text\gsub '(.-)\n', ( line ) ->
		table.insert result, '# ' .. line

	return table.concat result, '\n'

convertToValue = ( value ) ->
	switch type value
		when 'boolean'
			return value and 'yes' or 'no'
		when 'number'
			return tostring value
		else
			return value

combined = {}
for setting in *settings._keys
	value = settings[setting]
	comment = convertToComment helpText[setting]
	settingString = setting .. '=' .. convertToValue( value ) .. '\n'
	table.insert combined, comment
	table.insert combined, settingString
table.insert combined, ''

file = io.open arg[1], 'wb'
file\write table.concat combined, '\n'
file\close!
