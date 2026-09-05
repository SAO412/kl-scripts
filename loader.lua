local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local AUTH_URL = "https://kl-auth-api.onrender.com/verify"
local CORE_SCRIPT_URL = "https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"

local function req(options)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    return requestFunc(options)
end

-- 建立主視窗 UI (高質感美術極致優化版)
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KL_Auth_UI"
gui.ResetOnSpawn = false

-- 外層陰影發光底框 (Glow 效果)
local glow = Instance.new("Frame", gui)
glow.Size = UDim2.new(0, 380, 0, 204)
glow.Position = UDim2.new(0.5, -190, 0.5, -102)
glow.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
local glowCorner = Instance.new("UICorner", glow)
glowCorner.CornerRadius = UDim.new(0, 14)

-- 主視窗本體 (極深色高級感)
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
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 20, 0, 18)
title.BackgroundTransparency = 1
title.Text = "KING LEGACY — 授權系統"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- 英文副標題 (精緻點綴)
local subTitle = Instance.new("TextLabel", frame)
subTitle.Size = UDim2.new(1, -40, 0, 20)
subTitle.Position = UDim2.new(0, 20, 0, 42)
subTitle.BackgroundTransparency = 1
subTitle.Text = "SECURE LICENSE VERIFICATION"
subTitle.TextColor3 = Color3.fromRGB(90, 95, 115)
subTitle.TextSize = 10
subTitle.Font = Enum.Font.GothamBold
subTitle.TextXAlignment = Enum.TextXAlignment.Left

-- 輸入框外框背景 (微互動感內凹)
local inputBg = Instance.new("Frame", frame)
inputBg.Size = UDim2.new(1, -40, 0, 44)
inputBg.Position = UDim2.new(0, 20, 0, 78)
inputBg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
inputBg.BorderSizePixel = 0
local inputBgCorner = Instance.new("UICorner", inputBg)
inputBgCorner.CornerRadius = UDim.new(0, 8)

-- 邊框微光線條
local inputStroke = Instance.new("UIStroke", inputBg)
inputStroke.Color = Color3.fromRGB(45, 45, 60)
inputStroke.Thickness = 1

-- 輸入框 (TextBox)
local input = Instance.new("TextBox", inputBg)
input.Size = UDim2.new(1, -24, 1, 0)
input.Position = UDim2.new(0, 12, 0, 0)
input.BackgroundTransparency = 1
input.PlaceholderText = "請輸入卡號 / Enter License Key..."
input.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.TextSize = 13
input.Font = Enum.Font.Gotham
input.ClearTextOnFocus = false

-- 確認按鈕 (亮藍色立體漸層風格)
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -40, 0, 44)
btn.Position = UDim2.new(0, 20, 0, 136)
btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
btn.BorderSizePixel = 0
btn.Text = "確認驗證 / Verify Key"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 14
btn.Font = Enum.Font.GothamBold

local btnCorner = Instance.new("UICorner", btn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- 按鈕互動邏輯
btn.Activated:Connect(function()
    local userKey = input.Text:gsub("%s+", "")
    if userKey == "" then
        btn.Text = "請先輸入卡號！ / Please enter key"
        btn.BackgroundColor3 = Color3.fromRGB(230, 130, 0)
        task.wait(1.5)
        btn.Text = "確認驗證 / Verify Key"
        btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
        return
    end

    btn.Text = "驗證中... / Verifying..."
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
            btn.Text = "驗證成功！載入中... / Success!"
            btn.BackgroundColor3 = Color3.fromRGB(35, 185, 90)
            task.wait(0.8)
            getgenv().USER_TIER = data.tier
            gui:Destroy()
            loadstring(game:HttpGet(CORE_SCRIPT_URL))()
        else
            btn.Text = "卡號無效或錯誤 / Invalid Key"
            btn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
            task.wait(1.5)
            btn.Text = "確認驗證 / Verify Key"
            btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
        end
    else
        btn.Text = "伺服器未回應 / Server Error"
        btn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
        task.wait(1.5)
        btn.Text = "確認驗證 / Verify Key"
        btn.BackgroundColor3 = Color3.fromRGB(0, 115, 255)
    end
end)