msg = require 'mp.msg'

log = {
	debug: ( format, ... ) ->
		msg.debug format\format ...

	info: ( format, ... ) ->
		msg.info format\format ...

	warn: ( format, ... ) ->
		msg.warn format\format ...

	dump: ( item, ignore ) ->
		if "table" != type item
			msg.info tostring item
			return

		count = 1
		tablecount = 1

		result = { "{ @#{tablecount}" }
		seen   = { [item]: tablecount }
		recurse = ( item, space ) ->
			for key, value in pairs item
				unless key == ignore
					if "table" == type value
						unless seen[value]
							tablecount += 1
							seen[value] = tablecount
							count += 1
							result[count] = space .. "#{key}: { @#{tablecount}"
							recurse value, space .. "  "
							count += 1
							result[count] = space .. "}"
						else
							count += 1
							result[count] = space .. "#{key}: @#{seen[value]}"

					else
						if "string" == type value
							value = ("%q")\format value

						count += 1
						result[count] = space .. "#{key}: #{value}"

		recurse item, "  "

		count += 1
		result[count] = "}"
		msg.info table.concat result, "\n"
}
