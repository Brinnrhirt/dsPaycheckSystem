Config = {}
Config.ReceiveInCash = true -- If its in true, you'll recieve it on cash (wallet), false it will become on bank.
Config.UseEsExtendedType = true
Config.NPCS =  {
    {
        model = "cs_bankman",
        coords = vector3(-552.53454589844,-191.21502685547,37.219646453857),  
        heading = 209.4,
        animDict = "amb@world_human_cop_idles@male@idle_b",
        animName = "idle_e"
    },
    -- {
    --      Model = "cs_bankman", -- ped name
    --      Coords = vector3(0,0,0),  -- coords
    --      Heading = 0.0 -- heading
    --      animDict = "", -- https://pastebin.com/6mrYTdQv
    --      animName = "" -- https://alexguirre.github.io/animations-list/
    -- }
}

Config.Blips = {
    {title="Cityhall", colour=5, id=525, x = -552.86126708984, y = -191.00524902344, z = 37.219673156738},
}

--	Your Notification System
RegisterNetEvent('brinn_paycheck:notification')
AddEventHandler('brinn_paycheck:notification', function(msg,type)
--	Types used: (error | success)
--	print(msg)
--	exports['mythic_notify']:SendAlert(msg,type)
        exports.brinnNotify:SendNotification({                    
            text = '<b><i class="fas fa-bell"></i> NOTIFICACIÓN</span></b></br><span style="color: #a9a29f;">'..msg..'',
            type = type,
            timeout = 3000,
            layout = "centerRight"
        })
end)
