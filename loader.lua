local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local AUTH_URL = "https://kl-auth-api.onrender.com/verify"
local CORE_SCRIPT_URL = "https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"

local function req(options)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    return requestFunc(options)
end

-- 建立主視窗 UI (現代化深色風)
local gui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 175)
frame.Position = UDim2.new(0.5, -170, 0.5, -87.5)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0

-- 圓角裝飾
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

-- 頂部裝飾條 (漸層感或亮藍色識別條)
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 4)
topBar.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
topBar.BorderSizePixel = 0

-- 標題文字
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 15, 0, 15)
title.BackgroundTransparency = 1
title.Text = "KING LEGACY — 授權驗證系統"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- 輸入框外框背景
local inputBg = Instance.new("Frame", frame)
inputBg.Size = UDim2.new(1, -30, 0, 42)
inputBg.Position = UDim2.new(0, 15, 0, 55)
inputBg.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
inputBg.BorderSizePixel = 0
local inputBgCorner = Instance.new("UICorner", inputBg)
inputBgCorner.CornerRadius = UDim.new(0, 6)

-- 輸入框 (TextBox)
local input = Instance.new("TextBox", inputBg)
input.Size = UDim2.new(1, -20, 1, 0)
input.Position = UDim2.new(0, 10, 0, 0)
input.BackgroundTransparency = 1
input.PlaceholderText = "請輸入你的專屬授權卡號..."
input.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.TextSize = 13
input.Font = Enum.Font.Gotham
input.ClearTextOnFocus = false

-- 確認按鈕
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -30, 0, 42)
btn.Position = UDim2.new(0, 15, 0, 110)
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
btn.BorderSizePixel = 0
btn.Text = "驗證卡號"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 14
btn.Font = Enum.Font.GothamBold

local btnCorner = Instance.new("UICorner", btn)
btnCorner.CornerRadius = UDim.new(0, 6)

-- 按鈕互動邏輯
btn.Activated:Connect(function()
    local userKey = input.Text:gsub("%s+", "")
    if userKey == "" then
        btn.Text = "請先輸入卡號！"
        btn.BackgroundColor3 = Color3.fromRGB(220, 130, 0)
        task.wait(1.5)
        btn.Text = "驗證卡號"
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        return
    end

    btn.Text = "驗證中..."
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

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
            btn.Text = "驗證成功！載入中..."
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            task.wait(0.8)
            getgenv().USER_TIER = data.tier
            gui:Destroy()
            loadstring(game:HttpGet(CORE_SCRIPT_URL))()
        else
            btn.Text = "卡號無效或格式錯誤"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1.5)
            btn.Text = "驗證卡號"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        end
    else
        btn.Text = "卡號無效或伺服器未回應"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.wait(1.5)
        btn.Text = "驗證卡號"
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)