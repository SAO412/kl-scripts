local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local AUTH_URL = "https://kl-auth-api.onrender.com/verify"
local CORE_SCRIPT_URL = "https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"

local function req(options)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    return requestFunc(options)
end

-- 當前語言狀態: "ZH" (中文) 或 "EN" (英文)
local currentLang = "ZH"

-- 多國語系字典
local translations = {
    ZH = {
        title = "KING LEGACY — 授權系統",
        subtitle = "SECURE LICENSE VERIFICATION",
        placeholder = "請輸入卡號...",
        btnVerify = "確認驗證",
        btnVerifying = "驗證中...",
        btnEmpty = "請先輸入卡號！",
        btnSuccess = "驗證成功！載入中...",
        btnInvalid = "卡號無效或錯誤",
        btnError = "伺服器未回應",
        langSwitch = "EN"
    },
    EN = {
        title = "KING LEGACY — AUTH",
        subtitle = "SECURE LICENSE VERIFICATION",
        placeholder = "Enter License Key...",
        btnVerify = "Verify Key",
        btnVerifying = "Verifying...",
        btnEmpty = "Please enter key!",
        btnSuccess = "Success! Loading...",
        btnInvalid = "Invalid Key",
        btnError = "Server Error",
        langSwitch = "中文"
    }
}

-- 建立主視窗 UI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KL_Auth_UI"
gui.ResetOnSpawn = false

-- 外層陰影發光底框
local glow = Instance.new("Frame", gui)
glow.Size = UDim2.new(0, 380, 0, 204)
glow.Position = UDim2.new(0.5, -190, 0.5, -102)
glow.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
local glowCorner = Instance.new("UICorner", glow)
glowCorner.CornerRadius = UDim.new(0, 14)

-- 主視窗本體
local frame = Instance.new("Frame", glow)
frame.Size = UDim2.new(1, -4, 1, -4)
frame.Position = UDim2.new(0, 2, 0, 2)
frame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
frame.BorderSizePixel = 0
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- 頂部霓虹漸層裝飾條
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 3)
topBar.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
topBar.BorderSizePixel = 0

-- 標題文字
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -90, 0, 35)
title.Position = UDim2.new(0, 20, 0, 18)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- 副標題
local subTitle = Instance.new("TextLabel", frame)
subTitle.Size = UDim2.new(1, -90, 0, 20)
subTitle.Position = UDim2.new(0, 20, 0, 42)
subTitle.BackgroundTransparency = 1
subTitle.TextColor3 = Color3.fromRGB(90, 95, 115)
subTitle.TextSize = 10
subTitle.Font = Enum.Font.GothamBold
subTitle.TextXAlignment = Enum.TextXAlignment.Left

-- 語言切換按鈕 (右上角)
local langBtn = Instance.new("TextButton", frame)
langBtn.Size = UDim2.new(0, 50, 0, 26)
langBtn.Position = UDim2.new(1, -70, 0, 20)
langBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
langBtn.BorderSizePixel = 0
langBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
langBtn.TextSize = 12
langBtn.Font = Enum.Font.GothamBold
local langBtnCorner = Instance.new("UICorner", langBtn)
langBtnCorner.CornerRadius = UDim.new(0, 6)

-- 輸入框外框背景
local inputBg = Instance.new("Frame", frame)
inputBg.Size = UDim2.new(1, -40, 0, 44)
inputBg.Position = UDim2.new(0, 20, 0, 78)
inputBg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
inputBg.BorderSizePixel = 0
local inputBgCorner = Instance.new("UICorner", inputBg)
inputBgCorner.CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new("UIStroke", inputBg)
inputStroke.Color = Color3.fromRGB(45, 45, 60)
inputStroke.Thickness = 1

-- 輸入框
local input = Instance.new("TextBox", inputBg)
input.Size = UDim2.new(1, -24, 1, 0)
input.Position = UDim2.new(0, 12, 0, 0)
input.BackgroundTransparency = 1
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.TextSize = 13
input.Font = Enum.Font.Gotham
input.ClearTextOnFocus = false

-- 確認按鈕
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -40, 0, 44)
btn.Position = UDim2.new(0, 20, 0, 136)
btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
btn.BorderSizePixel = 0
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 14
btn.Font = Enum.Font.GothamBold

local btnCorner = Instance.new("UICorner", btn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- 更新介面文字的函數
local function updateTexts()
    local t = translations[currentLang]
    title.Text = t.title
    subTitle.Text = t.subtitle
    input.PlaceholderText = t.placeholder
    btn.Text = t.btnVerify
    langBtn.Text = t.langSwitch
end

-- 初始化載入文字
updateTexts()

-- 點擊切換語言
langBtn.Activated:Connect(function()
    if currentLang == "ZH" then
        currentLang = "EN"
    else
        currentLang = "ZH"
    end
    updateTexts()
end)

-- 按鈕互動邏輯
btn.Activated:Connect(function()
    local t = translations[currentLang]
    local userKey = input.Text:gsub("%s+", "")
    
    if userKey == "" then
        btn.Text = t.btnEmpty
        btn.BackgroundColor3 = Color3.fromRGB(230, 130, 0)
        task.wait(1.5)
        btn.Text = t.btnVerify
        btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
        return
    end

    btn.Text = t.btnVerifying
    btn.BackgroundColor3 = Color3.fromRGB(70, 75, 95)

    local res = req({
        Url = AUTH_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({key = userKey})
    })

    if res and res.StatusCode == 200 then
        local success, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)
        
        if success and data and data.success then
            btn.Text = t.btnSuccess
            btn.BackgroundColor3 = Color3.fromRGB(35, 185, 90)
            task.wait(0.8)
            getgenv().USER_TIER = data.tier
            gui:Destroy()
            loadstring(game:HttpGet(CORE_SCRIPT_URL))()
        else
            btn.Text = t.btnInvalid
            btn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
            task.wait(1.5)
            btn.Text = t.btnVerify
            btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
        end
    else
        btn.Text = t.btnError
        btn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
        task.wait(1.5)
        btn.Text = t.btnVerify
        btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
    end
end)