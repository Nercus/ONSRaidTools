local AddOnName, components = ...
local ONSRaidTools = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")


-- default active raid
ONSRaidTools.activeRaid = "DFS2"

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


local elapsed = 0;
local delay = 2;
local r, g, b = 0.8, 0, 1;
local r2, g2, b2 = random(2) - 1, random(2) - 1, random(2) - 1;
local colorOverlay = CreateFrame("Frame");

-- use the idea from weakauras: https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAuras/WeakAuras.lua#L1017
local ONSRaidToolsBroker
ONSRaidToolsBroker = LibStub("LibDataBroker-1.1"):NewDataObject(AddOnName, {
    type = "data source",
    icon = "Interface\\Addons\\ONSRaidTools\\assets\\onsIcon",
    OnClick = function(self, button)
        ONSRaidTools:ToggleFrame()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(AddOnName)
        tooltip:AddLine("Click to toggle the main window")
        colorOverlay:SetScript("OnUpdate", function(self, elaps)
            elapsed = elapsed + elaps;
            if (elapsed > delay) then
                elapsed = elapsed - delay;
                r, g, b = r2, g2, b2;
                r2, g2, b2 = random(2) - 1, random(2) - 1, random(2) - 1;
            end
            ONSRaidToolsBroker.r = r + (r2 - r) * elapsed / delay;
            ONSRaidToolsBroker.g = g + (g2 - g) * elapsed / delay;
            ONSRaidToolsBroker.b = b + (b2 - b) * elapsed / delay;
        end);
    end,
    OnLeave = function(self)
        colorOverlay:SetScript("OnUpdate", nil);
        GameTooltip:Hide();
    end,
    r = 0.6,
    g = 0,
    b = 1
})





local ONSOptionsTable = {
    name = AddOnName,
    type = "group",
    args = {
        description = {
            name = "ONSRaidTools is a tool to help you with your raiding experience.",
            width = "full",
            type = "description",
            order = 0
        },
        -- toggle minimap button
        minimap = {
            name = "Minimap Button",
            width = "full",
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
            width = "full",
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
            width = "full",
            type = "range",
            min = 0.5,
            max = 2,
            step = 0.1,
            get = function()
                return ONSRaidTools.db.global.options.scale
            end,
            set = function(_, value)
                ONSRaidTools.db.global.options.scale = value
                ONSRaidTools.mainWindow:SetScale(value)
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
    ONSRaidTools:RegisterEvent("MODIFIER_STATE_CHANGED")
    ONSRaidTools:RegisterEvent("CHAT_MSG_ADDON")
    AceConfig:RegisterOptionsTable(AddOnName, ONSOptionsTable)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddOnName, AddOnName)
    C_ChatInfo.RegisterAddonMessagePrefix(AddOnName)
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

function ONSRaidTools:Print(msg)
    if not msg then
        return
    end
    local prefix = "|cff00ff00ONSRaidTools|r: "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

function ONSRaidTools:GetBossNameByModuleAndIndex(moduleName, index)
    if not moduleName or not index then return end
    index = tonumber(index)
    local module = self.modules[moduleName]
    if not module then return end
    local bosses = module.bosses
    if not bosses then return end
    if not bosses[index] then return end
    return bosses[index].name
end

function ONSRaidTools:CHAT_MSG_ADDON(event, prefix, msg)
    if prefix ~= AddOnName then return end
    local bossNum, imageNum = strsplit(",", msg)
    if not bossNum or not imageNum then return end
    bossNum = tonumber(bossNum)
    imageNum = tonumber(imageNum)
    local bossName = ONSRaidTools:GetBossNameByModuleAndIndex(ONSRaidTools.activeRaid, bossNum)
    if not bossName then
        bossName = "Boss" .. tostring(bossNum)
    end
    self:Print(string.format("Received image %d for %s", imageNum, bossName))

    self:LoadEncounter(bossNum, ONSRaidTools.activeRaid, imageNum)
end

-- /ons send <bossnum> <imagenum>
function ONSRaidTools:SendImageToRaid(bossNum, imageNum)
    local isLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)
    if not isLeader then
        self:Print("You need to be the raid leader to send images")
        return
    end
    if not bossNum then self:Print("No boss number provided") end
    if not imageNum then self:Print("No image number provided") end

    local bossName = ONSRaidTools:GetBossNameByModuleAndIndex(ONSRaidTools.activeRaid, bossNum)
    if not bossName then
        bossName = "Boss" .. tostring(bossNum)
    end
    self:Print(string.format("Sending image %d for %s", imageNum, bossName))
    local msg = string.format("%s,%s", bossNum, imageNum)
    C_ChatInfo.SendAddonMessage(AddOnName, msg, "RAID")
end

SLASH_ONS1 = "/ons"

SlashCmdList["ONS"] = function(msg)
    if msg == "settings" or msg == "config" then
        ONSRaidTools:OpenSettings()
    elseif string.match(msg, "send") then
        local _, _, bossnum, imagenum = string.find(msg, "send%s+(%d+)%s+(%d+)")
        if not bossnum or not imagenum then
            ONSRaidTools:Print("Usage: /ons send <bossnum> <imagenum>")
            return
        end
        ONSRaidTools:SendImageToRaid(bossnum, imagenum)
    elseif msg == "minimap" then
        ONSRaidTools:ToggleMinimapButton()
    elseif msg == "DFS1" or msg == "DFS2" then
        ONSRaidTools:Print(string.format("Loaded module %s", msg))
        ONSRaidTools.activeRaid = msg
        ONSRaidTools:SetActiveRaidToSelectView()
    else
        ONSRaidTools:ToggleFrame()
    end
end
