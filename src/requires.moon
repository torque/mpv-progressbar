msg = require 'mp.msg'
options = require 'mp.options'

-- script namespace for options
script_name = 'torque-progressbar'

mp.get_osd_size = mp.get_osd_size or mp.get_screen_size

-- This is here so I can do bad things in the config generator tool.
settings = { }
