#!/usr/bin/env ruby
# This should probably not be a ruby script, but I hate shell.

# The files must be in a specific order.
sources = [
	'src/requires.moon',
	'src/log.moon',
	'src/OSDAggregator.moon',
	'src/AnimationQueue.moon',
	'src/Animation.moon',
	'src/Rect.moon',
	'src/ProgressBar.moon',
	'src/ProgressBarBackground.moon',
	'src/TimeElapsed.moon',
	'src/TimeRemaining.moon',
	'src/HoverTime.moon',
	'src/main.moon'
]

# Test for moonscript compile errors (this does not guarantee there
# won't be lua compile errors)
buildCount = 0
`mkdir -p .build`
sources.each do |sourceFile|
	output = ".build/#{sourceFile}.lua"
	if File.exists?( output ) && File.stat( output ) > File.stat( sourceFile )
		next
	end
	# This doesn't eat stderr
	`moonc -o #{output} #{sourceFile}`
	# Abort on error.
	if $?.exitstatus != 0
		`rm tmp.lua`
		return 1
	end
	buildCount += 1
end

if buildCount > 0
	# Compile the sources together.
	tempScript = 'mpv-progressbar-temp.moon'
	`cat #{sources.join ' '} > #{tempScript}`
	`moonc -o mpv-progressbar.lua #{tempScript}`
	`rm #{tempScript}`
else
	puts "Nothing to do."
end
