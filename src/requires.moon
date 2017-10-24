options = require 'mp.options'
utils = require 'mp.utils'

-- script namespace for options
script_name = 'torque-progressbar'

mp.get_osd_size = mp.get_osd_size or mp.get_screen_size

-- This is here instead of in settings.moon because it would conflict with the
-- default settings generator tool if it were placed in settings, and this is
-- the only file that goes before settings.
settings = { __defaults: { } }

-- These methods are jammed in a metatable so that they can't be overridden from
-- the configuration file.
settingsMeta = {
	__reload: =>
		-- Shallow copy should be good. This is necessary to reset values to the
		-- defaults so that removing a configuration key has an effect.
		for key, value in pairs @__defaults
			settings[key] = value

		options.read_options @, script_name .. '/main'

		if @['bar-height-inactive'] <= 0
			@['bar-hide-inactive'] = true
			-- This is set to 1 so that we don't end up with libass spamming messages
			-- about failing to stroke zero-height object.
			@['bar-height-inactive'] = 1

	__migrate: =>
		oldConfig = mp.find_config_file 'lua-settings/%s.conf'\format script_name
		newConfigFile = 'lua-settings/%s/main.conf'\format script_name
		newConfig = mp.find_config_file newConfigFile

		if oldConfig and not newConfig
			folder, _ = utils.split_path oldConfig
			configDir = utils.join_path folder, script_name
			newConfig = utils.join_path configDir, 'main.conf'
			log.info 'Old configuration detected. Attempting to migrate %q -> %q'\format oldConfig, newConfig

			dirExists = mp.find_config_file configDir
			if dirExists and not utils.readdir configDir
				log.warn 'Configuration migration failed. %q exists and does not appear to be a folder'\format configDir
				return

			else if not dirExists
				res = utils.subprocess { args: { 'mkdir', configDir } }
				if res.error or res.status != 0
					log.warn 'Making directory %q failed.'\format configDir
					return

			res = utils.subprocess { args: { 'mv', oldConfig, newConfig } }
			if res.error or res.status != 0
				log.warn 'Moving file %q -> %q failed.'\format oldConfig, newConfig
				return

			if mp.find_config_file newConfigFile
				log.info 'Configuration successfully migrated.'

	__newindex: ( key, value ) =>
		@__defaults[key] = value
		rawset @, key, value
}
settingsMeta.__index = settingsMeta

setmetatable settings, settingsMeta

settings\__migrate!
