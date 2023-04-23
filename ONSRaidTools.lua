local AddOnName, components = ...
local ONSRaidTools = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- FIXME: don't package that
ONSRaidTools.DEV = true


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
            },
            opacity = 1,
            scale = 1
        },
        loadedEncounter = {
            images = {},
            info = {}
        }
    }
}



local ONSRaidToolsBroker = LibStub("LibDataBroker-1.1"):NewDataObject(AddOnName, {
    type = "data source",
    icon = "Interface\\Addons\\ONSRaidTools\\assets\\onsIcon",
    OnClick = function(self, button)
        ONSRaidTools:ToggleFrame()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(AddOnName)
        tooltip:AddLine("Click to toggle the main window")
    end
})





local ONSOptionsTable = {
    name = AddOnName,
    type = "group",
    args = {
        description = {
            name = "ONSRaidTools is a tool to help you with your raiding experience.",
            type = "description",
            order = 0
        },
        -- toggle minimap button
        minimap = {
            name = "Minimap Button",
            type = "toggle",
            get = function()
                return not ONSRaidTools.db.global.options.minimap.hide
            end,
            set = function(_, value)
                ONSRaidTools.db.global.options.minimap.hide = not value
                ONSRaidTools:UpdateMinimapButton()
            end
        },
        -- opacity slider -> range
        opacity = {
            name = "Opacity",
            type = "range",
            min = 0.3,
            max = 1,
            step = 0.1,
            get = function()
                return ONSRaidTools.db.global.options.opacity
            end,
            set = function(_, value)
                ONSRaidTools.db.global.options.opacity = value
                ONSRaidTools.mainWindow:SetAlpha(value)
            end
        },
        -- scale slider -> range
        scale = {
            name = "Scale",
            type = "range",
            min = 0.5,
            max = 2,
            step = 0.1,
            get = function()
                return ONSRaidTools.db.global.options.scale
            end,
            set = function(_, value)
                -- FIXME: changing the scale and reloading moves the window
                ONSRaidTools.db.global.options.scale = value
                ONSRaidTools.mainWindow:SetScale(value)
                ONSRaidTools.mainWindow:StartMoving()
                ONSRaidTools.mainWindow:StopMovingOrSizing()
                local point, _, relativePoint, xOfs, yOfs = ONSRaidTools.mainWindow:GetPoint()
                print("A", point, relativePoint, xOfs, yOfs)
                if point and relativePoint and xOfs and xOfs then
                    ONSRaidTools.db.global.position = {
                        point = point,
                        relativePoint = relativePoint,
                        x = xOfs,
                        y = yOfs
                    }
                end
            end
        },
    }
}


function ONSRaidTools:LoadOptionsValues()
    for _, option in pairs(ONSOptionsTable.args) do
        if option.get and option.set then
            local value = option.get()
            if value ~= nil then
                option.set(nil, value)
            end
        end
    end
end

function ONSRaidTools:OnEnable()
    if self.DEV then
        C_Timer.After(1, function()
            self:ToggleFrame()
            ViragDevTool:AddData(components)
        end)
    end
    ONSRaidTools:RegisterEvent("MODIFIER_STATE_CHANGED")
    AceConfig:RegisterOptionsTable(AddOnName, ONSOptionsTable)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddOnName, AddOnName)
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

function ONSRaidTools:OpenSettings()
    if InterfaceOptionsFrame ~= nil then
        InterfaceOptionsFrame:Show()
    end
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

SLASH_ONS1 = "/ons"

SlashCmdList["ONS"] = function(msg)
    if msg == "settings" or msg == "config" then
        ONSRaidTools:OpenSettings()
    elseif msg == "minimap" then
        ONSRaidTools:ToggleMinimapButton()
    else
        ONSRaidTools:ToggleFrame()
    end
end
