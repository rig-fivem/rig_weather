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

--- @section Setters

exports.rig:register_command({
    name = "rig:setweather",
    ace = { "rig.dev", "rig.admin" },
    help = "Set weather for a bucket",
    params = {
        { name = "type", help = "Weather type" },
        { name = "bucket", help = "Bucket ID (optional)" }
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

        if not core.bucket_environments[bucket_id] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.bucket_not_found", bucket_id),
                type = "error",
                icon = "fa-solid fa-times-circle"
            })
            return
        end

        core.bucket_environments[bucket_id].weather = weather_type:upper()
        _utils.update_weather_effects(core.bucket_environments[bucket_id], weather_type:upper())
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.weather_set", weather_type:upper(), bucket_id),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })

        log("info", locale("debug.admin_weather_changed", GetPlayerName(source), weather_type:upper(), bucket_id))
    end
})

exports.rig:register_command({
    name = "rig:settime",
    ace = { "rig.dev", "rig.admin" },
    help = "Set time for a bucket",
    params = {
        { name = "hour", help = "Hour (0-23)" },
        { name = "minute", help = "Minute (0-59)" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])
        local bucket_id = _buckets.get_bucket_id(args[3] or 0)

        if not hour or not minute or hour < 0 or hour > 23 or minute < 0 or minute > 59 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.time_usage"),
                type = "inform",
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
    help = "Set season for a bucket",
    params = {
        { name = "season", help = "Season name" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local season = args[1] and args[1]:upper() or nil
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not season or not _settings.seasonal_weather[season] then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.season_usage"),
                type = "inform",
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
    help = "Set rain level (0.0-1.0)",
    params = {
        { name = "level", help = "Rain level 0.0-1.0" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local level = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not level or level < 0 or level > 1 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.rain_usage"),
                type = "inform",
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

        core.bucket_environments[bucket_id].rain_level = level
        _buckets.sync_bucket_environment(bucket_id)

        exports.rig:notify(source, {
            header = "Weather",
            message = locale("commands.rain_set", level, bucket_it),
            type = "success",
            icon = "fa-solid fa-check-circle"
        })
    end
})

exports.rig:register_command({
    name = "rig:setsnow",
    ace = { "rig.dev", "rig.admin" },
    help = "Set snow level (0.0-1.0)",
    params = {
        { name = "level", help = "Snow level 0.0-1.0" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local level = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not level or level < 0 or level > 1 then
            exports.rig:notify(source, {
                header = "Weather",
                message = "Usage: /rig:setsnow <0.0-1.0> [bucket]",
                type = "inform",
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

        core.bucket_environments[bucket_id].snow_level = level
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
    help = "Set wind speed",
    params = {
        { name = "speed", help = "Wind speed" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local speed = tonumber(args[1])
        local bucket_id = _buckets.get_bucket_id(args[2] or 0)

        if not speed or speed < 0 then
            exports.rig:notify(source, {
                header = "Weather",
                message = locales("commands.wind_usage"),
                type = "inform",
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
    help = "Freeze/unfreeze weather for a bucket",
    params = {
        { name = "bucket", help = "Bucket ID (optional)" }
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
    help = "Toggle dynamic weather or time",
    params = {
        { name = "mode", help = "weather | time" },
        { name = "state", help = "on | off" },
        { name = "bucket", help = "Bucket ID (optional)" }
    },
    handler = function(source, args, raw)
        local mode = args[1]
        local state = args[2]
        local bucket_id = _buckets.get_bucket_id(args[3] or 0)

        if not mode or not state or (mode ~= "weather" and mode ~= "time") or (state ~= "on" and state ~= "off") then
            exports.rig:notify(source, {
                header = "Weather",
                message = locale("commands.dynamic_usage"),
                type = "inform",
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