--------------------------------------------------
-- Dragonflight S2 - Aberrus, The Shadow Crucible
--------------------------------------------------
local AddOnName, _ = ...
local core = LibStub("AceAddon-3.0"):GetAddon(AddOnName)
local module = core:NewModule("DFS2")

-- Icons are taken from the PTR might need reviewing when the patch is live.

module.bosses = {
    [1] = {
        ["icon"] = 5161745,
        ["name"] = "Kazzara"
    },
    [2] = {
        ["icon"] = 5161744,
        ["name"] = "Amalgamation"
    },
    [3] = {
        ["icon"] = 5161744,
        ["name"] = "Experiments"
    },
    [4] = {
        ["icon"] = 5161751,
        ["name"] = "Zaqali"
    },
    [5] = {
        ["icon"] = 5161749,
        ["name"] = "Rashok"
    },
    [6] = {
        ["icon"] = 5161752,
        ["name"] = "Zskarn"
    },
    [7] = {
        ["icon"] = 5161746,
        ["name"] = "Magmorax"
    },
    [8] = {
        ["icon"] = 5161747,
        ["name"] = "Neltharion"
    },
    [9] = {
        ["icon"] = 5161750,
        ["name"] = "Sarkareth"
    },
}



-- Placeholder Images - File names will stay the same I will just update the artwork for each boss later.
module.images = {
    [1] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\1_1_Kazzara.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\1_2_Kazzara.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\1_3_Kazzara.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\1_4_Kazzara.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\1_5_Kazzara.png",
    },
    [2] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\2_1_Molgoth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\2_2_Molgoth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\2_3_Molgoth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\2_4_Molgoth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\2_5_Molgoth.png",
    },
    [3] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\3_1_Dracthyr.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\3_2_Dracthyr.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\3_3_Dracthyr.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\3_4_Dracthyr.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\3_5_Dracthyr.png",
    },
    [4] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\4_1_Zaqali.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\4_2_Zaqali.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\4_3_Zaqali.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\4_4_Zaqali.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\4_5_Zaqali.png",
    },
    [5] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\5_1_Rashok.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\5_2_Rashok.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\5_3_Rashok.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\5_4_Rashok.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\5_5_Rashok.png",
    },
    [6] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\6_1_Zskarn.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\6_2_Zskarn.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\6_3_Zskarn.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\6_4_Zskarn.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\6_5_Zskarn.png",
    },
    [7] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\7_1_Magmorax.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\7_2_Magmorax.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\7_3_Magmorax.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\7_4_Magmorax.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\7_5_Magmorax.png",
    },
    [8] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\8_1_Neltharion.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\8_2_Neltharion.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\8_3_Neltharion.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\8_4_Neltharion.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\8_5_Neltharion.png",
    },
    [9] = {
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\9_1_Sarkareth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\9_2_Sarkareth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\9_3_Sarkareth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\9_4_Sarkareth.png",
        "Interface\\Addons\\ONSRaidTools\\images\\df_s2\\9_5_Sarkareth.png",
    },
}
