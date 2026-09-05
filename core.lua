-- King Legacy Auto Bounty + Direct Tier System (v9.1 Optimized ESP Core)

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- 直接從全域變數讀取身分 (由 loader 傳入，預設若無則為 VIP)
local userTier = getgenv().USER_TIER or "VIP"

-- ========== 多語言字典 (Multi-Language Dictionary) ==========
local currentLang = "ZH"

local Lang = {
    ZH = {
        titleVIP = "KING LEGACY | VIP 全功能版",
        titleFree = "KING LEGACY | FREE 自瞄版",
        statusOff = "狀態：已停用",
        statusOn = "狀態：執行中...",
        tabMain = "主要控制",
        tabSkill = "技能與欄位",
        btnAutoStart = "▶ 啟動自動刷賞金",
        btnAutoStop = "⏸ 停止自動刷賞金",
        btnAimOff = "🌐 360°全方位技能追蹤/自瞄: OFF",
        btnAimOn = "🌐 360°全方位技能追蹤/自瞄: ON",
        btnStickOff = "極限吸附跟隨: OFF",
        btnStickOn = "極限吸附跟隨: ON",
        btnEspOff = "👁️ 頂級玩家透視 (ESP): OFF",
        btnEspOn = "👁️ 頂級玩家透視 (ESP): ON",
        targetPlaceholder = "🔍 輸入指定玩家 (留空自動鎖定)...",
        btnSwitchTarget = "👤 切換下個目標",
        btnHop = "🌐 自動伺服器 Hop",
        slot1 = "[ 1 ] 欄位", slot2 = "[ 2 ] 欄位", slot3 = "[ 3 ] 欄位",
        skillBtn = "技能 "
    },
    EN = {
        titleVIP = "KING LEGACY | VIP Full Version",
        titleFree = "KING LEGACY | FREE Aim Version",
        statusOff = "Status: Disabled",
        statusOn = "Status: Running...",
        tabMain = "Main Controls",
        tabSkill = "Skills & Slots",
        btnAutoStart = "▶ Start Auto Bounty",
        btnAutoStop = "⏸ Stop Auto Bounty",
        btnAimOff = "🌐 360° Skill Aimlock: OFF",
        btnAimOn = "🌐 360° Skill Aimlock: ON",
        btnStickOff = "Target Lock Magnet: OFF",
        btnStickOn = "Target Lock Magnet: ON",
        btnEspOff = "👁️ Pro Player ESP: OFF",
        btnEspOn = "👁️ Pro Player ESP: ON",
        targetPlaceholder = "🔍 Enter Player Name (Blank = Nearest)...",
        btnSwitchTarget = "👤 Switch Target",
        btnHop = "🌐 Server Hop",
        slot1 = "[ 1 ] Slot", slot2 = "[ 2 ] Slot", slot3 = "[ 3 ] Slot",
        skillBtn = "Skill "
    }
}

local function applyCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function bindResponsiveClick(button, callback)
    button.Activated:Connect(callback)
    button.MouseEnter:Connect(function() button.BackgroundTransparency = 0.15 end)
    button.MouseLeave:Connect(function() button.BackgroundTransparency = 0 end)
end

-- ========== [主程式 UI 與功能變數] ==========

local stop = false              
local autoEnabled = false       
local stickDeadTarget = true    
local standaloneAimEnabled = false 
local espEnabled = false
local manualTarget             
local isTeleporting = false    
local currentTarget = nil       
local espCache = {}

local SkillKeys = {
    [Enum.KeyCode.Q] = true, [Enum.KeyCode.Z] = true,
    [Enum.KeyCode.X] = false, [Enum.KeyCode.C] = false,
    [Enum.KeyCode.V] = false, [Enum.KeyCode.E] = false,
    [Enum.KeyCode.T] = true, [Enum.KeyCode.Y] = true,
}

local SlotKeys = {
    [Enum.KeyCode.One] = true, [Enum.KeyCode.Two] = true, [Enum.KeyCode.Three] = true
}

