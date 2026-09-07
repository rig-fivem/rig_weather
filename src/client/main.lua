--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @file src/client/main.lua
--- @description Main client side handling, just updates the client settings nothing else.

--- @section Events

RegisterNetEvent("rig_weather:client:set_environment", function(weather_data)
    if not weather_data then return end

    SetWeatherTypeOvertimePersist(weather_data.weather, weather_data.transition_time)
    NetworkOverrideClockTime(weather_data.hour, daweather_datata.minute, 0)
    SetRainLevel(weather_data.rain_level)
    SetSnowLevel(weather_data.snow_level)
    SetWindSpeed(weather_data.wind_speed)
end)