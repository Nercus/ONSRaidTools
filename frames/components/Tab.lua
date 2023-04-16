ONSRaidToolsTab = {}

local tabsBackdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}


function ONSRaidToolsTab:OnLoad()
    self.bg:SetBackdrop(tabsBackdrop)
    self.bg:SetBackdropColor(0, 0, 0, 0.7)
    self.bg:SetBackdropBorderColor(0, 0, 0, 1)
end

function ONSRaidToolsTab:SetActive()
    self:SetAlpha(1)
    self.bg:SetBackdropBorderColor(DARKYELLOW_FONT_COLOR.r, DARKYELLOW_FONT_COLOR.g, DARKYELLOW_FONT_COLOR.b, 1)
end

function ONSRaidToolsTab:SetInactive()
    self:SetAlpha(0.5)
    self.bg:SetBackdropBorderColor(0, 0, 0, 1)
end
