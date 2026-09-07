--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @module configs.buckets
--- @description Stores all bucket settings and configurations

return {
    [0] = {
        label = 'Main World', -- Display name for the bucket
        bucket = 0, -- GTA routing bucket ID (0 = main world)
        dynamic_weather = true, -- Enable automatic weather cycling
        weather = "CLEAR", -- Static weather type (used if dynamic_weather = false)
        dynamic_time = true, -- Enable automatic time progression
        hour = 12, -- Static hour (0-23, used if dynamic_time = false)
        minute = 0, -- Static minute (0-59, used if dynamic_time = false)
        season = "SPRING", -- Current season (WINTER, SPRING, SUMMER, AUTUMN)
        freeze_weather = false -- Freeze weather/wind changes when true
    },

    --- You can add support for more buckets below

    --[[
    [1] = {
        label = 'VIP World',
        dynamic_weather = true,
        weather = "EXTRASUNNY",
        dynamic_time = true,
        hour = 14,
        minute = 0,
        season = "SUMMER",
        freeze_weather = false
    },
    ]]
}