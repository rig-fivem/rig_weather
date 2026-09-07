--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @module utils
--- @file src/server/modules/utils.lua
--- @description Handles server side weather utilities

--- @section Imports

local _settings = require("configs.settings")

--- @section Initilisation

local m = {}

--- @section Functions

function m.get_current_season(month)
    local seasons = {
        [0] = "WINTER", [1] = "WINTER", [2] = "WINTER",
        [3] = "SPRING", [4] = "SPRING", [5] = "SPRING",
        [6] = "SUMMER", [7] = "SUMMER", [8] = "SUMMER",
        [9] = "AUTUMN", [10] = "AUTUMN", [11] = "AUTUMN"
    }
    return seasons[month] or "Unknown"
end

function m.get_sunrise_sunset(weather)
    return _settings.sunrise_sunset[weather] or { sunrise = 6, sunset = 18 }
end

function m.is_daytime(hour)
    local daytime = _settings.time_ranges.daytime
    return hour >= daytime.start and hour < daytime.stop
end

function m.is_night(hour)
    local nighttime = _settings.time_ranges.nighttime
    return hour >= nighttime.start or hour < nighttime.stop
end

function m.is_midday(hour)
    local midday = _settings.time_ranges.midday
    return hour >= midday.start and hour <= midday.stop
end

function m.calculate_temperature(hour, weather, season)
    local modifiers = _settings.temperature_modifiers[weather] or { base = 15, night_mult = 0.8 }
    local seasonal_offset = _settings.seasonal_temp_offset[season] or 0
    local base_temp = modifiers.base + seasonal_offset

    local hour_mult = 1.0

    if hour >= 6 and hour < 12 then
        hour_mult = 0.7 + (hour - 6) / 6 * 0.3
    elseif hour >= 12 and hour < 18 then
        hour_mult = 1.0
    elseif hour >= 18 and hour < 21 then
        hour_mult = 1.0 - (hour - 18) / 3 * 0.35
    else
        hour_mult = modifiers.night_mult
    end

    local final_temp = base_temp * hour_mult

    return math.floor(final_temp * 10) / 10
end

function m.update_weather_effects(env_data, weather)
    local effects = _settings.weather_effects[weather] or { rain = 0.0, snow = 0.0, wind_min = 5, wind_max = 10 }
    
    env_data.rain_level = effects.rain or (effects.rain_min and math.random(effects.rain_min, effects.rain_max) / 100 or 0.0)
    env_data.snow_level = effects.snow or (effects.snow_min and math.random(effects.snow_min, effects.snow_max) / 100 or 0.0)
    env_data.wind_speed = math.random(effects.wind_min, effects.wind_max) / 10
end

function m.build_environment_data(bucket_id)
    local env_data = core.bucket_environments[bucket_id]
    local sunrise_sunset = m.get_sunrise_sunset(env_data.weather)
    local temperature = m.calculate_temperature(env_data.hour, env_data.weather, env_data.season)

    return {
        weather = env_data.weather,
        hour = env_data.hour,
        minute = env_data.minute,
        day = env_data.day,
        month = env_data.month,
        year = env_data.year,
        season = env_data.season,
        rain_level = env_data.rain_level,
        snow_level = env_data.snow_level,
        wind_speed = env_data.wind_speed,
        wind_direction = env_data.wind_direction,
        sunrise = sunrise_sunset.sunrise,
        sunset = sunrise_sunset.sunset,
        temperature = temperature,
        transition_time = _settings.transition_time,
        is_daytime = m.is_daytime(env_data.hour),
        is_night = m.is_night(env_data.hour),
        is_midday = m.is_midday(env_data.hour)
    }
end

return m