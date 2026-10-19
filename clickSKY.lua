-- language: Lua, target: Roblox executor
-- 0xC76B — Clean Internal Autoclicker

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local VIM
pcall(function() VIM = getrenv().VirtualInputManager end)
if not VIM then pcall(function() VIM = game:GetService("VirtualInputManager") end) end

local THEME = {
    bg=Color3.fromRGB(6,11,28), panel=Color3.fromRGB(10,19,46), row=Color3.fromRGB(14,27,62),
    accent=Color3.fromRGB(58,118,255), accent2=Color3.fromRGB(125,195,255),
    good=Color3.fromRGB(80,220,140), bad=Color3.fromRGB(240,90,110),
    text=Color3.fromRGB(230,238,255), subtext=Color3.fromRGB(135,155,200), stroke=Color3.fromRGB(28,48,108),
}
local T_FAST   = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_SMOOTH = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function new(c, p, ch)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    for _, x in ipairs(ch or {}) do x.Parent = i end
    return i
end

local function mountScreenGui(name, order)
    local sg = Instance.new("ScreenGui")
    sg.Name = name .. "_" .. math.random(1000, 9999)
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = order or 0
    local ok = pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not ok or not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    return sg
end

local running, closed = false, false

-- ===================== MAIN WINDOW =====================
local gui = mountScreenGui("Grexsky_Clicker", 5)
local FINAL_SIZE = UDim2.fromOffset(260, 134)
local TOPBAR_H = 32
local minimized = false

local main = new("Frame", {
    Name="Main", Size=UDim2.fromOffset(0,0), Position=UDim2.new(0.5,-130,0.5,-67),
    BackgroundColor3=THEME.bg, BorderSizePixel=0, ClipsDescendants=true, Parent=gui})
new("UICorner", {CornerRadius=UDim.new(0,10), Parent=main})

local bg = new("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=0, Parent=main})
new("UICorner", {CornerRadius=UDim.new(0,10), Parent=bg})
new("UIGradient", {
    Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(3,7,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(13,30,76))},
    Rotation=90, Parent=bg})

local outline = new("UIStroke", {Color=Color3.new(1,1,1), Thickness=1.5, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=main})
local outlineG = new("UIGradient", {
    Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME.accent),
        ColorSequenceKeypoint.new(0.3, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(8,16,44)),
        ColorSequenceKeypoint.new(1, THEME.accent)},
    Parent=outline})

TweenService:Create(main, T_SMOOTH, {Size=FINAL_SIZE}):Play()

local topbar = new("Frame", {
    Name="TopBar", Size=UDim2.new(1,-10,0,26), Position=UDim2.fromOffset(5,5),
    BackgroundColor3=THEME.panel, BackgroundTransparency=0.1, BorderSizePixel=0, ZIndex=2, Parent=main})
new("UICorner", {CornerRadius=UDim.new(0,7), Parent=topbar})
new("UIStroke", {Color=THEME.stroke, Thickness=1, Parent=topbar})

local title = new("TextLabel", {
    Text="0xC76B  ·  CLICKER", Font=Enum.Font.GothamBlack, TextSize=12,
    TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1, Position=UDim2.fromOffset(10,2),
    Size=UDim2.new(1,-70,0,12), ZIndex=3, Parent=topbar})
local titleG = new("UIGradient", {
    Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME.accent2),
        ColorSequenceKeypoint.new(0.3, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.6, THEME.accent),
        ColorSequenceKeypoint.new(1, THEME.accent2)},
    Parent=title})
new("TextLabel", {
    Text="GrexskyAsianBoi", Font=Enum.Font.Gotham, TextSize=8,
    TextColor3=THEME.subtext, TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1, Position=UDim2.fromOffset(10,13),
    Size=UDim2.new(1,-70,0,10), ZIndex=3, Parent=topbar})

