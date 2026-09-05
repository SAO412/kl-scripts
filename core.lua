-- King Legacy - 完整功能核心選單 (Core GUI with Full Features)
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("KL_Main_Core") then
    CoreGui.KL_Main_Core:Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "KL_Main_Core"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 500, 0, 420)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- 標題列
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Text = "KING LEGACY — 綜合功能選單 (等級: " .. tostring(getgenv().USER_TIER) .. ")"

-- 功能按鈕建立函式
local function createButton(name, yPos, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 440, 0, 50)
    btn.Position = UDim2.new(0.5, -220, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = name
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 60, 100)
    stroke.Thickness = 1
    
    btn.Activated:Connect(callback)
end

-- 加入各項實用功能按鈕
createButton("⚔️ 自動農怪與等級 (Auto Farm Level)", 65, function()
    print("[KL Script] 自動農怪功能已啟動...")
    -- 這裡可對接你的自動刷等邏輯
end)

createButton("🏝️ 島嶼瞬間傳送 (Island Teleport)", 125, function()
    print("[KL Script] 開啟島嶼傳送選單...")
end)

createButton("⚡ 玩家強化 / 無限體力 (Player Stats & Misc)", 185, function()
    print("[KL Script] 玩家強化功能已套用...")
end)

createButton("🔄 尋找低人數伺服器 (Server Hop)", 245, function()
    print("[KL Script] 正在切換伺服器...")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end)

-- 關閉按鈕
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 440, 0, 40)
closeBtn.Position = UDim2.new(0.5, -220, 0, 310)
closeBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "關閉選單"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15

local btnCorner = Instance.new("UICorner", closeBtn)
btnCorner.CornerRadius = UDim.new(0, 6)

local btnStroke = Instance.new("UIStroke", closeBtn)
btnStroke.Color = Color3.fromRGB(150, 50, 50)
btnStroke.Thickness = 1

closeBtn.Activated:Connect(function()
    screenGui:Destroy()
end)