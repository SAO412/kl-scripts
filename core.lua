-- 測試用核心主介面 (Core GUI)
local CoreGui = game:GetService("CoreGui")

-- 避免重複生成
if CoreGui:FindFirstChild("KL_Main_Core") then
    CoreGui.KL_Main_Core:Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "KL_Main_Core"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Text = "KING LEGACY — 主選單 (VIP等級: " .. tostring(getgenv().USER_TIER) .. ")"

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 100, 0, 35)
closeBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "關閉"
closeBtn.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner", closeBtn)
btnCorner.CornerRadius = UDim.new(0, 6)

closeBtn.Activated:Connect(function()
    screenGui:Destroy()
end)