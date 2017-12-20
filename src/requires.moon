-- profiler = require 'jit.p'
-- profiler.start '-jp=fl', 'profiler-test.txt'

options = require 'mp.options'
utils = require 'mp.utils'

-- script namespace for options
script_name = 'torque-progressbar'

mp.get_osd_size = mp.get_osd_size or mp.get_screen_size
