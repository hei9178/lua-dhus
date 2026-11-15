local _ok, _err = xpcall(function()

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local PG           = LP:WaitForChild("PlayerGui")

local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
local Drawing = rawget(_G, "Drawing")

-- ============================================================
-- 语言
-- ============================================================
local Lang = "en"

local L = {
    en = {
        title = "Aim Helper", subtitle = "ESP · Aimbot · Silent Aim · Weapon",
        loading = "Loading", ready = "Ready",
        tabESP = "ESP", tabAim = "Aimbot", tabSilent = "Silent", tabWeapon = "Weapon", tabSet = "Settings",
        secDecrypt = "Decryption", secESP = "ESP Settings", secAim = "Aimbot Settings",
        secSilent = "Silent Aim Settings", secWeapon = "Weapon Settings", secGeneral = "General",
        espMode = "ESP Mode", modeA = "A: BB+HL", modeB = "B: HL Only", modeC = "C: Drawing", modeD = "D: Skeleton",
        coordDecrypt = "Coordinate Decrypt", fullMapDecrypt = "Full Map Decrypt",
        enableESP = "Enable ESP", box = "Box", name = "Name", health = "Health",
        distance = "Distance", tracer = "Tracer", highlight = "Highlight", teamCheck = "Team Check",
        skeleton = "Skeleton", maxDistance = "Max Distance",
        enableAim = "Enable Aimbot", showFov = "Show FOV", wallCheck = "Wall Check",
        prediction = "Prediction", predMode = "Predict Mode",
        predOff = "Off", predVel = "Velocity", predBallistic = "Ballistic",
        aimPart = "Aim Part", aimKey = "Aim Key",
        fov = "FOV Radius", smoothness = "Smoothness", bulletSpeed = "Bullet Speed",
        predictionFactor = "Predict Factor", hardLock = "Hard Lock",
        enableSilent = "Enable Silent Aim", silentFov = "Silent FOV", showSilentFov = "Show Silent FOV",
        modifyPos = "Modify Position", modifyDir = "Modify Direction",
        fireRate = "Fire Rate Multiplier", noRecoil = "No Recoil", noSpread = "No Spread",
        fireRateSpeed = "Fire Rate Speed",
        disableAll = "Disable All", unload = "Unload",
        disabledAll = "All disabled", loaded = "Loaded",
        menuHint = "Insert Menu / RMB Aim / RShift Silent",
        language = "Language", langName = "English",
        warning = "Silent needs WeaponClient source to be 100% effective",
        traceHint = "Silent fired: check console for raw args",
    },
    zh = {
        title = "瞄准助手", subtitle = "透视 · 自瞄 · 子弹追踪 · 枪械",
        loading = "加载中", ready = "就绪",
        tabESP = "透视", tabAim = "自瞄", tabSilent = "子弹追踪", tabWeapon = "枪械", tabSet = "设置",
        secDecrypt = "解密", secESP = "透视设置", secAim = "自瞄设置",
        secSilent = "子弹追踪设置", secWeapon = "枪械设置", secGeneral = "通用",
        espMode = "透视方案", modeA = "A: 名牌+高亮", modeB = "B: 仅高亮", modeC = "C: 绘制", modeD = "D: 骨骼",
        coordDecrypt = "坐标解密", fullMapDecrypt = "全图解密",
        enableESP = "启用透视", box = "方框", name = "名字", health = "血量",
        distance = "距离", tracer = "射线", highlight = "高亮", teamCheck = "队伍检测",
        skeleton = "骨骼", maxDistance = "最大距离",
        enableAim = "启用自瞄", showFov = "显示范围圈", wallCheck = "墙壁检测",
        prediction = "预判", predMode = "预判模式",
        predOff = "关闭", predVel = "移动预判", predBallistic = "弹道预判",
        aimPart = "瞄准部位", aimKey = "自瞄按键",
        fov = "视野半径", smoothness = "平滑度", bulletSpeed = "子弹速度",
        predictionFactor = "预判系数", hardLock = "强锁",
        enableSilent = "启用子弹追踪", silentFov = "追踪视野", showSilentFov = "显示追踪圈",
        modifyPos = "改写位置", modifyDir = "改写方向",
        fireRate = "射速加成", noRecoil = "无后座", noSpread = "无扩散",
        fireRateSpeed = "射速倍率",
        disableAll = "全部关闭", unload = "卸载",
        disabledAll = "已全部关闭", loaded = "加载完成",
        menuHint = "Insert 菜单 / 右键自瞄 / RShift 子弹追踪",
        language = "语言", langName = "简体中文",
        warning = "子弹追踪需 WeaponClient 源码才能百分百生效",
        traceHint = "子弹追踪触发: 查看控制台原始参数",
    },
}

-- ============================================================
-- 配置
-- ============================================================
local Config = {
    ESP = {
        Enabled = true, Mode = "A",
        Box = true, Name = true, Health = true, Distance = true,
        Tracer = true, Highlight = true, Skeleton = true,
        TeamCheck = false, MaxDistance = 1500,
        Color = Color3.fromRGB(255, 70, 70),
        TeamColor = Color3.fromRGB(60, 200, 255),
    },
    Aimbot = {
        Enabled = true, Key = Enum.UserInputType.MouseButton2, KeyName = "RMB",
        AimPart = "Head", FOV = 220, ShowFOV = true, Smoothness = 8,
        WallCheck = false, PredMode = "Ballistic",
        PredictionFactor = 1.0, PredictionIterations = 3,
        BulletSpeed = 10000, MaxDistance = 800,
        TeamCheck = false, HardLock = false,
    },
    Silent = {
        Enabled = false, AimPart = "Head", FOV = 300, ShowFOV = true,
        WallCheck = false, PredMode = "Ballistic", BulletSpeed = 10000,
        TeamCheck = false, MaxDistance = 900,
        ModifyPosition = true, ModifyDirection = true,
    },
    Weapon = { FireRate = false, NoRecoil = false, NoSpread = false, FireRateSpeed = 2.0 },
    Decrypt = { CoordinateDecrypt = false, FullMapDecrypt = false, CustomResolver = nil },
}

-- ============================================================
-- 工具
-- ============================================================
local function getChar(player)
    local c = player.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    return c, h
end

local function getAimPart(char, partName)
    local p = char:FindFirstChild(partName)
    if p and p:IsA("BasePart") then return p end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function worldToScreen(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local sp = cam:WorldToViewportPoint(pos)
    if sp.Z < 0 then return nil end
    return Vector2.new(sp.X, sp.Y)
end

-- 预判
local function predictPos(origin, part, mode, speed, factor, iters)
    if mode == "Off" then return part.Position end
    local p = part.Position
    local v = part.AssemblyLinearVelocity
    if mode == "Velocity" then
        return p + v * (factor or 1) * 0.1
    end
    -- Ballistic: 迭代外推
    for _ = 1, iters do
        local t = (p - origin).Magnitude / math.max(speed, 1)
        p = part.Position + v * t * (factor or 1)
    end
    return p
end

-- 坐标解密
local charCache = {}
local function scanChars()
    local r = {}
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then r[m.Name] = m end
    end
    for _, cname in ipairs({"Characters","Players","Entities","PlayerCharacters","AllPlayers"}) do
        local c = Workspace:FindFirstChild(cname)
        if c then
            for _, m in ipairs(c:GetChildren()) do
                if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then r[m.Name] = m end
            end
        end
    end
    return r
end

local function resolveChar(player)
    if type(Config.Decrypt.CustomResolver) == "function" then
        local ok, c = pcall(Config.Decrypt.CustomResolver, player)
        if ok and c then return c end
    end
    if player.Character then return player.Character end
    if Config.Decrypt.CoordinateDecrypt then return charCache[player] end
    return nil
end

-- ============================================================
-- GUI 容器
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AimHelperUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
do
    local ok = false
    if CoreGui then ok = pcall(function() gui.Parent = CoreGui end) end
    if not ok or not gui.Parent then gui.Parent = PG end
end

local espFolder = Instance.new("Folder")
espFolder.Name = "__AimHelperESP"
do
    local ok = false
    if CoreGui then ok = pcall(function() espFolder.Parent = CoreGui end) end
    if not ok or not espFolder.Parent then espFolder.Parent = Workspace end
end

-- ============================================================
-- 加载页 + 旋转光环
-- ============================================================
local loading = Instance.new("Frame")
loading.Size = UDim2.new(1, 0, 1, 0)
loading.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
loading.BorderSizePixel = 0
loading.ZIndex = 50
loading.Parent = gui

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, 0, 0, 40)
brand.Position = UDim2.new(0, 0, 0.5, -110)
brand.BackgroundTransparency = 1
brand.Font = Enum.Font.GothamBlack
brand.TextSize = 36
brand.TextColor3 = Color3.fromRGB(120, 150, 255)
brand.Parent = loading

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, 0, 0, 20)
subLbl.Position = UDim2.new(0, 0, 0.5, -68)
subLbl.BackgroundTransparency = 1
subLbl.Font = Enum.Font.Gotham
subLbl.TextSize = 12
subLbl.TextColor3 = Color3.fromRGB(110, 120, 160)
subLbl.Parent = loading

