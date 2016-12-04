local msg = require('mp.msg')
local options = require('mp.options')
local script_name = 'torque-progressbar'
mp.get_osd_size = mp.get_osd_size or mp.get_screen_size
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
    local level = 2
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
local FG_PLACEHOLDER = '__FG__'
local BG_PLACEHOLDER = '__BG__'
local settings = {
  ['hover-zone-height'] = 40,
  ['top-hover-zone-height'] = 40,
  ['foreground'] = 'FC799E',
  ['background'] = '2D2D2D',
  ['enable-bar'] = true,
  ['hide-inactive'] = false,
  ['bar-height-inactive'] = 2,
  ['bar-height-active'] = 8,
  ['seek-precision'] = 'exact',
  ['bar-foreground'] = FG_PLACEHOLDER,
  ['bar-cache-color'] = '515151',
  ['bar-background'] = BG_PLACEHOLDER,
  ['enable-elapsed-time'] = true,
  ['elapsed-foreground'] = FG_PLACEHOLDER,
  ['elapsed-background'] = BG_PLACEHOLDER,
  ['elapsed-left-margin'] = 2,
  ['elapsed-bottom-margin'] = 0,
  ['enable-remaining-time'] = true,
  ['remaining-foreground'] = FG_PLACEHOLDER,
  ['remaining-background'] = BG_PLACEHOLDER,
  ['remaining-right-margin'] = 4,
  ['remaining-bottom-margin'] = 0,
  ['enable-hover-time'] = true,
  ['hover-time-foreground'] = FG_PLACEHOLDER,
  ['hover-time-background'] = BG_PLACEHOLDER,
  ['hover-time-left-margin'] = 120,
  ['hover-time-right-margin'] = 130,
  ['hover-time-bottom-margin'] = 0,
  ['enable-title'] = true,
  ['title-left-margin'] = 4,
  ['title-top-margin'] = 0,
  ['title-font-size'] = 30,
  ['title-foreground'] = FG_PLACEHOLDER,
  ['title-background'] = BG_PLACEHOLDER,
  ['title-print-to-cli'] = true,
  ['enable-system-time'] = true,
  ['system-time-format'] = '%H:%M',
  ['system-time-right-margin'] = 4,
  ['system-time-top-margin'] = 0,
  ['system-time-font-size'] = 30,
  ['system-time-foreground'] = FG_PLACEHOLDER,
  ['system-time-background'] = BG_PLACEHOLDER,
  ['pause-indicator'] = true,
  ['pause-indicator-scale'] = 1,
  ['pause-indicator-foreground'] = FG_PLACEHOLDER,
  ['pause-indicator-background'] = BG_PLACEHOLDER,
  ['enable-chapter-markers'] = true,
  ['chapter-marker-width'] = 2,
  ['chapter-marker-width-active'] = 4,
  ['chapter-marker-active-height-fraction'] = 1,
  ['chapter-marker-before'] = FG_PLACEHOLDER,
  ['chapter-marker-after'] = BG_PLACEHOLDER,
  ['request-display-duration'] = 1,
  ['redraw-period'] = 0.03,
  ['font'] = 'Source Sans Pro Semibold',
  ['time-font-size'] = 30,
  ['hover-time-font-size'] = 26,
  ['elapsed-offscreen-pos'] = -100,
  ['remaining-offscreen-pos'] = -100,
  ['system-time-offscreen-pos'] = -100,
  ['title-offscreen-pos'] = -40
}
options.read_options(settings, script_name)
for key, value in pairs(settings) do
  if key:match('-foreground') or key == 'chapter-marker-before' then
    if value == FG_PLACEHOLDER then
      settings[key] = settings.foreground
    end
  elseif key:match('-background') or key == 'chapter-marker-after' then
    if value == BG_PLACEHOLDER then
      settings[key] = settings.background
    end
  end
end
if settings['bar-height-inactive'] <= 0 then
  settings['hide-inactive'] = true
  settings['bar-height-inactive'] = 1
