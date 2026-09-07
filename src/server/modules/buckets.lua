--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @module buckets
--- @file src/server/modules/buckets.lua
--- @description Handles server side bucket functions

--- @section Imports

local _buckets = require("configs.buckets")

local _utils = require("src.server.modules.utils")

--- @section Initialsiation

local m = {}

function m.get_bucket_id(bucket_identifier)
    if type(bucket_identifier) == "number" then
        return bucket_identifier
    end
    
    for bucket_name, bucket_config in pairs(_buckets) do
        if bucket_name == bucket_identifier or bucket_config.label == bucket_identifier then
            return bucket_config.bucket
        end
    end
    return nil
end

function m.resolve_bucket_id(bucket_identifier)
    if type(bucket_identifier) == "number" then
        return core.bucket_environments[bucket_identifier] and bucket_identifier or nil
    end
    
    for bucket_name, bucket_config in pairs(_buckets) do
        if bucket_name == bucket_identifier or bucket_config.label == bucket_identifier then
            return bucket_config.bucket
        end
    end
    return nil
end

function m.apply_bucket_config(bucket_id, config)
    if config.mode then
        SetRoutingBucketEntityLockdownMode(bucket_id, config.mode)
    end
    if config.population_enabled ~= nil then
        SetRoutingBucketPopulationEnabled(bucket_id, config.population_enabled)
    end
end

function m.sync_bucket_environment(bucket_id)
    local env_data = _utils.build_environment_data(bucket_id)
    local players = GetPlayers()

    for _, player in ipairs(players) do
        if GetPlayerRoutingBucket(player) == bucket_id then
            TriggerClientEvent("rig_weather:client:set_environment", player, env_data)
        end
    end
end

return m