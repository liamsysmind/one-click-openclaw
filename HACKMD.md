# OpenClaw 24 小時不休息的 AI 助理

> 不用學程式、不用買 Mac、不用花大錢。一個下午就能讓 AI 開始幫你處理信箱、搜尋資料、管理行程。

---

## 起因：EMBA 的 AI 課程

這週在 EMBA 課堂上，老師提到了 OpenClaw 專案，許多同學顯出高度興趣。OpenClaw 被稱為「個人版的 Jarvis」，可以像一個私人秘書那樣——傳訊息給它，它就幫你查資料、整理信件、提醒你開會。

我對 OpenClaw 的動態一直很關注，也知道它的進入門檻不低，原本比較適合有技術背景的使用者。但看到同學們的興致這麼高，我覺得值得花點時間把門檻降低。所以我做了一個一鍵安裝版本，讓大家不必花大錢買 Mac Mini（目前 lead time 已經 6-8 週），用手邊的 Windows 電腦就能體驗用手機跟 AI 秘書溝通、讓它幫你處理日常事務的便利。

---

## OpenClaw 是什麼

OpenClaw 是一個跑在你自己電腦上的 AI 助理，開源專案，GitHub 上有超過 20 萬顆星。你透過 Telegram 跟它對話，它可以幫你讀信、草擬回覆、上網搜尋資料、查行事曆、建立提醒、開啟網頁擷取內容。它 24 小時運行，你半夜傳個訊息給它，早上起來就能看到結果。

跟 ChatGPT 的差別在於：ChatGPT 是一個網頁，你去找它、聊完就關掉。OpenClaw 是住在你電腦裡的助理，它隨時在 Telegram 上等你的指令，而且它記得你說過的話、你的偏好、你上次交代的事。

---

## 安裝的門檻

OpenClaw 需要 Linux 環境。對工程師來說這不是問題，但對多數人來說，光是看到 terminal 就不想繼續了。官方推薦的硬體是 Mac Mini，但多數同學手邊只有 Windows 電腦。

所以我花了一個週末，把整個安裝流程打包成自動化腳本，取名叫 one-click-claw。

---

## one-click-claw 做了什麼

它把原本需要幾十個步驟的安裝流程簡化成：

1. 下載一個壓縮檔
2. 雙擊 `START-HERE.bat`
3. 貼上兩把 key（都是免費申請的）
4. 等 15 分鐘
5. 打開 Telegram 跟 AI 助理說話

不需要學 Linux，不需要懂程式，不需要改系統設定。腳本會自動處理技術細節。

---

## 安裝前需要準備三樣東西

### Gemini API Key（免費）

這讓 AI 助理能用 Google 搜尋。

