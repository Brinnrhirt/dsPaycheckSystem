Config = {}
Config.Locale = 'en'
Config.Framework = 'QBCore' -- ESX or QBCore
Config.ESXOldVersion = false
Config.ReceiveInCash = true -- If its in true, you'll recieve it on cash (wallet), false it will become on bank.
Config.UseFrameworkTrigger = true -- IF true, enable the trigger so you can place it in your es_extended or qb-core, false it will disable it
Config.WithdrawQuantity = true
Config.Timeout = 5000 -- Timeout for the citizen, briefly, 5 secs.
Config.Target = false -- To use the Target System, if you have this on true, put Config.DrawText in false
Config.TargetSystem = 'qb-target' -- Config your exports target (qtarget, ox_target, qb-target or custom)
Config.DrawText = true -- To use the DrawText System, if you have this on true, put the Config.Target in false
Config.Menu = 'qb' -- (esx, qb or ox_lib)
Config.ProgressBar = 'qb' -- (qb, rprogress or ox_lib)
Config.NPCS =  {
    [1] = {
        model = "cs_bankman",
        coords = vector3(-545.43, -203.78, 37.22),  
        heading = 209.15,
        animDict = "amb@world_human_cop_idles@male@idle_b",
        animName = "idle_e"
    },
    [2] = {
        model = "cs_bankman",
        coords = vector3(-537.84, -218.92, 36.65),  
        heading = 25.48,
        animDict = "amb@world_human_cop_idles@male@idle_b",
        animName = "idle_e"
    },
    -- [3] = {
    --      model = "cs_bankman", -- https://wiki.rage.mp/index.php?title=Peds
    --      coords = vector3(0,0,0),  -- coords
    --      heading = 0.0 -- heading
    --      animDict = "", -- https://pastebin.com/6mrYTdQv
    --      animName = "" -- https://alexguirre.github.io/animations-list/
    -- }
}

Config.Blips = {
    {title="Cityhall", colour=5, id=525, x = -552.86126708984, y = -191.00524902344, z = 37.219673156738},
}

--	Your Notification System
RegisterNetEvent('dsPaycheckSystem:notification')
AddEventHandler('dsPaycheckSystem:notification', function(msg,type)
--	Types used: (error | success)
	--exports['mythic_notify']:DoHudText(type,msg)
    -- ESX.ShowNotification(msg)
    TriggerEvent('QBCore:Notify', msg, type)
end)
