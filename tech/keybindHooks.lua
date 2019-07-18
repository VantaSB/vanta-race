if hook then return end

local hooks = {}

local function loop(hook, ...)
  local ret
  for k,v in pairs(hook) do
    if v then
      local r = k(...)
      if type(ret) == "nil" then ret = r end
    end
  end
  return ret
end

local function createHook(name)
  if hooks[name] then return hooks[name] end
  local hook = {}
  hooks[name] = hook

  if _ENV[name] then
    local old = _ENV[name]
    _ENV[name] = function(...)
      old(...)
      return loop(hook, ...)
    end
  else
    _ENV[name] = function(...)
      return loop(hook, ...)
    end
  end

  return hook
end

function hook(name, func)
  local hook = createHook(name)
  hook[func] = true
end
