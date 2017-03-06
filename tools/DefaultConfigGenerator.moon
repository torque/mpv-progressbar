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
for setting, value in pairs settings
	comment = convertToComment helpText[setting]
	settingString = setting .. '=' .. convertToValue value
	table.insert combined, comment
	table.insert combined, settingString

file = io.open arg[1], 'wb'
file\write table.concat combined, '\n'
file\close!