local ringContainer = Instance.new("Frame")
ringContainer.Size = UDim2.new(0, 120, 0, 120)
ringContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ringContainer.Position = UDim2.new(0.5, 0, 0.5, 10)
ringContainer.BackgroundTransparency = 1
ringContainer.Parent = loading

local rings = {}
for i = 1, 3 do
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(1, -((i-1) * 22), 1, -((i-1) * 22))
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.BackgroundTransparency = 1
    ring.Parent = ringContainer
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", ring)
    stroke.Thickness = 2
    stroke.Color = Color3.fromHSV((i * 0.12) % 1, 0.5, 1)
    stroke.Transparency = 0.2
    local grad = Instance.new("UIGradient", ring)
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.3, 1),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Rotation = i * 60
    rings[i] = ring
end

local pctLbl = Instance.new("TextLabel")
pctLbl.Size = UDim2.new(1, 0, 1, 0)
pctLbl.BackgroundTransparency = 1
pctLbl.Text = "0%"
pctLbl.Font = Enum.Font.GothamBlack
pctLbl.TextSize = 24
pctLbl.TextColor3 = Color3.fromRGB(150, 180, 255)
pctLbl.Parent = ringContainer

local barBG = Instance.new("Frame")
barBG.Size = UDim2.new(0, 360, 0, 4)
barBG.AnchorPoint = Vector2.new(0.5, 0.5)
barBG.Position = UDim2.new(0.5, 0, 0.5, 110)
barBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
barBG.BorderSizePixel = 0
barBG.Parent = loading
Instance.new("UICorner", barBG).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(120, 150, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBG
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local spinConnection
do
    local angle = 0
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        if not loading.Parent then
            if spinConnection then spinConnection:Disconnect() end
            return
        end
        angle += dt * 120
        for i, ring in ipairs(rings) do
            ring.Rotation = angle * (i % 2 == 0 and 1 or -1) * (1 + i * 0.3)
        end
    end)
end

-- ============================================================
-- 主面板
-- ============================================================
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 340, 0, 520)
panel.Position = UDim2.new(0, 40, 0, 40)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
panel.BackgroundTransparency = 0.03
panel.BorderSizePixel = 0
panel.Active = true
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local pStroke = Instance.new("UIStroke", panel)
pStroke.Color = Color3.fromRGB(70, 80, 140)
pStroke.Thickness = 1
pStroke.Transparency = 0.2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 8, 0, 18)
logo.Position = UDim2.new(0, 12, 0.5, -9)
logo.BackgroundColor3 = Color3.fromRGB(120, 150, 255)
logo.BorderSizePixel = 0
logo.Parent = titleBar
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -160, 1, 0)
titleText.Position = UDim2.new(0, 28, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextColor3 = Color3.fromRGB(200, 210, 255)
titleText.Parent = titleBar

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 28, 0, 28)
btnMin.Position = UDim2.new(1, -70, 0.5, -14)
btnMin.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
btnMin.BorderSizePixel = 0
btnMin.Text = "—"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 14
btnMin.TextColor3 = Color3.fromRGB(180, 180, 200)
btnMin.AutoButtonColor = false
btnMin.Parent = titleBar
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 28, 0, 28)
btnClose.Position = UDim2.new(1, -38, 0.5, -14)
btnClose.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
btnClose.BorderSizePixel = 0
btnClose.Text = "×"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.TextColor3 = Color3.fromRGB(230, 120, 120)
btnClose.AutoButtonColor = false
btnClose.Parent = titleBar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

