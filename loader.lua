-- King Legacy Modern Key System & Loader (Universal Request Fix)
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 容錯請求函數（相容 Synapse, Delta, Fluxus, KRNL 等各種執行器）
local requestFunc = syn and syn.request or request or http and http.request or fluxus and fluxus.request

if not requestFunc then
    LocalPlayer:Kick("【Error】Your executor does not support HTTP requests!")
    return
end

-- 1. 你的 Supabase 專案設定
local SUPABASE_URL = "https://jqmdlstpxumluolgyfza.supabase.co"
local SUPABASE_ANON_KEY = "sb_publishable_ZkX5UYbiX_ff5Eszv3xGqg__FiECsDV"
local playerHWID = RbxAnalyticsService:GetClientId()

-- 2. 多語言字典 (Languages Dictionary)
local currentLang = "TW"
local localizedText = {
    TW = {
        Title = "King Legacy | 專屬授權驗證系統",
        Subtitle = "請輸入您的購買卡號以啟動腳本",
        Placeholder = "請輸入卡號 (例如: VIP--...) ",
        ButtonText = "確認驗證 (Verify)",
        StatusReady = "狀態：請輸入金鑰",
        StatusChecking = "狀態：正在連線驗證伺服器...",
        Success = "驗證成功！正在載入主程式...",
        InvalidKey = "錯誤：此卡號不存在！",
        HwidLocked = "錯誤：此卡號已被其他電腦綁定！",
        ErrorConn = "錯誤：無法連線至授權伺服器。"
    },
    EN = {
        Title = "King Legacy | Secure Key System",
        Subtitle = "Please enter your purchased key to load script",
        Placeholder = "Enter key here...",
        ButtonText = "Verify Key",
        StatusReady = "Status: Ready for input",
        StatusChecking = "Status: Connecting to server...",
        Success = "Success! Loading core script...",
        InvalidKey = "Error: Key does not exist!",
        HwidLocked = "Error: Key is bound to another PC!",
        ErrorConn = "Error: Failed to connect auth server."
    }
}

-- 清理舊的 UI
if CoreGui:FindFirstChild("KL_Secure_Loader") then
    CoreGui.KL_Secure_Loader:Destroy()
end

-- 3. 建立 UI 介面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_Secure_Loader"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(110, 80, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 0, 40)
TitleLabel.Position = UDim2.new(0, 20, 0, 15)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = localizedText[currentLang].Title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, -40, 0, 20)
SubtitleLabel.Position = UDim2.new(0, 20, 0, 42)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.Text = localizedText[currentLang].Subtitle
SubtitleLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
SubtitleLabel.TextSize = 12
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = MainFrame

local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0, 50, 0, 28)
LangButton.Position = UDim2.new(1, -70, 0, 20)
LangButton.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
LangButton.Font = Enum.Font.GothamBold
LangButton.Text = currentLang == "TW" and "EN" or "TW"
LangButton.TextColor3 = Color3.fromRGB(200, 200, 220)
LangButton.TextSize = 12
LangButton.Parent = MainFrame
Instance.new("UICorner", LangButton).CornerRadius = UDim.new(0, 6)

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -40, 0, 48)
InputBox.Position = UDim2.new(0, 20, 0, 85)
InputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
InputBox.Font = Enum.Font.Gotham
InputBox.PlaceholderText = localizedText[currentLang].Placeholder
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(90, 95, 115)
InputBox.TextSize = 14
InputBox.Parent = MainFrame
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(45, 45, 60)
InputStroke.Thickness = 1
InputStroke.Parent = InputBox

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 20)
StatusLabel.Position = UDim2.new(0, 20, 0, 142)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = localizedText[currentLang].StatusReady
StatusLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local VerifyButton = Instance.new("TextButton")
VerifyButton.Size = UDim2.new(1, -40, 0, 46)
VerifyButton.Position = UDim2.new(0, 20, 0, 180)
VerifyButton.BackgroundColor3 = Color3.fromRGB(90, 60, 250)
VerifyButton.Font = Enum.Font.GothamBold
VerifyButton.Text = localizedText[currentLang].ButtonText
VerifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyButton.TextSize = 15
VerifyButton.Parent = MainFrame
Instance.new("UICorner", VerifyButton).CornerRadius = UDim.new(0, 8)

LangButton.MouseButton1Click:Connect(function()
    currentLang = currentLang == "TW" and "EN" or "TW"
    LangButton.Text = currentLang == "TW" and "EN" or "TW"
    TitleLabel.Text = localizedText[currentLang].Title
    SubtitleLabel.Text = localizedText[currentLang].Subtitle
    InputBox.PlaceholderText = localizedText[currentLang].Placeholder
    VerifyButton.Text = localizedText[currentLang].ButtonText
    StatusLabel.Text = localizedText[currentLang].StatusReady
end)

VerifyButton.MouseButton1Click:Connect(function()
    local inputKey = InputBox.Text
    if inputKey == "" or inputKey == " " then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        StatusLabel.Text = currentLang == "TW" and "錯誤：請先輸入卡號！" or "Error: Please enter a key!"
        return
    end

    VerifyButton.Active = false
    VerifyButton.BackgroundColor3 = Color3.fromRGB(50, 45, 90)
    StatusLabel.TextColor3 = Color3.fromRGB(220, 180, 50)
    StatusLabel.Text = localizedText[currentLang].StatusChecking

    local queryUrl = SUPABASE_URL .. "/rest/v1/keys?key=eq." .. inputKey
    local success, response = pcall(function()
        return requestFunc({
            Url = queryUrl,
            Method = "GET",
            Headers = {
                ["apikey"] = SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY
            }
        }).Body
    end)

    if not success then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        StatusLabel.Text = localizedText[currentLang].ErrorConn
        VerifyButton.Active = true
        VerifyButton.BackgroundColor3 = Color3.fromRGB(90, 60, 250)
        return
    end

    local data = HttpService:JSONDecode(response)

    if #data == 0 then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        StatusLabel.Text = localizedText[currentLang].InvalidKey
        VerifyButton.Active = true
        VerifyButton.BackgroundColor3 = Color3.fromRGB(90, 60, 250)
        return
    end

    local keyInfo = data[1]

    if keyInfo.hwid == nil or keyInfo.hwid == "" then
        local updateUrl = SUPABASE_URL .. "/rest/v1/keys?key=eq." .. inputKey
        pcall(function()
            requestFunc({
                Url = updateUrl,
                Method = "PATCH",
                Headers = {
                    ["apikey"] = SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
                    ["Content-Type"] = "application/json",
                    ["Prefer"] = "return=minimal"
                },
                Body = HttpService:JSONEncode({ hwid = playerHWID })
            })
        end)
    elseif keyInfo.hwid ~= playerHWID then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        StatusLabel.Text = localizedText[currentLang].HwidLocked
        task.wait(2)
        LocalPlayer:Kick(localizedText[currentLang].HwidLocked)
        return
    end

    StatusLabel.TextColor3 = Color3.fromRGB(60, 220, 120)
    StatusLabel.Text = localizedText[currentLang].Success
    
    task.wait(1)
    ScreenGui:Destroy()

    getgenv().__KL_SECURE_AUTH_SESSION_2026__ = {
        Tier = keyInfo.tier,
        Token = "Verified_Secure_Token_987654321"
    }
    table.freeze(getgenv().__KL_SECURE_AUTH_SESSION_2026__)

    loadstring(game:HttpGet("https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"))()
end)
