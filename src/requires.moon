msg = require 'mp.msg'
utils = require 'mp.utils'

-- pixels
bar_height = 2
hover_zone = 20
-- seconds
redraw_period = 0.03

scriptDir = utils.join_path os.getenv( 'HOME' ), '.config/mpv/scripts'
prefix = utils.join_path scriptDir, 'progressbar'
