local msg = require('mp.msg')
local log = {
  debug = function(format, ...)
    return msg.debug(format:format(...))
  end,
  info = function(format, ...)
    return msg.info(format:format(...))
  end,
  warn = function(format, ...)
    return msg.warn(format:format(...))
  end,
  dump = function(item, ignore)
    if "table" ~= type(item) then
      msg.info(tostring(item))
      return 
    end
    local count = 1
    local tablecount = 1
    local result = {
      "{ @" .. tostring(tablecount)
    }
    local seen = {
      [item] = tablecount
    }
    local recurse
    recurse = function(item, space)
      for key, value in pairs(item) do
        if not (key == ignore) then
          if "table" == type(value) then
            if not (seen[value]) then
              tablecount = tablecount + 1
              seen[value] = tablecount
              count = count + 1
              result[count] = space .. tostring(key) .. ": { @" .. tostring(tablecount)
              recurse(value, space .. "  ")
              count = count + 1
              result[count] = space .. "}"
            else
              count = count + 1
              result[count] = space .. tostring(key) .. ": @" .. tostring(seen[value])
            end
          else
            if "string" == type(value) then
              value = ("%q"):format(value)
            end
            count = count + 1
            result[count] = space .. tostring(key) .. ": " .. tostring(value)
          end
        end
      end
    end
    recurse(item, "  ")
    count = count + 1
    result[count] = "}"
    return msg.info(table.concat(result, "\n"))
  end
}
local _mathmin = math.min
local _mathmax = math.max
local clamp
clamp = function(value, min, max)
  return _mathmin(max, _mathmax(value, min))
