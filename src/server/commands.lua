--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @file src/server/commands.lua
--- @description Handles all commands exported into RIG command system.

--- @section Imports

local _buckets = require("src.server.modules.buckets")
local _utils = require("src.server.modules.utils")
local _settings = require("configs.settings")

--- @section Helpers

local function supports_rain(weather)
    local fx = _settings.weather_effects[weather]
    if not fx then return false end
    return (fx.rain_min and fx.rain_min > 0) or (fx.rain and fx.rain > 0)
end

local function supports_snow(weather)
    local fx = _settings.weather_effects[weather]
    if not fx then return false end
    return (fx.snow_min and fx.snow_min > 0) or (fx.snow and fx.snow > 0)
end

--- @section Setters

exports.rig:register_command({
    name = "rig:setweather",
    ace = { "rig.dev", "rig.admin" },
    help = "Set the active weather type for a routing bucket",
    params = {
        { name = "type", help = "Weather type (e.g. clear, rain, xmas, extrasunny)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local weather_type = args[1]
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not weather_type then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.weather_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        local upper_weather = weather_type:upper()
        if not _settings.weather_effects[upper_weather] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.invalid_weather_type", upper_weather),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].weather = upper_weather
        _utils.update_weather_effects(core.bucket_environments[bucket_id], upper_weather)
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.weather_set", upper_weather, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_weather_changed", GetPlayerName(source), upper_weather, bucket_id))
    end
})

exports.rig:register_command({
    name = "rig:settime",
    ace = { "rig.dev", "rig.admin" },
    help = "Set the in-game clock (hour and minute) for a routing bucket",
    params = {
        { name = "hour", help = "Hour of the day (0-23)" },
        { name = "minute", help = "Minute of the hour (0-59)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])
        local bucket_id = _buckets.get_bucket_id(args[3] or 0)

        if not hour or not minute or hour < 0 or hour > 23 or minute < 0 or minute > 59 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.time_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].hour = hour
        core.bucket_environments[bucket_id].minute = minute
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.time_set", hour, minute, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_time_changed", GetPlayerName(source), hour, minute, bucket_id))
    end
})

exports.rig:register_command({
    name = "rig:setseason",
    ace = { "rig.dev", "rig.admin" },
    help = "Set the current season for a routing bucket",
    params = {
        { name = "season", help = "Season name (winter, spring, summer, autumn)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local season = args[1] and args[1]:upper() or nil
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not season or not _settings.seasonal_weather[season] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.season_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].season = season
        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.season_set", season, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_season_changed", GetPlayerName(source), season, bucket_id))
    end
})

exports.rig:register_command({
    name = "rig:setrain",
    ace = { "rig.dev", "rig.admin" },
    help = "Set rain intensity for a routing bucket",
    params = {
        { name = "level", help = "Rain intensity (0.0 to 1.0)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local level = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not level or level < 0 or level > 1 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.rain_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        local env = core.bucket_environments[bucket_id]
        if not env then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        if level > 0 and not supports_rain(env.weather) then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.rain_incompatible_weather", env.weather),
                type = "error",
                icon = "fa-solid fa-exclamation-triangle"
            })
            return
        end

        env.rain_level = level
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.rain_set", level, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })
    end
})

exports.rig:register_command({
    name = "rig:setsnow",
    ace = { "rig.dev", "rig.admin" },
    help = "Set snow accumulation level for a routing bucket",
    params = {
        { name = "level", help = "Snow level (0.0 to 1.0)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local level = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not level or level < 0 or level > 1 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.snow_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        local env = core.bucket_environments[bucket_id]
        if not env then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        if level > 0 and not supports_snow(env.weather) then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.snow_incompatible_weather", env.weather),
                type = "error",
                icon = "fa-solid fa-exclamation-triangle"
            })
            return
        end

        env.snow_level = level
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.snow_set", level, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })
    end
})

exports.rig:register_command({
    name = "rig:setwind",
    ace = { "rig.dev", "rig.admin" },
    help = "Set wind speed for a routing bucket",
    params = {
        { name = "speed", help = "Wind speed value (0 or higher)" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local speed = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not speed or speed < 0 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.wind_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].wind_speed = speed
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.wind_set", speed, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })
    end
})

--- @section Toggles

exports.rig:register_command({
    name = "rig:freeze",
    ace = { "rig.dev", "rig.admin" },
    help = "Freeze or unfreeze automated weather progression for a routing bucket",
    params = {
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local bucket_id = _buckets.get_bucket_id(args[1] or 0)

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].freeze_weather = not core.bucket_environments[bucket_id].freeze_weather
        local state = core.bucket_environments[bucket_id].freeze_weather and "frozen" or "unfrozen"

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.weather_frozen", state, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_freeze_toggled", GetPlayerName(source), state, bucket_id))
    end
})

exports.rig:register_command({
    name = "rig:dynamic",
    ace = { "rig.dev", "rig.admin" },
    help = "Toggle dynamic weather or time cycles on or off for a routing bucket",
    params = {
        { name = "mode", help = "Target cycle mode: 'weather' or 'time'" },
        { name = "state", help = "State setting: 'on' or 'off'" },
        { name = "bucket", help = "(Optional) Routing bucket ID. Defaults to 0." }
    },
    handler = function(source, args, raw)
        local mode = args[1] and args[1]:lower() or nil
        local state = args[2] and args[2]:lower() or nil
        local bucket_id = _buckets.get_bucket_id(args[3] or 0)

        if not mode or not state or (mode ~= "weather" and mode ~= "time") or (state ~= "on" and state ~= "off") then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.dynamic_usage"),
                type = "info",
                icon = "fa-solid fa-circle-info"
            })
            return
        end

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        local enabled = state == "on"

        if mode == "weather" then
            core.bucket_environments[bucket_id].dynamic_weather = enabled
        else
            core.bucket_environments[bucket_id].dynamic_time = enabled
        end

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.dynamic_toggled", mode, state, bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_dynamic_toggled", GetPlayerName(source), mode, state, bucket_id))
    end
})