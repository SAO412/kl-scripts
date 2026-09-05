local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local AUTH_URL = "https://kl-auth-api.onrender.com/verify"
local CORE_SCRIPT_URL = "https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"

local function req(options)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    return requestFunc(options)
end

local gui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 140)
frame.Position = UDim2.new(0.5, -140, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -20, 0, 35)
input.Position = UDim2.new(0, 10, 0, 20)
input.PlaceholderText = "請輸入卡號 (Enter Key)..."
input.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
input.TextColor3 = Color3.fromRGB(255, 255, 255)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -20, 0, 35)
btn.Position = UDim2.new(0, 10, 0, 70)
btn.Text = "驗證卡號"
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)

btn.Activated:Connect(function()
    local userKey = input.Text:gsub("%s+", "")
    local res = req({
        Url = AUTH_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({key = userKey})
    })

    if res and res.StatusCode == 200 then
        local data = HttpService:JSONDecode(res.Body)
        if data.success then
            getgenv().USER_TIER = data.tier
            gui:Destroy()
            loadstring(game:HttpGet(CORE_SCRIPT_URL))()
        end
    else
        btn.Text = "卡號無效或已過期！"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.wait(1.5)
        btn.Text = "驗證卡號"
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    end
end)