end
local options = require('mp.options')
local utils = require('mp.utils')
local script_name = 'torque-progressbar'
mp.get_osd_size = mp.get_osd_size or mp.get_screen_size
local settings = {
  _defaults = { }
}
local settingsMeta = {
  _reload = function(self)
    for key, value in pairs(self._defaults) do
      settings[key] = value
    end
    options.read_options(self, script_name .. '/main')
    if self['bar-height-inactive'] <= 0 then
      self['bar-hide-inactive'] = true
      self['bar-height-inactive'] = 1
    end
  end,
  _migrate = function(self)
    local pathSep = package.config:sub(1, 1)
    local onWindows = pathSep == '\\'
    local mv
    mv = function(oldFile, newFile)
      local cmd = {
        args = {
          'mv',
          oldConfig,
          newConfig
        }
      }
      if onWindows then
        local oldfile = oldFile:gsub('/', pathSep)
        newFile = newFile:gsub('/', pathSep)
        cmd = {
          args = {
            'cmd',
            '/Q',
            '/C',
            'move',
            '/Y',
            oldfile,
            newFile
          }
        }
      end
      return utils.subprocess(cmd)
    end
    local mkdir
    mkdir = function(directory)
      local cmd = {
        args = {
          'mkdir',
          '-p',
          directory
        }
      }
      if onWindows then
        directory = directory:gsub('/', pathSep)
        cmd = {
          args = {
            'cmd',
            '/Q',
            '/C',
            'mkdir',
            directory
          }
        }
      end
      return utils.subprocess(cmd)
    end
    local settingsDirectories = {
      'script-opts',
      'lua-settings'
    }
    local oldConfigFiles
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #settingsDirectories do
        local dir = settingsDirectories[_index_0]
        _accum_0[_len_0] = ('%s/%s.conf'):format(dir, script_name)
        _len_0 = _len_0 + 1
      end
      oldConfigFiles = _accum_0
    end
    local newConfigFiles
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #settingsDirectories do
        local dir = settingsDirectories[_index_0]
        _accum_0[_len_0] = ('%s/%s/main.conf'):format(dir, script_name)
        _len_0 = _len_0 + 1
      end
      newConfigFiles = _accum_0
    end
    local oldConfig = nil
    local oldConfigIndex = 1
    local newConfigFile = nil
    local newConfig = nil
    for idx, file in ipairs(oldConfigFiles) do
      log.debug(('checking for old config "%s"'):format(file))
      oldConfig = mp.find_config_file(file)
      if oldConfig then
        log.debug(('found "%s"'):format(oldConfig))
        oldConfigIndex = idx
        break
      end
    end
    if not (oldConfig) then
      log.debug('No old config file found. Migration finished.')
      return 
    end
    for _index_0 = 1, #newConfigFiles do
      local file = newConfigFiles[_index_0]
      log.debug(('checking for new config "%s"'):format(file))
      newConfig = mp.find_config_file(file)
      if newConfig then
        log.debug(('found "%s"'):format(newConfig))
        newConfigFile = file
        break
      end
    end
    if oldConfig and not newConfig then
      log.debug(('Found "%s". Processing migration.'):format(oldConfig))
      newConfigFile = newConfigFiles[oldConfigIndex]
      local baseConfigFolder, _ = utils.split_path(oldConfig)
      local configDir = utils.join_path(baseConfigFolder, script_name)
      newConfig = utils.join_path(configDir, 'main.conf')
      log.info(('Old configuration detected. Attempting to migrate "%s" -> "%s"'):format(oldConfig, newConfig))
      local dirExists = mp.find_config_file(configDir)
      if dirExists and not utils.readdir(configDir) then
        log.warn(('Configuration migration failed. "%s" exists and does not appear to be a folder'):format(configDir))
        return 
      else
        if not dirExists then
          log.debug(('Attempting to create directory "%s"'):format(configDir))
          local res = mkdir(configDir)
          if res.error or res.status ~= 0 then
            log.warn(('Making directory "%s" failed.'):format(configDir))
            return 
          end
          log.debug('successfully created directory.')
        else
          log.debug(('Directory "%s" already exists. Continuing.'):format(configDir))
        end
      end
      log.debug(('Attempting to move "%s" -> "%s"'):format(oldConfig, newConfig))
      local res = mv(oldConfig, newConfig)
      if res.error or res.status ~= 0 then
        log.warn(('Moving file "%s" -> "%s" failed.'):format(oldConfig, newConfig))
        return 
      end
      if mp.find_config_file(newConfigFile) then
        return log.info('Configuration successfully migrated.')
      else
        return log.warn(('Cannot find "%s". Migration mysteriously failed?'):format(newConfigFile))
      end
    end
  end,
  __newindex = function(self, key, value)
    self._defaults[key] = value
    return rawset(self, key, value)
  end
}
settingsMeta.__index = settingsMeta
setmetatable(settings, settingsMeta)
settings:_migrate()
local helpText = { }
settings['hover-zone-height'] = 40
helpText['hover-zone-height'] = [[Sets the height of the rectangular area at the bottom of the screen that expands
the progress bar and shows playback time information when the mouse is hovered
over it.
]]
settings['top-hover-zone-height'] = 40
helpText['top-hover-zone-height'] = [[Sets the height of the rectangular area at the top of the screen that shows the
file name and system time when the mouse is hovered over it.
]]
settings['default-style'] = [[\fnSource Sans Pro\b1\bord2\shad0\fs30\c&HFC799E&\3c&H2D2D2D&]]
helpText['default-style'] = [[Default style that is applied to all UI elements. A string of ASS override tags.
Individual elements have their own style settings which override the tags here.
Changing the font will likely require changing the hover-time margin settings
and the offscreen-pos settings.

Here are some useful ASS override tags (omit square brackets):
\fn[Font Name]: sets the font to the named font.
\fs[number]: sets the font size to the given number.
\b[1/0]: sets the text bold or not (\b1 is bold, \b0 is regular weight).
\i[1/0]: sets the text italic or not (same semantics as bold).
\bord[number]: sets the outline width to the given number (in pixels).
\shad[number]: sets the shadow size to the given number (pixels).
\c&H[BBGGRR]&: sets the fill color for the text to the given color (hex pairs in
	             the order, blue, green, red).
\3c&H[BBGGRR]&: sets the outline color of the text to the given color.
\4c&H[BBGGRR]&: sets the shadow color of the text to the given color.
\alpha&H[AA]&: sets the line's transparency as a hex pair. 00 is fully opaque
               and FF is fully transparent. Some UI elements are composed of
               multiple layered lines, so adding transparency may not look good.
               For further granularity, \1a&H[AA]& controls the fill opacity,
               \3a&H[AA]& controls the outline opacity, and \4a&H[AA]& controls
               the shadow opacity.
]]
settings['enable-bar'] = true
helpText['enable-bar'] = [[Controls whether or not the progress bar is drawn at all. If this is disabled,
it also (naturally) disables the click-to-seek functionality.
]]
settings['bar-hide-inactive'] = false
helpText['bar-hide-inactive'] = [[Causes the bar to not be drawn unless the mouse is hovering over it or a
request-display call is active. This is somewhat redundant with setting bar-
height-inactive=0, except that it can allow for very rudimentary context-
sensitive behavior because it can be toggled at runtime. For example, by using
the binding `f cycle pause; script-binding progressbar/toggle-inactive-bar`, it
is possible to have the bar be persistently present only in windowed or
fullscreen contexts, depending on the default setting.
]]
settings['bar-height-inactive'] = 3
helpText['bar-height-inactive'] = [[Sets the height of the bar display when the mouse is not in the active zone and
there is no request-display active. A value of 0 or less will cause bar-hide-
inactive to be set to true and the bar height to be set to 1. This should result
in the desired behavior while avoiding annoying debug logging in mpv (libass
does not like zero-height objects).
]]
settings['bar-height-active'] = 8
helpText['bar-height-active'] = [[Sets the height of the bar display when the mouse is in the active zone or
request-display is active. There is no logic attached to this, so 0 or negative
values may have unexpected results.
]]
settings['progress-bar-width'] = 0
helpText['progress-bar-width'] = [[If greater than zero, changes the progress bar style to be a small segment
rather than a continuous bar and sets its width.
]]
settings['seek-precision'] = 'exact'
helpText['seek-precision'] = [[Affects precision of seeks due to clicks on the progress bar. Should be 'exact' or
'keyframes'. Exact is slightly slower, but won't jump around between two
different times when clicking in the same place.

Actually, this gets passed directly into the `seek` command, so the value can be
any of the arguments supported by mpv, though the ones above are the only ones
that really make sense.
]]
settings['bar-background-adaptive'] = true
helpText['bar-background-adaptive'] = [[Causes the progress bar background layer to automatically size itself to the
tallest of the cache or progress bars. Useful for improving contrast but can
make the bar take up more screen space. Has no effect if the cache bar height is
less than the bar height.
]]
settings['bar-cache-position'] = 'overlay'
helpText['bar-cache-position'] = [[Placement of the cache bar. Valid values are 'overlay' and 'underlay'.

'overlay' causes the cache bar to be drawn on top of the foreground layer of the
bar, allowing the display of seek ranges that have already been encountered.

'underlay' draws the cache bar between the foreground and background layers. Any
demuxer cache ranges that are prior to the current playback point will not be
shown. This matches the previous behavior.
]]
settings['bar-cache-height-inactive'] = 1.5
helpText['bar-cache-height-inactive'] = [[Sets the height of the cache bar display when the mouse is not in the active
zone and there is no request-display active. Useful in combination with bar-
cache-position to control whether or not the cache bar is occluded by (or
occludes) the progress bar.
]]
settings['bar-cache-height-active'] = 4
helpText['bar-cache-height-active'] = [[Sets the height of the cache bar display when the mouse is in the active zone or
request-display is active. Useful in combination with bar-cache- position to
control whether or not the cache bar is occluded by (or occludes) the progress
bar.
]]
settings['bar-default-style'] = [[\bord0\shad0]]
helpText['bar-default-style'] = [[A string of ASS override tags that get applied to all three layers of the bar:
progress, cache, and background. You probably don't want to remove \bord0 unless
your default-style includes it.
]]
settings['bar-foreground-style'] = ''
helpText['bar-foreground-style'] = [[A string of ASS override tags that get applied only to the progress layer of the
bar.
]]
settings['bar-cache-style'] = [[\c&H515151&]]
helpText['bar-cache-style'] = [[A string of ASS override tags that get applied only to the cache layer of the
bar, particularly the part of the cache bar that is behind the current playback
position. The default sets only the color.
]]
settings['bar-cache-background-style'] = [[]]
helpText['bar-cache-background-style'] = [[A string of ASS override tags that get applied only to the cache layer of the
bar, particularly the part of the cache bar that is after the current playback
position. The tags specified here are applied after bar-cache-style and override
them. Leaving this blank will leave the style the same as specified by bar-
cache-style. The split does not account for a nonzero progress-bar-width and may
look odd when used in tandem with that setting.
]]
settings['bar-background-style'] = [[\c&H2D2D2D&]]
helpText['bar-background-style'] = [[A string of ASS override tags that get applied only to the background layer of
the bar. The default sets only the color.
]]
settings['enable-elapsed-time'] = true
helpText['enable-elapsed-time'] = [[Sets whether or not the elapsed time is displayed at all.
]]
settings['elapsed-style'] = ''
helpText['elapsed-style'] = [[A string of ASS override tags that get applied only to the elapsed time display.
]]
settings['elapsed-left-margin'] = 4
helpText['elapsed-left-margin'] = [[Controls how far from the left edge of the window the elapsed time display is
positioned.
]]
settings['elapsed-bottom-margin'] = 0
helpText['elapsed-bottom-margin'] = [[Controls how far above the expanded progress bar the elapsed time display is
positioned.
]]
settings['enable-remaining-time'] = true
helpText['enable-remaining-time'] = [[Sets whether or not the remaining time is displayed at all.
]]
settings['remaining-style'] = ''
helpText['remaining-style'] = [[A string of ASS override tags that get applied only to the remaining time
display.
]]
settings['remaining-right-margin'] = 4
helpText['remaining-right-margin'] = [[Controls how far from the right edge of the window the remaining time display is
positioned.
]]
settings['remaining-bottom-margin'] = 0
helpText['remaining-bottom-margin'] = [[Controls how far above the expanded progress bar the remaining time display is
positioned.
]]
settings['enable-hover-time'] = true
helpText['enable-hover-time'] = [[Sets whether or not the calculated time corresponding to the mouse position
is displayed when the mouse hovers over the progress bar.
]]
settings['hover-time-style'] = [[\fs26]]
helpText['hover-time-style'] = [[A string of ASS override tags that get applied only to the hover time display.
Unfortunately, due to the way the hover time display is animated, alpha values
set here will be overridden. This is subject to change in future versions.
]]
settings['hover-time-left-margin'] = 120
helpText['hover-time-left-margin'] = [[Controls how close to the left edge of the window the hover time display can
get. If this value is too small, it will end up overlapping the elapsed time
display.
]]
settings['hover-time-right-margin'] = 130
helpText['hover-time-right-margin'] = [[Controls how close to the right edge of the window the hover time display can
get. If this value is too small, it will end up overlapping the remaining time
display.
]]
settings['hover-time-bottom-margin'] = 0
helpText['hover-time-bottom-margin'] = [[Controls how far above the expanded progress bar the remaining time display is
positioned.
]]
settings['enable-thumbnail'] = true
helpText['enable-thumbnail'] = [[Sets whether or not thumbnails are displayed at all. Note: thumbnail display
requires use of the thumbfast script (See: https://github.com/po5/thumbfast).
]]
settings['thumbnail-left-margin'] = 10
helpText['thumbnail-left-margin'] = [[Controls how close to the left edge of the window the thumbnail display can
get.
]]
settings['thumbnail-right-margin'] = 10
helpText['thumbnail-right-margin'] = [[Controls how close to the right edge of the window the thumbnail display can
get.
]]
settings['thumbnail-bottom-margin'] = 40
helpText['thumbnail-bottom-margin'] = [[Controls how far above the expanded progress bar the thumbnail display is
positioned.
]]
settings['enable-title'] = true
helpText['enable-title'] = [[Sets whether or not the video title is displayed at all.
]]
settings['title-style'] = ''
helpText['title-style'] = [[A string of ASS override tags that get applied only to the video title display.
]]
settings['title-left-margin'] = 4
helpText['title-left-margin'] = [[Controls how far from the left edge of the window the video title display is
positioned.
]]
settings['title-top-margin'] = 0
helpText['title-top-margin'] = [[Controls how far from the top edge of the window the video title display is
positioned.
]]
settings['title-print-to-cli'] = true
helpText['title-print-to-cli'] = [[Controls whether or not the script logs the video title and playlist position
to the console every time a new video starts.
]]
settings['enable-system-time'] = true
helpText['enable-system-time'] = [[Sets whether or not the system time is displayed at all.
]]
settings['system-time-style'] = ''
helpText['system-time-style'] = [[A string of ASS override tags that get applied only to the system time display.
]]
settings['system-time-format'] = '%H:%M'
helpText['system-time-format'] = [[Sets the format used for the system time display. This must be a strftime-
compatible format string.
]]
settings['system-time-right-margin'] = 4
helpText['system-time-right-margin'] = [[Controls how far from the right edge of the window the system time display is
positioned.
]]
settings['system-time-top-margin'] = 0
helpText['system-time-top-margin'] = [[Controls how far from the top edge of the window the system time display is
positioned.
]]
settings['pause-indicator'] = true
helpText['pause-indicator'] = [[Sets whether or not the pause indicator is displayed. The pause indicator is a
momentary icon that flashes in the middle of the screen, similar to youtube.
]]
settings['pause-indicator-foreground-style'] = [[\c&HFC799E&]]
helpText['pause-indicator-foreground-style'] = [[A string of ASS override tags that get applied only to the foreground of the
pause indicator.
]]
settings['pause-indicator-background-style'] = [[\c&H2D2D2D&]]
helpText['pause-indicator-background-style'] = [[A string of ASS override tags that get applied only to the background of the
pause indicator.
]]
settings['enable-chapter-markers'] = true
helpText['enable-chapter-markers'] = [[Sets whether or not the progress bar is decorated with chapter markers. Due to
the way the chapter markers are currently implemented, videos with a large
number of chapters may slow down the script somewhat, but I have yet to run
into this being a problem.
]]
settings['chapter-marker-width'] = 2
helpText['chapter-marker-width'] = [[Controls the width of each chapter marker when the progress bar is inactive.
]]
settings['chapter-marker-width-active'] = 4
helpText['chapter-marker-width-active'] = [[Controls the width of each chapter marker when the progress bar is active.
]]
settings['chapter-marker-active-height-fraction'] = 1
helpText['chapter-marker-active-height-fraction'] = [[Modifies the height of the chapter markers when the progress bar is active. Acts
as a multiplier on the height of the active progress bar. A value greater than 1
will cause the markers to be taller than the expanded progress bar, whereas a
value less than 1 will cause them to be shorter.
]]
settings['chapter-marker-before-style'] = [[\c&HFC799E&]]
helpText['chapter-marker-before-style'] = [[A string of ASS override tags that get applied only to chapter markers that have
not yet been passed.
]]
settings['chapter-marker-after-style'] = [[\c&H2D2D2D&]]
helpText['chapter-marker-after-style'] = [[A string of ASS override tags that get applied only to chapter markers that have
already been passed.
]]
settings['request-display-duration'] = 1
helpText['request-display-duration'] = [[Sets the amount of time in seconds that the UI stays on the screen after it
receives a request-display signal. A value of 0 will keep the display on screen
only as long as the key bound to it is held down.
]]
settings['redraw-period'] = 0.03
helpText['redraw-period'] = [[Controls how often the display is redrawn, in seconds. This does not seem to
significantly affect the smoothness of animations, and it is subject to the
accuracy limits imposed by the scheduler mpv uses. Probably not worth changing
unless you have major performance problems.
]]
settings['animation-duration'] = 0.25
helpText['animation-duration'] = [[Controls how long the UI animations take. A value of 0 disables all animations
(which breaks the pause indicator).
]]
settings['elapsed-offscreen-pos'] = -100
helpText['elapsed-offscreen-pos'] = [[Controls how far off the left side of the window the elapsed time display tries
to move when it is inactive. If you use a non-default font, this value may need
to be tweaked. If this value is not far enough off-screen, the elapsed display
will disappear without animating all the way off-screen. Positive values will
cause the display to animate the wrong direction.
]]
settings['remaining-offscreen-pos'] = -100
helpText['remaining-offscreen-pos'] = [[Controls how far off the left side of the window the remaining time display
tries to move when it is inactive. If you use a non-default font, this value may
need to be tweaked. If this value is not far enough off-screen, the elapsed
display will disappear without animating all the way off-screen. Positive values
will cause the display to animate the wrong direction.
]]
settings['hover-time-offscreen-pos'] = -50
helpText['hover-time-offscreen-pos'] = [[Controls how far off the bottom of the window the mouse hover time display tries
to move when it is inactive. If you use a non-default font, this value may need
to be tweaked. If this value is not far enough off-screen, the elapsed
display will disappear without animating all the way off-screen. Positive values
will cause the display to animate the wrong direction.
]]
settings['system-time-offscreen-pos'] = -100
helpText['system-time-offscreen-pos'] = [[Controls how far off the left side of the window the system time display tries
to move when it is inactive. If you use a non-default font, this value may need
to be tweaked. If this value is not far enough off-screen, the elapsed display
will disappear without animating all the way off-screen. Positive values will
cause the display to animate the wrong direction.
]]
settings['title-offscreen-pos'] = -40
helpText['title-offscreen-pos'] = [[Controls how far off the left side of the window the video title display tries
to move when it is inactive. If you use a non-default font, this value may need
to be tweaked. If this value is not far enough off-screen, the elapsed display
will disappear without animating all the way off-screen. Positive values will
cause the display to animate the wrong direction.
]]
settings:_reload()
local Stack
do
  local _class_0
  local removeElementMetadata, reindex
  local _base_0 = {
    insert = function(self, element, index)
      if index then
        table.insert(self, index, element)
        element[self] = index
      else
        table.insert(self, element)
        element[self] = #self
      end
      if self.containmentKey then
        element[self.containmentKey] = true
      end
    end,
    remove = function(self, element)
      if element[self] == nil then
        error("Trying to remove an element that doesn't exist in this stack.")
      end
      table.remove(self, element[self])
      reindex(self, element[self])
      return removeElementMetadata(self, element)
    end,
    clear = function(self)
      local element = table.remove(self)
      while element do
        removeElementMetadata(self, element)
        element = table.remove(self)
      end
    end,
    removeSortedList = function(self, elementList)
      if #elementList < 1 then
        return 
      end
      for i = 1, #elementList - 1 do
        local element = table.remove(elementList)
        table.remove(self, element[self])
        removeElementMetadata(self, element)
      end
      local lastElement = table.remove(elementList)
      table.remove(self, lastElement[self])
      reindex(self, lastElement[self])
      return removeElementMetadata(self, lastElement)
    end,
    removeList = function(self, elementList)
      table.sort(elementList, function(a, b)
        return a[self] < b[self]
      end)
      return self:removeSortedList(elementList)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, containmentKey)
      self.containmentKey = containmentKey
    end,
    __base = _base_0,
    __name = "Stack"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  removeElementMetadata = function(self, element)
    element[self] = nil
    if self.containmentKey then
      element[self.containmentKey] = false
    end
  end
  reindex = function(self, start)
    if start == nil then
      start = 1
    end
    for i = start, #self do
      (self[i])[self] = i
    end
  end
  Stack = _class_0
end
local Window
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Window"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.osdScale = mp.get_property_number("display-hidpi-scale", 1)
  self.__class.w, self.__class.h = 0, 0
  self.__class._rawW, self.__class._rawH = 0, 0
  self.update = function(self)
    local w, h = mp.get_osd_size()
    local osdScale = mp.get_property_number("display-hidpi-scale", 1)
    self._rawW, self._rawH = w, h
    w, h = math.floor(w / osdScale), math.floor(h / osdScale)
    if w ~= self.w or h ~= self.h or osdScale ~= self.osdScale then
      self.w, self.h, self.osdScale = w, h, osdScale
      return true
    else
      return false
    end
  end
  Window = _class_0
end
local Mouse
do
  local _class_0
  local scaledPosition
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Mouse"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.x, self.__class.y = -1, -1
  self.__class._rawX, self.__class._rawY = -1, -1
  self.__class.inWindow, self.__class.dead = false, true
  self.__class.clickX, self.__class.clickY = -1, -1
  self.__class.clickPending = false
  scaledPosition = function(self)
    local x, y = mp.get_mouse_pos()
    self._rawX, self._rawY = x, y
    return math.floor(x / Window.osdScale), math.floor(y / Window.osdScale)
  end
  self.update = function(self)
    local oldX, oldY = self.x, self.y
    self.x, self.y = scaledPosition(self)
    if self.dead and (oldX ~= self.x or oldY ~= self.y) then
      self.dead = false
    end
    if not self.dead and self.clickPending then
      self.clickPending = false
      return true
    end
    return false
  end
  self.cacheClick = function(self)
    if not self.dead then
      self.clickX, self.clickY = scaledPosition(self)
      self.clickPending = true
    else
      self.dead = false
    end
  end
  Mouse = _class_0
end
mp.add_key_binding("mouse_btn0", "left-click", function()
  return Mouse:cacheClick()
end)
mp.observe_property('fullscreen', 'bool', function()
  Mouse:update()
  Mouse.dead = true
end)
mp.add_forced_key_binding("mouse_leave", "mouse-leave", function()
  Mouse.inWindow = false
end)
mp.add_forced_key_binding("mouse_enter", "mouse-enter", function()
  Mouse.inWindow = true
end)
local Rect
do
  local _class_0
  local _base_0 = {
    cacheMaxBounds = function(self)
      self.xMax = self.x + self.w
      self.yMax = self.y + self.h
    end,
    setPosition = function(self, x, y)
      self.x = x or self.x
      self.y = y or self.y
      return self:cacheMaxBounds()
    end,
    setSize = function(self, w, h)
      self.w = w or self.w
      self.h = h or self.h
      return self:cacheMaxBounds()
    end,
    reset = function(self, x, y, w, h)
      self.x = x or self.x
      self.y = y or self.y
      self.w = w or self.w
      self.h = h or self.h
      return self:cacheMaxBounds()
    end,
    move = function(self, x, y)
      self.x = self.x + (x or self.x)
      self.y = self.y + (y or self.y)
      return self:cacheMaxBounds()
    end,
    stretch = function(self, w, h)
      self.w = self.w + (w or self.w)
      self.h = self.h + (h or self.h)
      return self:cacheMaxBounds()
    end,
    containsPoint = function(self, x, y)
      return (x >= self.x) and (x < self.xMax) and (y >= self.y) and (y < self.yMax)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, w, h)
      if x == nil then
        x = -1
      end
      if y == nil then
        y = -1
      end
      if w == nil then
        w = -1
      end
      if h == nil then
        h = -1
      end
      self.x, self.y, self.w, self.h = x, y, w, h
      return self:cacheMaxBounds()
    end,
    __base = _base_0,
    __name = "Rect"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Rect = _class_0
end
local ActivityZone
do
  local _class_0
  local _parent_0 = Rect
  local _base_0 = {
    reconfigure = function(self)
      self.active = false
    end,
    addUIElement = function(self, element)
      self.elements:insert(element)
      return element:activate(self.active)
    end,
    removeUIElement = function(self, element)
      return self.elements:remove(element)
    end,
    clickHandler = function(self)
      if not (self:containsPoint(Mouse.clickX, Mouse.clickY)) then
        return 
      end
      for _, element in ipairs(self.elements) do
        if element.clickHandler and not element:clickHandler() then
          break
        end
      end
    end,
    activityCheck = function(self, displayRequested)
      if displayRequested == true then
        return true
      end
      if not (Mouse.inWindow) then
        return false
      end
      if Mouse.dead then
        return false
      end
      return self:containsPoint(Mouse.x, Mouse.y)
    end,
    update = function(self, displayRequested, clickPending)
      local nowActive = self:activityCheck(displayRequested)
      if self.active ~= nowActive then
        self.active = nowActive
        for id, element in ipairs(self.elements) do
          element:activate(nowActive)
        end
      end
      if clickPending then
        self:clickHandler()
      end
      return nowActive
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, resize, activityCheck)
      self.resize, self.activityCheck = resize, activityCheck
      _class_0.__parent.__init(self)
      self.active = false
      self.elements = Stack()
    end,
    __base = _base_0,
    __name = "ActivityZone",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ActivityZone = _class_0
end
local AnimationQueue
do
  local _class_0
  local animationList, deletionQueue
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "AnimationQueue"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  animationList = Stack('active')
  deletionQueue = { }
  self.addAnimation = function(animation)
    if not (animation.active) then
      return animationList:insert(animation)
    end
  end
  self.removeAnimation = function(animation)
    if animation.active then
      return animationList:remove(animation)
    end
  end
  self.destroyAnimationStack = function()
    return animationList:clear()
  end
  self.animate = function()
    if #animationList == 0 then
      return 
    end
    local currentTime = mp.get_time()
    for _, animation in ipairs(animationList) do
      if animation:update(currentTime) then
        table.insert(deletionQueue, animation)
      end
    end
    if #deletionQueue > 0 then
      return animationList:removeSortedList(deletionQueue)
    end
  end
  self.active = function()
    return #animationList > 0
  end
  AnimationQueue = _class_0
end
local EventLoop
do
  local _class_0
  local _base_0 = {
    reconfigure = function(self)
      settings:_reload()
      AnimationQueue.destroyAnimationStack()
      for _, zone in ipairs(self.activityZones) do
        zone:reconfigure()
      end
      for _, element in ipairs(self.uiElements) do
        element:reconfigure()
      end
    end,
    addZone = function(self, zone)
      if zone == nil then
        return 
      end
      return self.activityZones:insert(zone)
    end,
    removeZone = function(self, zone)
      if zone == nil then
        return 
      end
      return self.activityZones:remove(zone)
    end,
    generateUIFromZones = function(self)
      local seenUIElements = { }
      self.script = { }
      self.uiElements:clear()
      AnimationQueue.destroyAnimationStack()
      for _, zone in ipairs(self.activityZones) do
        for _, uiElement in ipairs(zone.elements) do
          if not (seenUIElements[uiElement]) then
            self:addUIElement(uiElement)
            seenUIElements[uiElement] = true
          end
        end
      end
      return self.updateTimer:resume()
    end,
    addUIElement = function(self, uiElement)
      if uiElement == nil then
        error('nil UIElement added.')
      end
      self.uiElements:insert(uiElement)
      return table.insert(self.script, '')
    end,
    removeUIElement = function(self, uiElement)
      if uiElement == nil then
        error('nil UIElement removed.')
      end
      table.remove(self.script, uiElement[self.uiElements])
      self.uiElements:remove(uiElement)
      self.needsRedraw = true
    end,
    resize = function(self)
      for _, zone in ipairs(self.activityZones) do
        zone:resize()
      end
      for _, uiElement in ipairs(self.uiElements) do
        uiElement:resize()
      end
    end,
    redraw = function(self, forceRedraw)
      local clickPending = Mouse:update()
      if Window:update() then
        self.canvas.res_x = Window.w
        self.canvas.res_y = Window.h
        self:resize()
      end
      for index, zone in ipairs(self.activityZones) do
        zone:update(self.displayRequested, clickPending)
      end
      AnimationQueue.animate()
      for index, uiElement in ipairs(self.uiElements) do
        if uiElement:redraw() then
          self.script[index] = uiElement:stringify()
          self.needsRedraw = true
        end
      end
      if self.needsRedraw then
        self.canvas.data = table.concat(self.script, '\n')
        self.canvas:update()
        self.needsRedraw = false
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.script = { }
      self.uiElements = Stack()
      self.activityZones = Stack()
      self.displayRequested = false
      self.needsRedraw = false
      self.canvas = mp.create_osd_overlay("ass-events")
      self.updateTimer = mp.add_periodic_timer(settings['redraw-period'], (function()
        local _base_1 = self
        local _fn_0 = _base_1.redraw
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
      self.updateTimer:stop()
      mp.register_event('shutdown', function()
        return self.updateTimer:kill()
      end)
      local displayRequestTimer
      local displayDuration = settings['request-display-duration']
      mp.add_key_binding("tab", "request-display", function(event)
        if event.event == "repeat" then
          return 
        end
        if event.event == "down" or event.event == "press" then
          if displayRequestTimer then
            displayRequestTimer:kill()
          end
          self.displayRequested = true
        end
        if event.event == "up" or event.event == "press" then
          if displayDuration == 0 then
            self.displayRequested = false
          else
            displayRequestTimer = mp.add_timeout(displayDuration, function()
              self.displayRequested = false
            end)
          end
        end
      end, {
        complex = true
      })
      return mp.add_key_binding('ctrl+r', 'reconfigure', (function()
        local _base_1 = self
        local _fn_0 = _base_1.reconfigure
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), {
        repeatable = false
      })
    end,
    __base = _base_0,
    __name = "EventLoop"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EventLoop = _class_0
end
local Animation
do
  local _class_0
  local _base_0 = {
    update = function(self, now)
      if self.isReversed then
        self.linearProgress = clamp(self.linearProgress + (self.lastUpdate - now) * self.durationR, 0, 1)
        if self.linearProgress == 0 then
          self.isFinished = true
        end
      else
        self.linearProgress = clamp(self.linearProgress + (now - self.lastUpdate) * self.durationR, 0, 1)
        if self.linearProgress == 1 then
          self.isFinished = true
        end
      end
      self.lastUpdate = now
      local progress = math.pow(self.linearProgress, self.accel)
      self.value = (1 - progress) * self.initialValue + progress * self.endValue
      self.updateCb(self.value)
      if self.isFinished and self.finishedCb then
        self:finishedCb()
      end
      return self.isFinished
    end,
    interrupt = function(self, reverse)
      self.finishedCb = nil
      self.lastUpdate = mp.get_time()
      self.isReversed = reverse
      if not (self.active) then
        self.isFinished = false
        return AnimationQueue.addAnimation(self)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, initialValue, endValue, duration, updateCb, finishedCb, accel)
      if accel == nil then
        accel = 1
      end
      self.initialValue, self.endValue, self.duration, self.updateCb, self.finishedCb, self.accel = initialValue, endValue, duration, updateCb, finishedCb, accel
      self.value = self.initialValue
      self.linearProgress = 0
      self.lastUpdate = mp.get_time()
      self.durationR = 1 / self.duration
      self.isFinished = (self.duration <= 0)
      self.active = false
      self.isReversed = false
    end,
    __base = _base_0,
    __name = "Animation"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Animation = _class_0
end
local UIElement
do
  local _class_0
  local _base_0 = {
    stringify = function(self)
      self.needsUpdate = false
      if not self.active then
        return ''
      else
        return table.concat(self.line)
      end
    end,
    activate = function(self, activate)
      if activate == true then
        if self.animation then
          self.animation:interrupt(false)
        end
        self.active = true
      else
        if self.animation then
          self.animation:interrupt(true)
          self.animation.finishedCb = function()
            self.active = false
          end
        else
          self.active = false
        end
      end
    end,
    reconfigure = function(self)
      self.needsUpdate = true
      self.animationDuration = settings['animation-duration']
    end,
    resize = function(self)
      return error('UIElement updateSize called')
    end,
    redraw = function(self)
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.needsUpdate = false
      self.active = false
      self.animationDuration = settings['animation-duration']
    end,
    __base = _base_0,
    __name = "UIElement"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  UIElement = _class_0
end
local BarAccent
do
  local _class_0
  local barSize
  local _parent_0 = UIElement
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      barSize = settings['bar-height-active']
    end,
    resize = function(self)
      self.yPos = Window.h - barSize
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.barSize ~= barSize then
        self.barSize = barSize
        return self:resize()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.yPos = Window.h - barSize
    end,
    __base = _base_0,
    __name = "BarAccent",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  barSize = settings['bar-height-active']
  self.changeBarSize = function(size)
    barSize = size
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BarAccent = _class_0
end
local BarBase
do
  local _class_0
  local hideInactive, lineBaseTemplate
  local _parent_0 = UIElement
  local _base_0 = {
    _updateBarVisibility = function(self)
      if hideInactive then
        self.animationMinHeight = 0
      else
        self.animationMinHeight = self.minHeight
      end
    end,
    reconfigure = function(self, prefix)
      if prefix == nil then
        prefix = 'bar-'
      end
      _class_0.__parent.__base.reconfigure(self)
      self.minHeight = settings[prefix .. 'height-inactive'] * 100
      self.maxHeight = settings[prefix .. 'height-active'] * 100
      hideInactive = settings['bar-hide-inactive']
      self:_updateBarVisibility()
      self.line[4] = self.minHeight
      self.line[8] = lineBaseTemplate:format(settings['default-style'], settings['bar-default-style'], '%s')
      self.animation = Animation(0, 1, self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
    end,
    stringify = function(self)
      self.needsUpdate = false
      if hideInactive and not self.active then
        return ""
      else
        return table.concat(self.line)
      end
    end,
    resize = function(self)
      self.line[2] = ([[%d,%d]]):format(0, Window.h)
      self.line[9] = ([[m 0 0 l %d 0 %d 1 0 1]]):format(Window.w, Window.w)
      self.needsUpdate = true
    end,
    animate = function(self, value)
      self.line[4] = ([[%g]]):format((self.maxHeight - self.animationMinHeight) * value + self.animationMinHeight)
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.hideInactive ~= hideInactive then
        self.hideInactive = hideInactive
        if not (self.active) then
          self:animate(0)
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      self.minHeight = settings['bar-height-inactive'] * 100
      self.animationMinHeight = minHeight
      self.maxHeight = settings['bar-height-active'] * 100
      self.line = {
        [[{\pos(]],
        0,
        [[)\fscy]],
        minHeight,
        [[\fscx]],
        0.001,
        [[]],
        lineBaseTemplate,
        0
      }
      _class_0.__parent.__init(self)
      table.insert(self.__class.instantiatedBars, self)
      return self:reconfigure()
    end,
    __base = _base_0,
    __name = "BarBase",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  hideInactive = settings['bar-hide-inactive']
  self.instantiatedBars = { }
  self.toggleInactiveVisibility = function(self)
    hideInactive = not hideInactive
    local _list_0 = self.instantiatedBars
    for _index_0 = 1, #_list_0 do
      local bar = _list_0[_index_0]
      bar:_updateBarVisibility()
    end
  end
  lineBaseTemplate = [[\an1%s%s%s\p1}]]
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BarBase = _class_0
end
local ProgressBar
do
  local _class_0
  local seekString
  local _parent_0 = BarBase
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      seekString = ('absolute-percent+%s'):format(settings['seek-precision'])
      self.barShift = settings['progress-bar-width'] / 2.0
      self:resize()
      self.line[7] = [[]]
      self.line[8] = self.line[8]:format(settings['bar-foreground-style'])
    end,
    clickHandler = function(self)
      return mp.commandv("seek", Mouse.clickX * 100 / Window.w, seekString)
    end,
    resize = function(self)
      _class_0.__parent.__base.resize(self)
      if self.barShift > 0 then
        self.line[2] = ('%g,%g'):format(self.barShift, Window.h)
      end
    end,
    redraw = function(self)
      _class_0.__parent.__base.redraw(self)
      if self.hideInactive and not self.active then
        return self.needsUpdate
      end
      local position = mp.get_property_number('percent-pos', 0)
      if position ~= self.lastPosition or self.needsUpdate then
        self.line[6] = position
        if self.barShift > 0 then
          local followingEdge = Window.w * position * 1e-2 - self.barShift
          self.line[7] = ([[\clip(m %g 0 l %g 0 %g %g %g %g)]]):format(followingEdge, Window.w, Window.w, Window.h, followingEdge, Window.h)
        end
        self.lastPosition = position
        self.needsUpdate = true
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.lastPosition = 0
    end,
    __base = _base_0,
    __name = "ProgressBar",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  seekString = ('absolute-percent+%s'):format(settings['seek-precision'])
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBar = _class_0
end
local ProgressBarCache
do
  local _class_0
  local timestamp
  local _parent_0 = BarBase
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self, 'bar-cache-')
      self.line[6] = 100
      self.line[8] = self.line[8]:format(settings['bar-cache-style']) .. 'm 0 0'
      self.line[10] = ([[{\p0%s\p1}]]):format(settings['bar-cache-background-style'])
      self.line[11] = [[]]
      self.fileDuration = mp.get_property_number('duration', nil)
    end,
    resize = function(self)
      _class_0.__parent.__base.resize(self)
      if self.fileDuration then
        self.coordinateRemap = Window.w / self.fileDuration
      end
      self.line[9] = [[]]
    end,
    clobber = function(self)
      self.line[9] = ""
      self.line[11] = ""
    end,
    redraw = function(self)
      _class_0.__parent.__base.redraw(self)
      if self.hideInactive and not self.active then
        return self.needsUpdate
      end
      if self.fileDuration and (self.fileDuration > 0) then
        local barDrawing = {
          past = { },
          future = { }
        }
        local ranges
        ranges = mp.get_property_native('demuxer-cache-state', { })['seekable-ranges']
        if ranges and (#ranges > 0) then
          local position = mp.get_property_number('percent-pos', 0)
          local cacheKeyAggregator = {
            Window.w,
            position
          }
          for _index_0 = 1, #ranges do
            local _des_0 = ranges[_index_0]
            local rangeStart, rangeEnd
            rangeStart, rangeEnd = _des_0.start, _des_0["end"]
            table.insert(cacheKeyAggregator, rangeStart)
            table.insert(cacheKeyAggregator, rangeEnd)
          end
          local cacheKey = table.concat(cacheKeyAggregator, '_')
          if cacheKey == self.cacheKey then
            return self.needsUpdate
          end
          local progressPosition = mp.get_property_number('percent-pos', 0) * Window.w * 0.01
          for _index_0 = 1, #ranges do
            local _des_0 = ranges[_index_0]
            local rangeStart, rangeEnd
            rangeStart, rangeEnd = _des_0.start, _des_0["end"]
            rangeStart = rangeStart * self.coordinateRemap
            rangeEnd = rangeEnd * self.coordinateRemap
            if rangeEnd < progressPosition then
              local rect = ('m %g 0 l %g 1 %g 1 %g 0'):format(rangeStart, rangeStart, rangeEnd, rangeEnd)
              table.insert(barDrawing.past, rect)
            elseif rangeStart > progressPosition then
              rangeStart = rangeStart - progressPosition
              rangeEnd = rangeEnd - progressPosition
              local rect = ('m %g 0 l %g 1 %g 1 %g 0'):format(rangeStart, rangeStart, rangeEnd, rangeEnd)
              table.insert(barDrawing.future, rect)
            else
              rangeEnd = rangeEnd - progressPosition
              local rectPast = ('m %g 0 l %g 1 %g 1 %g 0'):format(rangeStart, rangeStart, progressPosition, progressPosition)
              local rectFuture = ('m %g 0 l %g 1 %g 1 %g 0'):format(0, 0, rangeEnd, rangeEnd)
              table.insert(barDrawing.past, rectPast)
              table.insert(barDrawing.future, rectFuture)
            end
          end
          self.line[9] = table.concat(barDrawing.past, ' ') .. ('m %g 0'):format(progressPosition)
          self.line[11] = table.concat(barDrawing.future, ' ')
          self.cacheKey = cacheKey
          self.needsUpdate = true
        else
          self:clobber()
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.cacheKey = nil
      self.coordinateRemap = 0
      return mp.observe_property('duration', 'number', function(name, value)
        if value and (value > 0) then
          self.fileDuration = value
          self.coordinateRemap = Window.w / value
        end
      end)
    end,
    __base = _base_0,
    __name = "ProgressBarCache",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  timestamp = os.time()
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBarCache = _class_0
end
local ProgressBarBackground
do
  local _class_0
  local _parent_0 = BarBase
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      if settings['bar-background-adaptive'] then
        local _list_0 = self.__class.instantiatedBars
        for _index_0 = 1, #_list_0 do
          local bar = _list_0[_index_0]
          self.minHeight = math.max(self.minHeight, bar.minHeight)
          self.maxHeight = math.max(self.maxHeight, bar.maxHeight)
        end
        self:_updateBarVisibility()
      end
      self.line[6] = 100
      self.line[8] = self.line[8]:format(settings['bar-background-style'])
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "ProgressBarBackground",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBarBackground = _class_0
end
local ChapterMarker
do
  local _class_0
  local beforeStyle, afterStyle
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    resize = function(self)
      self.line[2] = ('%d,%d'):format(math.floor(self.position * Window.w), Window.h)
    end,
    animate = function(self, width, height)
      self.line[4] = ('%g'):format(width)
      self.line[6] = ('%g'):format(height)
    end,
    redraw = function(self, position, update)
      if update == nil then
        update = false
      end
      if not self.passed and (position > self.position) then
        self.line[7] = afterStyle
        self.passed = true
        update = true
      elseif self.passed and (position < self.position) then
        self.line[7] = beforeStyle
        self.passed = false
        update = true
      end
      return update
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, position, minWidth, minHeight)
      self.position = position
      self.line = {
        [[{\an2\bord0\p1\pos(]],
        ([[%g,%g]]):format(self.position * Window.w, Window.h),
        [[)\fscx]],
        minWidth,
        [[\fscy]],
        minHeight,
        beforeStyle,
        '}m 0 0 l 1 0 1 1 0 1\n'
      }
      self.passed = false
    end,
    __base = _base_0,
    __name = "ChapterMarker"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  beforeStyle = settings['chapter-marker-before-style']
  afterStyle = settings['chapter-marker-after-style']
  self.reconfigure = function(self)
    beforeStyle = settings['chapter-marker-before-style']
    afterStyle = settings['chapter-marker-after-style']
  end
  ChapterMarker = _class_0
end
local Chapters
do
  local _class_0
  local minWidth, maxWidth, maxHeight, maxHeightFrac
  local _parent_0 = BarBase
  local _base_0 = {
    createMarkers = function(self)
      self.line = { }
      self.markers = { }
      local totalTime = mp.get_property_number('duration', 0.01)
      local chapters = mp.get_property_native('chapter-list', { })
      local markerHeight = self.active and maxHeight * maxHeightFrac or BarBase.instantiatedBars[1].animationMinHeight
      local markerWidth = self.active and maxWidth or minWidth
      for _index_0 = 1, #chapters do
        local chapter = chapters[_index_0]
        local marker = ChapterMarker(chapter.time / totalTime, markerWidth, markerHeight)
        table.insert(self.markers, marker)
        table.insert(self.line, marker:stringify())
      end
      self.needsUpdate = true
    end,
    reconfigure = function(self)
      UIElement.reconfigure(self)
      minWidth = settings['chapter-marker-width'] * 100
      maxWidth = settings['chapter-marker-width-active'] * 100
      maxHeight = settings['bar-height-active'] * 100
      maxHeightFrac = settings['chapter-marker-active-height-fraction']
      ChapterMarker:reconfigure()
      self:createMarkers()
      self.animation = Animation(0, 1, self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
    end,
    resize = function(self)
      for i, marker in ipairs(self.markers) do
        marker:resize()
        self.line[i] = marker:stringify()
      end
      self.needsUpdate = true
    end,
    animate = function(self, value)
      local width = (maxWidth - minWidth) * value + minWidth
      local height = (maxHeight * maxHeightFrac - BarBase.instantiatedBars[1].animationMinHeight) * value + BarBase.instantiatedBars[1].animationMinHeight
      for i, marker in ipairs(self.markers) do
        marker:animate(width, height)
        self.line[i] = marker:stringify()
      end
      self.needsUpdate = true
    end,
    redraw = function(self)
      _class_0.__parent.__base.redraw(self)
      local currentPosition = mp.get_property_number('percent-pos', 0) * 0.01
      local update = false
      for i, marker in ipairs(self.markers) do
        if marker:redraw(currentPosition) then
          self.line[i] = marker:stringify()
          update = true
        end
      end
      return self.needsUpdate or update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.line = { }
      self.markers = { }
      self.animation = Animation(0, 1, self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
    end,
    __base = _base_0,
    __name = "Chapters",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  minWidth = settings['chapter-marker-width'] * 100
  maxWidth = settings['chapter-marker-width-active'] * 100
  maxHeight = settings['bar-height-active'] * 100
  maxHeightFrac = settings['chapter-marker-active-height-fraction']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Chapters = _class_0
end
local TimeElapsed
do
  local _class_0
  local bottomMargin
  local _parent_0 = BarAccent
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      bottomMargin = settings['elapsed-bottom-margin']
      local offscreenPos = settings['elapsed-offscreen-pos']
      self.line[2] = ('%g,%g'):format(self.position, self.yPos - bottomMargin)
      self.line[3] = ([[)\an1%s%s}]]):format(settings['default-style'], settings['elapsed-style'])
      self.animation = Animation(offscreenPos, settings['elapsed-left-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    resize = function(self)
      _class_0.__parent.__base.resize(self)
      self.line[2] = ('%g,%g'):format(self.position, self.yPos - bottomMargin)
    end,
    animate = function(self, value)
      self.position = value
      self.line[2] = ('%g,%g'):format(value, self.yPos - bottomMargin)
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.active then
        _class_0.__parent.__base.redraw(self)
        local timeElapsed = math.floor(mp.get_property_number('time-pos', 0))
        if timeElapsed ~= self.lastTime then
          local update = true
          self.line[4] = ('%d:%02d:%02d'):format(math.floor(timeElapsed / 3600), math.floor((timeElapsed / 60) % 60), math.floor(timeElapsed % 60))
          self.lastTime = timeElapsed
          self.needsUpdate = true
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      local offscreenPos = settings['elapsed-offscreen-pos']
      self.line = {
        [[{\pos(]],
        ([[%g,0]]):format(offscreenPos),
        ([[)\an1%s%s}]]):format(settings['default-style'], settings['elapsed-style']),
        [[????]]
      }
      self.lastTime = -1
      self.position = offscreenPos
      self.animation = Animation(offscreenPos, settings['elapsed-left-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    __base = _base_0,
    __name = "TimeElapsed",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  bottomMargin = settings['elapsed-bottom-margin']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TimeElapsed = _class_0
end
local TimeRemaining
do
  local _class_0
  local bottomMargin
  local _parent_0 = BarAccent
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      bottomMargin = settings['remaining-bottom-margin']
      local offscreenPos = settings['remaining-offscreen-pos']
      self.line[2] = ('%g,%g'):format(self.position, self.yPos - bottomMargin)
      self.line[3] = ([[)\an3%s%s}]]):format(settings['default-style'], settings['remaining-style'])
      self.animation = Animation(offscreenPos, settings['remaining-right-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    resize = function(self)
      _class_0.__parent.__base.resize(self)
      self.position = Window.w - self.animation.value
      self.line[2] = ('%g,%g'):format(self.position, self.yPos - bottomMargin)
    end,
    animate = function(self, value)
      self.position = Window.w - value
      self.line[2] = ('%g,%g'):format(self.position, self.yPos - bottomMargin)
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.active then
        _class_0.__parent.__base.redraw(self)
        local timeRemaining = math.floor(mp.get_property_number('playtime-remaining', 0))
        if timeRemaining ~= self.lastTime then
          local update = true
          self.line[4] = ('–%d:%02d:%02d'):format(math.floor(timeRemaining / 3600), math.floor((timeRemaining / 60) % 60), math.floor(timeRemaining % 60))
          self.lastTime = timeRemaining
          self.needsUpdate = true
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      local offscreenPos = settings['remaining-offscreen-pos']
      self.line = {
        [[{\pos(]],
        ([[%g,0]]):format(offscreenPos),
        ([[)\an3%s%s}]]):format(settings['default-style'], settings['remaining-style']),
        [[????]]
      }
      self.lastTime = -1
      self.position = offscreenPos
      self.animation = Animation(offscreenPos, settings['remaining-right-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    __base = _base_0,
    __name = "TimeRemaining",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  bottomMargin = settings['remaining-bottom-margin']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TimeRemaining = _class_0
end
local HoverTime
do
  local _class_0
  local rightMargin, leftMargin, bottomMargin, offScreenPos
  local _parent_0 = BarAccent
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      rightMargin = settings['hover-time-right-margin']
      leftMargin = settings['hover-time-left-margin']
      bottomMargin = settings['hover-time-bottom-margin']
      offScreenPos = settings['hover-time-offscreen-pos']
      self.line[2] = ('%g,%g'):format(clamp(Mouse.x, leftMargin, Window.w - rightMargin), self.position)
      self.line[1] = ([[{%s%s\pos(]]):format(settings['default-style'], settings['hover-time-style'])
      self.animation = Animation(offScreenPos, bottomMargin, self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    resize = function(self)
      _class_0.__parent.__base.resize(self)
      self.line[2] = ("%g,%g"):format(clamp(Mouse.x, leftMargin, Window.w - rightMargin), self.yPos - self.animation.value)
    end,
    animate = function(self, value)
      self.position = self.yPos - value
      self.line[2] = ("%g,%g"):format(clamp(Mouse.x, leftMargin, Window.w - rightMargin), self.position)
      self.needsUpdate = true
    end,
    _setXPosition = function(self, x)
      self.line[2] = ("%g,%g"):format(clamp(x, leftMargin, Window.w - rightMargin), self.position)
      self.needsUpdate = true
    end,
    _setUnknownDuration = function(self)
      self.line[4] = "????"
      self.needsUpdate = true
    end,
    _setTime = function(self, hoverTime)
      self.line[4] = ([[%d:%02d:%02d]]):format(math.floor(hoverTime / 3600), math.floor((hoverTime / 60) % 60), math.floor(hoverTime % 60))
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.active then
        _class_0.__parent.__base.redraw(self)
        local duration = mp.get_property_number('duration', 0)
        local hoverTime = duration * Mouse.x / Window.w
        if Mouse.x ~= self.lastX then
          self.lastX = Mouse.x
          self:_setXPosition(Mouse.x)
        end
        if duration ~= self.lastDuration or hoverTime ~= self.lastTime then
          self.lastDuration = duration
          self.lastTime = hoverTime
          if duration == 0 then
            self:_setUnknownDuration()
          else
            self:_setTime(hoverTime)
          end
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.line = {
        ([[{%s%s\pos(]]):format(settings['default-style'], settings['hover-time-style']),
        [[-100,0]],
        [[)\an2}]],
        [[????]]
      }
      self.lastDuration = 0
      self.lastTime = 0
      self.lastX = -1
      self.position = offScreenPos
      self.animation = Animation(offScreenPos, bottomMargin, self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    __base = _base_0,
    __name = "HoverTime",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  rightMargin = settings['hover-time-right-margin']
  leftMargin = settings['hover-time-left-margin']
  bottomMargin = settings['hover-time-bottom-margin']
  offScreenPos = settings['hover-time-offscreen-pos']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  HoverTime = _class_0
end
local Thumbnail
do
  local _class_0
  local rightMargin, leftMargin, bottomMargin
  local _parent_0 = BarAccent
  local _base_0 = {
    updateInfo = function(self, thumbfastInfo)
      self.thumbfast = thumbfastInfo
      self.lastX = -1
      self.needsUpdate = true
    end,
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      rightMargin = settings['thumbnail-right-margin']
      leftMargin = settings['thumbnail-left-margin']
      bottomMargin = settings['thumbnail-bottom-margin']
    end,
    activate = function(self, activate)
      _class_0.__parent.__base.activate(self, activate)
      if not activate then
        mp.commandv('script-message-to', 'thumbfast', 'clear')
        self.needsUpdate = true
      end
    end,
    redraw = function(self)
      if self.active then
        _class_0.__parent.__base.redraw(self)
        if Mouse.x ~= self.lastX and not self.thumbfast.disabled then
          self.lastX = Mouse.x
          local hoverTime = mp.get_property_number('duration', 0) * Mouse.x / Window.w
          mp.commandv('script-message-to', 'thumbfast', 'thumb', hoverTime, clamp(Mouse._rawX - self.thumbfast.width / 2, leftMargin, Window._rawW - self.thumbfast.width - rightMargin), Window._rawH - bottomMargin * Window.osdScale - self.thumbfast.height)
        end
        self.needsUpdate = true
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, thumbfastInfo)
      _class_0.__parent.__init(self)
      self.line = { }
      self.lastX = -1
      return self:updateInfo(thumbfastInfo)
    end,
    __base = _base_0,
    __name = "Thumbnail",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  rightMargin = settings['thumbnail-right-margin']
  leftMargin = settings['thumbnail-left-margin']
  bottomMargin = settings['thumbnail-bottom-margin']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Thumbnail = _class_0
end
local PauseIndicator
do
  local _class_0
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    resize = function(self)
      local w, h = 0.5 * Window.w, 0.5 * Window.h
      self.line[5] = ([[%g,%g]]):format(w, h)
      self.line[12] = ([[%g,%g]]):format(w, h)
    end,
    redraw = function()
      return true
    end,
    animate = function(self, value)
      local scale = value * 50 + 100
      local scaleStr = ([[{\fscx%g\fscy%g]]):format(scale, scale)
      local alphaStr = ('%02X'):format(value * value * 255)
      self.line[1] = scaleStr
      self.line[8] = scaleStr
      self.line[3] = alphaStr
      self.line[10] = alphaStr
    end,
    destroy = function(self, animation)
      return self.eventLoop:removeUIElement(self)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, eventLoop, paused)
      self.eventLoop = eventLoop
      local w, h = 0.5 * Window.w, 0.5 * Window.h
      self.line = {
        [[{\fscx0\fscy0]],
        [[\alpha&H]],
        0,
        [[&\pos(]],
        ([[%g,%g]]):format(w, h),
        ([[)\an5\bord0%s\p1}]]):format(settings['pause-indicator-background-style']),
        0,
        [[{\fscx0\fscy0]],
        [[\alpha&H]],
        0,
        [[&\pos(]],
        ([[%g,%g]]):format(w, h),
        ([[)\an5\bord0%s\p1}]]):format(settings['pause-indicator-foreground-style']),
        0
      }
      if paused then
        self.line[7] = 'm 75 37.5 b 75 58.21 58.21 75 37.5 75 16.79 75 0 58.21 0 37.5 0 16.79 16.79 0 37.5 0 58.21 0 75 16.79 75 37.5 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20\n'
        self.line[14] = 'm 0 0 m 75 75 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20'
      else
        self.line[7] = 'm 75 37.5 b 75 58.21 58.21 75 37.5 75 16.79 75 0 58.21 0 37.5 0 16.79 16.79 0 37.5 0 58.21 0 75 16.79 75 37.5 m 25.8333 17.18 l 25.8333 57.6 60.8333 37.39\n'
        self.line[14] = 'm 0 0 m 75 75 m 25.8333 17.18 l 25.8333 57.6 60.8333 37.39'
      end
      AnimationQueue.addAnimation(Animation(0, 1, settings['animation-duration'], (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), (function()
        local _base_1 = self
        local _fn_0 = _base_1.destroy
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)()))
      return self.eventLoop:addUIElement(self)
    end,
    __base = _base_0,
    __name = "PauseIndicator"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PauseIndicator = _class_0
end
local Title
do
  local _class_0
  local _parent_0 = UIElement
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      local offscreenPos = settings['title-offscreen-pos']
      self.line[2] = ('%g,%g'):format(settings['title-left-margin'], self.animation.value)
      self.line[3] = ([[)\an7%s%s}]]):format(settings['default-style'], settings['title-style'])
      self.animation = Animation(offscreenPos, settings['title-top-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    resize = function(self) end,
    animate = function(self, value)
      self.line[2] = ('%g,%g'):format(settings['title-left-margin'], value)
      self.needsUpdate = true
    end,
    _forceUpdatePlaylistInfo = function(self)
      self.playlistInfo = {
        ['media-title'] = mp.get_property('media-title', '????'),
        ['playlist-pos-1'] = mp.get_property_number('playlist-pos-1', 1),
        ['playlist-count'] = mp.get_property_number('playlist-count', 1)
      }
    end,
    generateTitleString = function(self, quote)
      if quote == nil then
        quote = false
      end
      local title, position, total
      do
        local _obj_0 = self.playlistInfo
        title, position, total = _obj_0['media-title'], _obj_0['playlist-pos-1'], _obj_0['playlist-count']
      end
      local prefix = (total > 1) and ('%d/%d - '):format(position, total) or ''
      if quote then
        return prefix .. ('%q'):format(title)
      else
        return prefix .. title
      end
    end,
    updatePlaylistInfo = function(self, changedProp, newValue)
      if newValue then
        self.playlistInfo[changedProp] = newValue
        self.line[4] = self:generateTitleString()
        self.needsUpdate = true
      end
    end,
    print = function(self)
      if settings['title-print-to-cli'] then
        return log.warn("Playing: %s", self:generateTitleString(true))
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      local offscreenPos = settings['title-offscreen-pos']
      self.line = {
        [[{\pos(]],
        ([[%g,%g]]):format(settings['title-left-margin'], offscreenPos),
        ([[)\an7%s%s}]]):format(settings['default-style'], settings['title-style']),
        [[????]]
      }
      self.position = offscreenPos
      self.animation = Animation(offscreenPos, settings['title-top-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
      self:_forceUpdatePlaylistInfo()
      local updatePlaylistInfo
      do
        local _base_1 = self
        local _fn_0 = _base_1.updatePlaylistInfo
        updatePlaylistInfo = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      mp.observe_property('media-title', 'string', updatePlaylistInfo)
      mp.observe_property('playlist-pos-1', 'number', updatePlaylistInfo)
      return mp.observe_property('playlist-count', 'number', updatePlaylistInfo)
    end,
    __base = _base_0,
    __name = "Title",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Title = _class_0
end
local SystemTime
do
  local _class_0
  local offscreenPosition, topMargin, timeFormat
  local _parent_0 = UIElement
  local _base_0 = {
    reconfigure = function(self)
      _class_0.__parent.__base.reconfigure(self)
      offscreenPosition = settings['system-time-offscreen-pos']
      topMargin = settings['system-time-top-margin']
      timeFormat = settings['system-time-format']
      self.line[2] = ('%g,%g'):format(self.position, topMargin)
      self.line[3] = ([[)\an9%s%s}]]):format(settings['default-style'], settings['system-time-style'])
      self.animation = Animation(offscreenPosition, settings['system-time-right-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    resize = function(self)
      self.position = Window.w - self.animation.value
      self.line[2] = ('%g,%g'):format(self.position, topMargin)
    end,
    animate = function(self, value)
      self.position = Window.w - value
      self.line[2] = ('%g,%g'):format(self.position, topMargin)
      self.needsUpdate = true
    end,
    redraw = function(self)
      if self.active then
        local systemTime = os.time()
        if systemTime ~= self.lastTime then
          local update = true
          self.line[4] = os.date(timeFormat, systemTime)
          self.lastTime = systemTime
          self.needsUpdate = true
        end
      end
      return self.needsUpdate
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.line = {
        [[{\pos(]],
        [[-100,0]],
        ([[)\an9%s%s}]]):format(settings['default-style'], settings['system-time-style']),
        [[????]]
      }
      self.lastTime = -1
      self.position = offscreenPosition
      self.animation = Animation(offscreenPosition, settings['system-time-right-margin'], self.animationDuration, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.5)
    end,
    __base = _base_0,
    __name = "SystemTime",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  offscreenPosition = settings['system-time-offscreen-pos']
  topMargin = settings['system-time-top-margin']
  timeFormat = settings['system-time-format']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SystemTime = _class_0
end
local eventLoop = EventLoop()
local activeHeight = settings['hover-zone-height']
local ignoreRequestDisplay
ignoreRequestDisplay = function(self)
  if not (Mouse.inWindow) then
    return false
  end
  if Mouse.dead then
    return false
  end
  return self:containsPoint(Mouse.x, Mouse.y)
end
local bottomZone = ActivityZone(function(self)
  return self:reset(0, Window.h - activeHeight, Window.w, activeHeight)
end)
local hoverTimeZone = ActivityZone(function(self)
  return self:reset(0, Window.h - activeHeight, Window.w, activeHeight)
end, ignoreRequestDisplay)
local topZone = ActivityZone(function(self)
  return self:reset(0, 0, Window.w, activeHeight)
end, ignoreRequestDisplay)
local chapters, progressBar, barCache, barBackground, elapsedTime, remainingTime, hoverTime, thumbnail
if settings['enable-bar'] then
  progressBar = ProgressBar()
  barCache = ProgressBarCache()
  barBackground = ProgressBarBackground()
  bottomZone:addUIElement(barBackground)
  if settings['bar-cache-position'] == 'overlay' then
    bottomZone:addUIElement(progressBar)
    bottomZone:addUIElement(barCache)
  else
    bottomZone:addUIElement(barCache)
    bottomZone:addUIElement(progressBar)
  end
  mp.add_key_binding("c", "toggle-inactive-bar", function()
    return BarBase:toggleInactiveVisibility()
  end)
end
if settings['enable-chapter-markers'] then
  chapters = Chapters()
  bottomZone:addUIElement(chapters)
end
if settings['enable-elapsed-time'] then
  elapsedTime = TimeElapsed()
  bottomZone:addUIElement(elapsedTime)
end
if settings['enable-remaining-time'] then
  remainingTime = TimeRemaining()
  bottomZone:addUIElement(remainingTime)
end
if settings['enable-hover-time'] then
  hoverTime = HoverTime()
  hoverTimeZone:addUIElement(hoverTime)
end
if settings['enable-thumbnail'] then
  mp.register_script_message('thumbfast-info', function(json)
    local data = utils.parse_json(json)
    if type(data) ~= 'table' or not data.width or not data.height then
      return log.warn('thumbfast did not respond with proper thumbnail information. Thumbnails are disabled.')
    else
      if thumbnail then
        return thumbnail:updateInfo(data)
      else
        thumbnail = Thumbnail(data)
        hoverTimeZone:addUIElement(thumbnail)
        return eventLoop:generateUIFromZones()
      end
    end
  end)
end
local title = nil
if settings['enable-title'] then
  title = Title()
  bottomZone:addUIElement(title)
  topZone:addUIElement(title)
end
if settings['enable-system-time'] then
  local systemTime = SystemTime()
  bottomZone:addUIElement(systemTime)
  topZone:addUIElement(systemTime)
end
eventLoop:addZone(hoverTimeZone)
eventLoop:addZone(bottomZone)
eventLoop:addZone(topZone)
local notFrameStepping = false
if settings['pause-indicator'] then
  local PauseIndicatorWrapper
  PauseIndicatorWrapper = function(event, paused)
    if notFrameStepping then
      return PauseIndicator(eventLoop, paused)
    elseif paused then
      notFrameStepping = true
    end
  end
  mp.add_key_binding('.', 'step-forward', function()
    notFrameStepping = false
    return mp.commandv('frame_step')
  end, {
    repeatable = true
  })
  mp.add_key_binding(',', 'step-backward', function()
    notFrameStepping = false
    return mp.commandv('frame_back_step')
  end, {
    repeatable = true
  })
  mp.observe_property('pause', 'bool', PauseIndicatorWrapper)
end
local streamMode = false
local initDraw
initDraw = function()
  if chapters then
    chapters:createMarkers()
  end
  if title then
    title:_forceUpdatePlaylistInfo()
    title:print()
  end
  notFrameStepping = true
  local duration = mp.get_property('duration')
  if not (streamMode or duration) then
    BarAccent.changeBarSize(0)
    if progressBar then
      bottomZone:removeUIElement(progressBar)
      bottomZone:removeUIElement(barCache)
      bottomZone:removeUIElement(barBackground)
    end
    if chapters then
      bottomZone:removeUIElement(chapters)
    end
    if hoverTime then
      hoverTimeZone:removeUIElement(hoverTime)
    end
    if remainingTime then
      bottomZone:removeUIElement(remainingTime)
    end
    streamMode = true
  elseif streamMode and duration then
    BarAccent.changeBarSize(settings['bar-height-active'])
    if progressBar then
      bottomZone:addUIElement(barBackground)
      bottomZone:addUIElement(barCache)
      bottomZone:addUIElement(progressBar)
    end
    if chapters then
      bottomZone:addUIElement(chapters)
    end
    if hoverTime then
      hoverTimeZone:addUIElement(hoverTime)
    end
    if remainingTime then
      bottomZone:addUIElement(remainingTime)
    end
    streamMode = false
  end
  mp.command('script-message-to osc disable-osc')
  eventLoop:generateUIFromZones()
  eventLoop:resize()
  return eventLoop:redraw()
end
return mp.register_event('file-loaded', initDraw)
