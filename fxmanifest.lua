--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

fx_version "cerulean"
games { "gta5" }
name "rig_weather"
version "0.2.0"
description "Persistent seasonal weather system for RIG (FiveM)."
license "Apache 2.0"
author "Case"
lua54 "yes"

files {
    "locales/*.json",
}

shared_script "init.lua"

client_script "src/client/main.lua"

server_scripts {
    "configs/*.lua",
    "src/server/modules/*.lua",
    "src/server/commands.lua",
    "src/server/main.lua"
}

dependency "rig"