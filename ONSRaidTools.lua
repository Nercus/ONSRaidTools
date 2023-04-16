local AddOnName, _ = ...
local ONSRaidTools = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceEvent-3.0")


local LDBIcon = LibStub("LibDBIcon-1.0")
local defaults = {
    global = {
        position = {
            x = 0,
            y = 0,
            point = "CENTER",
            relativePoint = "CENTER"
        },
        options = {
            minimap = {
                hide = false
            }
        }
    }
}

local ONSRaidToolsBroker = LibStub("LibDataBroker-1.1"):NewDataObject(AddOnName, {
    type = "data source",
    icon = "Interface\\Addons\\ONSRaidTools\\assets\\ons_icon",
    OnClick = function(self, button)
        ONSRaidTools:ToggleFrame()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(AddOnName)
        tooltip:AddLine("Click to toggle the main window")
    end
})


function ONSRaidTools:OnEnable()
    C_Timer.After(1, function()
        self:ToggleFrame()
    end)
    ONSRaidTools:RegisterEvent("MODIFIER_STATE_CHANGED")
end

function ONSRaidTools:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ONSRaidToolsDB", defaults)

    LDBIcon:Register(AddOnName, ONSRaidToolsBroker, self.db.global.options.minimap)
end

function ONSRaidTools:UpdateMinimapButton()
    if (self.db.global.options.minimap.hide) then
        LDBIcon:Hide(AddOnName)
    else
        LDBIcon:Show(AddOnName)
    end
end

function ONSRaidTools:ToggleMinimapButton()
    if (self.db.global.options.minimap.hide) then
        self.db.global.options.minimap.hide = false
    else
        self.db.global.options.minimap.hide = true
    end
    self:UpdateMinimapButton()
end

SLASH_ONS1 = "/ons"

SlashCmdList["ONS"] = function(msg)
    if msg == "settings" or msg == "config" then
        -- TODO: Add options
    elseif msg == "minimap" then
        ONSRaidTools:ToggleMinimapButton()
    else
        ONSRaidTools:ToggleFrame()
    end
end
