--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @module fs
--- @file src/server/modules/fs.lua
--- @description Handles file system stuff; save / load

--- @section Imports

local _settings = require("configs.settings")

--- @section Constants

local PERSIST_DIR = _settings and _settings.save_directory or "src/server/saves"

--- @section Initialisation

local m = {}

--- @section Save

function m.save_bucket_state(bucket_id)
    local env_data = core.bucket_environments[bucket_id]
    if not env_data then return end

    local file_content = "return {\n"
    file_content = file_content .. string.format("    weather = %q,\n", env_data.weather)
    file_content = file_content .. string.format("    hour = %d,\n", math.floor(env_data.hour or 0))
    file_content = file_content .. string.format("    minute = %d,\n", math.floor(env_data.minute or 0))
    file_content = file_content .. string.format("    day = %d,\n", math.floor(env_data.day or 0))
    file_content = file_content .. string.format("    month = %d,\n", math.floor(env_data.month or 0))
    file_content = file_content .. string.format("    year = %d,\n", math.floor(env_data.year or 0))
    file_content = file_content .. string.format("    season = %q,\n", env_data.season)
    file_content = file_content .. "}\n"

    SaveResourceFile(GetCurrentResourceName(), PERSIST_DIR .. "/bucket_" .. bucket_id .. ".lua", file_content, -1)
end

function m.save_all_bucket_states(buckets_cfg)
    for bucket_id, _ in pairs(buckets_cfg) do
        m.save_bucket_state(bucket_id)
    end
end

--- @section Load

function m.load_bucket_state(bucket_id, bucket_config)
    local file_path = PERSIST_DIR .. "/bucket_" .. bucket_id .. ".lua"
    local file_content = LoadResourceFile(GetCurrentResourceName(), file_path)

    if file_content then
        local success, loaded_data = pcall(function()
            return load(file_content, "@@" .. file_path, "t", {})()
        end)

         if success and loaded_data then
            core.bucket_environments[bucket_id].weather = loaded_data.weather ~= nil and loaded_data.weather or bucket_config.weather
            core.bucket_environments[bucket_id].hour = loaded_data.hour ~= nil and loaded_data.hour or bucket_config.hour
            core.bucket_environments[bucket_id].minute = loaded_data.minute ~= nil and loaded_data.minute or bucket_config.minute
            core.bucket_environments[bucket_id].day = loaded_data.day ~= nil and loaded_data.day or 1
            core.bucket_environments[bucket_id].month = loaded_data.month ~= nil and loaded_data.month or 1
            core.bucket_environments[bucket_id].year = loaded_data.year ~= nil and loaded_data.year or 2026
            core.bucket_environments[bucket_id].season = loaded_data.season ~= nil and loaded_data.season or bucket_config.season

            log("info", ("Loaded bucket %d state from disk"):format(bucket_id))
            return
        end
    end

    m.save_bucket_state(bucket_id)
end

return m