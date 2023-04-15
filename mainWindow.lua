local AddOnName, _ = ...
local ONSImageView = LibStub("AceAddon-3.0"):GetAddon(AddOnName)


local VIEWS = {
    IMAGE = "image",
    SELECT = "select"
}
local moveCrosshair = "Interface/CURSOR/UI-Cursor-Move.crosshair"
local function createWindow()
    -- Create the frame
    local frame = CreateFrame("Frame", AddOnName .. "MainWindow", UIParent, "ONSImagViewMainWindowTemplate")
    frame:SetPoint("CENTER")
    return frame
end

function ONSImageView:AddListernersToView(view)
    if not view then return print("view is nil") end
    view:SetScript("OnEnter", function(f)
        if IsShiftKeyDown() then
            f:EnableMouse(false)
            f:SetAlpha(0.1)
        end
    end)
end

function ONSImageView:GetCurrentView()
    if not self.activeView then return end
    local current = self:GetViewByName(self.activeView)
    return current
end

function ONSImageView:AddMainListeners()
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

function ONSImageView:SetInitPosition()
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
    local frame = CreateFrame("Frame", AddOnName .. "ImageView", UIParent, "ONSImageViewTemplate")
    return frame
end

function ONSImageView:GetViewByName(name)
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

function ONSImageView:SetView(view)
    if not view then return end
    if not self.activeView then return end
    local current = self:GetCurrentView()
    if current then
        current:Hide()
        current:EnableMouse(false)
    end
    print("SetView", view.name)
    view:SetParent(self.mainWindow)
    view:SetPoint("TOPLEFT", self.mainWindow, "TOPLEFT", 0, 0)
    view:SetPoint("BOTTOMRIGHT", self.mainWindow, "BOTTOMRIGHT", 0, 0)
    view:Show()
    self.activeView = view.name
end

function ONSImageView:InitImageView()
    self.imageView = createImageView()
    self.imageView.menuButton:SetScript("OnClick", function(f)
        if not self.selectView then
            self:InitSelectView()
        end
        self:SetView(self.selectView)
    end)

    self.imageView.name = VIEWS.IMAGE
    self:AddListernersToView(self.imageView)
end

local function createSelectView()
    local frame = CreateFrame("Frame", AddOnName .. "SelectView", UIParent, "ONSSelectViewTemplate")
    return frame
end

function ONSImageView:InitSelectView()
    self.selectView = createSelectView()
    self:AddListernersToView(self.selectView)
    self.selectView.backButton:SetScript("OnClick", function(f)
        self:SetView(self.imageView)
    end)
    self.selectView.name = VIEWS.SELECT
end

function ONSImageView:setupMainWindow()
    self.mainWindow = createWindow()
    self:AddMainListeners()
    self:SetInitPosition()
    ONSImageView:GetViewByName(VIEWS.IMAGE)
    self.activeView = VIEWS.IMAGE
    self:SetView(self.imageView)
    C_Timer.After(0.1, function()
        -- ViragDevTool:AddData(self)
    end)
end

function ONSImageView:ToggleFrame()
    --Create the window if it doesn't exist
    if not self.mainWindow then
        self:setupMainWindow()
    end

    local image = self.modules.DFS1.images[1][3]
    print(image)
    self.imageView.img:SetTexture(image)


    --Show or hide the window depending on its current state
    if self.mainWindow:IsShown() then
        self.mainWindow:Hide()
    else
        self.mainWindow:Show()
    end
end

function ONSImageView:MODIFIER_STATE_CHANGED(e, key, state)
    if key ~= "LSHIFT" and key ~= "RSHIFT" then return end

    if state == 1 and (self.imageView:IsMouseOver(1, 0, 1, 0)) then
        self.imageView:EnableMouse(false)
        self.imageView:SetAlpha(0.1)
    else
        self.imageView:EnableMouse(true)
        self.imageView:SetAlpha(1)
    end
end
