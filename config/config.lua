Config = {}
Config.Locale = 'en'
Config.ESXOldVersion = false
Config.ReceiveInCash = true -- If its in true, you'll recieve it on cash (wallet), false it will become on bank.
Config.UseEsExtendedType = true -- IF true, enable the trigger so you can place it in your es_extended, false it will disable it
Config.WithdrawQuantity = true
Config.Timeout = 5000 -- Timeout for the citizen, briefly, 5 secs.
Config.Target = true -- To use the Target System, if you have this on true, put Config.DrawText in false
Config.TargetSystem = 'qtarget' -- Config your exports target (qtarget, ox_target or custom)
Config.DrawText = false -- To use the DrawText System, if you have this on true, put the Config.Target in false
Config.Menu = 'ox_lib' -- (esx or ox_lib)
Config.NPCS =  {
    {
        model = "cs_bankman",
        coords = vector3(-552.90313720703,-192.07667541504,37.219646453857),  
        heading = 209.4,
        animDict = "amb@world_human_cop_idles@male@idle_b",
        animName = "idle_e"
    },
    -- {
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
    exports.brinnNotify:SendNotification({                    
        text = '<b><i class="fas fa-bell"></i> NOTIFICACIÓN</span></b></br><span style="color: #a9a29f;">'..msg..'',
        type = type,
        timeout = 3000,
        layout = "centerRight"
    })
end)
