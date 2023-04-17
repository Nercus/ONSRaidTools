local AddOnName, components = ...
local ONSRaidTools = LibStub("AceAddon-3.0"):GetAddon(AddOnName)

-- TODO: Add recipe module

local VIEWS = {
    IMAGE = "image",
    SELECT = "select"
}

local activeRaid = "DFS2"
local moveCrosshair = "Interface/CURSOR/UI-Cursor-Move.crosshair"
local function createWindow()
    -- Create the frame
    local frame = CreateFrame("Frame", AddOnName .. "MainWindow", UIParent, "ONSImagViewMainWindowTemplate")
    frame:SetPoint("CENTER")
    return frame
end

function ONSRaidTools:AddListernersToView(view)
    if not view then return error("view is nil") end
    view:SetScript("OnEnter", function(f)
        if IsShiftKeyDown() then
            f:EnableMouse(false)
            f:SetAlpha(0.1)
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
            view:EnableMouse(true)
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

function ONSRaidTools:CreateImageViewTabs(tabsTable)
    if not tabsTable then return end
    local tabs = components:CreateTabs(tabsTable)
    components:LayoutTabs(tabs, self.imageView.tabsHolder, 5, 5, 4)
    -- Set the first tab as active
    tabsTable[1].callback()
    components:SetActiveTab(tabs, 1)
end

function ONSRaidTools:LoadCurrentImageCollection()
    if not self.db.global.loadedEncounter then return end
    if not self.db.global.loadedEncounter.images then return end

    local images = self.db.global.loadedEncounter.images
    local tabsTable = {}

    for i, path in ipairs(images) do
        local tab = {
            label = "Image " .. i,
            callback = function()
                self:LoadImageToView(path)
            end
        }
        table.insert(tabsTable, tab)
    end
    self:CreateImageViewTabs(tabsTable)
end

-- Example: ONSRaidTools:LoadEncounter(1, "dfs1")
function ONSRaidTools:LoadEncounter(encounterIndex, moduleName)
    -- encounterIndex -> index of encounter in the raid
    -- Check if an encounter index is set, if not return
    if not encounterIndex then
        error("encounterIndex not found")
        return
    end
    -- Check if a module name is set, if not return
    if not moduleName then
        error("moduleName not found")
        return
    end
    -- Set the module to the module with the specified name
    local module = self.modules[moduleName]
    -- Check if the module is set, if not return
    if not module then
        error("module not found")
        return
    end
    -- Set the images to the images for the specified encounterIndex
    local images = module.images[encounterIndex]
    -- Check if the images are set, if not return
    if not images then
        error("images not found")
        return
    end
    -- Set the info to the info for the specified encounterIndex
    local info = module.bosses[encounterIndex]
    -- Check if the info is set, if not return
    if not info then
        error("info not found")
        return
    end
    -- Set the loadedEncounter images to the images
    self.db.global.loadedEncounter.images = images
    -- Set the loadedEncounter info to the info
    self.db.global.loadedEncounter.info = info
    self:LoadCurrentImageCollection()
end

function ONSRaidTools:InitImageView()
    self.imageView = createImageView()
    self.imageView.menuButton:SetScript("OnClick", function(f)
        if not self.selectView then
            self:InitSelectView()
        end
        self:SetView(self.selectView)
    end)

    -- TODO: hide/show tabs on mouse enter/leave
    -- self.imageView:SetScript("OnEnter", function(f)
    --     f.tabsHolder:Show()
    -- end)

    -- self.imageView:SetScript("OnLeave", function(f)
    --     f.tabsHolder:Hide()
    -- end)

    self.imageView.name = VIEWS.IMAGE
    self:AddListernersToView(self.imageView)
end

local function createSelectView()
    local frame = CreateFrame("Frame", AddOnName .. "SelectView", UIParent, "ONSSelectViewTemplate")
    return frame
end





function ONSRaidTools:InitSelectView()
    self.selectView = createSelectView()
    self:AddListernersToView(self.selectView)
    self.selectView.backButton:SetScript("OnClick", function(f)
        self:SetView(self.imageView)
    end)

    -- only for hardcoded raid
    -- Set the module to the module with the specified name
    local module = self.modules[activeRaid]
    -- Check if the module is set, if not return
    if not module then
        error("module not found")
        return
    end
    local gap = 5
    local row = 0


    -- TODO: set dynamic button height ?????
    -- TODO: set dynamic width for last button when number of encounters is odd
    local buttonIndex = 1
    for bossIndex, bossInfo in ipairs(module.bosses) do
        if module.images[bossIndex] then
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
            button.icon:SetTexture(bossInfo.icon)
            button.label:SetText(bossInfo.name)
            button:SetScript("OnClick", function(f)
                self:LoadEncounter(bossIndex, activeRaid)
                self:SetView(self.imageView)
            end)
            button:Show()
            buttonIndex = buttonIndex + 1
        end
    end



    self.selectView.name = VIEWS.SELECT
end

function ONSRaidTools:setupMainWindow()
    self.mainWindow = createWindow()
    self:AddMainListeners()
    self:SetInitPosition()
    ONSRaidTools:GetViewByName(VIEWS.IMAGE)
    self.activeView = VIEWS.IMAGE
    self:SetView(self.imageView)
    if self.DEV then
        C_Timer.After(0.1, function()
            ViragDevTool:AddData(self)
            self:LoadEncounter(1, "DFS2")
        end)
    end
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
        self.imageView:EnableMouse(false)
        self.imageView:SetAlpha(0.1)
    else
        self.imageView:EnableMouse(true)
        self.imageView:SetAlpha(1)
    end

    if not self.selectView then return end
    if state == 1 and (self.selectView:IsMouseOver(1, 0, 1, 0)) then
        self.selectView:EnableMouse(false)
        self.selectView:SetAlpha(0.1)
    else
        self.selectView:EnableMouse(true)
        self.selectView:SetAlpha(1)
    end
end
