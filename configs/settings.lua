--[[
----------------------------------------
RIG Weather (built for RIG-FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_weather
License: https://github.com/rig-fivem/rig_weather/blob/main/LICENSE
----------------------------------------
]]

--- @module configs.settings
--- @description Contains all configurable weather and environmental settings

return {

    --- @section Save Directory

    --- Where weather files should be saved
    save_directory = "src/server/saves",

    --- @section Timers
    
    --- Real-world minutes per GTA in-game day
    real_minutes_per_gta_day = 42,

    --- How often weather changes should happen in minutes
    update_interval = 7,

    --- Weather transition time in seconds
    transition_time = 10, 
    
    --- @section Seasonal Weather
    
    --- Weather types available for each season
    seasonal_weather = {
        WINTER = { "SNOW", "SNOWLIGHT", "BLIZZARD", "XMAS", "CLOUDS", "OVERCAST", "SNOW_HALLOWEEN" },
        SPRING = { "CLEAR", "EXTRASUNNY", "CLOUDS", "RAIN", "OVERCAST", "CLEARING", "NEUTRAL" },
        SUMMER = { "CLEAR", "EXTRASUNNY", "CLOUDS", "RAIN", "THUNDER", "NEUTRAL" },
        AUTUMN = { "CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST", "RAIN", "CLEARING", "FOGGY", "SMOG", "HALLOWEEN", "RAIN_HALLOWEEN" }
    },
    
    --- @section Sunrise/Sunset Times
    
    --- Sunrise and sunset times for each weather type
    sunrise_sunset = {
        CLEAR = { sunrise = 6, sunset = 18 },
        EXTRASUNNY = { sunrise = 6, sunset = 18 },
        CLOUDS = { sunrise = 6.25, sunset = 17.75 },
        OVERCAST = { sunrise = 6.5, sunset = 17.5 },
        RAIN = { sunrise = 7, sunset = 17 },
        THUNDER = { sunrise = 7, sunset = 17 },
        CLEARING = { sunrise = 6.5, sunset = 17.5 },
        FOGGY = { sunrise = 7, sunset = 16.75 },
        SMOG = { sunrise = 7, sunset = 16.75 },
        SNOW = { sunrise = 8, sunset = 16 },
        SNOWLIGHT = { sunrise = 8, sunset = 16 },
        BLIZZARD = { sunrise = 9, sunset = 15 },
        XMAS = { sunrise = 8, sunset = 16 },
        HALLOWEEN = { sunrise = 7, sunset = 17 },
        NEUTRAL = { sunrise = 6, sunset = 18 },
        RAIN_HALLOWEEN = { sunrise = 7, sunset = 17 },
        SNOW_HALLOWEEN = { sunrise = 8, sunset = 16 }
    },
    
    --- @section Temperature Modifiers
    
    --- Temperature modifiers for each weather type
    temperature_modifiers = {
        CLEAR = { base = 18, night_mult = 0.6 },
        EXTRASUNNY = { base = 22, night_mult = 0.65 },
        CLOUDS = { base = 16, night_mult = 0.7 },
        OVERCAST = { base = 14, night_mult = 0.75 },
        RAIN = { base = 12, night_mult = 0.8 },
        THUNDER = { base = 10, night_mult = 0.85 },
        CLEARING = { base = 13, night_mult = 0.75 },
        FOGGY = { base = 11, night_mult = 0.8 },
        SMOG = { base = 15, night_mult = 0.78 },
        SNOW = { base = -5, night_mult = 0.9 },
        SNOWLIGHT = { base = -2, night_mult = 0.88 },
        BLIZZARD = { base = -10, night_mult = 0.95 },
        XMAS = { base = -3, night_mult = 0.92 },
        HALLOWEEN = { base = 14, night_mult = 0.8 },
        NEUTRAL = { base = 16, night_mult = 0.7 },
        RAIN_HALLOWEEN = { base = 12, night_mult = 0.85 },
        SNOW_HALLOWEEN = { base = -4, night_mult = 0.92 }
    },
    
    --- @section Seasonal Temperature Offsets
    
    --- Temperature offset modifier for each season
    seasonal_temp_offset = {
        WINTER = -8,
        SPRING = 2,
        SUMMER = 10,
        AUTUMN = -2
    },
    
    --- @section Weather Effects
    
    --- Rain, snow, and wind effects for each weather type
    weather_effects = {
        CLEAR = { rain = 0.0, snow = 0.0, wind_min = 5, wind_max = 10 },
        EXTRASUNNY = { rain = 0.0, snow = 0.0, wind_min = 3, wind_max = 8 },
        CLOUDS = { rain = 0.0, snow = 0.0, wind_min = 5, wind_max = 12 },
        OVERCAST = { rain = 0.0, snow = 0.0, wind_min = 8, wind_max = 15 },
        RAIN = { rain_min = 30, rain_max = 80, snow = 0.0, wind_min = 10, wind_max = 18 },
        THUNDER = { rain_min = 60, rain_max = 100, snow = 0.0, wind_min = 15, wind_max = 25 },
        CLEARING = { rain_min = 5, rain_max = 20, snow = 0.0, wind_min = 8, wind_max = 14 },
        FOGGY = { rain = 0.0, snow = 0.0, wind_min = 3, wind_max = 10 },
        SMOG = { rain = 0.0, snow = 0.0, wind_min = 2, wind_max = 8 },
        SNOW = { rain = 0.0, snow_min = 40, snow_max = 80, wind_min = 8, wind_max = 16 },
        SNOWLIGHT = { rain = 0.0, snow_min = 20, snow_max = 50, wind_min = 5, wind_max = 12 },
        BLIZZARD = { rain = 0.0, snow_min = 80, snow_max = 100, wind_min = 18, wind_max = 30 },
        XMAS = { rain = 0.0, snow_min = 30, snow_max = 60, wind_min = 5, wind_max = 12 },
        HALLOWEEN = { rain = 0.0, snow = 0.0, wind_min = 8, wind_max = 16 },
        NEUTRAL = { rain = 0.0, snow = 0.0, wind_min = 4, wind_max = 10 },
        RAIN_HALLOWEEN = { rain_min = 40, rain_max = 90, snow = 0.0, wind_min = 12, wind_max = 20 },
        SNOW_HALLOWEEN = { rain = 0.0, snow_min = 50, snow_max = 85, wind_min = 10, wind_max = 18 }
    },
    
    --- @section Time Constants
    
    --- Hour ranges for different times of day
    time_ranges = {
        daytime = { start = 6, stop = 18 },
        nighttime = { start = 20, stop = 6 },
        midday = { start = 11, stop = 13 }
    },
    
    --- @section Randomization
    
    --- Weather change probability (0-100)
    weather_change_probability = 5,
    
    --- Wind direction change range (-degrees to +degrees)
    wind_direction_change = { min = -15, max = 15 }
}