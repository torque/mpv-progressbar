#!/usr/bin/env ruby
# This should probably not be a ruby script, but I hate shell.

# The files must be in a specific order.
sources = [
	'src/requires.moon',
	'src/log.moon',
	'src/OSDAggregator.moon',
	'src/Rect.moon',
	'src/ProgressBar.moon',
	'src/main.moon'
]

# Test for moonscript compile errors (this does not guarantee there
# won't be lua compile errors)
sources.each do |sourceFile|
	# This doesn't eat stderr
	`moonc -o tmp.lua #{sourceFile}`
	# Abort on error.
	if $?.exitstatus != 0
		`rm tmp.lua`
		return 1
	end
end

`rm tmp.lua`

# Compile the sources together.
tempScript = 'mpv-progressbar-temp.moon'
`cat #{sources.join ' '} > #{tempScript}`
`moonc -o mpv-progressbar.lua #{tempScript}`
`rm #{tempScript}`
