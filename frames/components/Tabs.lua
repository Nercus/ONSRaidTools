local AddOnName, components = ...
-- tabsInfo = {
--     {
--         label = "Tab 1",
--         callback = function() print("Tab 1") end
--     },
--     {
--         label = "Tab 2",
--         callback = function() print("Tab 2") end
--           onLeave = function() print("Tab 2 onLeave") end
--     }
-- }
local tabsFramePool = CreateFramePool("Button", nil, "ONSRaidToolsTabTemplate")

function components:SetActiveTab(frames, index)
    -- frames -> all the tab frames
    -- index -> the index of the tab to set active
    for i, j in ipairs(frames) do
        if i == index then
            j:SetActive()
        else
            j:SetInactive()
        end
    end
end

function components:CreateTabs(tabsInfo)
    local frames = {}
    self:KillTabs() -- We only want one set of tabs at a time
    for i, tabInfo in ipairs(tabsInfo) do
        local tab = tabsFramePool:Acquire()
        tab.text:SetText(i)
        tab:SetScript("OnClick", function()
            self:SetActiveTab(frames, i)
            tabInfo.callback()
        end)

        tab:SetScript("OnEnter", function(f)
            GameTooltip:SetOwner(f, "ANCHOR_BOTTOM", 0, -1)
            GameTooltip:SetText(tabInfo.label)
            GameTooltip:Show()
        end)
        tab:SetScript("OnLeave", function(f)
            GameTooltip:Hide()
            tabInfo.onLeave()
        end)
        table.insert(frames, tab)
    end
    return frames
end

function components:LayoutTabs(tabs, parentFrame, gap, paddingX, paddingBottom)
    local tabWidth = (parentFrame:GetWidth() - (paddingX * 2) - ((#tabs - 1) * gap)) / #tabs
    for i, tab in ipairs(tabs) do
        tab:SetParent(parentFrame)
        tab:ClearAllPoints()
        tab:SetPoint("LEFT", parentFrame, "LEFT", paddingX + ((i - 1) * (tabWidth + gap)), paddingBottom)
        tab:SetWidth(tabWidth)
        tab:Show()
    end
    parentFrame.tabs = tabs
end

function components:KillTabs()
    tabsFramePool:ReleaseAll()
end