local gui = Instance.new("ScreenGui")
gui.Name = "KingLegacy_BountyHub_v91"
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, userTier == "VIP" and 450 or 100)
mainFrame.Position = UDim2.new(0, 30, 0.5, userTier == "VIP" and -225 or -50)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.Active = true
mainFrame.Parent = gui
applyCorner(mainFrame, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
topBar.Parent = mainFrame
applyCorner(topBar, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -85, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = userTier == "VIP" and Lang[currentLang].titleVIP or Lang[currentLang].titleFree
titleLabel.TextColor3 = userTier == "VIP" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 200, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- 主介面語言切換鈕
local mainLangBtn = Instance.new("TextButton")
mainLangBtn.Size = UDim2.new(0, 32, 0, 22)
mainLangBtn.Position = UDim2.new(1, -66, 0, 7)
mainLangBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
mainLangBtn.Text = currentLang == "ZH" and "EN" or "中文"
mainLangBtn.TextColor3 = Color3.new(1, 1, 1)
mainLangBtn.Font = Enum.Font.GothamBold
mainLangBtn.TextSize = 10
mainLangBtn.Parent = topBar
applyCorner(mainLangBtn, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar
applyCorner(closeBtn, 5)

bindResponsiveClick(closeBtn, function()
    stop = true
    autoEnabled = false
    standaloneAimEnabled = false
    espEnabled = false
    for _, cache in pairs(espCache) do
        for _, obj in pairs(cache) do obj:Remove() end
    end
    gui:Destroy()
end)

local uiElements = {}

local function updateLanguage()
    titleLabel.Text = userTier == "VIP" and Lang[currentLang].titleVIP or Lang[currentLang].titleFree
    mainLangBtn.Text = currentLang == "ZH" and "EN" or "中文"

    if userTier == "FREE" then
        if uiElements.aimBtn then
            uiElements.aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
        end
    else
        if uiElements.statusText then
            uiElements.statusText.Text = autoEnabled and Lang[currentLang].statusOn or Lang[currentLang].statusOff
        end
        if uiElements.mainTabBtn then uiElements.mainTabBtn.Text = Lang[currentLang].tabMain end
        if uiElements.skillTabBtn then uiElements.skillTabBtn.Text = Lang[currentLang].tabSkill end
        if uiElements.autoBtn then
            uiElements.autoBtn.Text = autoEnabled and Lang[currentLang].btnAutoStop or Lang[currentLang].btnAutoStart
        end
        if uiElements.aimBtn then
            uiElements.aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
        end
        if uiElements.stickBtn then
            uiElements.stickBtn.Text = stickDeadTarget and Lang[currentLang].btnStickOn or Lang[currentLang].btnStickOff
        end
        if uiElements.espBtn then
            uiElements.espBtn.Text = espEnabled and Lang[currentLang].btnEspOn or Lang[currentLang].btnEspOff
        end
        if uiElements.targetInput then uiElements.targetInput.PlaceholderText = Lang[currentLang].targetPlaceholder end
        if uiElements.switchBtn then uiElements.switchBtn.Text = Lang[currentLang].btnSwitchTarget end
        if uiElements.hopBtn then uiElements.hopBtn.Text = Lang[currentLang].btnHop end
    end
end

mainLangBtn.Activated:Connect(function()
    currentLang = currentLang == "ZH" and "EN" or "ZH"
    updateLanguage()
end)

-- FREE 模式介面
if userTier == "FREE" then
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(1, -20, 0, 40)
    aimBtn.Position = UDim2.new(0, 10, 0, 48)
    aimBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    aimBtn.Text = Lang[currentLang].btnAimOff
    aimBtn.TextColor3 = Color3.new(1, 1, 1)
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.TextSize = 11
    aimBtn.Parent = mainFrame
    applyCorner(aimBtn, 6)
    uiElements.aimBtn = aimBtn

    bindResponsiveClick(aimBtn, function()
        standaloneAimEnabled = not standaloneAimEnabled
        aimBtn.BackgroundColor3 = standaloneAimEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(28, 28, 36)
        aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
    end)
end

-- VIP 模式介面
if userTier == "VIP" then
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -20, 0, 28)
    statusFrame.Position = UDim2.new(0, 10, 0, 42)
    statusFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    statusFrame.Parent = mainFrame
    applyCorner(statusFrame, 6)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 10, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    statusDot.Parent = statusFrame
    applyCorner(statusDot, 4)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -30, 1, 0)
    statusText.Position = UDim2.new(0, 24, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = Lang[currentLang].statusOff
    statusText.TextColor3 = Color3.fromRGB(180, 180, 195)
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusFrame
    uiElements.statusText = statusText

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 28)
    tabContainer.Position = UDim2.new(0, 10, 0, 76)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local mainTabBtn = Instance.new("TextButton")
    mainTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    mainTabBtn.Text = Lang[currentLang].tabMain
    mainTabBtn.TextColor3 = Color3.new(1, 1, 1)
    mainTabBtn.Font = Enum.Font.GothamBold
    mainTabBtn.TextSize = 11
    mainTabBtn.Parent = tabContainer
    applyCorner(mainTabBtn, 6)
    uiElements.mainTabBtn = mainTabBtn

    local skillTabBtn = Instance.new("TextButton")
    skillTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
    skillTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
    skillTabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    skillTabBtn.Text = Lang[currentLang].tabSkill
    skillTabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    skillTabBtn.Font = Enum.Font.GothamBold
    skillTabBtn.TextSize = 11
    skillTabBtn.Parent = tabContainer
    applyCorner(skillTabBtn, 6)
    uiElements.skillTabBtn = skillTabBtn

    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -20, 0, 330)
    pageContainer.Position = UDim2.new(0, 10, 0, 110)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = mainFrame

    local mainPage = Instance.new("Frame")
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    mainPage.BackgroundTransparency = 1
    mainPage.Parent = pageContainer

    local skillPage = Instance.new("Frame")
    skillPage.Size = UDim2.new(1, 0, 1, 0)
    skillPage.BackgroundTransparency = 1
    skillPage.Visible = false
    skillPage.Parent = pageContainer

    bindResponsiveClick(mainTabBtn, function()
        mainPage.Visible = true; skillPage.Visible = false
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60); mainTabBtn.TextColor3 = Color3.new(1, 1, 1)
        skillTabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36); skillTabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    end)

    bindResponsiveClick(skillTabBtn, function()
        mainPage.Visible = false; skillPage.Visible = true
        skillTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60); skillTabBtn.TextColor3 = Color3.new(1, 1, 1)
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36); mainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    end)

    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, 0, 0, 34)
    autoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    autoBtn.Text = Lang[currentLang].btnAutoStart
    autoBtn.TextColor3 = Color3.fromRGB(0, 220, 130)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    autoBtn.Parent = mainPage
    applyCorner(autoBtn, 6)
    uiElements.autoBtn = autoBtn

    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(1, 0, 0, 28)
    aimBtn.Position = UDim2.new(0, 0, 0, 40)
    aimBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    aimBtn.Text = Lang[currentLang].btnAimOff
    aimBtn.TextColor3 = Color3.new(1, 1, 1)
    aimBtn.Font = Enum.Font.GothamMedium
    aimBtn.TextSize = 11
    aimBtn.Parent = mainPage
    applyCorner(aimBtn, 6)
    uiElements.aimBtn = aimBtn

    bindResponsiveClick(aimBtn, function()
        standaloneAimEnabled = not standaloneAimEnabled
        aimBtn.BackgroundColor3 = standaloneAimEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(28, 28, 36)
        aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
    end)

    local stickBtn = Instance.new("TextButton")
    stickBtn.Size = UDim2.new(1, 0, 0, 28)
    stickBtn.Position = UDim2.new(0, 0, 0, 74)
    stickBtn.BackgroundColor3 = stickDeadTarget and Color3.fromRGB(120, 50, 20) or Color3.fromRGB(28, 28, 36)
    stickBtn.Text = stickDeadTarget and Lang[currentLang].btnStickOn or Lang[currentLang].btnStickOff
    stickBtn.TextColor3 = Color3.new(1, 1, 1)
    stickBtn.Font = Enum.Font.GothamMedium
    stickBtn.TextSize = 11
    stickBtn.Parent = mainPage
    applyCorner(stickBtn, 6)
    uiElements.stickBtn = stickBtn

    bindResponsiveClick(stickBtn, function()
        stickDeadTarget = not stickDeadTarget
        stickBtn.BackgroundColor3 = stickDeadTarget and Color3.fromRGB(120, 50, 20) or Color3.fromRGB(28, 28, 36)
        stickBtn.Text = stickDeadTarget and Lang[currentLang].btnStickOn or Lang[currentLang].btnStickOff
    end)

    -- 升級版 ESP 按鈕
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(1, 0, 0, 28)
    espBtn.Position = UDim2.new(0, 0, 0, 108)
    espBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    espBtn.Text = Lang[currentLang].btnEspOff
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.Font = Enum.Font.GothamMedium
    espBtn.TextSize = 11
    espBtn.Parent = mainPage
    applyCorner(espBtn, 6)
    uiElements.espBtn = espBtn

    bindResponsiveClick(espBtn, function()
        espEnabled = not espEnabled
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(28, 28, 36)
        espBtn.Text = espEnabled and Lang[currentLang].btnEspOn or Lang[currentLang].btnEspOff
    end)

    local targetInput = Instance.new("TextBox")
    targetInput.Size = UDim2.new(1, 0, 0, 30)
    targetInput.Position = UDim2.new(0, 0, 0, 142)
    targetInput.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    targetInput.PlaceholderText = Lang[currentLang].targetPlaceholder
    targetInput.Text = ""
    targetInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    targetInput.Font = Enum.Font.Gotham
    targetInput.TextSize = 11
    targetInput.Parent = mainPage
    applyCorner(targetInput, 6)
    uiElements.targetInput = targetInput

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0.48, 0, 0, 30)
    switchBtn.Position = UDim2.new(0, 0, 0, 178)
    switchBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    switchBtn.Text = Lang[currentLang].btnSwitchTarget
    switchBtn.TextColor3 = Color3.new(1, 1, 1)
    switchBtn.Font = Enum.Font.GothamMedium
    switchBtn.TextSize = 11
    switchBtn.Parent = mainPage
    applyCorner(switchBtn, 6)
    uiElements.switchBtn = switchBtn

    local hopBtn = Instance.new("TextButton")
    hopBtn.Size = UDim2.new(0.48, 0, 0, 30)
    hopBtn.Position = UDim2.new(0.52, 0, 0, 178)
    hopBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    hopBtn.Text = Lang[currentLang].btnHop
    hopBtn.TextColor3 = Color3.new(1, 1, 1)
    hopBtn.Font = Enum.Font.GothamMedium
    hopBtn.TextSize = 11
    hopBtn.Parent = mainPage
    applyCorner(hopBtn, 6)
    uiElements.hopBtn = hopBtn

    -- 欄位與技能列表
    local slotList = {{key = Enum.KeyCode.One, id = "slot1"}, {key = Enum.KeyCode.Two, id = "slot2"}, {key = Enum.KeyCode.Three, id = "slot3"}}
    for i, item in ipairs(slotList) do
        local sBtn = Instance.new("TextButton")
        sBtn.Size = UDim2.new(0.31, 0, 0, 28)
        sBtn.Position = UDim2.new((i - 1) * 0.345, 0, 0, 10)
        sBtn.BackgroundColor3 = SlotKeys[item.key] and Color3.fromRGB(0, 110, 180) or Color3.fromRGB(28, 28, 36)
        sBtn.Text = Lang[currentLang][item.id]
        sBtn.TextColor3 = Color3.new(1, 1, 1)
        sBtn.Font = Enum.Font.GothamMedium
        sBtn.TextSize = 10
        sBtn.Parent = skillPage
        applyCorner(sBtn, 5)

        bindResponsiveClick(sBtn, function()
            SlotKeys[item.key] = not SlotKeys[item.key]
            sBtn.BackgroundColor3 = SlotKeys[item.key] and Color3.fromRGB(0, 110, 180) or Color3.fromRGB(28, 28, 36)
        end)
    end

    local keysList = {Enum.KeyCode.Q, Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.E, Enum.KeyCode.T, Enum.KeyCode.Y}
    for i, key in ipairs(keysList) do
        local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
        local kBtn = Instance.new("TextButton")
        kBtn.Size = UDim2.new(0.31, 0, 0, 28)
        kBtn.Position = UDim2.new(col * 0.345, 0, 0, 50 + row * 34)
        kBtn.BackgroundColor3 = SkillKeys[key] and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(28, 28, 36)
        kBtn.Text = Lang[currentLang].skillBtn .. key.Name
        kBtn.TextColor3 = Color3.new(1, 1, 1)
        kBtn.Font = Enum.Font.GothamMedium
        kBtn.TextSize = 10
        kBtn.Parent = skillPage
        applyCorner(kBtn, 5)

        bindResponsiveClick(kBtn, function()
            SkillKeys[key] = not SkillKeys[key]
            kBtn.BackgroundColor3 = SkillKeys[key] and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(28, 28, 36)
        end)
    end

    bindResponsiveClick(autoBtn, function()
        autoEnabled = not autoEnabled
        if autoEnabled then
            autoBtn.Text = Lang[currentLang].btnAutoStop
            autoBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
            statusText.Text = Lang[currentLang].statusOn
        else
            autoBtn.Text = Lang[currentLang].btnAutoStart
            autoBtn.TextColor3 = Color3.fromRGB(0, 220, 130)
            statusDot.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            statusText.Text = Lang[currentLang].statusOff
        end
    end)
