# 🔐 KL Scripts - KING LEGACY Authentication System

**A secure, modern authentication system with obfuscated core scripts for game customization.**

---

## 📋 Features

✨ **High-End Modern UI**
- Aesthetic dark theme with neon glow effects
- Bilingual support (Chinese 中文 / English)
- Premium visual design with rounded corners and accent bars
- Real-time status feedback

🔒 **Secure Authentication**
- Server-side key verification via Express.js API
- Support for VIP and FREE tier licenses
- Automatic core script loading after authentication
- Multi-language error messages

🚀 **Easy Integration**
- Single-line loader script execution
- Automatic API communication
- Global tier variable for script logic
- Works with multiple Roblox exploit executors

---

## 🎯 Quick Start

### 1. **Load the Loader Script**

Execute this in your Roblox exploit executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SAO412/kl-scripts/main/loader.lua"))()
```

### 2. **Enter Your License Key**

When the UI appears:
- Input your VIP or FREE license key
- Press "確認驗證 / Verify Key"
- Wait for authentication

### 3. **Automatic Core Loading**

Once verified, the obfuscated `core.lua` script loads automatically with your tier level.

---

## 🔑 License Keys (Sample)

**VIP Keys** (Full Features):
- `VIP-KING-8888`
- `VIP-LEGACY-9999`

**FREE Keys** (Limited Features):
- `FREE-AIM-2026`

> **Note:** These are sample keys. Replace with your actual authentication system.

---

## 📁 Repository Structure

```
kl-scripts/
├── loader.lua          # Main authentication UI & loader
├── core.lua            # Obfuscated core script (auto-loaded)
└── README.md           # This file
```

---

## 🔗 Important URLs

| File | Raw URL |
|------|----------|
| **Loader** | `https://raw.githubusercontent.com/SAO412/kl-scripts/main/loader.lua` |
| **Core** | `https://raw.githubusercontent.com/SAO412/kl-scripts/main/core.lua` |

---

## 🛠️ API Integration

The loader communicates with your Express.js authentication API:

**Endpoint:** `https://kl-auth-api.onrender.com/verify`

**Request:**
```json
{
  "key": "VIP-KING-8888"
}
```

**Response (Success):**
```json
{
  "success": true,
  "tier": "VIP"
}
```

**Response (Failure):**
```json
{
  "success": false,
  "message": "Invalid Key"
}
```

---

## 💻 Global Variables

After successful authentication, the following global variable is available:

```lua
getgenv().USER_TIER  -- Returns: "VIP" or "FREE"
```

Use this in your core script to conditionally load features:

```lua
if getgenv().USER_TIER == "VIP" then
    -- Load VIP features
else
    -- Load FREE features
end
```

---

## 🎨 UI Customization

The loader includes:
- **Glow Effect:** Blue neon outer shadow
- **Title:** "KING LEGACY — 授權系統"
- **Subtitle:** "SECURE LICENSE VERIFICATION"
- **Input Field:** Bilingual placeholder text
- **Status Messages:** Color-coded feedback
  - 🟠 Orange: Input required
  - 🟡 Gray: Verifying...
  - 🟢 Green: Success!
  - 🔴 Red: Error/Invalid

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| **"Server Error"** | Check internet connection & API availability |
| **"Invalid Key"** | Verify key spelling; use correct key format |
| **UI Not Appearing** | Ensure CoreGui is accessible; disable other scripts |
| **Script Won't Load** | Check raw GitHub URL is accessible |

---

## 📝 Supported Executors

The loader works with these Roblox exploit executors:
- ✅ Synapse X
- ✅ ScriptWare
- ✅ Fluxus
- ✅ Oxygen U
- ✅ Any executor with `HttpGet` and `request` support

---

## ⚖️ Legal Disclaimer

This authentication system is provided for educational and authorized use only. Ensure all scripts comply with:
- Roblox Terms of Service
- Game-specific terms
- Local laws and regulations

**Unauthorized use of cheats or exploits may result in account bans.**

---

## 📧 Support & Documentation

- **Repository:** https://github.com/SAO412/kl-scripts
- **Auth API:** https://github.com/SAO412/kl-auth-api
- **Created:** September 2026
- **Version:** 1.0.0

---

## 🎯 Next Steps

1. Copy the loader URL
2. Execute in your exploit
3. Enter your license key
4. Enjoy authenticated features!

**Happy scripting! 🚀**
