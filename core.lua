-- King Legacy Auto Bounty + Direct Tier System (v9.8 Extra Large & Rounded Hand-Written Style UI & ESP Core)

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer
local userTier = getgenv().USER_TIER or "VIP"

-- ========== 多語言字典 (全域超大圓潤手寫風版) ==========
local currentLang = "ZH"

local Lang = {
    ZH = {
        titleVIP = "⚜ 👑 KING LEGACY | 頂級奢華 VIP 核心 👑 ⚜",
        titleFree = "✦ ⚡ KING LEGACY | 輕量奢華 FREE 版 ⚡ ✦",
        statusOff = "❖ 狀態：系統安全待命中 ✦",
        statusOn = "⚡ 狀態：極速自動掛機掠奪中... ⚜",
        tabMain = "❖ 核心控制面板",
        tabSkill = "⚡ 戰鬥技能配置",
        btnAutoStart = "▶ 啟動自動刷賞金系統",
        btnAutoStop = "⏸ 暫停自動刷賞金系統",
        btnAimOff = "🌐 360° 全方位自瞄追蹤 ➔ [ 關閉 ]",
        btnAimOn = "🌐 360° 全方位自瞄追蹤 ➔ [ 開啟 ⚡ ]",
        btnStickOff = "🔒 極限目標吸附跟隨 ➔ [ 關閉 ]",
        btnStickOn = "🔒 極限目標吸附跟隨 ➔ [ 開啟 ⚜ ]",
        btnEspOff = "👁️ 頂級精準玩家透視 (ESP) ➔ [ 關閉 ]",
        btnEspOn = "👁️ 頂級精準玩家透視 (ESP) ➔ [ 開啟 ✦ ]",
        targetPlaceholder = "🔍 請輸入鎖定玩家名稱 (留空自動尋敵)...",
        btnSwitchTarget = "👤 輪替切換下個目標",
        btnHop = "🌐 智慧伺服器跨頻切換",
        slot1 = "⭐ [ 1 ] 武器欄位", slot2 = "⭐ [ 2 ] 武器欄位", slot3 = "⭐ [ 3 ] 武器欄位",
        skillBtn = "⚜ 技能 "
    },
    EN = {
        titleVIP = "⚜ 👑 KING LEGACY | ULTIMATE VIP CORE 👑 ⚜",
        titleFree = "✦ ⚡ KING LEGACY | LUXURY FREE ⚡ ✦",
        statusOff = "❖ Status: Standby & Secure ✦",
        statusOn = "⚡ Status: Auto Bounty Executing... ⚜",
        tabMain = "❖ Main Control",
        tabSkill = "⚡ Skill Config",
        btnAutoStart = "▶ Start Auto Bounty",
        btnAutoStop = "⏸ Stop Auto Bounty",
        btnAimOff = "🌐 360° Skill Aimlock ➔ [ OFF ]",
        btnAimOn = "🌐 360° Skill Aimlock ➔ [ ON ⚡ ]",
        btnStickOff = "🔒 Target Lock Magnet ➔ [ OFF ]",
        btnStickOn = "🔒 Target Lock Magnet ➔ [ ON ⚜ ]",
        btnEspOff = "👁️ Pro Player ESP ➔ [ OFF ]",
        btnEspOn = "👁️ Pro Player ESP ➔ [ ON ✦ ]",
        targetPlaceholder = "🔍 Enter Player Name (Blank = Nearest)...",
        btnSwitchTarget = "👤 Switch Target",
        btnHop = "🌐 Smart Server Hop",
        slot1 = "⭐ [ 1 ] Slot", slot2 = "⭐ [ 2 ] Slot", slot3 = "⭐ [ 3 ] Slot",
        skillBtn = "⚜ Skill "
    }
}

local function applyCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = p
end

local function bindResponsiveClick(button, callback)
    button.Activated:Connect(callback)
    button.MouseEnter:Connect(function() button.BackgroundTransparency = 0.1 end)
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

-- 放大版奢華主介面 (寬度 420，高度放大)
local gui = Instance.new("ScreenGui")
gui.Name = "KingLegacy_LuxuryHub_v98"
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, userTier == "VIP" and 590 or 145)
mainFrame.Position = UDim2.new(0, 40, 0.5, userTier == "VIP" and -295 or -72)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
mainFrame.Active = true
mainFrame.Parent = gui
applyCorner(mainFrame, 16)

