local AddOnName, components = ...
local ONSRaidTools = LibStub("AceAddon-3.0"):GetAddon(AddOnName)

-- TODO: Add recipe module

local VIEWS = {
    IMAGE = "image",
    SELECT = "select"
}


local moveCrosshair = "Interface/CURSOR/UI-Cursor-Move.crosshair"
local function createWindow()
    -- Create the frame
    local frame = CreateFrame("Frame", AddOnName .. "mainWindow", UIParent, "ONSImagViewMainWindowTemplate")
    return frame
end


function ONSRaidTools:HideImageViewButtons()
    if not self.imageView then return end
    self.imageView.tabsHolder:Hide()
    self.imageView.menuButton:Hide()
end

function ONSRaidTools:ShowImageViewButtons()
    if not self.imageView then return end
    self.imageView.tabsHolder:Show()
    self.imageView.menuButton:Show()
end

local function CheckFrameMouseover(f)
    if not f then return end
    if f:IsMouseOver() then
        return true
    end
    local children = { f:GetChildren() }
    while #children > 0 do
        local child = table.remove(children, 1)
        if child:IsMouseOver() then
            return true
        end
        local subChildren = { child:GetChildren() }
        for i = 1, #subChildren do
            table.insert(children, subChildren[i])
        end
    end
    return false
end


function ONSRaidTools:UpdateImageViewMouseOverState()
    if not self.imageView then return end
    if CheckFrameMouseover(self.imageView) then
        self:ShowImageViewButtons()
    else
        self:HideImageViewButtons()
    end
end

function ONSRaidTools:AddListernersToView(view)
    if not view then return error("view is nil") end
    view:SetScript("OnEnter", function(f)
        if IsShiftKeyDown() then
            f:EnableMouse(false)
            f:SetAlpha(0.1)
            return
        end
        if view.name == VIEWS.IMAGE then
            self:UpdateImageViewMouseOverState()
        end
    end)
    view:SetScript("OnLeave", function(f)
        local v = self:GetCurrentView()
        if v then
            v:SetAlpha(1)
        end
        if view.name == VIEWS.IMAGE then
            self:UpdateImageViewMouseOverState()
        end
    end)
end

function ONSRaidTools:GetCurrentView()
    if not self.activeView then return end
    local current = self:GetViewByName(self.activeView)
    return current
end

function ONSRaidTools:AddMainListeners()
    local frame = self.mainWindow
    frame:SetScript("OnDragStart", function(f)
        f:StartMoving()
        f:SetUserPlaced(false)
        SetCursor(moveCrosshair)
    end)

    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        SetCursor(nil)
        -- Get the position of the frame
        local point, _, relativePoint, xOfs, yOfs = f:GetPoint()
        -- If we found a point then save that position
        if point and relativePoint and xOfs and xOfs then
            self.db.global.position = {
                point = point,
                relativePoint = relativePoint,
                x = xOfs,
                y = yOfs
            }
        end
    end)

    frame:SetScript("OnLeave", function(f)
        local view = self:GetCurrentView()
        if view then
            -- view:EnableMouse(true)
            view:SetAlpha(1)
        end
    end)
end

function ONSRaidTools:SetInitPosition()
    local x, y, point, relativePoint
    if self.db.global.position then
        x = self.db.global.position.x
        y = self.db.global.position.y
        relativePoint = self.db.global.position.relativePoint
        point = self.db.global.position.point
    end
    local frame = self.mainWindow
    frame:SetPoint(point, UIParent, relativePoint, x, y)
end

local function createImageView()
    local frame = CreateFrame("Frame", AddOnName .. "ImageView", UIParent, "ONSRaidToolsTemplate")
    return frame
end

function ONSRaidTools:GetViewByName(name)
    if name == VIEWS.IMAGE then
        if not self.imageView then
            self:InitImageView()
        end
        return self.imageView
    elseif name == VIEWS.SELECT then
        if not self.selectView then
            self:InitSelectView()
        end
        return self.selectView
    end
