--- @script server
--- Handles syncing comprehensive weather and environmental data across all players per bucket.

--- @section Imports

local _settings = require("configs.settings")
local _buckets_cfg = require("configs.buckets")

local _fs = require("src.server.modules.fs")
local _utils = require("src.server.modules.utils")
local _buckets = require("src.server.modules.buckets")

--- @section Constants

local GTA_MINUTES_PER_REAL_SECOND = (24 * 60) / (_settings.real_minutes_per_gta_day * 60)
local SYNC_TIMER = _settings.update_interval * 60 * 1000

--- @section Variables

local last_sync_time = GetGameTimer()

--- @section Initialisation

for bucket_name, bucket_config in pairs(_buckets_cfg) do
    local bucket_id = bucket_config.bucket
    local init_season = bucket_config.season
    local init_weather = bucket_config.weather

    if bucket_config.dynamic_weather then
        local allowed = _settings.seasonal_weather[init_season]
        init_weather = allowed[math.random(1, #allowed)]
    end

    core.bucket_environments[bucket_id] = {
        season = init_season,
        weather = init_weather,
        hour = bucket_config.dynamic_time and math.random(0, 23) or bucket_config.hour,
        minute = bucket_config.dynamic_time and math.random(0, 59) or bucket_config.minute,
        day = math.random(1, 30),
        month = math.random(0, 11),
        year = 2026,
        rain_level = 0.0,
        snow_level = 0.0,
        wind_speed = math.random(1, 15) / 10,
        wind_direction = math.random(0, 360),
        temperature = 20.0,
        dynamic_weather = bucket_config.dynamic_weather,
        dynamic_time = bucket_config.dynamic_time,
        freeze_weather = bucket_config.freeze_weather
    }

    local env_data = core.bucket_environments[bucket_id]
    local effects = _settings.weather_effects[env_data.weather] or { rain = 0.0, snow = 0.0, wind_min = 5, wind_max = 10 }
    env_data.rain_level = effects.rain or (effects.rain_min and math.random(effects.rain_min, effects.rain_max) / 100 or 0.0)
    env_data.snow_level = effects.snow or (effects.snow_min and math.random(effects.snow_min, effects.snow_max) / 100 or 0.0)
    env_data.wind_speed = math.random(effects.wind_min, effects.wind_max) / 10

    _fs.load_bucket_state(bucket_id, bucket_config)
end

--- @section Functions

local function sync_player_weather(source, bucket_id)
    local env_data = _utils.build_environment_data(bucket_id)
    if env_data then
        TriggerClientEvent("rig_weather:client:set_environment", source, env_data)
    else
        log("error", ("Environment data missing for bucket %d"):format(bucket_id))
    end
end

local function advance_bucket_time(bucket_id, milliseconds_passed)
    local env_data = core.bucket_environments[bucket_id]

    if not env_data.dynamic_time then
        return
    end

    local gta_minutes_passed = (milliseconds_passed / 1000) * GTA_MINUTES_PER_REAL_SECOND
    env_data.minute = env_data.minute + gta_minutes_passed

    while env_data.minute >= 60 do
        env_data.minute = env_data.minute - 60
        env_data.hour = env_data.hour + 1

        if env_data.hour >= 24 then
            env_data.hour = 0
            env_data.day = env_data.day + 1

            if env_data.day > 30 then
                env_data.day = 1
                env_data.month = (env_data.month + 1) % 12
            end
        end
    end
end

local function get_bucket_environment(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if not bucket_id then return nil end

    local env_data = core.bucket_environments[bucket_id]
    if not env_data then return nil end

    local sunrise_sunset = _utils.get_sunrise_sunset(env_data.weather)
    local temperature = _utils.calculate_temperature(env_data.hour, env_data.weather, env_data.season)

    return {
        bucket_id = bucket_id,
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
        temperature = temperature,
        sunrise = sunrise_sunset.sunrise,
        sunset = sunrise_sunset.sunset,
        is_daytime = _utils.is_daytime(env_data.hour),
        is_night = _utils.is_night(env_data.hour),
        is_midday = _utils.is_midday(env_data.hour),
        dynamic_weather = env_data.dynamic_weather,
        dynamic_time = env_data.dynamic_time,
        freeze_weather = env_data.freeze_weather
    }
end

local function get_weather(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].weather
    end
    return nil
end

local function get_temperature(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        local env_data = core.bucket_environments[bucket_id]
        return _utils.calculate_temperature(env_data.hour, env_data.weather, env_data.season)
    end
    return nil
end

local function get_time(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        local env_data = core.bucket_environments[bucket_id]
        return { hour = env_data.hour, minute = env_data.minute }
    end
    return nil
end

local function get_season(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].season
    end
    return nil
end

local function get_rain_level(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].rain_level
    end
    return nil
end

local function get_snow_level(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].snow_level
    end
    return nil
end

local function get_wind_speed(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].wind_speed
    end
    return nil
end

local function get_wind_direction(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].wind_direction
    end
    return nil
end

local function is_daytime(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return _utils.is_daytime(core.bucket_environments[bucket_id].hour)
    end
    return nil
end

local function is_night(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return _utils.is_night(core.bucket_environments[bucket_id].hour)
    end
    return nil
end

local function is_midday(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return _utils.is_midday(core.bucket_environments[bucket_id].hour)
    end
    return nil
end

local function get_sunrise_sunset(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return _utils.get_sunrise_sunset(core.bucket_environments[bucket_id].weather)
    end
    return nil
end

local function is_weather_frozen(bucket_identifier)
    local bucket_id = _buckets.resolve_bucket_id(bucket_identifier or 0)
    if bucket_id and core.bucket_environments[bucket_id] then
        return core.bucket_environments[bucket_id].freeze_weather
    end
    return nil
end

local function get_bucket_ids()
    local ids = {}
    for bucket_id, _ in pairs(core.bucket_environments) do
        table.insert(ids, bucket_id)
    end
    return ids
end

--- @section RIG Events

AddEventHandler("rig:server:player_bucket_changed", function(source, bucket_id)
    if not core.bucket_environments[bucket_id] then return end
    sync_player_weather(source, bucket_id)
end)

--- @section CFX Events

AddEventHandler("onResourceStop", function(resource_name)
    if resource_name ~= GetCurrentResourceName() then return end
    _fs.save_all_bucket_states(_buckets_cfg)
    log("info", "Saved all bucket states on resource stop")
end)

--- @section Update Thread

CreateThread(function()
    while true do
        Wait(SYNC_TIMER)

        local current_time = GetGameTimer()
        local time_passed = current_time - last_sync_time
        last_sync_time = current_time

        for bucket_name, bucket_config in pairs(_buckets_cfg) do
            local bucket_id = bucket_config.bucket
            local env_data = core.bucket_environments[bucket_id]

            advance_bucket_time(bucket_id, time_passed)

            if env_data.dynamic_weather then
                local current_season = _utils.get_current_season(env_data.month)
                if env_data.season ~= current_season then
                    env_data.season = current_season
                end

                if not env_data.freeze_weather and math.random(1, 100) <= WEATHER_CONFIG.weather_change_probability then
                    local allowed = WEATHER_CONFIG.seasonal_weather[current_season]
                    env_data.weather = allowed[math.random(1, #allowed)]
                    _utils.update_weather_effects(env_data, env_data.weather)
                    log("info", ("Weather changed to %s in bucket '%s'"):format(env_data.weather, bucket_config.label))
                end

                if not env_data.freeze_weather then
                    local wind_change = WEATHER_CONFIG.wind_direction_change
                    env_data.wind_direction = (env_data.wind_direction + math.random(wind_change.min, wind_change.max)) % 360
                end
            end

            _buckets.sync_bucket_environment(bucket_id)
            _fs.save_bucket_state(bucket_id)
        end
    end
end)

--- @section API Exports

exports("sync_player_weather", sync_player_weather)
exports("get_bucket_environment", get_bucket_environment)
exports("get_weather", get_weather)
exports("get_temperature", get_temperature)
exports("get_time", get_time)
exports("get_season", get_season)
exports("get_rain_level", get_rain_level)
exports("get_snow_level", get_snow_level)
exports("get_wind_speed", get_wind_speed)
exports("get_wind_direction", get_wind_direction)
exports("is_daytime", is_daytime)
exports("is_night", is_night)
exports("is_midday", is_midday)
exports("get_sunrise_sunset", get_sunrise_sunset)
exports("is_weather_frozen", is_weather_frozen)
exports("get_bucket_ids", get_bucket_ids)