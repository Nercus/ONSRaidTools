ONSRaidToolsButton = {}

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


function ONSRaidToolsButton:OnLoad()
    self.bg:SetBackdrop(tabsBackdrop)
    self.bg:SetBackdropColor(0, 0, 0, 0.3)
    self.bg:SetBackdropBorderColor(0, 0, 0, 1)
end

-- function ONSRaidToolsButton:SetActive()
--     self:SetAlpha(1)
--     self.bg:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
-- end

-- function ONSRaidToolsButton:SetInactive()
--     self:SetAlpha(0.5)
--     self.bg:SetBackdropBorderColor(0, 0, 0, 1)
-- end
