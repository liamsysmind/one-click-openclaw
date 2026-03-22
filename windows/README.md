# one-click-claw

OpenClaw 一鍵安裝包。不需要 Linux 經驗，雙擊就能在 Windows 上跑 AI 助理。

> 未來將支援 macOS。

## 你需要什麼

- Windows 10 (build 19041+) 或 Windows 11
- 至少 8GB RAM（建議 16GB）
- 一個 ChatGPT Plus 帳號（$20/月，用來當 AI 的大腦）
- 網路連線

## 安裝前：準備三樣東西

安裝過程會用到以下三樣東西。建議先全部準備好，到時候貼上就行。

### 1. Gemini API Key（免費，讓 AI 能搜尋網路）

1. 打開 https://aistudio.google.com
2. 用你的 Google 帳號登入
3. 點左邊選單的 **「Get API Key」**
4. 點 **「Create API Key」**
5. 選一個 Google Cloud 專案（沒有的話選「Create new project」）
6. 複製產生的 key（開頭是 `AIza...`）
7. 存起來，等一下安裝時要用

### 2. Telegram Bot Token（免費，讓你用手機跟 AI 對話）

1. 打開 Telegram（手機或電腦都可以）
2. 搜尋 **`@BotFather`** 並打開對話
3. 傳送 `/newbot`
4. BotFather 會問你 bot 的**名稱** → 輸入一個名稱（例如 `My AI Assistant`）
5. 再問 **username** → 輸入一個名稱，**必須以 `bot` 結尾**（例如 `my_ai_helper_bot`）
6. BotFather 會回覆一串 token，格式像 `7123456789:AAH-xxxxx...`
7. 複製這串 token，存起來

> 沒有 Telegram？可以跳過，之後用瀏覽器的 Web UI（http://localhost:18789）操作。

### 3. ChatGPT Plus 帳號（$20/月，AI 的大腦）

你需要一個 ChatGPT Plus 訂閱。如果已經有了，安裝完成後會引導你連接。

> 💡 **完整費用：ChatGPT Plus $20/月。Gemini API key 和 Telegram 都免費。**

## 安裝

### 方法一：雙擊安裝

1. 下載這個壓縮檔到你的電腦
2. **⚠️ 重要！先對 `.zip` 檔解除封鎖：**
   - 對 `.zip` 檔按**右鍵** → **「內容」**
   - 在最下面找到 **「安全性：這個檔案來自其他電腦...」**
   - 勾選 **☐ 解除封鎖** → 按**確定**
   - 如果沒看到這個選項，代表不需要，直接下一步
3. 解壓縮到任意資料夾
4. 雙擊 **`START-HERE.bat`**
   - 跳出「使用者帳戶控制」→ 按 **「是」**
   - 如果跳出「Windows 已保護您的電腦」→ 點 **「其他資訊」** → **「仍要執行」**
5. 照畫面提示操作（約 15 分鐘）

### 方法二：如果被 Windows 擋住

如果看到「智慧型應用程式控制已封鎖可能不安全的檔案」，用這個方法：

1. 解壓縮到一個簡單的路徑（例如 `C:\openclaw`）
2. 按 **Win 鍵** → 輸入 **PowerShell** → 選 **「以系統管理員身分執行」**
3. 貼上以下指令：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\openclaw
Get-ChildItem -Recurse | Unblock-File
.\install-openclaw.ps1
```

## 安裝完成後

安裝程式會自動啟動 OpenClaw，然後引導你完成三件事：

### 步驟 A：連接 ChatGPT

執行指令：
```
openclaw onboard --auth-choice openai-codex
```

1. 瀏覽器會開啟 ChatGPT 登入頁面 → 登入並授權
2. 瀏覽器顯示 **「Authentication successful」**
3. ⚠️ **如果 terminal 沒有自動繼續**：把瀏覽器網址列的**完整網址**複製，貼回 terminal 按 Enter

### 步驟 B：配對 Telegram Bot

1. 打開 Telegram，搜尋你建立的 bot
2. 發一條訊息（例如「你好」）
3. Bot 會回覆一段配對網址
4. ⚠️ **把那段網址複製，貼回 terminal 按 Enter**
5. 配對完成！之後只有你能跟這個 bot 對話

### 步驟 C：測試

對 bot 說這些話試試看：

| 你說 | 測試什麼 |
|------|---------|
| 「今天天氣如何？」 | 搜尋功能 |
| 「幫我摘要這個網頁 https://...」 | 網頁擷取 |
| 「提醒我明天早上 9 點開會」 | 提醒功能 |
| 「你能做什麼？」 | 完整功能列表 |

## 日常使用

安裝完成後，OpenClaw 會在你登入 Windows 時自動啟動。你只需要：

- 打開 Telegram 跟 bot 對話
- 或打開瀏覽器 http://localhost:18789

## 常用指令

在 PowerShell 中執行：

```powershell
wsl -d openclaw openclaw gateway start    # 啟動
wsl -d openclaw openclaw gateway stop     # 停止
wsl -d openclaw openclaw gateway status   # 查看狀態
wsl -d openclaw openclaw doctor           # 診斷
```

> OpenClaw 安裝在獨立的 WSL 環境裡，不影響你電腦上其他東西。

## 遇到問題？

| 問題 | 解法 |
|------|------|
| Gateway 沒有自動啟動 | `wsl -d openclaw openclaw gateway start` |
| WSL2 吃太多記憶體 | 編輯 `%USERPROFILE%\.wslconfig` 調整 `memory=` 後 `wsl --shutdown` |
| Windows Update 後 WSL2 壞了 | `wsl --update` 然後 `wsl --shutdown` |
| 其他問題 | 聯繫 Liam 或到 GitHub 開 issue |

## 費用總覽

| 項目 | 費用 |
|------|------|
| OpenClaw | 免費（開源） |
| Gemini API Key（搜尋） | 免費 |
| Telegram | 免費 |
| **ChatGPT Plus（AI 大腦）** | **$20/月** |
| **總計** | **$20/月** |

> ⚠️ ChatGPT Plus 的 Codex 有每週 5 小時使用限制。一般個人使用夠了。超過時 AI 會暫停回應，下週自動恢復。