end
local OSDAggregator
do
  local _class_0
  local _base_0 = {
    addSubscriber = function(self, subscriber)
      if not subscriber then
        return 
      end
      self.subscriberCount = self.subscriberCount + 1
      subscriber.aggregatorIndex = self.subscriberCount
      self.subscribers[self.subscriberCount] = subscriber
      self.script[self.subscriberCount] = subscriber:stringify()
    end,
    removeSubscriber = function(self, index)
      table.remove(self.subscribers, index)
      table.remove(self.script, index)
      self.subscriberCount = self.subscriberCount - 1
      for i = index, self.subscriberCount do
        self.subscribers[i].aggregatorIndex = i
      end
    end,
    forceResize = function(self)
      for index, subscriber in ipairs(self.subscribers) do
        subscriber:updateSize(self.w, self.h)
      end
    end,
    update = function(self, needsRedraw)
      do
        local _with_0 = self.inputState
        local oldX, oldY = _with_0.mouseX, _with_0.mouseY
        _with_0.mouseX, _with_0.mouseY = mp.get_mouse_pos()
        if _with_0.mouseDead and (oldX ~= _with_0.mouseX or oldY ~= _with_0.mouseY) then
          _with_0.mouseDead = false
        end
      end
      local w, h = mp.get_osd_size()
      local needsResize = false
      if w ~= self.w or h ~= self.h then
        self.w, self.h = w, h
        needsResize = true
      end
      for sub = 1, self.subscriberCount do
        local theSub = self.subscribers[sub]
        local update = false
        if theSub:update(self.inputState) then
          update = true
        end
        if (needsResize and theSub:updateSize(w, h)) or update or self.needsRedrawAll then
          needsRedraw = true
          if self.hideInactive and not theSub.active then
            self.script[sub] = ""
          else
            self.script[sub] = theSub:stringify()
          end
        end
      end
      if needsRedraw == true then
        mp.set_osd_ass(self.w, self.h, table.concat(self.script, '\n'))
      end
      self.needsRedrawAll = false
    end,
    pause = function(self, event, paused)
      self.paused = paused
      if self.paused then
        return self.updateTimer:stop()
      else
        return self.updateTimer:resume()
      end
    end,
    forceUpdate = function(self)
      self.updateTimer:kill()
      self:update(true)
      if not (self.paused) then
        return self.updateTimer:resume()
      end
    end,
    toggleInactiveVisibility = function(self)
      self.hideInactive = not self.hideInactive
      self.needsRedrawAll = true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.script = { }
      self.subscribers = { }
      self.inputState = {
        mouseX = -1,
        mouseY = -1,
        mouseInWindow = false,
        displayRequested = false,
        mouseDead = true
      }
      self.subscriberCount = 0
      self.w = 0
      self.h = 0
      self.hideInactive = settings['hide-inactive']
      self.needsRedrawAll = false
      self.updateTimer = mp.add_periodic_timer(settings['redraw-period'], (function()
        local _base_1 = self
        local _fn_0 = _base_1.update
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
      mp.register_event('shutdown', function()
        return self.updateTimer:kill()
      end)
      mp.observe_property('fullscreen', 'bool', function()
        do
          local _with_0 = self.inputState
          _with_0.mouseX, _with_0.mouseY = mp.get_mouse_pos()
          _with_0.mouseDead = true
          return _with_0
        end
      end)
      mp.add_forced_key_binding("mouse_leave", "mouse-leave", function()
        self.inputState.mouseInWindow = false
      end)
      mp.add_forced_key_binding("mouse_enter", "mouse-enter", function()
        self.inputState.mouseInWindow = true
      end)
      local displayDuration = settings['request-display-duration']
      local displayRequestTimer = mp.add_timeout(0, function() end)
      return mp.add_key_binding("tab", "request-display", function(event)
        if event.event == "down" or event.event == "press" then
          displayRequestTimer:kill()
          self.inputState.displayRequested = true
        end
        if event.event == "up" or event.event == "press" then
          displayRequestTimer = mp.add_timeout(displayDuration, function()
            self.inputState.displayRequested = false
          end)
        end
      end, {
        complex = true
      })
    end,
    __base = _base_0,
    __name = "OSDAggregator"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  OSDAggregator = _class_0
end
local AnimationQueue
do
  local _class_0
  local _base_0 = {
    registerAnimation = function(self, animation)
      self.animationCount = self.animationCount + 1
      animation.index = self.animationCount
      animation.isRegistered = true
      table.insert(self.list, animation)
      return self:startAnimation()
    end,
    unregisterAnimation = function(self, animation)
      return self:unregisterAnimationByIndex(animation.index)
    end,
    unregisterAnimationByIndex = function(self, index)
      self.animationCount = self.animationCount - 1
      local animation = table.remove(self.list, index)
      animation.index = nil
      animation.isRegistered = false
      if self.animationCount == 0 then
        return self:stopAnimation()
      end
    end,
    startAnimation = function(self)
      if self.animating then
        return 
      end
      self.timer:resume()
      self.animating = true
    end,
    stopAnimation = function(self)
      if not (self.animating) then
        return 
      end
      self.timer:kill()
      self.animating = false
    end,
    destroyAnimationStack = function(self)
      self:stopAnimation()
      local currentAnimation = self.list
      for i = self.animationCount, 1, -1 do
        self:unregisterAnimationByIndex(i)
      end
    end,
    animate = function(self)
      local currentTime = mp.get_time()
      for i = self.animationCount, 1, -1 do
        if self.list[i]:update(currentTime) then
          self:unregisterAnimationByIndex(i)
        end
      end
      return self.aggregator:forceUpdate()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, aggregator)
      self.aggregator = aggregator
      self.list = { }
      self.animationCount = 0
      self.animating = false
      self.timer = mp.add_periodic_timer(settings['redraw-period'], (function()
        local _base_1 = self
        local _fn_0 = _base_1.animate
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
      return self.timer:kill()
    end,
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
  AnimationQueue = _class_0
end
local Animation
do
  local _class_0
  local _base_0 = {
    update = function(self, currentTime)
      self.currentTime = currentTime
      local progress = math.max(0, math.min(1, (self.currentTime - self.startTime) * self.durationR))
      if progress == 1 then
        self.isFinished = true
      end
      if self.accel then
        progress = math.pow(progress, self.accel)
      end
      if self.isReversed then
        self.value = (1 - progress) * self.endValue + progress * self.initialValue
      else
        self.value = (1 - progress) * self.initialValue + progress * self.endValue
      end
      self:updateCb(self.value)
      if self.isFinished and self.finishedCb then
        self:finishedCb()
      end
      return self.isFinished
    end,
    interrupt = function(self, reverse, queue)
      self.finishedCb = nil
      if reverse ~= self.isReversed then
        self:reverse()
      end
      if not (self.isRegistered) then
        self:restart()
        return queue:registerAnimation(self)
      end
    end,
    reverse = function(self)
      self.isReversed = not self.isReversed
      self.startTime = 2 * self.currentTime - self.duration - self.startTime
      self.accel = 1 / self.accel
    end,
    restart = function(self)
      self.startTime = mp.get_time()
      self.currentTime = self.startTime
      self.isFinished = false
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
      self.startTime = mp.get_time()
      self.currentTime = self.startTime
      self.durationR = 1 / self.duration
      self.isFinished = (self.duration <= 0)
      self.isRegistered = false
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
local Subscriber
do
  local _class_0
  local active_height
  local _base_0 = {
    stringify = function(self)
      if not self.active then
        return ""
      end
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      return self.zone:reset(nil, h - active_height, w, h)
    end,
    hoverCondition = function(self, inputState)
      if inputState.displayRequested then
        return true
      end
      if not (inputState.mouseDead) then
        return self.zone:containsPoint(inputState.mouseX, inputState.mouseY)
      else
        return false
      end
    end,
    update = function(self, inputState)
      do
        local _with_0 = inputState
        local update = self.needsUpdate
        self.needsUpdate = false
        if (_with_0.mouseInWindow or _with_0.displayRequested) and self:hoverCondition(inputState) then
          if not (self.hovered) then
            update = true
            self.hovered = true
            self.animation:interrupt(false, self.animationQueue)
            self.active = true
          end
        else
          if self.hovered then
            update = true
            self.hovered = false
            self.animation:interrupt(true, self.animationQueue)
            self.animation.finishedCb = self.deactivate
          end
        end
        return update
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.zone = Rect(0, 0, 0, 0)
      self.hovered = false
      self.needsUpdate = false
      self.active = false
      self.deactivate = function()
        self.active = false
      end
    end,
    __base = _base_0,
    __name = "Subscriber"
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
  active_height = settings['hover-zone-height']
  Subscriber = _class_0
end
local TopSubscriber
do
  local _class_0
  local top_height
  local _parent_0 = Subscriber
  local _base_0 = {
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      return self.topZone:setSize(w)
    end,
    hoverCondition = function(self, inputState)
      if inputState.displayRequested then
        return true
      end
      if not (inputState.mouseDead) then
        return self.zone:containsPoint(inputState.mouseX, inputState.mouseY) or self.topZone:containsPoint(inputState.mouseX, inputState.mouseY)
      else
        return false
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.topZone = Rect(0, 0, 0, top_height)
    end,
    __base = _base_0,
    __name = "TopSubscriber",
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
  top_height = settings['top-hover-zone-height']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TopSubscriber = _class_0
end
local BarAccent
do
  local _class_0
  local barSize
  local _parent_0 = Subscriber
  local _base_0 = {
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.yPos = h - barSize
      self.sizeChanged = true
    end,
    changeBarSize = function(self, size)
      barSize = size
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BarAccent = _class_0
end
local ProgressBar
do
  local _class_0
  local minHeight, maxHeight
  local _parent_0 = Subscriber
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.line[2] = ([[%d,%d]]):format(0, h)
      self.line[8] = ([[%d 0 %d 1 0 1]]):format(w, w)
      return true
    end,
    animateHeight = function(self, animation, value)
      self.line[6] = ([[%g]]):format(value)
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      local position = mp.get_property_number('percent-pos', 0)
      if position ~= self.lastPosition then
        update = true
        self.line[4] = ([[%g]]):format(position)
        self.lastPosition = position
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = {
        ([[{\an1\bord0\c&H%s&\pos(]]):format(settings['bar-foreground']),
        0,
        [[)\fscx]],
        0.01,
        [[\fscy]],
        minHeight,
        [[\p1}m 0 0 l ]],
        0
      }
      self.lastPosition = 0
      self.animation = Animation(minHeight, maxHeight, 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animateHeight
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
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
  minHeight = settings['bar-height-inactive'] * 100
  maxHeight = settings['bar-height-active'] * 100
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBar = _class_0
end
local ProgressBarCache
do
  local _class_0
  local _parent_0 = Subscriber
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.line[2] = ([[%d,%d]]):format(0, h)
      self.line[8] = ([[%d 0 %d 1 0 1]]):format(w, w)
      return true
    end,
    animateHeight = function(self, animation, value)
      self.line[6] = ([[%g]]):format(value)
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      local totalSize = mp.get_property_number('file-size', 0)
      if totalSize ~= 0 then
        local position = mp.get_property_number('percent-pos', 0.001)
        local cacheUsed = mp.get_property_number('cache-used', 0) * 1024
        local networkCacheContribution = cacheUsed / totalSize
        local demuxerCacheDuration = mp.get_property_number('demuxer-cache-duration', 0)
        local fileDuration = mp.get_property_number('duration', 0.001)
        local demuxerCacheContribution = demuxerCacheDuration / fileDuration
        update = true
        self.line[4] = (networkCacheContribution + demuxerCacheContribution) * 100 + position
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      local minHeight = settings['bar-height-inactive'] * 100
      local maxHeight = settings['bar-height-active'] * 100
      self.line = {
        ([[{\an1\bord0\c&H%s&\pos(]]):format(settings['bar-cache-color']),
        0,
        [[)\fscx]],
        0.001,
        [[\fscy]],
        minHeight,
        [[\p1}m 0 0 l ]],
        0
      }
      self.animation = Animation(minHeight, maxHeight, 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animateHeight
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBarCache = _class_0
end
local ProgressBarBackground
do
  local _class_0
  local minHeight, maxHeight
  local _parent_0 = Subscriber
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.line[2] = ([[%d,%d]]):format(0, h)
      self.line[6] = ([[%d 0 %d 1 0 1]]):format(w, w)
      return true
    end,
    animateHeight = function(self, animation, value)
      self.line[4] = ([[%g]]):format(value)
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      return _class_0.__parent.__base.update(self, inputState)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = {
        ([[{\an1\bord0\c&H%s&\pos(]]):format(settings['bar-background']),
        0,
        [[)\fscy]],
        minHeight,
        [[\p1}m 0 0 l ]],
        0
      }
      self.animation = Animation(minHeight, maxHeight, 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animateHeight
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
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
  local self = _class_0
  minHeight = settings['bar-height-inactive'] * 100
  maxHeight = settings['bar-height-active'] * 100
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ProgressBarBackground = _class_0
end
local ChapterMarker
do
  local _class_0
  local minWidth, maxWidth, minHeight, maxHeight, maxHeightFrac, beforeColor, afterColor
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      self.line[2] = ([[%d,%d]]):format(math.floor(self.position * w), h)
      return true
    end,
    animateSize = function(self, value)
      self.line[4] = ([[%g]]):format((maxWidth - minWidth) * value + minWidth)
      self.line[6] = ([[%g]]):format((maxHeight * maxHeightFrac - minHeight) * value + minHeight)
    end,
    update = function(self, position)
      local update = false
      if not self.passed and (position > self.position) then
        self.line[8] = afterColor
        self.passed = true
        update = true
      elseif self.passed and (position < self.position) then
        self.line[8] = beforeColor
        self.passed = false
        update = true
      end
      return update
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, position, w, h)
      self.position = position
      self.line = {
        [[{\an2\bord0\p1\pos(]],
        ([[%d,%d]]):format(math.floor(self.position * w), h),
        [[)\fscx]],
        minWidth,
        [[\fscy]],
        minHeight,
        [[\c&H]],
        beforeColor,
        [[&}m 0 0 l 1 0 1 1 0 1]]
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
  minWidth = settings['chapter-marker-width'] * 100
  maxWidth = settings['chapter-marker-width-active'] * 100
  minHeight = settings['bar-height-inactive'] * 100
  maxHeight = settings['bar-height-active'] * 100
  maxHeightFrac = settings['chapter-marker-active-height-fraction']
  beforeColor = settings['chapter-marker-before']
  afterColor = settings['chapter-marker-after']
  ChapterMarker = _class_0
end
local Chapters
do
  local _class_0
  local minHeight
  local _parent_0 = Subscriber
  local _base_0 = {
    createMarkers = function(self, w, h)
      self.line = { }
      self.markers = { }
      local totalTime = mp.get_property_number('duration', 0.01)
      local chapters = mp.get_property_native('chapter-list', { })
      for _index_0 = 1, #chapters do
        local chapter = chapters[_index_0]
        local marker = ChapterMarker(chapter.time / totalTime, w, h)
        table.insert(self.markers, marker)
        table.insert(self.line, marker:stringify())
      end
    end,
    stringify = function(self)
      return table.concat(self.line, '\n')
    end,
    redrawMarker = function(self, i)
      self.line[i] = self.markers[i]:stringify()
    end,
    redrawMarkers = function(self)
      for i, marker in ipairs(self.markers) do
        self.line[i] = marker:stringify()
      end
    end,
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      for i, marker in ipairs(self.markers) do
        marker:updateSize(w, h)
        self.line[i] = marker:stringify()
      end
      return true
    end,
    animateSize = function(self, animation, value)
      for i, marker in ipairs(self.markers) do
        marker:animateSize(value)
        self.line[i] = marker:stringify()
      end
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      local currentPosition = mp.get_property_number('percent-pos', 0) * 0.01
      for i, marker in ipairs(self.markers) do
        if marker:update(currentPosition) then
          self:redrawMarker(i)
          update = true
        end
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = { }
      self.markers = { }
      self.animation = Animation(0, 1, 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animateSize
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
  minHeight = settings['bar-height-inactive'] * 100
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Chapters = _class_0
end
local TimeElapsed
do
  local _class_0
  local _parent_0 = BarAccent
  local _base_0 = {
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.line[2] = ([[%g,%g]]):format(self.position, self.yPos - settings['elapsed-bottom-margin'])
      return true
    end,
    animatePos = function(self, animation, value)
      self.position = value
      self.line[2] = ([[%g,%g]]):format(self.position, self.yPos - settings['elapsed-bottom-margin'])
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      if update or self.hovered then
        local timeElapsed = math.floor(mp.get_property_number('time-pos', 0))
        if timeElapsed ~= self.lastTime then
          update = true
          self.line[4] = ([[%d:%02d:%02d]]):format(math.floor(timeElapsed / 3600), math.floor((timeElapsed / 60) % 60), math.floor(timeElapsed % 60))
          self.lastTime = timeElapsed
        end
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      local offscreenPos = settings['elapsed-offscreen-pos']
      self.line = {
        ([[{\fn%s\bord2\fs%d\pos(]]):format(settings.font, settings['time-font-size']),
        ([[%g,0]]):format(offscreenPos),
        ([[)\c&H%s&\3c&H%s&\an1}]]):format(settings['elapsed-foreground'], settings['elapsed-background']),
        0
      }
      self.lastTime = -1
      self.position = offscreenPos
      self.animation = Animation(offscreenPos, settings['elapsed-left-margin'], 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animatePos
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.25)
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TimeElapsed = _class_0
end
local TimeRemaining
do
  local _class_0
  local _parent_0 = BarAccent
  local _base_0 = {
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.position = self.zone.w - self.animation.value
      self.line[2] = ([[%g,%g]]):format(self.position, self.yPos - settings['remaining-bottom-margin'])
      return true
    end,
    animatePos = function(self, animation, value)
      self.position = self.zone.w - value
      self.line[2] = ([[%g,%g]]):format(self.position, self.yPos - settings['remaining-bottom-margin'])
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      if update or self.hovered then
        local timeRemaining = math.floor(mp.get_property_number('playtime-remaining', 0))
        if timeRemaining ~= self.lastTime then
          update = true
          self.line[4] = ([[–%d:%02d:%02d]]):format(math.floor(timeRemaining / 3600), math.floor((timeRemaining / 60) % 60), math.floor(timeRemaining % 60))
          self.lastTime = timeRemaining
        end
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = {
        ([[{\fn%s\bord2\fs%d\pos(]]):format(settings.font, settings['time-font-size']),
        [[-100,0]],
        ([[)\c&H%s&\3c&H%s&\an3}]]):format(settings['remaining-foreground'], settings['remaining-background']),
        0
      }
      local offscreenPos = settings['remaining-offscreen-pos']
      self.lastTime = -1
      self.position = offscreenPos
      self.animation = Animation(offscreenPos, settings['remaining-right-margin'], 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animatePos
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.25)
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  TimeRemaining = _class_0
end
local HoverTime
do
  local _class_0
  local rightMargin, leftMargin
  local _parent_0 = BarAccent
  local _base_0 = {
    animateAlpha = function(self, animation, value)
      self.line[4] = ([[%02X]]):format(value)
      self.needsUpdate = true
    end,
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.yposChanged = true
    end,
    hoverCondition = function(self, inputState)
      do
        local _with_0 = inputState
        return _with_0.mouseInWindow and not _with_0.mouseDead and self.zone:containsPoint(_with_0.mouseX, _with_0.mouseY)
      end
    end,
    update = function(self, inputState)
      do
        local _with_0 = inputState
        local update = _class_0.__parent.__base.update(self, inputState)
        if update or self.hovered then
          if _with_0.mouseX ~= self.lastX or self.sizeChanged then
            self.line[2] = ("%g,%g"):format(math.min(self.zone.w - rightMargin, math.max(leftMargin, _with_0.mouseX)), self.yPos - settings['hover-time-bottom-margin'])
            self.sizeChanged = false
            self.lastX = _with_0.mouseX
            local hoverTime = mp.get_property_number('duration', 0) * _with_0.mouseX / self.zone.w
            if hoverTime ~= self.lastTime and (self.hovered or self.animation.isRegistered) then
              update = true
              self.line[6] = ([[%d:%02d:%02d]]):format(math.floor(hoverTime / 3600), math.floor((hoverTime / 60) % 60), math.floor(hoverTime % 60))
              self.lastTime = hoverTime
            end
          end
        end
        return update
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = {
        ([[{\fn%s\bord2\fs%d\pos(]]):format(settings.font, settings['hover-time-font-size']),
        [[-100,0]],
        ([[)\c&H%s&\3c&H%s&\an2\alpha&H]]):format(settings['hover-time-foreground'], settings['hover-time-background']),
        [[FF]],
        [[&}]],
        0
      }
      self.lastTime = 0
      self.lastX = -1
      self.position = -100
      self.animation = Animation(255, 0, 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animateAlpha
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  HoverTime = _class_0
end
local PauseIndicator
do
  local _class_0
  local scaleMultiplier
  local _base_0 = {
    stringify = function(self)
      return table.concat(self.line)
    end,
    updateSize = function(self, w, h)
      w, h = 0.5 * w, 0.5 * h
      self.line[6] = ([[%g,%g]]):format(w, h)
      self.line[14] = ([[%g,%g]]):format(w, h)
      return true
    end,
    update = function()
      return true
    end,
    animate = function(self, animation, value)
      local scale = (value * 50 + 100) * scaleMultiplier
      local scaleStr = ([[\fscx%g\fscy%g]]):format(scale, scale)
      local alphaStr = ('%02X'):format(value * value * 255)
      self.line[2] = scaleStr
      self.line[10] = scaleStr
      self.line[4] = alphaStr
      self.line[12] = alphaStr
    end,
    destroy = function(self, animation)
      return self.aggregator:removeSubscriber(self.aggregatorIndex)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, queue, aggregator, paused)
      self.aggregator = aggregator
      local w, h = mp.get_osd_size()
      w, h = 0.5 * w, 0.5 * h
      self.line = {
        ([[{\an5\bord0\c&H%s&]]):format(settings['pause-indicator-background']),
        [[\fscx0\fscy0]],
        [[\alpha&H]],
        0,
        [[&\pos(]],
        ([[%g,%g]]):format(w, h),
        [[)\p1}]],
        0,
        ([[{\an5\bord0\c&H%s&]]):format(settings['pause-indicator-foreground']),
        [[\fscx0\fscy0]],
        [[\alpha&H]],
        0,
        [[&\pos(]],
        ([[%g,%g]]):format(w, h),
        [[)\p1}]],
        0
      }
      if paused then
        self.line[8] = "m 15 0 l 60 0 b 75 0 75 0 75 15 l 75 60 b 75 75 75 75 60 75 l 15 75 b 0 75 0 75 0 60 l 0 15 b 0 0 0 0 15 0 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20\n"
        self.line[16] = [[m 0 0 m 75 75 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20]]
      else
        self.line[8] = "m 15 0 l 60 0 b 75 0 75 0 75 15 l 75 60 b 75 75 75 75 60 75 l 15 75 b 0 75 0 75 0 60 l 0 15 b 0 0 0 0 15 0 m 23 18 l 23 57 58 37.5\n"
        self.line[16] = [[m 0 0 m 75 75 m 23 18 l 23 57 58 37.5]]
      end
      do
        local _base_1 = self
        local _fn_0 = _base_1.animate
        self.animationCb = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      do
        local _base_1 = self
        local _fn_0 = _base_1.destroy
        self.finishedCb = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      queue:registerAnimation(Animation(0, 1, 0.3, self.animationCb, self.finishedCb))
      return self.aggregator:addSubscriber(self)
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
  local self = _class_0
  scaleMultiplier = settings['pause-indicator-scale']
  PauseIndicator = _class_0
end
local Playlist
do
  local _class_0
  local _parent_0 = TopSubscriber
  local _base_0 = {
    animatePos = function(self, animation, value)
      self.line[2] = ([[%g,%g]]):format(settings['title-left-margin'], value)
      self.needsUpdate = true
    end,
    updatePlaylistInfo = function(self)
      local title = mp.get_property('media-title', '')
      local position = mp.get_property_number('playlist-pos-1', 1)
      local total = mp.get_property_number('playlist-count', 1)
      local playlistString = (total > 1) and ('%d/%d - '):format(position, total) or ''
      if settings['title-print-to-cli'] then
        log.warn("Playing: %s%q", playlistString, title)
      end
      self.line[4] = ([[%s%s]]):format(playlistString, title)
      self.needsUpdate = true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      local offscreenPos = settings['title-offscreen-pos']
      self.line = {
        ([[{\fn%s\bord2\fs%d\pos(]]):format(settings.font, settings['title-font-size']),
        ([[%g,%g]]):format(settings['title-left-margin'], offscreenPos),
        ([[)\c&H%s&\3c&H%s&\an7}]]):format(settings['title-foreground'], settings['title-background']),
        0
      }
      self.animation = Animation(offscreenPos, settings['title-top-margin'], 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animatePos
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.25)
    end,
    __base = _base_0,
    __name = "Playlist",
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
  Playlist = _class_0
end
local SystemTime
do
  local _class_0
  local offscreen_position, top_margin, time_format
  local _parent_0 = TopSubscriber
  local _base_0 = {
    updateSize = function(self, w, h)
      _class_0.__parent.__base.updateSize(self, w, h)
      self.position = self.zone.w - self.animation.value
      self.line[2] = ([[%g,%g]]):format(self.position, top_margin)
      return true
    end,
    animatePos = function(self, animation, value)
      self.position = self.zone.w - value
      self.line[2] = ([[%g,%g]]):format(self.position, top_margin)
      self.needsUpdate = true
    end,
    update = function(self, inputState)
      local update = _class_0.__parent.__base.update(self, inputState)
      if update or self.hovered then
        local systemTime = os.time()
        if systemTime ~= self.lastTime then
          update = true
          self.line[4] = os.date(time_format, systemTime)
          self.lastTime = systemTime
        end
      end
      return update
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, animationQueue)
      self.animationQueue = animationQueue
      _class_0.__parent.__init(self)
      self.line = {
        ([[{\fn%s\bord2\fs%d\pos(]]):format(settings.font, settings['system-time-font-size']),
        [[-100,0]],
        ([[)\c&H%s&\3c&H%s&\an9}]]):format(settings['system-time-foreground'], settings['system-time-background']),
        0
      }
      self.lastTime = -1
      self.position = offscreen_position
      self.animation = Animation(offscreen_position, settings['system-time-right-margin'], 0.25, (function()
        local _base_1 = self
        local _fn_0 = _base_1.animatePos
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), nil, 0.25)
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
  offscreen_position = settings['system-time-offscreen-pos']
  top_margin = settings['system-time-top-margin']
  time_format = settings['system-time-format']
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SystemTime = _class_0
end
local aggregator = OSDAggregator()
local animationQueue = AnimationQueue(aggregator)
local chapters, progressBar, barCache, barBackground, elapsedTime, remainingTime, hoverTime
if settings['enable-bar'] then
  progressBar = ProgressBar(animationQueue)
  barCache = ProgressBarCache(animationQueue)
  barBackground = ProgressBarBackground(animationQueue)
  aggregator:addSubscriber(barBackground)
  aggregator:addSubscriber(barCache)
  aggregator:addSubscriber(progressBar)
  mp.add_key_binding("mouse_btn0", "seek-to-mouse", function()
    local x, y = mp.get_mouse_pos()
    return mp.add_timeout(0.001, function()
      if not aggregator.inputState.mouseDead and progressBar.zone:containsPoint(x, y) then
        return mp.commandv("seek", x * 100 / progressBar.zone.w, "absolute-percent+" .. tostring(settings['seek-precision']))
      end
    end)
  end)
  mp.add_key_binding("c", "toggle-inactive-bar", function()
    return aggregator:toggleInactiveVisibility()
  end)
end
if settings['enable-chapter-markers'] then
  chapters = Chapters(animationQueue)
  aggregator:addSubscriber(chapters)
end
if settings['enable-elapsed-time'] then
  elapsedTime = TimeElapsed(animationQueue)
  aggregator:addSubscriber(elapsedTime)
end
if settings['enable-remaining-time'] then
  remainingTime = TimeRemaining(animationQueue)
  aggregator:addSubscriber(remainingTime)
end
if settings['enable-hover-time'] then
  hoverTime = HoverTime(animationQueue)
  aggregator:addSubscriber(hoverTime)
end
local playlist = nil
if settings['enable-title'] then
  playlist = Playlist(animationQueue)
  aggregator:addSubscriber(playlist)
end
if settings['enable-system-time'] then
  local systemTime = SystemTime(animationQueue)
  aggregator:addSubscriber(systemTime)
end
local notFrameStepping = false
if settings['pause-indicator'] then
  local PauseIndicatorWrapper
  PauseIndicatorWrapper = function(event, paused)
    if notFrameStepping then
      return PauseIndicator(animationQueue, aggregator, paused)
    else
      if paused then
        notFrameStepping = true
      end
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
  mp.unregister_event(initDraw)
  local width, height = mp.get_osd_size()
  if chapters then
    chapters:createMarkers(width, height)
  end
  if playlist then
    playlist:updatePlaylistInfo()
  end
  notFrameStepping = true
  local duration = mp.get_property('duration')
  if not (streamMode or duration) then
    if progressBar then
      aggregator:removeSubscriber(progressBar.aggregatorIndex)
      aggregator:removeSubscriber(barCache.aggregatorIndex)
      aggregator:removeSubscriber(barBackground.aggregatorIndex)
    end
    if chapters then
      aggregator:removeSubscriber(chapters.aggregatorIndex)
    end
    if hoverTime then
      aggregator:removeSubscriber(hoverTime.aggregatorIndex)
    end
    if remainingTime then
      aggregator:removeSubscriber(remainingTime.aggregatorIndex)
    end
    if elapsedTime then
      elapsedTime:changeBarSize(0)
      aggregator:forceResize()
    end
    streamMode = true
  elseif streamMode and duration then
    if progressBar then
      aggregator:addSubscriber(barBackground)
      aggregator:addSubscriber(barCache)
      aggregator:addSubscriber(progressBar)
    end
    if chapters then
      aggregator:addSubscriber(chapters)
    end
    if hoverTime then
      aggregator:addSubscriber(hoverTime)
    end
    if remainingTime then
      aggregator:addSubscriber(remainingTime)
    end
    if elapsedTime then
      elapsedTime:changeBarSize(settings['bar-height-active'])
    end
    aggregator:forceResize()
    streamMode = false
  end
  return mp.command('script-message-to osc disable-osc')
end
local fileLoaded
fileLoaded = function()
  return mp.register_event('playback-restart', initDraw)
end
return mp.register_event('file-loaded', fileLoaded)