local function topBtn(t, xOff)
    local b = new("TextButton", {
        Text=t, Font=Enum.Font.GothamBold, TextSize=13, TextColor3=THEME.subtext,
        BackgroundColor3=THEME.row, AutoButtonColor=false, Size=UDim2.fromOffset(20,20),
        Position=UDim2.new(1,xOff,0.5,-10), ZIndex=3, Parent=topbar})
    new("UICorner", {CornerRadius=UDim.new(0,5), Parent=b})
    b.MouseEnter:Connect(function() TweenService:Create(b, T_FAST, {BackgroundColor3=THEME.accent, TextColor3=Color3.new(1,1,1)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, T_FAST, {BackgroundColor3=THEME.row, TextColor3=THEME.subtext}):Play() end)
    return b
end
local minimizeBtn = topBtn("—", -46)
local closeBtn    = topBtn("×", -24)

local hb = RunService.Heartbeat:Connect(function(dt)
    outlineG.Rotation = (outlineG.Rotation + dt * 140) % 360
    titleG.Rotation   = (titleG.Rotation + dt * 90)  % 360
end)

closeBtn.MouseButton1Click:Connect(function()
    closed = true; running = false
    pcall(function() UserInputService.MouseIconEnabled = true end)
    if hb then hb:Disconnect() end
    local tw = TweenService:Create(main, T_FAST, {Size=UDim2.fromOffset(0,0)})
    tw:Play(); tw.Completed:Wait()
    gui:Destroy()
    if markerGui then markerGui:Destroy() end
end)

-- window drag
local dragging, dragStart, startPos = false, nil, nil
topbar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = inp.Position; startPos = main.Position
        inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local content = new("Frame", {
    Size=UDim2.new(1,-16,1,-(TOPBAR_H+10)), Position=UDim2.fromOffset(8,TOPBAR_H),
    BackgroundTransparency=1, ZIndex=2, Parent=main},
    {new("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})})

new("TextLabel", {
    Text="SPEED", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=THEME.subtext,
    TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1,
    Size=UDim2.new(1,0,0,11), LayoutOrder=1, ZIndex=2, Parent=content})

local speedRow = new("Frame", {
    Size=UDim2.new(1,0,0,34), BackgroundTransparency=1, LayoutOrder=2, ZIndex=2, Parent=content},
    {new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4)})})

local function speedField(label, default, order)
    local col = new("Frame", {Size=UDim2.new(1/3,-3,1,0), BackgroundTransparency=1, LayoutOrder=order, ZIndex=2, Parent=speedRow},
        {new("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1)})})
    new("TextLabel", {
        Text=label, Font=Enum.Font.Gotham, TextSize=8, TextColor3=THEME.subtext,
        TextXAlignment=Enum.TextXAlignment.Center, BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,10), LayoutOrder=1, ZIndex=2, Parent=col})
    local box = new("TextBox", {
        Text=default, Font=Enum.Font.Code, TextSize=13, TextColor3=THEME.text,
        TextXAlignment=Enum.TextXAlignment.Center, ClearTextOnFocus=false,
        BackgroundColor3=THEME.row, BackgroundTransparency=0.1, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,22), LayoutOrder=2, ZIndex=2, Parent=col})
    new("UICorner", {CornerRadius=UDim.new(0,5), Parent=box})
    new("UIStroke", {Color=THEME.stroke, Thickness=1, Parent=box})
    box:GetPropertyChangedSignal("Text"):Connect(function() box.Text = box.Text:gsub("%D", "") end)
    return box
end

local msBox  = speedField("MS",  "50", 1)
local secBox = speedField("SEC", "0",  2)
local minBox = speedField("MIN", "0",  3)

local function readIntervalMs()
    local total = (tonumber(msBox.Text) or 0) + (tonumber(secBox.Text) or 0)*1000 + (tonumber(minBox.Text) or 0)*60000
    if total < 15 then total = 15 end
    return total
end

local startBtn = new("TextButton", {
    Text="START", Font=Enum.Font.GothamBold, TextSize=15, TextColor3=Color3.new(1,1,1),
    BackgroundColor3=THEME.good, AutoButtonColor=false, Size=UDim2.new(1,0,0,38),
    LayoutOrder=3, ZIndex=2, Parent=content},
    {new("UICorner", {CornerRadius=UDim.new(0,7)})})
startBtn.MouseEnter:Connect(function()
    TweenService:Create(startBtn, T_FAST, {BackgroundColor3= running and Color3.fromRGB(255,130,140) or THEME.accent2}):Play()
end)
startBtn.MouseLeave:Connect(function()
    TweenService:Create(startBtn, T_FAST, {BackgroundColor3= running and THEME.bad or THEME.good}):Play()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        content.Visible = false
        minimizeBtn.Text = "🚀"; minimizeBtn.TextSize = 12
        TweenService:Create(main, T_SMOOTH, {Size=UDim2.fromOffset(FINAL_SIZE.X.Offset, TOPBAR_H)}):Play()
    else
        TweenService:Create(main, T_SMOOTH, {Size=FINAL_SIZE}):Play()
        minimizeBtn.Position = UDim2.new(1, -46, 0.5, -10)
        minimizeBtn.Text = "—"; minimizeBtn.TextSize = 13
        content.Visible = true
    end
end)

-- ===================== MARKER =====================
local markerGui = mountScreenGui("Grexsky_Marker", 999)
local MARKER_SIZE = 56

local marker = new("Frame", {
    Name="Marker", Size=UDim2.fromOffset(MARKER_SIZE, MARKER_SIZE),
    AnchorPoint=Vector2.new(0.5, 0.5), Position=UDim2.fromScale(0.5, 0.5),
    BackgroundTransparency=1, Active=false, Parent=markerGui})

local markerFill = new("Frame", {
    Size=UDim2.fromScale(1,1), BackgroundColor3=THEME.accent2, BackgroundTransparency=0.85,
    BorderSizePixel=0, Active=false, Parent=marker})
new("UICorner", {CornerRadius=UDim.new(1,0), Parent=markerFill})

local markerStroke = new("UIStroke", {
    Color=THEME.accent2, Thickness=2, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=markerFill})

local centerDot = new("Frame", {
    Size=UDim2.fromOffset(6,6), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    BackgroundColor3=THEME.accent2, BackgroundTransparency=0.2, BorderSizePixel=0,
    Active=false, Parent=marker})
new("UICorner", {CornerRadius=UDim.new(1,0), Parent=centerDot})

-- container size — ambil dari ScreenGui absolute (bukan Camera.ViewportSize,
-- karena beda inset 36px; pakai yang sama dengan ruang UDim2.fromScale)
local function getContainerSize()
    local size = markerGui.AbsoluteSize
    if size.X > 0 and size.Y > 0 then return size end
    local cam = workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1, 1)
end

-- ===================== DRAG (1:1 offset dari center, denominator sama dgn scale) =====================
local draggingMarker = false
local dragOffset = Vector2.new()

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp or running or closed or draggingMarker then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    local mp = Vector2.new(inp.Position.X, inp.Position.Y)
    local ap = marker.AbsolutePosition
    local asz = marker.AbsoluteSize
    if mp.X >= ap.X and mp.X <= ap.X + asz.X and mp.Y >= ap.Y and mp.Y <= ap.Y + asz.Y then
        draggingMarker = true
        local centerAbs = Vector2.new(ap.X + asz.X/2, ap.Y + asz.Y/2)
        dragOffset = Vector2.new(mp.X - centerAbs.X, mp.Y - centerAbs.Y)
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not draggingMarker then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    local cs = getContainerSize()
    if cs.X <= 0 or cs.Y <= 0 then return end
    local mp = Vector2.new(inp.Position.X, inp.Position.Y)
    local targetCenter = Vector2.new(mp.X - dragOffset.X, mp.Y - dragOffset.Y)
    local sx = math.clamp(targetCenter.X / cs.X, 0, 1)
    local sy = math.clamp(targetCenter.Y / cs.Y, 0, 1)
    marker.Position = UDim2.fromScale(sx, sy)
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingMarker = false
    end
end)

