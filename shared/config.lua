Config = {}

Config.CarWashEnabled = true
Config.RepairKitEnabled = false
Config.RepairBayEnabled = true

Config.EnableVehicleHealthInPayment = {
    engine = true,
    body = true
}

Config.CarWashAnims = {
    dict = 'amb@world_human_maid_clean@base',
    clip = 'base'
}

Config.RepairKitAnims = {
    dict = 'mini@repair',
    clip = 'fixing_a_ped'
}

Config.MoneyItem = 'cash'
Config.ProgressType = 'circle' -- circle / bar

Config.RepairBays = {
    {location = vec3(449.48, -972.62, 25.71), name = 'Repair Bay', sprite = 402, blipColour = 0, price = 5000, range = 5, blip = true}, -- blip == blip enabled? -- name == the blip name -- blip == the blip (found at https://docs.fivem.net/docs/game-references/blips/) -- blipColour == Find at the same place as the blip icon -- Price == the price it costts
}

Config.CarWashes = {
    {location = vec3(23.62, -1391.97, 29.33), name = 'Car Wash', sprite = 100, blipColour = 0, price = 2000, range = 5, blip = true}
}