end

function ONSRaidTools:SetView(view)
    if not view then return end
    if not self.activeView then return end
    local current = self:GetCurrentView()
    if current then
        current:Hide()
    end
    view:SetParent(self.mainWindow)
    view:SetPoint("TOPLEFT", self.mainWindow, "TOPLEFT", 0, 0)
    view:SetPoint("BOTTOMRIGHT", self.mainWindow, "BOTTOMRIGHT", 0, 0)
    view:Show()
    self.activeView = view.name
end

function ONSRaidTools:LoadImageToView(img)
    -- img -> path to image
    if not img then return end
    self.imageView.img:SetTexture(img)
end

function ONSRaidTools:CreateImageViewTabs(tabsTable, overrideIntitial)
    if not tabsTable then return end
    local tabs = components:CreateTabs(tabsTable)
    components:LayoutTabs(tabs, self.imageView.tabsHolder, 5, 5, 4)
    local indexToLoad = 1
    if overrideIntitial then
        indexToLoad = overrideIntitial
    end
    -- Set the first tab as active
    tabsTable[indexToLoad].callback()
    components:SetActiveTab(tabs, indexToLoad)
end

function ONSRaidTools:LoadCurrentImageCollection(overrideIntitial)
    if not self.db.global.loadedEncounter then return end
    if not self.db.global.loadedEncounter.images then return end

    local images = self.db.global.loadedEncounter.images
    local tabsTable = {}

    for i, path in ipairs(images) do
        local tab = {
            label = "Image " .. i,
            callback = function()
                self:LoadImageToView(path)
            end,
            onLeave = function()
                self:UpdateImageViewMouseOverState()
            end
        }
        table.insert(tabsTable, tab)
    end
    self:CreateImageViewTabs(tabsTable, overrideIntitial)
end

function ONSRaidTools:SetEncounterNameByIndex(index)
    if not index then return end
    local bossName = self:GetBossNameByModuleAndIndex(self.activeRaid, index)
    if not bossName then return end
    self.imageView.menuButton.bossName:SetText(bossName)
end

-- Example: ONSRaidTools:LoadEncounter(1, "dfs1")
function ONSRaidTools:LoadEncounter(encounterIndex, moduleName, overrideIntitial)
    -- encounterIndex -> index of encounter in the raid
    if not encounterIndex then
        error("encounterIndex not found")
        return
    end
    if not moduleName then
        error("moduleName not found")
        return
    end
    local module = self.modules[moduleName]
    if not module then
        error("module not found")
        return
    end
    local images = module.images[encounterIndex]
    if not images then
        error("images not found")
        return
    end
    local info = module.bosses[encounterIndex]
    if not info then
        error("info not found")
        return
    end
    self.db.global.loadedEncounter.images = images
    self.db.global.loadedEncounter.info = info
    self:SetEncounterNameByIndex(encounterIndex)
    self:LoadCurrentImageCollection(overrideIntitial)
end

function ONSRaidTools:InitImageView()
    self.imageView = createImageView()
    self.imageView.menuButton:SetScript("OnClick", function(f)
        if not self.selectView then
            self:InitSelectView()
        end
        self:SetView(self.selectView)
    end)


    self.imageView.menuButton:SetScript("OnLeave", function(f)
        self:UpdateImageViewMouseOverState()
    end)

    self.imageView.tabsHolder:SetScript("OnLeave", function(f)
        self:UpdateImageViewMouseOverState()
    end)


    self.imageView.name = VIEWS.IMAGE
    self:AddListernersToView(self.imageView)
end

local function createSelectView()
    local frame = CreateFrame("Frame", nil, UIParent, "ONSSelectViewTemplate")
    return frame
end


