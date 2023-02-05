require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  if level then parameters.level = level end

  if parameters.level == 1 then
    config.maleFrames = config.upgradeMatrixParameters.level1.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level1.femaleFrames
  elseif parameters.level == 2 then
    config.maleFrames = config.upgradeMatrixParameters.level2.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level2.femaleFrames
  elseif parameters.level == 3 then
    config.maleFrames = config.upgradeMatrixParameters.level3.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level3.femaleFrames
  elseif parameters.level == 4 then
    config.maleFrames = config.upgradeMatrixParameters.level4.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level4.femaleFrames
  elseif parameters.level == 5 then
    config.maleFrames = config.upgradeMatrixParameters.level5.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level5.femaleFrames
  elseif parameters.level == 6 then
    config.maleFrames = config.upgradeMatrixParameters.level6.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level6.femaleFrames
  elseif parameters.level == 7 then
    config.maleFrames = config.upgradeMatrixParameters.level7.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level7.femaleFrames
  elseif parameters.level == 8 then
    config.maleFrames = config.upgradeMatrixParameters.level8.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level8.femaleFrames
  elseif parameters.level == 9 then
    config.maleFrames = config.upgradeMatrixParameters.level9.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level9.femaleFrames
  elseif parameters.level == 10 then
    config.maleFrames = config.upgradeMatrixParameters.level10.maleFrames
    config.femaleFrames = config.upgradeMatrixParameters.level10.femaleFrames
  end

  return config, parameters
end