-- 拖动
do
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 30)
tabBar.Position = UDim2.new(0, 10, 0, 44)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel
local tabLay = Instance.new("UIListLayout")
tabLay.FillDirection = Enum.FillDirection.Horizontal
tabLay.Padding = UDim.new(0, 4)
tabLay.Parent = tabBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -86)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = panel

local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -20, 0, 18)
statusBar.Position = UDim2.new(0, 10, 1, -24)
statusBar.BackgroundTransparency = 1
statusBar.Font = Enum.Font.Code
statusBar.TextSize = 10
statusBar.TextColor3 = Color3.fromRGB(110, 120, 160)
statusBar.TextXAlignment = Enum.TextXAlignment.Left
statusBar.Parent = panel

-- ============================================================
-- 控件工厂
-- ============================================================
local pages = {}
local tabButtons = {}
local tabOrder = 0
local function nextOrder() tabOrder = tabOrder + 1; return tabOrder end

local function makePage()
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Color3.fromRGB(80, 90, 140)
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Visible = false
    f.Parent = contentFrame
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = f
    return f
end

local function sectionLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextColor3 = Color3.fromRGB(120, 140, 200)
    l.LayoutOrder = nextOrder()
    l.Parent = parent
end

local function toggleRow(parent, text, getter, setter, refreshList)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = nextOrder()
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = Color3.fromRGB(210, 215, 230)
    l.Parent = btn

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 40, 0, 18)
    pill.Position = UDim2.new(1, -52, 0.5, -9)
    pill.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    pill.BorderSizePixel = 0
    pill.Parent = btn
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    dot.BorderSizePixel = 0
    dot.Parent = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = getter()
        local targetPos = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = on and Color3.fromRGB(120, 200, 140) or Color3.fromRGB(120, 120, 130)
        local pillColor = on and Color3.fromRGB(55, 90, 65) or Color3.fromRGB(40, 40, 50)
        TweenService:Create(dot, TweenInfo.new(0.15), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        TweenService:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = pillColor}):Play()
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        refresh()
        if refreshList then refreshList() end
    end)
    return btn
end

local function numberRow(parent, text, getter, setter, step, minV, maxV, refreshList)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = nextOrder()
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -170, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = Color3.fromRGB(210, 215, 230)
    l.Parent = frame

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 70, 1, 0)
    val.Position = UDim2.new(1, -150, 0, 0)
    val.BackgroundTransparency = 1
    val.TextXAlignment = Enum.TextXAlignment.Center
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextColor3 = Color3.fromRGB(150, 180, 255)
    val.Parent = frame

    local function refresh() val.Text = tostring(getter()) end
    refresh()

    local function mkbtn(label, x, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0.5, -11)
        b.BackgroundColor3 = Color3.fromRGB(52, 54, 70)
        b.BorderSizePixel = 0
        b.Text = label
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.TextColor3 = Color3.new(1, 1, 1)
        b.AutoButtonColor = false
        b.Parent = frame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(function() cb(); refresh() end)
    end
    mkbtn("-", -76, function() setter(math.clamp(getter() - step, minV, maxV)); if refreshList then refreshList() end end)
    mkbtn("+", -40, function() setter(math.clamp(getter() + step, minV, maxV)); if refreshList then refreshList() end end)
end

