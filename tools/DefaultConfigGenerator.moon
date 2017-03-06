convertToComment = ( text ) ->
	result = { '' }
	text\gsub '(.-)\n', ( line ) ->
		table.insert result, '# ' .. line

	table.concat result, '\n'

convertToValue = ( value ) ->
	switch type value
		when 'boolean'
			value and 'yes' or 'no'
		when 'number'
			tostring value
		else
			value

combined = {}
for setting in *settings.__keys
	value = settings[setting]
	comment = convertToComment helpText[setting]
	settingString = setting .. '=' .. convertToValue value
	table.insert combined, comment
	table.insert combined, settingString
table.insert combined, ''

file = io.open arg[1], 'wb'
file\write table.concat combined, '\n'
file\close!
