--------------------------------------------
-- Dragonflight S1 - Vault of the Incarnates
--------------------------------------------
local AddOnName, _ = ...
local core = LibStub("AceAddon-3.0"):GetAddon(AddOnName)
local module = core:NewModule("DFS1")



module.bosses = {
    [1] = {
        ["icon"] = 4630361,
        ["name"] = "Eranog"
    },
    [2] = {
        ["icon"] = 4630366,
        ["name"] = "Terros"
    },
    [3] = {
        ["icon"] = 4630359,
        ["name"] = "Council"
    },
    [4] = {
        ["icon"] = 4630365,
        ["name"] = "Sennarth"
    },
    [5] = {
        ["icon"] = 4630367,
        ["name"] = "Dathea"
    },
    [6] = {
        ["icon"] = 4630362,
        ["name"] = "Kurog"
    },
    [7] = {
        ["icon"] = 4630360,
        ["name"] = "Diurna"
    },
    [8] = {
        ["icon"] = 4630364,
        ["name"] = "Raszageth"
    },
}



module.images = {
    [1] = {
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\1_1_Boss.png",
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\1_2_Boss.png",
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\1_3_Boss.png",
    },
    [3] = {
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\3_1_Boss.png",
    },
    [4] = {
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\4_1_Boss.png",
    },
    [5] = {
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\5_1_Boss.png",
    },
    [7] = {
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\7_1_Boss.png",
        "Interface\\Addons\\ONSImageView\\images\\df_s1\\7_2_Boss.png",
    }
}