local function choiceRow(parent, text, options, getter, setter, displayMap, refreshList)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = nextOrder()
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -130, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = Color3.fromRGB(210, 215, 230)
    l.Parent = btn

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 110, 1, 0)
    val.Position = UDim2.new(1, -120, 0, 0)
    val.BackgroundTransparency = 1
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextColor3 = Color3.fromRGB(150, 180, 255)
    val.Parent = btn

    local function refresh()
        local cur = getter()
        val.Text = displayMap and displayMap[cur] or cur
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        for i, opt in ipairs(options) do
            if opt == getter() then
                setter(options[(i % #options) + 1])
                break
            end
        end
        refresh()
        if refreshList then refreshList() end
    end)
end

local function infoLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 32)
    l.BackgroundColor3 = Color3.fromRGB(45, 35, 35)
    l.BorderSizePixel = 0
    l.Text = text
    l.TextWrapped = true
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextColor3 = Color3.fromRGB(230, 180, 130)
    l.LayoutOrder = nextOrder()
    l.Parent = parent
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
    return l
end

-- ============================================================
-- 构建 UI
-- ============================================================
local rebuildUI

rebuildUI = function()
    local T = L[Lang]
    titleText.Text = T.title
    brand.Text = T.title
    subLbl.Text = T.subtitle
    if not pctLbl.Text:find("%%") then pctLbl.Text = T.loading end
    statusBar.Text = T.ready

    for _, b in pairs(tabButtons) do b:Destroy() end
    tabButtons = {}
    for _, f in pairs(pages) do f:Destroy() end
    pages = {}
    tabOrder = 0

    local tabNames = {
        { key = "ESP", label = T.tabESP },
        { key = "AIM", label = T.tabAim },
        { key = "SILENT", label = T.tabSilent },
        { key = "WEAPON", label = T.tabWeapon },
        { key = "CONFIG", label = T.tabSet },
    }

    for _, def in ipairs(tabNames) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 60, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
        b.BorderSizePixel = 0
        b.Text = def.label
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.fromRGB(150, 160, 190)
        b.AutoButtonColor = false
        b.Parent = tabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            for n, p in pairs(pages) do p.Visible = (n == def.key) end
            for n, bb in pairs(tabButtons) do
                local on = (n == def.key)
                bb.BackgroundColor3 = on and Color3.fromRGB(60, 75, 140) or Color3.fromRGB(30, 32, 42)
                bb.TextColor3 = on and Color3.fromRGB(230, 235, 255) or Color3.fromRGB(150, 160, 190)
            end
        end)
        tabButtons[def.key] = b
        pages[def.key] = makePage()
    end

    -- 透视页
    local espPage = pages.ESP
    sectionLabel(espPage, T.secDecrypt)
    toggleRow(espPage, T.coordDecrypt, function() return Config.Decrypt.CoordinateDecrypt end,
        function(v) Config.Decrypt.CoordinateDecrypt = v end)
    toggleRow(espPage, T.fullMapDecrypt, function() return Config.Decrypt.FullMapDecrypt end,
        function(v) Config.Decrypt.FullMapDecrypt = v end)
    sectionLabel(espPage, T.secESP)
    choiceRow(espPage, T.espMode, {"A", "B", "C", "D"},
        function() return Config.ESP.Mode end,
        function(v) Config.ESP.Mode = v end,
        {A = T.modeA, B = T.modeB, C = T.modeC, D = T.modeD})
    toggleRow(espPage, T.enableESP, function() return Config.ESP.Enabled end, function(v) Config.ESP.Enabled = v end)
    toggleRow(espPage, T.box, function() return Config.ESP.Box end, function(v) Config.ESP.Box = v end)
    toggleRow(espPage, T.name, function() return Config.ESP.Name end, function(v) Config.ESP.Name = v end)
    toggleRow(espPage, T.health, function() return Config.ESP.Health end, function(v) Config.ESP.Health = v end)
    toggleRow(espPage, T.distance, function() return Config.ESP.Distance end, function(v) Config.ESP.Distance = v end)
    toggleRow(espPage, T.tracer, function() return Config.ESP.Tracer end, function(v) Config.ESP.Tracer = v end)
    toggleRow(espPage, T.highlight, function() return Config.ESP.Highlight end, function(v) Config.ESP.Highlight = v end)
    toggleRow(espPage, T.skeleton, function() return Config.ESP.Skeleton end, function(v) Config.ESP.Skeleton = v end)
    toggleRow(espPage, T.teamCheck, function() return Config.ESP.TeamCheck end, function(v) Config.ESP.TeamCheck = v end)
    numberRow(espPage, T.maxDistance, function() return Config.ESP.MaxDistance end,
        function(v) Config.ESP.MaxDistance = v end, 100, 100, 5000)

    -- 自瞄页
    local aimPage = pages.AIM
    sectionLabel(aimPage, T.secAim)
    toggleRow(aimPage, T.enableAim, function() return Config.Aimbot.Enabled end, function(v) Config.Aimbot.Enabled = v end)
    toggleRow(aimPage, T.showFov, function() return Config.Aimbot.ShowFOV end, function(v) Config.Aimbot.ShowFOV = v end)
    toggleRow(aimPage, T.hardLock, function() return Config.Aimbot.HardLock end, function(v) Config.Aimbot.HardLock = v end)
    toggleRow(aimPage, T.wallCheck, function() return Config.Aimbot.WallCheck end, function(v) Config.Aimbot.WallCheck = v end)
    toggleRow(aimPage, T.teamCheck, function() return Config.Aimbot.TeamCheck end, function(v) Config.Aimbot.TeamCheck = v end)
    choiceRow(aimPage, T.predMode, {"Off", "Velocity", "Ballistic"},
        function() return Config.Aimbot.PredMode end,
        function(v) Config.Aimbot.PredMode = v end,
        {Off = T.predOff, Velocity = T.predVel, Ballistic = T.predBallistic})
    choiceRow(aimPage, T.aimPart, {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
        function() return Config.Aimbot.AimPart end, function(v) Config.Aimbot.AimPart = v end)
    choiceRow(aimPage, T.aimKey, {"RMB", "LMB", "MMB", "Mouse4"},
        function() return Config.Aimbot.KeyName end,
        function(v)
            Config.Aimbot.KeyName = v
            Config.Aimbot.Key = ({
                RMB = Enum.UserInputType.MouseButton2,
                LMB = Enum.UserInputType.MouseButton1,
                MMB = Enum.UserInputType.MouseButton3,
                Mouse4 = Enum.UserInputType.MouseButton4,
            })[v]
        end)
    numberRow(aimPage, T.fov, function() return Config.Aimbot.FOV end,
        function(v) Config.Aimbot.FOV = v end, 10, 10, 1200)
    numberRow(aimPage, T.smoothness, function() return Config.Aimbot.Smoothness end,
        function(v) Config.Aimbot.Smoothness = v end, 1, 1, 30)
    numberRow(aimPage, T.bulletSpeed, function() return Config.Aimbot.BulletSpeed end,
        function(v) Config.Aimbot.BulletSpeed = v end, 500, 100, 20000)
    numberRow(aimPage, T.predictionFactor, function() return Config.Aimbot.PredictionFactor end,
        function(v) Config.Aimbot.PredictionFactor = v end, 0.05, 0, 3)
    numberRow(aimPage, T.maxDistance, function() return Config.Aimbot.MaxDistance end,
        function(v) Config.Aimbot.MaxDistance = v end, 100, 100, 3000)

    -- 子弹追踪页
    local silentPage = pages.SILENT
    sectionLabel(silentPage, T.secSilent)
    toggleRow(silentPage, T.enableSilent, function() return Config.Silent.Enabled end, function(v) Config.Silent.Enabled = v end)
    toggleRow(silentPage, T.showSilentFov, function() return Config.Silent.ShowFOV end, function(v) Config.Silent.ShowFOV = v end)
    toggleRow(silentPage, T.wallCheck, function() return Config.Silent.WallCheck end, function(v) Config.Silent.WallCheck = v end)
    toggleRow(silentPage, T.teamCheck, function() return Config.Silent.TeamCheck end, function(v) Config.Silent.TeamCheck = v end)
    toggleRow(silentPage, T.modifyPos, function() return Config.Silent.ModifyPosition end, function(v) Config.Silent.ModifyPosition = v end)
    toggleRow(silentPage, T.modifyDir, function() return Config.Silent.ModifyDirection end, function(v) Config.Silent.ModifyDirection = v end)
    choiceRow(silentPage, T.predMode, {"Off", "Velocity", "Ballistic"},
        function() return Config.Silent.PredMode end,
        function(v) Config.Silent.PredMode = v end,
        {Off = T.predOff, Velocity = T.predVel, Ballistic = T.predBallistic})
    choiceRow(silentPage, T.aimPart, {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
        function() return Config.Silent.AimPart end, function(v) Config.Silent.AimPart = v end)
    numberRow(silentPage, T.silentFov, function() return Config.Silent.FOV end,
        function(v) Config.Silent.FOV = v end, 20, 20, 1500)
    numberRow(silentPage, T.bulletSpeed, function() return Config.Silent.BulletSpeed end,
        function(v) Config.Silent.BulletSpeed = v end, 500, 100, 20000)
    numberRow(silentPage, T.maxDistance, function() return Config.Silent.MaxDistance end,
        function(v) Config.Silent.MaxDistance = v end, 100, 100, 3000)
    infoLabel(silentPage, T.warning)

    -- 枪械页
    local weaponPage = pages.WEAPON
    sectionLabel(weaponPage, T.secWeapon)
    toggleRow(weaponPage, T.fireRate, function() return Config.Weapon.FireRate end, function(v) Config.Weapon.FireRate = v end)
    toggleRow(weaponPage, T.noRecoil, function() return Config.Weapon.NoRecoil end, function(v) Config.Weapon.NoRecoil = v end)
    toggleRow(weaponPage, T.noSpread, function() return Config.Weapon.NoSpread end, function(v) Config.Weapon.NoSpread = v end)
    numberRow(weaponPage, T.fireRateSpeed, function() return Config.Weapon.FireRateSpeed end,
        function(v) Config.Weapon.FireRateSpeed = v end, 0.1, 0.5, 10)
    infoLabel(weaponPage, T.warning)

    -- 设置页
    local cfgPage = pages.CONFIG
    sectionLabel(cfgPage, T.secGeneral)
    choiceRow(cfgPage, T.language, {"en", "zh"},
        function() return Lang end,
        function(v) Lang = v; rebuildUI() end,
        {en = "English", zh = "简体中文"})

    local function mkBtn(text, color, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BackgroundColor3 = color
        b.BorderSizePixel = 0
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextColor3 = Color3.new(1, 1, 1)
        b.AutoButtonColor = false
        b.LayoutOrder = nextOrder()
        b.Parent = cfgPage
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    mkBtn(T.disableAll, Color3.fromRGB(90, 50, 50), function()
        Config.ESP.Enabled = false
        Config.Aimbot.Enabled = false
        Config.Silent.Enabled = false
        Config.Weapon.FireRate = false
        Config.Weapon.NoRecoil = false
        Config.Weapon.NoSpread = false
        statusBar.Text = T.disabledAll
    end)
    mkBtn(T.unload, Color3.fromRGB(120, 60, 60), function()
        pcall(function() gui:Destroy() end)
        pcall(function() espFolder:Destroy() end)
        pcall(function() RunService:UnbindFromRenderStep("AimHelperCamera") end)
    end)

    for n, p in pairs(pages) do p.Visible = (n == "ESP") end
    for n, bb in pairs(tabButtons) do
        local on = (n == "ESP")
        bb.BackgroundColor3 = on and Color3.fromRGB(60, 75, 140) or Color3.fromRGB(30, 32, 42)
        bb.TextColor3 = on and Color3.fromRGB(230, 235, 255) or Color3.fromRGB(150, 160, 190)
    end
end

rebuildUI()

-- ============================================================
-- 范围圈 (在按钮连接之前创建)
-- ============================================================
local aimFov = Instance.new("Frame")
aimFov.AnchorPoint = Vector2.new(0.5, 0.5)
aimFov.Position = UDim2.new(0.5, 0, 0.5, 0)
aimFov.BackgroundTransparency = 1
aimFov.BorderSizePixel = 0
aimFov.Visible = false
aimFov.ZIndex = 2
aimFov.Parent = gui
Instance.new("UICorner", aimFov).CornerRadius = UDim.new(1, 0)
local aimFovStroke = Instance.new("UIStroke", aimFov)
aimFovStroke.Thickness = 1.5
aimFovStroke.Color = Color3.fromRGB(120, 200, 255)
aimFovStroke.Transparency = 0.3

local silentFov = Instance.new("Frame")
silentFov.AnchorPoint = Vector2.new(0.5, 0.5)
silentFov.Position = UDim2.new(0.5, 0, 0.5, 0)
silentFov.BackgroundTransparency = 1
silentFov.BorderSizePixel = 0
silentFov.Visible = false
silentFov.ZIndex = 2
silentFov.Parent = gui
Instance.new("UICorner", silentFov).CornerRadius = UDim.new(1, 0)
local silentFovStroke = Instance.new("UIStroke", silentFov)
silentFovStroke.Thickness = 1.5
silentFovStroke.Color = Color3.fromRGB(255, 140, 200)
silentFovStroke.Transparency = 0.3

-- ============================================================
-- 面板按钮 / 最小化 / 关闭
-- ============================================================
local function setPanelCollapsed(collapsed)
    contentFrame.Visible = not collapsed
    tabBar.Visible = not collapsed
    statusBar.Visible = not collapsed
    panel.Size = collapsed and UDim2.new(0, 340, 0, 38) or UDim2.new(0, 340, 0, 520)
end

btnMin.MouseButton1Click:Connect(function()
    setPanelCollapsed(contentFrame.Visible)
end)

btnClose.MouseButton1Click:Connect(function()
    panel.Visible = false
    aimFov.Visible = false
    silentFov.Visible = false
    statusBar.Text = L[Lang].menuHint
end)

-- ============================================================
-- 透视数据
-- ============================================================
local espData = {}

local function createESP(player)
    if player == LP or espData[player] then return end
    local d = {}

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. player.Name
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 130, 0, 44)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.ResetOnSpawn = false
    bb.Enabled = false
    bb.Adornee = nil

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = player.Name
    nameLbl.Font = Enum.Font.SourceSansBold
    nameLbl.TextSize = 14
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.TextStrokeTransparency = 0
    nameLbl.Parent = bb

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, 0, 0, 14)
    distLbl.Position = UDim2.new(0, 0, 0, 15)
    distLbl.BackgroundTransparency = 1
    distLbl.Font = Enum.Font.SourceSans
    distLbl.TextSize = 12
    distLbl.TextColor3 = Color3.new(1, 1, 1)
    distLbl.TextStrokeTransparency = 0
    distLbl.Parent = bb

    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.new(1, 0, 0, 4)
    hpBar.Position = UDim2.new(0, 0, 0, 30)
    hpBar.BackgroundColor3 = Color3.new(0, 0, 0)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBar

    d.bb = bb; d.name = nameLbl; d.dist = distLbl; d.hf = hpFill
    bb.Parent = espFolder

    local hl = Instance.new("Highlight")
    hl.FillColor = Config.ESP.Color
    hl.FillTransparency = 0.6
    hl.OutlineColor = Config.ESP.Color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Adornee = nil
    hl.Parent = espFolder
    d.hl = hl

    if Drawing then
        pcall(function()
            d.box = Drawing.new("Square")
            d.box.Thickness = 1; d.box.Filled = false
            d.box.Color = Color3.new(1, 0, 0); d.box.Visible = false
        end)
        pcall(function()
            d.tr = Drawing.new("Line")
            d.tr.Thickness = 1; d.tr.Color = Color3.new(1, 0, 0); d.tr.Visible = false
        end)
        pcall(function()
            d.bone1 = Drawing.new("Line")
            d.bone1.Thickness = 1; d.bone1.Color = Color3.fromRGB(120, 255, 255); d.bone1.Visible = false
        end)
        pcall(function()
            d.bone2 = Drawing.new("Line")
            d.bone2.Thickness = 1; d.bone2.Color = Color3.fromRGB(120, 255, 255); d.bone2.Visible = false
        end)
        pcall(function()
            d.bone3 = Drawing.new("Line")
            d.bone3.Thickness = 1; d.bone3.Color = Color3.fromRGB(120, 255, 255); d.bone3.Visible = false
        end)
        pcall(function()
            d.bone4 = Drawing.new("Line")
            d.bone4.Thickness = 1; d.bone4.Color = Color3.fromRGB(120, 255, 255); d.bone4.Visible = false
        end)
    end

    espData[player] = d
end

local function removeESP(player)
    local d = espData[player]; if not d then return end
    for _, k in ipairs({"bb","hl"}) do
        if d[k] then pcall(function() d[k]:Destroy() end) end
    end
    for _, k in ipairs({"box","tr","bone1","bone2","bone3","bone4"}) do
        if d[k] then pcall(function() d[k]:Remove() end) end
    end
    espData[player] = nil
end

local function updateESP(player)
    local d = espData[player]; if not d then return end
    local cam = Workspace.CurrentCamera; if not cam then return end
    local char, hum = getChar(player)

    if not char and Config.Decrypt.CoordinateDecrypt then
        char = resolveChar(player)
        if char then hum = char:FindFirstChildOfClass("Humanoid") end
    end

    local isTeam = player.Team and LP.Team and player.Team == LP.Team
    local hide = (not Config.ESP.Enabled) or (Config.ESP.TeamCheck and isTeam)

    local function hideAll()
        if d.bb then d.bb.Enabled = false; d.bb.Adornee = nil end
        if d.hl then d.hl.Enabled = false; d.hl.Adornee = nil end
        for _, k in ipairs({"box","tr","bone1","bone2","bone3","bone4"}) do
            if d[k] then d[k].Visible = false end
        end
    end

    if not char or not hum then hideAll(); return end

    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then hideAll(); return end

    local dist = (head.Position - cam.CFrame.Position).Magnitude
    local maxDist = Config.Decrypt.FullMapDecrypt and math.huge or Config.ESP.MaxDistance
    local visible = (not hide) and dist <= maxDist
    local color = isTeam and Config.ESP.TeamColor or Config.ESP.Color
    if not visible then hideAll(); return end

    local mode = Config.ESP.Mode

    if d.bb then
        if mode == "A" then
            d.bb.Adornee = head
            d.bb.Enabled = true
            d.name.Visible = Config.ESP.Name
            d.dist.Visible = Config.ESP.Distance
            d.dist.Text = string.format("[%d]", math.floor(dist))
            local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            d.hf.Size = UDim2.new(hp, 0, 1, 0)
            d.hf.BackgroundColor3 = Color3.fromHSV(hp * 0.3, 1, 1)
        else
            d.bb.Enabled = false
            d.bb.Adornee = nil
        end
    end

    if d.hl then
        local showHL = Config.ESP.Highlight and (mode == "A" or mode == "B" or mode == "D")
        d.hl.Adornee = showHL and char or nil
        d.hl.Enabled = showHL
        d.hl.FillColor = color
        d.hl.OutlineColor = color
    end

    local headScreen = worldToScreen(head.Position + Vector3.new(0, 1.2, 0))
    local root = char:FindFirstChild("HumanoidRootPart")
    local footScreen = root and worldToScreen(root.Position - Vector3.new(0, 2.6, 0))

    if d.box then
        if (mode == "A" or mode == "C" or mode == "D") and Config.ESP.Box
        and headScreen and footScreen and not Config.Decrypt.FullMapDecrypt then
            local h = math.abs(footScreen.Y - headScreen.Y)
            local w = h * 0.5
            d.box.Size = Vector2.new(w, h)
            d.box.Position = Vector2.new(headScreen.X - w / 2, headScreen.Y)
            d.box.Color = color
            d.box.Visible = true
        else
            d.box.Visible = false
        end
    end
    if d.tr then
        if (mode == "A" or mode == "C") and Config.ESP.Tracer
        and headScreen and not Config.Decrypt.FullMapDecrypt then
            d.tr.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
            d.tr.To = headScreen
            d.tr.Color = color
            d.tr.Visible = true
        else
            d.tr.Visible = false
        end
    end

    local function hideBones()
        for _, k in ipairs({"bone1","bone2","bone3","bone4"}) do
            if d[k] then d[k].Visible = false end
        end
    end
    if mode == "D" and Config.ESP.Skeleton and not Config.Decrypt.FullMapDecrypt then
        local ut = char:FindFirstChild("UpperTorso")
        local lt = char:FindFirstChild("LowerTorso")
        local lf = char:FindFirstChild("LeftFoot") or char:FindFirstChild("LeftLeg")
        local rf = char:FindFirstChild("RightFoot") or char:FindFirstChild("RightLeg")
        local function s(p) return p and worldToScreen(p.Position) end
        local sHead, sUT, sLT, sLF, sRF = s(head), s(ut), s(lt), s(lf), s(rf)
        if d.bone1 and sHead and sUT then
            d.bone1.From = sHead; d.bone1.To = sUT; d.bone1.Visible = true
        else if d.bone1 then d.bone1.Visible = false end end
        if d.bone2 and sUT and sLT then
            d.bone2.From = sUT; d.bone2.To = sLT; d.bone2.Visible = true
        else if d.bone2 then d.bone2.Visible = false end end
        if d.bone3 and sLT and sLF then
            d.bone3.From = sLT; d.bone3.To = sLF; d.bone3.Visible = true
        else if d.bone3 then d.bone3.Visible = false end end
        if d.bone4 and sLT and sRF then
            d.bone4.From = sLT; d.bone4.To = sRF; d.bone4.Visible = true
        else if d.bone4 then d.bone4.Visible = false end end
    else
        hideBones()
    end
end

-- ============================================================
-- 自瞄 (预判模式: Off / Velocity / Ballistic)
-- ============================================================
local aiming = false

local function getTargetList(cfg)
    local cam = Workspace.CurrentCamera; if not cam then return {} end
    local camPos = cam.CFrame.Position
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local list = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local isTeam = p.Team and LP.Team and p.Team == LP.Team
            if not (cfg.TeamCheck and isTeam) then
                local char = resolveChar(p)
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = getAimPart(char, cfg.AimPart)
                        if part then
                            local d = (part.Position - camPos).Magnitude
                            if d <= cfg.MaxDistance then
                                local pass = true
                                if cfg.WallCheck then
                                    local rp = RaycastParams.new()
                                    rp.FilterType = Enum.RaycastFilterType.Exclude
                                    rp.FilterDescendantsInstances = { char, LP.Character }
                                    local hit = Workspace:Raycast(camPos, part.Position - camPos, rp)
                                    if hit then pass = false end
                                end
                                if pass then
                                    local sp = worldToScreen(part.Position)
                                    if sp then
                                        local sd = (sp - center).Magnitude
                                        if sd <= cfg.FOV then
                                            list[#list + 1] = { part = part, dist = d, sd = sd, char = char, hum = hum }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.sd < b.sd end)
    return list
end

pcall(function() RunService:UnbindFromRenderStep("AimHelperCamera") end)
RunService:BindToRenderStep("AimHelperCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local cam = Workspace.CurrentCamera; if not cam then return end

    -- 范围圈
    local aimSize = Config.Aimbot.FOV * 2
    aimFov.Size = UDim2.new(0, aimSize, 0, aimSize)
    aimFov.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled and panel.Visible

    local silentSize = Config.Silent.FOV * 2
    silentFov.Size = UDim2.new(0, silentSize, 0, silentSize)
    silentFov.Visible = Config.Silent.ShowFOV and Config.Silent.Enabled and panel.Visible

    if not aiming or not Config.Aimbot.Enabled then return end

    local list = getTargetList(Config.Aimbot)
    local target = list[1]
    if not target then return end

    local camPos = cam.CFrame.Position
    local targetPos = predictPos(camPos, target.part, Config.Aimbot.PredMode,
        Config.Aimbot.BulletSpeed, Config.Aimbot.PredictionFactor, Config.Aimbot.PredictionIterations)
    local dir = targetPos - camPos
    if dir.Magnitude < 0.1 then return end

    local targetCF = CFrame.lookAt(camPos, camPos + dir.Unit)

    if Config.Aimbot.HardLock then
        cam.CFrame = targetCF
    else
        local smooth = math.max(Config.Aimbot.Smoothness, 1)
        local alpha = 1 - math.exp(-dt * smooth)
        cam.CFrame = cam.CFrame:Lerp(targetCF, alpha)
    end
end)

-- ============================================================
-- 子弹追踪 (多层参数探测)
-- ============================================================
local function isDirVec(v)
    return v.Magnitude > 0.5 and v.Magnitude < 1.5
end

local traceOnce = false

local function rewriteArg(arg, origin, targetPos, lookCF)
    local t = typeof(arg)
    if t == "Vector3" then
        if Config.Silent.ModifyDirection and isDirVec(arg) then
            local desired = targetPos - origin
            if desired.Magnitude > 0.001 then return desired.Unit end
        elseif Config.Silent.ModifyPosition then
            if (arg - origin).Magnitude > 5 then return targetPos end
        end
    elseif t == "CFrame" and Config.Silent.ModifyDirection then
        return lookCF
    elseif t == "table" then
        local copy = {}
        for k, v in pairs(arg) do copy[k] = rewriteArg(v, origin, targetPos, lookCF) end
        return copy
    end
    return arg
end

local SILENT_REMOTE_NAMES = {
    Fire = true, Shoot = true, Hit = true, FireWeapon = true, Shot = true,
    Bullet = true, Projectile = true, Damage = true, DealDamage = true,
    FireGun = true, Attack = true, FireBullet = true,
}

local function getSelfOrigin()
    local char = LP.Character
    if not char then return Workspace.CurrentCamera.CFrame.Position end
    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    return part and part.Position or Workspace.CurrentCamera.CFrame.Position
end

local function currentSilentTarget()
    if not Config.Silent.Enabled then return nil end
    local list = getTargetList(Config.Silent)
    return list[1]
end

do
    local getrawmetatable   = rawget(_G, "getrawmetatable")
    local setreadonly       = rawget(_G, "setreadonly")
    local newcclosure       = rawget(_G, "newcclosure") or function(f) return f end
    local getnamecallmethod = rawget(_G, "getnamecallmethod")

    if type(getgenv) == "function" then
        local g = getgenv()
        if type(g) == "table" then
            getrawmetatable   = getrawmetatable   or g.getrawmetatable
            setreadonly       = setreadonly       or g.setreadonly
            newcclosure       = g.newcclosure     or newcclosure
            getnamecallmethod = getnamecallmethod or g.getnamecallmethod
        end
    end

    if getrawmetatable and setreadonly and getnamecallmethod then
        pcall(function()
            local mt = getrawmetatable(game)
            local orig = mt.__namecall
            if type(orig) ~= "function" then return end
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if (method == "FireServer" or method == "InvokeServer")
                and self and self.Name and SILENT_REMOTE_NAMES[self.Name]
                and Config.Silent.Enabled then
                    local target = currentSilentTarget()
                    if target then
                        local origin = getSelfOrigin()
                        local tPos = predictPos(origin, target.part, Config.Silent.PredMode,
                            Config.Silent.BulletSpeed, 1.0, 3)
                        local lookCF = CFrame.lookAt(origin, tPos)
                        local args = { ... }

                        -- 第一次触发时打印原始参数, 方便你贴给我
                        if not traceOnce then
                            traceOnce = true
                            print("[Silent] Remote:", self:GetFullName())
                            for i, a in ipairs(args) do
                                print(string.format("  arg[%d] type=%s value=%s", i, typeof(a), tostring(a)))
                            end
                        end

                        for i = 1, #args do
                            args[i] = rewriteArg(args[i], origin, tPos, lookCF)
                        end
                        return orig(self, table.unpack(args))
                    end
                end
                return orig(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end
end

-- ============================================================
-- 射速 / 无后座 (每 0.5 秒重试)
-- ============================================================
task.spawn(function()
    while gui.Parent do
        if Config.Weapon.FireRate or Config.Weapon.NoRecoil or Config.Weapon.NoSpread then
            local rs = game:GetService("ReplicatedStorage")
            local weapons = rs:FindFirstChild("Weapons")
            if weapons then
                local remotes = weapons:FindFirstChild("Remotes")
                if remotes then
                    if Config.Weapon.FireRate then
                        local r = remotes:FindFirstChild("SetFireRate")
                        if r then pcall(function() r:FireServer(Config.Weapon.FireRateSpeed) end) end
                    end
                    if Config.Weapon.NoRecoil then
                        local r = remotes:FindFirstChild("SetRecoil")
                        if r then pcall(function() r:FireServer(0) end) end
                    end
                    if Config.Weapon.NoSpread then
                        local r = remotes:FindFirstChild("SetSpread")
                        if r then pcall(function() r:FireServer(0) end) end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ============================================================
-- 输入
-- ============================================================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Config.Aimbot.Key then aiming = true end
    if input.KeyCode == Enum.KeyCode.Insert then
        panel.Visible = not panel.Visible
        if panel.Visible then
            setPanelCollapsed(false)
            aimFov.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
            silentFov.Visible = Config.Silent.ShowFOV and Config.Silent.Enabled
        else
            aimFov.Visible = false
            silentFov.Visible = false
        end
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.Silent.Enabled = not Config.Silent.Enabled
        rebuildUI()
    end
end)
UIS.InputEnded:Connect(function(input, _)
    if input.UserInputType == Config.Aimbot.Key then aiming = false end
end)

-- ============================================================
-- 玩家事件 + 主循环
-- ============================================================
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

task.spawn(function()
    while gui.Parent do
        if Config.Decrypt.CoordinateDecrypt then
            charCache = scanChars()
        else
            charCache = {}
        end
        task.wait(1)
    end
end)

RunService.RenderStepped:Connect(function()
    for p in pairs(espData) do updateESP(p) end
end)

-- ============================================================
-- 加载完成
-- ============================================================
local duration = 2.0
local t0 = tick()
task.spawn(function()
    while true do
        local p = math.clamp((tick() - t0) / duration, 0, 1)
        local eased = 1 - (1 - p) ^ 3
        barFill.Size = UDim2.new(eased, 0, 1, 0)
        pctLbl.Text = string.format("%d%%", math.floor(eased * 100))
        if p >= 1 then break end
        task.wait(0.02)
    end
    task.wait(0.2)
    if spinConnection then spinConnection:Disconnect() end
    TweenService:Create(loading, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    for _, ch in ipairs(loading:GetDescendants()) do
        if ch:IsA("TextLabel") then
            TweenService:Create(ch, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        elseif ch:IsA("Frame") then
            TweenService:Create(ch, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        end
    end
    task.wait(0.5)
    loading:Destroy()
    panel.Visible = true
    statusBar.Text = L[Lang].menuHint
end)

if type(getgenv) == "function" then
    local g = getgenv()
    if type(g) == "table" then
        g.AimHelper = { Config = Config, Panel = panel, Gui = gui }
    end
end

end, function(e)
    return tostring(e) .. "\n" .. debug.traceback()
end)

if not _ok then
    pcall(function()
        local PG = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if PG then
            local sg = Instance.new("ScreenGui")
            sg.Name = "AimHelperError"; sg.Parent = PG
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0, 700, 0, 260)
            l.Position = UDim2.new(0, 20, 0, 20)
            l.BackgroundColor3 = Color3.new(0, 0, 0)
            l.BackgroundTransparency = 0.15
            l.TextColor3 = Color3.fromRGB(255, 100, 100)
            l.Text = "AimHelper Error:\n" .. tostring(_err)
            l.TextWrapped = true
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextYAlignment = Enum.TextYAlignment.Top
            l.Font = Enum.Font.Code
            l.TextSize = 11
            l.Parent = sg
        end
    end)
    warn("[AimHelper] " .. tostring(_err))
end