1. 打開 [Google AI Studio](https://aistudio.google.com)
2. 用 Google 帳號登入
3. 點左邊的「Get API Key」
4. 點「Create API Key」
5. 複製產生的 key（開頭是 `AIza...`），存在記事本裡

不需要信用卡。

### Telegram Bot Token（免費）

這讓你可以用手機跟 AI 助理對話。

1. 手機下載 Telegram, 安裝
2. 搜尋 `@BotFather`，打開對話
3. 傳送 `/newbot`, 建立一個AI bot, AI bot就是你的OpenClaw對話窗口, 未來與OpenClaw交談的代理對象
4. 它會問 你想要使用的 AI bot 的名稱，隨便取一個（例如 My AI Assistant）
5. 再問 username，為你的AI bot建立一個系統代號, 實際上在對話窗看到的AI bot會是第四步, Teltgram強制要求取一個以 `bot` 結尾的名稱（例如 `my_ai_helper_bot`）

7. 它會回覆一串 token，格式像 `7123456789:AAH-xxxxx...`
8. 複製這串 token，存在起來. 在手機端, 我是用email的方式將token寄出來, 然後在Windows 11收信, 收集到這一長串的token。

沒有 Telegram 的話可以跳過，之後用瀏覽器操作也行，體驗會稍微差一點。

### ChatGPT Plus 帳號（$20/月）

這是 AI 助理的運算後端。你需要一個 ChatGPT Plus 訂閱，安裝完成後會引導你連接。

總費用：每月 $20 美金（約 NT$640）。Gemini 和 Telegram 都免費。

---

## 安裝步驟

下載安裝包：

- [Google Drive 下載](你的 Google Drive 連結)
- [GitHub 頁面](https://github.com/liamsysmind/one-click-claw)

下載後：

1. 對 `.zip` 檔按右鍵 →「內容」→ 勾選「解除封鎖」→ 確定
2. 解壓縮到桌面
3. 雙擊 `START-HERE.bat`
4. 如果 Windows 跳出安全性警告，按「是」或「仍要執行」

如果被「智慧型應用程式控制」擋住，改用 PowerShell 方式安裝，步驟寫在 README 裡。

安裝程式會問你 Gemini API Key 和 Telegram Bot Token，貼上之前準備好的，剩下全部自動完成。

---

## 安裝完成後

安裝程式會自動引導你完成以下步驟，照畫面提示操作即可。

### Gateway Token（記下來！）

安裝完成後畫面會顯示一串 Gateway Token。**請截圖或複製到記事本**，之後用瀏覽器開 Web UI 時需要它登入。

使用方式：打開 `http://localhost:18789` → 進入 `Control UI Settings` → 貼上 Token。

### 連接 ChatGPT

安裝程式會按 Enter 後自動開啟 OpenClaw 設定精靈。畫面上會出現一些英文訊息，這是正常的。

你會看到類似這樣的畫面：

```
◇  Existing config detected
│  workspace: ~/.openclaw/workspace
│  gateway.mode: local
│  gateway.port: 18789

◇  Config handling
│  Use existing values       ← 選這個就好
```

如果出現 **Config handling** 的選項，選 **Use existing values**（用方向鍵選，按 Enter 確認）。

如果出現 **Enable hooks?** 的選項，畫面會像這樣：

```
◆  Enable hooks?
│  ◼ Skip for now
│  ◻ 🚀 boot-md
│  ◻ 📎 bootstrap-extra-files
│  ◻ 📝 command-logger
│  ◻ 💾 session-memory
```

> **這種選單的操作方式（很重要！）：**
> - **↑↓ 方向鍵**：上下移動游標
> - **空白鍵**：選擇或取消選擇項目（◼ = 已選、◻ = 未選）
> - **Enter**：確定送出
>
> 注意：**不要直接按 Enter！** 要先用空白鍵選好，再按 Enter 確認。

第一次安裝建議直接選 **Skip for now** 就好（預設已選），直接按 Enter 跳過。

接著會出現：

```
◇  OpenAI Codex OAuth
│  Browser will open for OpenAI authentication.

Open: https://auth.openai.com/oauth/authorize?...
◒  Complete sign-in in browser...
```

這時瀏覽器會自動打開 ChatGPT 登入頁面：

1. 登入你的 ChatGPT 帳號
2. 按「授權」
3. 瀏覽器顯示 **「Authentication successful」** 就完成了
4. 回到安裝視窗，如果看到：
   ```
   ◆  Paste the authorization code (or full redirect URL):
   ```
   把瀏覽器**網址列的完整網址**複製，貼回安裝視窗按 Enter。
   （網址開頭像 `http://localhost:1455/auth/callback?code=...`）

> ⚠️ **安全提醒：** OpenClaw 的 AI 運算透過 ChatGPT 雲端進行，你傳給 AI 的內容會經過 OpenAI 伺服器。請勿傳送機密資料（密碼、公司內部文件等）。

### 配對 Telegram Bot

安裝程式會提示你進行 Telegram 配對：

1. 打開 Telegram，搜尋你建立的 bot
2. 對它發一條訊息（例如「你好」）
3. Bot 會回覆一組**配對碼**（Pairing Code）
4. 回到安裝視窗按 Enter，程式會自動偵測並完成配對

如果自動配對失敗，畫面會顯示手動指令，照著做就好：
```
openclaw pairing list              ← 查看配對請求
openclaw pairing approve <配對碼>  ← 批准配對
```

配對完成後，只有你能跟這個 bot 對話。

### 測試

對 bot 說這些話，確認功能正常：

| 你說 | 測試什麼 |
|------|---------|
| 今天天氣如何 | 搜尋功能 |
| 幫我摘要這個網頁 https://... | 網頁擷取 |
| 提醒我明天早上 9 點開會 | 提醒功能 |
| 你能做什麼 | 功能列表 |

如果有回覆，代表 AI 助理已經在運作了。

---

## 費用

| 項目 | 費用 |
|------|------|
| OpenClaw 軟體 | 免費（開源） |
| Gemini API Key | 免費 |
| Telegram | 免費 |
| ChatGPT Plus | $20/月 |
| 每月總計 | $20/月（約 NT$640） |

ChatGPT Plus 的 Codex 有每週 5 小時使用限制。一般個人使用夠了，超過時 AI 會暫停回應，下週自動恢復。

---

## 常見問題

**電腦會不會變慢？**
不會。OpenClaw 本身很輕量，AI 運算在雲端進行，你的電腦只負責轉發訊息。

**資料安全嗎？**
OpenClaw 跑在你的電腦上，但它需要連接 ChatGPT 的 API，你傳給 AI 的內容會經過 OpenAI 的伺服器。如果公司有資料合規要求，建議先跟 IT 確認。

**電腦關機後 AI 會停嗎？**
會。下次開機登入後會自動重新啟動。如果希望不中斷，需要讓電腦一直開著。

**可以讓助理或 IT 幫我裝嗎？**
可以，建議這樣做。把這篇文章和下載連結轉給他們就好。

**英文介面看不懂怎麼辦？**
安裝過程的互動部分是中文。使用中遇到英文看不懂的地方，截圖傳給 ChatGPT 問「這個畫面要我做什麼？」就行。

---

## 寫在最後

這個安裝包是週末趕工的成果，目的是讓不碰技術的人也能試試 AI 助理。它不完美，但能讓你花一個下午的時間，體驗一下「AI 幫你做事」是什麼感覺。

安裝過程中遇到問題，歡迎留言或私訊我。

---

下載安裝包：[Google Drive](你的連結) ｜ [GitHub](https://github.com/liamsysmind/one-click-claw)