options = require 'mp.options'
utils = require 'mp.utils'

-- script namespace for options
script_name = 'torque-progressbar'

mp.get_osd_size = mp.get_osd_size or mp.get_screen_size

-- This is here instead of in settings.moon because it would conflict with the
-- default settings generator tool if it were placed in settings, and this is
-- the only file that goes before settings.
settings = { _defaults: { } }

-- These methods are jammed in a metatable so that they can't be overridden from
-- the configuration file.
settingsMeta = {
	_reload: =>
		-- Shallow copy should be good. This is necessary to reset values to the
		-- defaults so that removing a configuration key has an effect.
		for key, value in pairs @_defaults
			settings[key] = value

		options.read_options @, script_name .. '/main'

		if @['bar-height-inactive'] <= 0
			@['bar-hide-inactive'] = true
			-- This is set to 1 so that we don't end up with libass spamming messages
			-- about failing to stroke zero-height object.
			@['bar-height-inactive'] = 1

	_migrate: =>
		pathSep = package.config\sub( 1, 1 )
		onWindows = pathSep == '\\'

		mv = (oldFile, newFile) ->
			cmd = { args: { 'mv', oldConfig, newConfig } }
			if onWindows
				oldfile = oldFile\gsub( '/', pathSep )
				newFile = newFile\gsub( '/', pathSep )
				cmd = { args: { 'cmd', '/Q', '/C', 'move', '/Y', oldfile, newFile } }
			return utils.subprocess cmd

		mkdir = (directory) ->
			cmd = { args: { 'mkdir', '-p', directory } }
			if onWindows
				directory = directory\gsub( '/', pathSep )
				cmd = { args: { 'cmd', '/Q', '/C', 'mkdir', directory } }
			return utils.subprocess cmd

		settingsDirectories = { 'script-opts', 'lua-settings' }
		oldConfigFiles = [ '%s/%s.conf'\format dir, script_name for dir in *settingsDirectories ]
		newConfigFiles = [ '%s/%s/main.conf'\format dir, script_name for dir in *settingsDirectories ]

		oldConfig = nil
		oldConfigIndex = 1
		newConfigFile = nil
		newConfig = nil

		for idx, file in ipairs oldConfigFiles
			log.debug 'checking for old config "%s"'\format file
			oldConfig = mp.find_config_file file
			if oldConfig
				log.debug 'found "%s"'\format oldConfig
				oldConfigIndex = idx
				break

		unless oldConfig
			log.debug 'No old config file found. Migration finished.'
			return

		for file in *newConfigFiles
			log.debug 'checking for new config "%s"'\format file
			newConfig = mp.find_config_file file
			if newConfig
				log.debug 'found "%s"'\format newConfig
				newConfigFile = file
				break

		if oldConfig and not newConfig
			log.debug 'Found "%s". Processing migration.'\format oldConfig

			newConfigFile = newConfigFiles[oldConfigIndex]
			baseConfigFolder, _ = utils.split_path oldConfig
			configDir = utils.join_path baseConfigFolder, script_name
			newConfig = utils.join_path configDir, 'main.conf'
			log.info 'Old configuration detected. Attempting to migrate "%s" -> "%s"'\format oldConfig, newConfig

			dirExists = mp.find_config_file configDir
			if dirExists and not utils.readdir configDir
				log.warn 'Configuration migration failed. "%s" exists and does not appear to be a folder'\format configDir
				return

			else if not dirExists
				log.debug 'Attempting to create directory "%s"'\format configDir
				res = mkdir configDir
				if res.error or res.status != 0
					log.warn 'Making directory "%s" failed.'\format configDir
					return
				log.debug 'successfully created directory.'
			else
				log.debug 'Directory "%s" already exists. Continuing.'\format configDir

			log.debug 'Attempting to move "%s" -> "%s"'\format oldConfig, newConfig
			res = mv oldConfig, newConfig
			if res.error or res.status != 0
				log.warn 'Moving file "%s" -> "%s" failed.'\format oldConfig, newConfig
				return

			if mp.find_config_file newConfigFile
				log.info 'Configuration successfully migrated.'
			else
				log.warn 'Cannot find "%s". Migration mysteriously failed?'\format newConfigFile

	__newindex: ( key, value ) =>
		@_defaults[key] = value
		rawset @, key, value
}
settingsMeta.__index = settingsMeta

setmetatable settings, settingsMeta

settings\_migrate!