function ONSRaidTools:SetActiveRaidToSelectView()
    -- only for hardcoded raid
    -- Set the module to the module with the specified name
    local module = self.modules[self.activeRaid]
    -- Check if the module is set, if not return
    if not module then
        error("module not found")
        return
    end
    for i, button in ipairs(self.selectView.encounterButtons) do
        button:Hide()
    end
    local buttonIndex = 1
    for bossIndex, bossInfo in ipairs(module.bosses) do
        if module.images[bossIndex] then
            local button = self.selectView.encounterButtons[buttonIndex]
            button.icon:SetTexture(bossInfo.icon)
            button.label:SetText(bossInfo.name)
            button:SetScript("OnClick", function(f)
                self:LoadEncounter(bossIndex, self.activeRaid)
                self:SetView(self.imageView)
            end)
            button:Show()
            buttonIndex = buttonIndex + 1
        end
    end
end

function ONSRaidTools:InitSelectView()
    self.selectView = createSelectView()
    self:AddListernersToView(self.selectView)
    self.selectView.titleBar.backButton:SetScript("OnClick", function(f)
        self:SetView(self.imageView)
    end)

    self.selectView.titleBar.settingsButton:SetScript("OnClick", function(f)
        self:OpenSettings()
    end)

    local gap = 5
    local row = 0
    local max = 14
    self.selectView.encounterButtons = {}

    for buttonIndex = 1, max do
        local button = CreateFrame("Button", nil, self.selectView.encounterButtonHolder,
            "ONSRaidToolsEncounterButtonTemplate")
        local width = button:GetWidth()
        local height = button:GetHeight()
        local col = (buttonIndex % 2 == 0 and 2 or 1)
        if col == 1 then
            row = row + 1
        end

        local xOffset = (col - 1) * (width + gap)
        local yOffset = -((row - 1) * (height + gap))

        button:SetPoint("TOPLEFT", self.selectView.encounterButtonHolder, "TOPLEFT", xOffset, yOffset)
        button:Hide()
        table.insert(self.selectView.encounterButtons, button)
    end

    self:SetActiveRaidToSelectView()
    self.selectView.name = VIEWS.SELECT
end

function ONSRaidTools:setupMainWindow()
    self.mainWindow = createWindow()
    self:AddMainListeners()
    self:SetInitPosition()
    ONSRaidTools:GetViewByName(VIEWS.IMAGE)
    self.activeView = VIEWS.IMAGE
    self:SetView(self.imageView)
    self:LoadOptionsValues()
end

function ONSRaidTools:ToggleFrame()
    --Create the window if it doesn't exist
    if not self.mainWindow then
        self:setupMainWindow()
    end

    --Show or hide the window depending on its current state
    if self.mainWindow:IsShown() then
        self.mainWindow:Hide()
    else
        self.mainWindow:Show()
    end
end

function ONSRaidTools:MODIFIER_STATE_CHANGED(e, key, state)
    if key ~= "LSHIFT" and key ~= "RSHIFT" then return end
    if not self.imageView then return end
    if state == 1 and (self.imageView:IsMouseOver(1, 0, 1, 0)) then
        self.mainWindow.moveInfo:Show()
        self.imageView:EnableMouse(false)
        self.imageView:SetAlpha(0.1)
    else
        self.mainWindow.moveInfo:Hide()
        self.imageView:EnableMouse(true)
        self.imageView:SetAlpha(1)
        if (self.imageView:IsMouseOver(1, 0, 1, 0)) then
            self.imageView.tabsHolder:Show()
            self.imageView.menuButton:Show()
        end
    end

    if not self.selectView then return end
    if state == 1 and (self.selectView:IsMouseOver(1, 0, 1, 0)) then
        self.mainWindow.moveInfo:Show()
        self.selectView:EnableMouse(false)
        self.selectView:SetAlpha(0.1)
    else
        self.mainWindow.moveInfo:Hide()
        self.selectView:EnableMouse(true)
        self.selectView:SetAlpha(1)
    end
end