-- 質感邊框金線
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(212, 175, 55) 
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
topBar.Parent = mainFrame
applyCorner(topBar, 16)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = userTier == "VIP" and Lang[currentLang].titleVIP or Lang[currentLang].titleFree
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 15 -- 標題明顯放大
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local mainLangBtn = Instance.new("TextButton")
mainLangBtn.Size = UDim2.new(0, 44, 0, 32)
mainLangBtn.Position = UDim2.new(1, -86, 0, 10)
mainLangBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
mainLangBtn.Text = currentLang == "ZH" and "EN" or "中"
mainLangBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
mainLangBtn.Font = Enum.Font.FredokaOne
mainLangBtn.TextSize = 14
mainLangBtn.Parent = topBar
applyCorner(mainLangBtn, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.FredokaOne
closeBtn.TextSize = 15
closeBtn.Parent = topBar
applyCorner(closeBtn, 8)

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
    mainLangBtn.Text = currentLang == "ZH" and "EN" or "中"

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

-- FREE 介面
if userTier == "FREE" then
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(1, -30, 0, 56)
    aimBtn.Position = UDim2.new(0, 15, 0, 68)
    aimBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    aimBtn.Text = Lang[currentLang].btnAimOff
    aimBtn.TextColor3 = Color3.new(1, 1, 1)
    aimBtn.Font = Enum.Font.FredokaOne
    aimBtn.TextSize = 15
    aimBtn.Parent = mainFrame
    applyCorner(aimBtn, 12)
    uiElements.aimBtn = aimBtn

    bindResponsiveClick(aimBtn, function()
        standaloneAimEnabled = not standaloneAimEnabled
        aimBtn.BackgroundColor3 = standaloneAimEnabled and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(22, 22, 30)
        aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
    end)
end

-- VIP 奢華介面 (全面放大尺寸與字體)
if userTier == "VIP" then
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -30, 0, 42)
    statusFrame.Position = UDim2.new(0, 15, 0, 62)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    statusFrame.Parent = mainFrame
    applyCorner(statusFrame, 12)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(0, 14, 0.5, -5)
    statusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    statusDot.Parent = statusFrame
    applyCorner(statusDot, 5)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -36, 1, 0)
    statusText.Position = UDim2.new(0, 32, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = Lang[currentLang].statusOff
    statusText.TextColor3 = Color3.fromRGB(190, 190, 210)
    statusText.Font = Enum.Font.FredokaOne
    statusText.TextSize = 14
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusFrame
    uiElements.statusText = statusText

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -30, 0, 40)
    tabContainer.Position = UDim2.new(0, 15, 0, 112)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local mainTabBtn = Instance.new("TextButton")
    mainTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    mainTabBtn.Text = Lang[currentLang].tabMain
    mainTabBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    mainTabBtn.Font = Enum.Font.FredokaOne
    mainTabBtn.TextSize = 14
    mainTabBtn.Parent = tabContainer
    applyCorner(mainTabBtn, 12)
    uiElements.mainTabBtn = mainTabBtn

    local skillTabBtn = Instance.new("TextButton")
    skillTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
    skillTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
    skillTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    skillTabBtn.Text = Lang[currentLang].tabSkill
    skillTabBtn.TextColor3 = Color3.fromRGB(140, 140, 160)
    skillTabBtn.Font = Enum.Font.FredokaOne
    skillTabBtn.TextSize = 14
    skillTabBtn.Parent = tabContainer
    applyCorner(skillTabBtn, 12)
    uiElements.skillTabBtn = skillTabBtn

    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -30, 0, 410)
    pageContainer.Position = UDim2.new(0, 15, 0, 162)
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
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); mainTabBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
        skillTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28); skillTabBtn.TextColor3 = Color3.fromRGB(140, 140, 160)
    end)

    bindResponsiveClick(skillTabBtn, function()
        mainPage.Visible = false; skillPage.Visible = true
        skillTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); skillTabBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28); mainTabBtn.TextColor3 = Color3.fromRGB(140, 140, 160)
    end)

    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, 0, 0, 46)
    autoBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    autoBtn.Text = Lang[currentLang].btnAutoStart
    autoBtn.TextColor3 = Color3.fromRGB(0, 230, 130)
    autoBtn.Font = Enum.Font.FredokaOne
    autoBtn.TextSize = 15
    autoBtn.Parent = mainPage
    applyCorner(autoBtn, 12)
    uiElements.autoBtn = autoBtn

    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(1, 0, 0, 40)
    aimBtn.Position = UDim2.new(0, 0, 0, 56)
    aimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    aimBtn.Text = Lang[currentLang].btnAimOff
    aimBtn.TextColor3 = Color3.new(1, 1, 1)
    aimBtn.Font = Enum.Font.FredokaOne
    aimBtn.TextSize = 14
    aimBtn.Parent = mainPage
    applyCorner(aimBtn, 12)
    uiElements.aimBtn = aimBtn

    bindResponsiveClick(aimBtn, function()
        standaloneAimEnabled = not standaloneAimEnabled
        aimBtn.BackgroundColor3 = standaloneAimEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(20, 20, 28)
        aimBtn.Text = standaloneAimEnabled and Lang[currentLang].btnAimOn or Lang[currentLang].btnAimOff
    end)

    local stickBtn = Instance.new("TextButton")
    stickBtn.Size = UDim2.new(1, 0, 0, 40)
    stickBtn.Position = UDim2.new(0, 0, 0, 104)
    stickBtn.BackgroundColor3 = stickDeadTarget and Color3.fromRGB(140, 60, 20) or Color3.fromRGB(20, 20, 28)
    stickBtn.Text = stickDeadTarget and Lang[currentLang].btnStickOn or Lang[currentLang].btnStickOff
    stickBtn.TextColor3 = Color3.new(1, 1, 1)
    stickBtn.Font = Enum.Font.FredokaOne
    stickBtn.TextSize = 14
    stickBtn.Parent = mainPage
    applyCorner(stickBtn, 12)
    uiElements.stickBtn = stickBtn

    bindResponsiveClick(stickBtn, function()
        stickDeadTarget = not stickDeadTarget
        stickBtn.BackgroundColor3 = stickDeadTarget and Color3.fromRGB(140, 60, 20) or Color3.fromRGB(20, 20, 28)
        stickBtn.Text = stickDeadTarget and Lang[currentLang].btnStickOn or Lang[currentLang].btnStickOff
    end)

    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(1, 0, 0, 40)
    espBtn.Position = UDim2.new(0, 0, 0, 152)
    espBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    espBtn.Text = Lang[currentLang].btnEspOff
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.Font = Enum.Font.FredokaOne
    espBtn.TextSize = 14
    espBtn.Parent = mainPage
    applyCorner(espBtn, 12)
    uiElements.espBtn = espBtn

    bindResponsiveClick(espBtn, function()
        espEnabled = not espEnabled
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(180, 45, 55) or Color3.fromRGB(20, 20, 28)
        espBtn.Text = espEnabled and Lang[currentLang].btnEspOn or Lang[currentLang].btnEspOff
    end)

    local targetInput = Instance.new("TextBox")
    targetInput.Size = UDim2.new(1, 0, 0, 42)
    targetInput.Position = UDim2.new(0, 0, 0, 200)
    targetInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    targetInput.PlaceholderText = Lang[currentLang].targetPlaceholder
    targetInput.Text = ""
    targetInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    targetInput.Font = Enum.Font.FredokaOne
    targetInput.TextSize = 14
    targetInput.Parent = mainPage
    applyCorner(targetInput, 12)
    uiElements.targetInput = targetInput

    targetInput.FocusLost:Connect(function(enterPressed)
        if targetInput.Text ~= "" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and string.lower(p.Name):sub(1, #targetInput.Text) == string.lower(targetInput.Text) then
                    manualTarget = p
                    break
                end
            end
        else
            manualTarget = nil
        end
    end)

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0.48, 0, 0, 42)
    switchBtn.Position = UDim2.new(0, 0, 0, 252)
    switchBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    switchBtn.Text = Lang[currentLang].btnSwitchTarget
    switchBtn.TextColor3 = Color3.new(1, 1, 1)
    switchBtn.Font = Enum.Font.FredokaOne
    switchBtn.TextSize = 13.5
    switchBtn.Parent = mainPage
    applyCorner(switchBtn, 12)
    uiElements.switchBtn = switchBtn

    bindResponsiveClick(switchBtn, function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then table.insert(list, p) end
            end
        end
        if #list > 0 then
            local currentIdx = 1
            for i, p in ipairs(list) do
                if p == currentTarget or p == manualTarget then
                    currentIdx = i + 1
                    break
                end
            end
            if currentIdx > #list then currentIdx = 1 end
            manualTarget = list[currentIdx]
            currentTarget = list[currentIdx]
            targetInput.Text = manualTarget.Name
        end
    end)

    local hopBtn = Instance.new("TextButton")
    hopBtn.Size = UDim2.new(0.48, 0, 0, 42)
    hopBtn.Position = UDim2.new(0.52, 0, 0, 252)
    hopBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    hopBtn.Text = Lang[currentLang].btnHop
    hopBtn.TextColor3 = Color3.new(1, 1, 1)
    hopBtn.Font = Enum.Font.FredokaOne
    hopBtn.TextSize = 13.5
    hopBtn.Parent = mainPage
    applyCorner(hopBtn, 12)
    uiElements.hopBtn = hopBtn

    bindResponsiveClick(hopBtn, function()
        local success, err = pcall(function()
            local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                    break
                end
            end
        end)
    end)

    local slotList = {{key = Enum.KeyCode.One, id = "slot1"}, {key = Enum.KeyCode.Two, id = "slot2"}, {key = Enum.KeyCode.Three, id = "slot3"}}
    for i, item in ipairs(slotList) do
        local sBtn = Instance.new("TextButton")
        sBtn.Size = UDim2.new(0.31, 0, 0, 40)
        sBtn.Position = UDim2.new((i - 1) * 0.345, 0, 0, 12)
        sBtn.BackgroundColor3 = SlotKeys[item.key] and Color3.fromRGB(0, 110, 180) or Color3.fromRGB(20, 20, 28)
        sBtn.Text = Lang[currentLang][item.id]
        sBtn.TextColor3 = Color3.new(1, 1, 1)
        sBtn.Font = Enum.Font.FredokaOne
        sBtn.TextSize = 13
        sBtn.Parent = skillPage
        applyCorner(sBtn, 10)

        bindResponsiveClick(sBtn, function()
            SlotKeys[item.key] = not SlotKeys[item.key]
            sBtn.BackgroundColor3 = SlotKeys[item.key] and Color3.fromRGB(0, 110, 180) or Color3.fromRGB(20, 20, 28)
        end)
    end

    local keysList = {Enum.KeyCode.Q, Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.E, Enum.KeyCode.T, Enum.KeyCode.Y}
    for i, key in ipairs(keysList) do
        local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
        local kBtn = Instance.new("TextButton")
        kBtn.Size = UDim2.new(0.31, 0, 0, 40)
        kBtn.Position = UDim2.new(col * 0.345, 0, 0, 64 + row * 46)
        kBtn.BackgroundColor3 = SkillKeys[key] and Color3.fromRGB(35, 130, 70) or Color3.fromRGB(20, 20, 28)
        kBtn.Text = Lang[currentLang].skillBtn .. key.Name
        kBtn.TextColor3 = Color3.new(1, 1, 1)
        kBtn.Font = Enum.Font.FredokaOne
        kBtn.TextSize = 13
        kBtn.Parent = skillPage
        applyCorner(kBtn, 10)

        bindResponsiveClick(kBtn, function()
            SkillKeys[key] = not SkillKeys[key]
            kBtn.BackgroundColor3 = SkillKeys[key] and Color3.fromRGB(35, 130, 70) or Color3.fromRGB(20, 20, 28)
        end)
    end

    bindResponsiveClick(autoBtn, function()
        autoEnabled = not autoEnabled
        if autoEnabled then
            autoBtn.Text = Lang[currentLang].btnAutoStop
            autoBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 130)
            statusText.Text = Lang[currentLang].statusOn
        else
            autoBtn.Text = Lang[currentLang].btnAutoStart
            autoBtn.TextColor3 = Color3.fromRGB(0, 230, 130)
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
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

