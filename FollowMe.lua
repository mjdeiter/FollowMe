--- FollowMe.lua
--- Spams /e3bcg /nav id <driver ID> at a configurable interval
--- Automatically goes into standby while in user-configured zones
--- (Nexus, Plane of Knowledge, Plane of Tranquility by default)
--- Run: /lua run FollowMe

local mq    = require('mq')
local imgui = require('ImGui')

-- State
local open      = true
local enabled   = false
local interval  = 5.0
local lastFire  = 0
local statusMsg = 'Idle'
-- Flash
local FLASH_DURATION = 0.5
local lastFlash      = 0
local flashing       = false

-- Zone standby
local standbyActive  = true
local standbyZones   = {
    'nexus',        -- The Nexus
    'poknowledge',  -- Plane of Knowledge
    'tranquility',  -- Plane of Tranquility
}
local newZoneInput    = ''
local selectedZoneIdx = 1
local inStandbyZone   = false

--- Trim leading/trailing whitespace
local function trim(s)
    return s:match('^%s*(.-)%s*$')
end

--- Returns true if the current zone short name is in standbyZones
local function isInStandbyZone()
    local zoneShort = mq.TLO.Zone.ShortName() or ''
    zoneShort = zoneShort:lower()
    for _, z in ipairs(standbyZones) do
        if z:lower() == zoneShort then
            return true
        end
    end
    return false
end

--- Add the contents of newZoneInput to the standby zone list
local function addZone()
    local name = trim(newZoneInput):lower()
    if name == '' then return end

    for _, z in ipairs(standbyZones) do
        if z == name then
            newZoneInput = ''
            return -- already in the list
        end
    end

    table.insert(standbyZones, name)
    newZoneInput    = ''
    selectedZoneIdx = #standbyZones
end

--- Remove the currently selected zone from the dropdown list
local function removeSelectedZone()
    if selectedZoneIdx >= 1 and selectedZoneIdx <= #standbyZones then
        table.remove(standbyZones, selectedZoneIdx)
        if selectedZoneIdx > #standbyZones then
            selectedZoneIdx = #standbyZones
        end
        if selectedZoneIdx < 1 then
            selectedZoneIdx = 1
        end
    end
end

local function sendCommand()
    mq.cmdf('/e3bcg /nav id %d', mq.TLO.Me.ID())
    statusMsg = 'Fired!'
    lastFlash = mq.gettime() / 1000.0
    flashing  = true
end

local function renderGUI()
    if not open then return end

    imgui.SetNextWindowSize(260, 0, ImGuiCond.FirstUseEver)
    local show
    open, show = imgui.Begin('FollowMe', open)

    if show then
        imgui.Text('Interval (seconds):')
        interval, _ = imgui.SliderFloat('##interval', interval, 1.0, 30.0, '%.1f s')

        imgui.Spacing()

        if enabled then
            imgui.PushStyleColor(ImGuiCol.Button,        0.7, 0.15, 0.15, 1.0)
            imgui.PushStyleColor(ImGuiCol.ButtonHovered, 0.9, 0.25, 0.25, 1.0)
            imgui.PushStyleColor(ImGuiCol.ButtonActive,  0.5, 0.10, 0.10, 1.0)
            if imgui.Button('STOP', -1, 0) then
                enabled   = false
                statusMsg = 'Stopped'
                flashing  = false
            end
            imgui.PopStyleColor(3)
        else
            imgui.PushStyleColor(ImGuiCol.Button,        0.15, 0.55, 0.15, 1.0)
            imgui.PushStyleColor(ImGuiCol.ButtonHovered, 0.20, 0.75, 0.20, 1.0)
            imgui.PushStyleColor(ImGuiCol.ButtonActive,  0.10, 0.40, 0.10, 1.0)
            if imgui.Button('START', -1, 0) then
                enabled   = true
                lastFire  = 0
                statusMsg = 'Running...'
            end
            imgui.PopStyleColor(3)
        end

        imgui.Spacing()

        if imgui.Button('Fire Once', -1, 0) then
            sendCommand()
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        -- Zone standby controls
        standbyActive, _ = imgui.Checkbox('Standby in listed zones', standbyActive)

        imgui.Spacing()
        imgui.Text('Add zone (short name):')
        imgui.SetNextItemWidth(150)
        newZoneInput, _ = imgui.InputText('##newzone', newZoneInput)
        imgui.SameLine()
        if imgui.Button('Add') then
            addZone()
        end

        imgui.Spacing()
        imgui.Text('Standby zones:')
        imgui.SetNextItemWidth(-1)
        local comboLabel = standbyZones[selectedZoneIdx] or '(none)'
        if imgui.BeginCombo('##zonelist', comboLabel) then
            for i, z in ipairs(standbyZones) do
                local isSelected = (i == selectedZoneIdx)
                local pressed
                pressed, _ = imgui.Selectable(z, isSelected)
                if pressed then
                    selectedZoneIdx = i
                end
                if isSelected then
                    imgui.SetItemDefaultFocus()
                end
            end
            imgui.EndCombo()
        end

        if #standbyZones > 0 then
            if imgui.Button('Remove Selected', -1, 0) then
                removeSelectedZone()
            end
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        local now = mq.gettime() / 1000.0
        if inStandbyZone then
            imgui.PushStyleColor(ImGuiCol.Text, 0.4, 0.7, 1.0, 1.0)
        elseif flashing and (now - lastFlash) < FLASH_DURATION then
            imgui.PushStyleColor(ImGuiCol.Text, 0.2, 1.0, 0.4, 1.0)
        elseif enabled then
            imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.85, 0.2, 1.0)
        else
            imgui.PushStyleColor(ImGuiCol.Text, 0.6, 0.6, 0.6, 1.0)
        end
        imgui.Text(statusMsg)
        imgui.PopStyleColor()

        if enabled then
            if inStandbyZone then
                imgui.PushStyleColor(ImGuiCol.PlotHistogram, 0.4, 0.4, 0.4, 1.0)
                imgui.ProgressBar(0.0, -1, 0, 'Standby - zone excluded')
                imgui.PopStyleColor()
            else
                local elapsed = (mq.gettime() / 1000.0) - lastFire
                local frac    = math.min(elapsed / interval, 1.0)
                imgui.PushStyleColor(ImGuiCol.PlotHistogram, 0.2, 0.6, 1.0, 1.0)
                imgui.ProgressBar(frac, -1, 0, string.format('%.1fs / %.1fs', elapsed, interval))
                imgui.PopStyleColor()
            end
        end
    end

    imgui.End()
end

mq.imgui.init('FollowMe', renderGUI)

while open do
    inStandbyZone = standbyActive and isInStandbyZone()

    if enabled then
        local now = mq.gettime() / 1000.0

        if inStandbyZone then
            flashing  = false
            statusMsg = string.format('Standby (zone: %s)', mq.TLO.Zone.ShortName() or '?')
        else
            if (now - lastFire) >= interval then
                sendCommand()
                lastFire = now
            end
            if flashing and (now - lastFlash) >= FLASH_DURATION then
                flashing  = false
                statusMsg = 'Running...'
            end
        end
    end

    mq.delay(100)
end

mq.exit()
