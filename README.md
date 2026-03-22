# one-click-claw

> Windows 一鍵安裝 [OpenClaw](https://www.npmjs.com/package/openclaw) AI 助理。不用學程式、不用買 Mac，雙擊 `.bat` 就能搞定。

## 它做了什麼

自動在 WSL2 裡建立完整的 OpenClaw 環境，包含：

- 安裝 WSL2 + Ubuntu 24.04
- 安裝 Node.js 與 OpenClaw
- 設定 Telegram Bot 與 Web UI
- 註冊 Windows 排程，開機自動啟動

## 事前準備

| 項目 | 費用 | 說明 |
|------|------|------|
| [Gemini API Key](https://aistudio.google.com) | 免費 | 讓 AI 能用 Google 搜尋 |
| [Telegram Bot Token](https://t.me/BotFather) | 免費 | 用手機跟 AI 對話的管道 |
| ChatGPT Plus 帳號 | $20/月 | AI 運算後端 |

## 安裝步驟

1. 下載或 clone 這個 repo
2. 對 `.zip` 按右鍵 →「內容」→ 勾選「解除封鎖」（如果是 zip 下載）
3. 雙擊 `windows/START-HERE.bat`
4. 依畫面提示貼上 Gemini API Key 和 Telegram Bot Token
5. 等待安裝完成，照指示連接 ChatGPT 和配對 Telegram Bot

詳細圖文教學請參考 [HackMD 安裝指南](HACKMD.md)。

## 安裝完成後

- Web UI：`http://localhost:18789`
- 開機後自動啟動（透過 Windows 排程任務 `OpenClaw-WSL-Gateway`）
- 用 Telegram 對你的 Bot 傳訊息，即可開始使用

## 啟動 / 停止

| 操作 | 方式 |
|------|------|
| 啟動 | 雙擊 `windows/START-OPENCLAW.bat` |
| 停止 | 雙擊 `windows/STOP-OPENCLAW.bat` |

停止後 bot 不會回應，也不會被自動重啟。下次要用時再雙擊 START 即可。

## 架構

```
windows/
├── START-HERE.bat          # 入口，請求管理員權限後啟動安裝
├── install-openclaw.ps1    # PowerShell 安裝腳本（WSL2、distro、排程）
├── setup-openclaw.sh       # Linux 端設定（Node.js、OpenClaw、設定檔）
├── START-OPENCLAW.bat      # 雙擊啟動 OpenClaw
└── STOP-OPENCLAW.bat       # 雙擊停止 OpenClaw
```

## License

MIT