end

-- 平滑拖動 UI
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = mainFrame.Position:Lerp(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), 0.4)
    end
end)

-- ========== 頂級優化 ESP 系統初始化 ==========
local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false

    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Thickness = 3

    local healthBarBg = Drawing.new("Line")
    healthBarBg.Visible = false
    healthBarBg.Thickness = 3
    healthBarBg.Color = Color3.fromRGB(30, 30, 30)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true
    nameText.Font = 2
    nameText.Size = 13
    nameText.Color = Color3.fromRGB(255, 255, 255)

    espCache[player] = {
        Box = box,
        HealthBar = healthBar,
        HealthBarBg = healthBarBg,
        NameText = nameText
    }
end

local function removeESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            obj:Remove()
        end
        espCache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then createESP(p) end
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ========== 核心 360° 自瞄與 ESP 總迴圈 ==========
local function getClosestPlayer()
    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local closest, shortestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (myHRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function(deltaTime)
    -- 1. 處理高階優化 ESP 渲染 (方框、血量條、名稱)
    for p, cache in pairs(espCache) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if espEnabled and hrp and hum and hum.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = math.clamp(2500 / vector.Z, 15, 300)
                local width = size * 0.6
                local height = size
                local posX = vector.X - width / 2
                local posY = vector.Y - height / 2

                -- 隊友顏色判定
                local teamColor = (p.Team and lp.Team and p.Team == lp.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)

                -- 方框更新
                cache.Box.Size = Vector2.new(width, height)
                cache.Box.Position = Vector2.new(posX, posY)
                cache.Box.Color = teamColor
                cache.Box.Visible = true

                -- 血量條背景與動態血量計算
                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barHeight = height * healthPercent
                
                cache.HealthBarBg.From = Vector2.new(posX - 6, posY + height)
                cache.HealthBarBg.To = Vector2.new(posX - 6, posY)
                cache.HealthBarBg.Visible = true

                cache.HealthBar.From = Vector2.new(posX - 6, posY + height)
                cache.HealthBar.To = Vector2.new(posX - 6, posY + (height - barHeight))
                cache.HealthBar.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                cache.HealthBar.Visible = true

                -- 玩家名稱更新
                cache.NameText.Text = p.Name .. " [" .. math.floor(hum.Health) .. "]"
                cache.NameText.Position = Vector2.new(vector.X, posY - 18)
                cache.NameText.Visible = true
            else
                cache.Box.Visible = false
                cache.HealthBar.Visible = false
                cache.HealthBarBg.Visible = false
                cache.NameText.Visible = false
            end
        else
            cache.Box.Visible = false
            cache.HealthBar.Visible = false
            cache.HealthBarBg.Visible = false
            cache.NameText.Visible = false
        end
    end

    if isTeleporting then return end

    local targetToLock = nil
    if autoEnabled and userTier == "VIP" then targetToLock = currentTarget
    elseif standaloneAimEnabled then targetToLock = manualTarget or getClosestPlayer() end

    if not targetToLock then return end

    local myChar, tChar = lp.Character, targetToLock.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local tHRP = tChar and (tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head"))
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")

    if myHRP and myHum and myHum.Health > 0 and tHRP and tHum and tHum.Health > 0 then
        if autoEnabled and stickDeadTarget and userTier == "VIP" then
            local targetCFrame = tHRP.CFrame * CFrame.new(0, 0, 1.5)
            myHRP.CFrame = myHRP.CFrame:Lerp(targetCFrame, math.clamp(deltaTime * 25, 0, 1))
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
        
        local velocity = tHRP.AssemblyLinearVelocity or Vector3.zero
        local distance = (tHRP.Position - myHRP.Position).Magnitude
        local timeOffset = math.clamp(distance / 120, 0.08, 0.25)
        local predictedPos = tHRP.Position + Vector3.new(0, 0.5, 0) + (velocity * timeOffset)

        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, predictedPos), math.clamp(deltaTime * 35, 0, 1))

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if onScreen then VIM:SendMouseMoveEvent(screenPos.X, screenPos.Y, game) end
    end
end)