-- ========== 完美優化縮小 2 倍的 ESP 系統 (同步放大超清晰圓潤文字) ==========
local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5 
    box.Filled = false

    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Thickness = 4

    local healthBarBg = Drawing.new("Line")
    healthBarBg.Visible = false
    healthBarBg.Thickness = 4
    healthBarBg.Color = Color3.fromRGB(20, 20, 20)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true
    nameText.Font = 3 
    nameText.Size = 19 -- ESP 名稱文字再放大，清晰度倍增
    nameText.Color = Color3.fromRGB(255, 255, 255)

    local infoText = Drawing.new("Text")
    infoText.Visible = false
    infoText.Center = true
    infoText.Outline = true
    infoText.Font = 3
    infoText.Size = 16 -- ESP 狀態/等級文字同步放大
    infoText.Color = Color3.fromRGB(255, 230, 100)

    espCache[player] = {
        Box = box,
        HealthBar = healthBar,
        HealthBarBg = healthBarBg,
        NameText = nameText,
        InfoText = infoText
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

local function getPlayerStatusInfo(player)
    local level = "LV.?"
    local pvpStatus = "⚔️ PVP: ✕"

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, stat in ipairs(ls:GetChildren()) do
            local lname = string.lower(stat.Name)
            if lname:find("level") or lname:find("lv") or lname:find("等級") then
                level = "LV." .. tostring(stat.Value)
                break
            end
        end
    end
    if level == "LV.?" and player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        level = "LV." .. tostring(player.Data.Level.Value)
    end

    local char = player.Character
    if char then
        if char:GetAttribute("PVP") == true or char:FindFirstChild("PVP") and char.PVP.Value == true then
            pvpStatus = "⚔️ PVP: ✓"
        elseif player:GetAttribute("PVP") == true then
            pvpStatus = "⚔️ PVP: ✓"
        end
    end

    return level, pvpStatus
end

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
    for p, cache in pairs(espCache) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if espEnabled and hrp and hum and hum.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = math.clamp(5500 / vector.Z, 35, 600)
                local width = size * 0.65
                local height = size
                local posX = vector.X - width / 2
                local posY = vector.Y - height / 2

                local teamColor = (p.Team and lp.Team and p.Team == lp.Team) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)

                cache.Box.Size = Vector2.new(width, height)
                cache.Box.Position = Vector2.new(posX, posY)
                cache.Box.Color = teamColor
                cache.Box.Visible = true

                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barHeight = height * healthPercent
                
                cache.HealthBarBg.From = Vector2.new(posX - 8, posY + height)
                cache.HealthBarBg.To = Vector2.new(posX - 8, posY)
                cache.HealthBarBg.Visible = true

                cache.HealthBar.From = Vector2.new(posX - 8, posY + height)
                cache.HealthBar.To = Vector2.new(posX - 8, posY + (height - barHeight))
                cache.HealthBar.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                cache.HealthBar.Visible = true

                cache.NameText.Text = "❖ " .. p.Name .. " [ " .. math.floor(hum.Health) .." HP ] ❖"
                cache.NameText.Position = Vector2.new(vector.X, posY - 27)
                cache.NameText.Visible = true

                local pLevel, pPvp = getPlayerStatusInfo(p)
                cache.InfoText.Text = "⚜ " .. pLevel .. " ✦ " .. pPvp .. " ⚜"
                cache.InfoText.Position = Vector2.new(vector.X, posY + height + 5)
                cache.InfoText.Visible = true
            else
                cache.Box.Visible = false
                cache.HealthBar.Visible = false
                cache.HealthBarBg.Visible = false
                cache.NameText.Visible = false
                cache.InfoText.Visible = false
            end
        else
            cache.Box.Visible = false
            cache.HealthBar.Visible = false
            cache.HealthBarBg.Visible = false
            cache.NameText.Visible = false
            cache.InfoText.Visible = false
        end
    end

    if isTeleporting then return end

    local targetToLock = nil
    if autoEnabled and userTier == "VIP" then
        if not currentTarget or not currentTarget.Character or currentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            currentTarget = manualTarget or getClosestPlayer()
        end
        targetToLock = currentTarget
    elseif standaloneAimEnabled then
        targetToLock = manualTarget or getClosestPlayer()
    end

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