-- ===================== CLICK =====================
local function fallbackClick(cx, cy)
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("GuiButton") and d.Visible then
            local ap = d.AbsolutePosition
            local asz = d.AbsoluteSize
            if cx >= ap.X and cx <= ap.X + asz.X and cy >= ap.Y and cy <= ap.Y + asz.Y then
                pcall(function()
                    for _, c in ipairs(getconnections(d.MouseButton1Click)) do
                        pcall(function() c:Fire() end)
                    end
                end)
                return
            end
        end
    end
end

local function flashMarker()
    markerFill.BackgroundTransparency = 0.35
    TweenService:Create(markerFill, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency=0.85}):Play()
end

local function doClick()
    local ap = marker.AbsolutePosition
    local asz = marker.AbsoluteSize
    local cx = ap.X + asz.X/2
    local cy = ap.Y + asz.Y/2
    if VIM then
        local ok = pcall(function()
            -- cuma button event, tanpa SendMouseMoveEvent (biar kursor nggak muncul)
            VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
            VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
        end)
        if not ok then fallbackClick(cx, cy) end
    else
        fallbackClick(cx, cy)
    end
end

startBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        startBtn.Text = "STOP"
        startBtn.BackgroundColor3 = THEME.bad
        pcall(function() UserInputService.MouseIconEnabled = false end)
    else
        startBtn.Text = "START"
        startBtn.BackgroundColor3 = THEME.good
        pcall(function() UserInputService.MouseIconEnabled = true end)
    end
end)

task.spawn(function()
    while not closed do
        if running then
            local w = readIntervalMs() / 1000
            doClick()
            flashMarker()
            task.wait(w)
        else
            task.wait(0.08)
        end
    end
end)

print(("[GREXSKY] clicker ready — VIM %s"):format(VIM and "OK" or "FALLBACK"))
