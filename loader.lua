-- King Legacy Loader (Supabase HWID Binding Version - Final)

local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

-- 1. 取得當前玩家的唯一硬體識別碼 (HWID)
local playerHWID = RbxAnalyticsService:GetClientId()
local inputKey = "VIP-KL99-A7x9K2pQ" -- 玩家輸入的卡號

-- 2. 你的 Supabase 專案金鑰與網址
local SUPABASE_URL = "https://jqmdlstpxumluolgyfza.supabase.co"
local SUPABASE_ANON_KEY = "sb_publishable_ZkX5UYbiX_ff5Eszv3xGqg__FiECsDV"

-- 3. 向 Supabase 查詢該卡號狀態
local queryUrl = SUPABASE_URL .. "/rest/v1/keys?key=eq." .. inputKey
local success, response = pcall(function()
    return syn.request({
        Url = queryUrl,
        Method = "GET",
        Headers = {
            ["apikey"] = SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY
        }
    }).Body
end)

if not success then
    game:GetService("Players").LocalPlayer:Kick("【系統錯誤】無法連線到授權伺服器。")
    return
end

local data = HttpService:JSONDecode(response)

if #data == 0 then
    game:GetService("Players").LocalPlayer:Kick("【驗證失敗】此卡號不存在！")
    return
end

local keyInfo = data[1]

-- 4. HWID 一機一碼綁定檢核邏輯
if keyInfo.hwid == nil or keyInfo.hwid == "" then
    -- 首次使用：將當前電腦的 HWID 寫入資料庫進行綁定
    local updateUrl = SUPABASE_URL .. "/rest/v1/keys?key=eq." .. inputKey
    pcall(function()
        syn.request({
            Url = updateUrl,
            Method = "PATCH",
            Headers = {
                ["apikey"] = SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " = SUPABASE_ANON_KEY,
                ["Content-Type"] = "application/json",
                ["Prefer"] = "return=minimal"
            },
            Body = HttpService:JSONEncode({ hwid = playerHWID })
        })
    end)
    print("【驗證成功】卡號首次啟用，已成功綁定本機裝置！")
    
elseif keyInfo.hwid ~= playerHWID then
    -- 異機登入防護：HWID 不符則直接踢出遊戲
    game:GetService("Players").LocalPlayer:Kick("【驗證失敗】此卡號已被其他電腦綁定！")
    return
else
    -- 驗證通過
    print("【驗證成功】硬體識別碼吻合，歡迎回來！")
end

-- 5. 傳遞安全權限並載入你的主程式 (core.lua)
getgenv().__KL_SECURE_AUTH_SESSION_2026__ = {
    Tier = keyInfo.tier,
    Token = "Verified_Secure_Token_987654321"
}
table.freeze(getgenv().__KL_SECURE_AUTH_SESSION_2026__)

loadstring(game:HttpGet("https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua"))()
