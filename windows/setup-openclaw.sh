#!/usr/bin/env bash
# ============================================================
#  OpenClaw WSL2 Setup Script
#  Author: Liam
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

step() { echo -e "  ${GREEN}[$1]${NC} $2"; }
info() { echo -e "      ${GRAY}$1${NC}"; }
warn() { echo -e "  ${YELLOW}[!]${NC} $1"; }
err()  { echo -e "  ${RED}[X]${NC} $1"; }

OPENCLAW_DIR="$HOME/.openclaw"

echo ""
echo -e "  ${CYAN}=============================================${NC}"
echo -e "  ${CYAN} OpenClaw 安裝程式${NC}"
echo -e "  ${CYAN}=============================================${NC}"
echo ""

# ===========================================================
#  PART 1: 收集資料
# ===========================================================
echo -e "  ${CYAN}=== 第一步：準備 API Key 和 Telegram Bot ===${NC}"
echo ""
echo "  安裝過程需要兩樣東西，都是免費的："
echo "    1. Gemini API Key（讓 AI 能搜尋網路）"
echo "    2. Telegram Bot Token（讓你用手機跟 AI 對話）"
echo ""
echo "  如果你還沒有，現在照畫面提示一步步做。"
echo "  如果已經有了，直接貼上就好。"
echo ""

# --- Gemini API Key ---
echo -e "  ${CYAN}--- Gemini API Key（免費）---${NC}"
echo ""
echo "  這把 key 讓你的 AI 助理能用 Google 搜尋資料。"
echo ""
echo -e "  ${GRAY}申請方式（不需要信用卡）：${NC}"
echo -e "  ${GRAY}  1. 用瀏覽器打開 https://aistudio.google.com${NC}"
echo -e "  ${GRAY}  2. 用你的 Google 帳號登入${NC}"
echo -e "  ${GRAY}  3. 點左邊的「Get API Key」${NC}"
echo -e "  ${GRAY}  4. 點「Create API Key」${NC}"
echo -e "  ${GRAY}  5. 複製產生的 key（開頭是 AIza...）${NC}"
echo ""
read -rp "  貼上你的 Gemini API Key: " GEMINI_KEY
echo ""

# --- Telegram Bot ---
echo -e "  ${CYAN}--- Telegram Bot Token（免費）---${NC}"
echo ""
echo "  這讓你可以用 Telegram App 跟 AI 助理對話。"
echo ""
echo -e "  ${GRAY}建立方式：${NC}"
echo -e "  ${GRAY}  1. 手機下載 Telegram，安裝${NC}"
echo -e "  ${GRAY}  2. 搜尋 ${NC}@BotFather${GRAY}，打開對話${NC}"
echo -e "  ${GRAY}  3. 傳送 ${NC}/newbot${GRAY}，建立一個 AI bot${NC}"
echo -e "  ${GRAY}     這個 bot 就是你未來跟 AI 對話的窗口${NC}"
echo -e "  ${GRAY}  4. 它會問 bot 的名稱，隨便取（例如 My AI Assistant）${NC}"
echo -e "  ${GRAY}  5. 再問 username，這是系統代號，必須以 bot 結尾${NC}"
echo -e "  ${GRAY}     （例如 my_ai_helper_bot）${NC}"
echo -e "  ${GRAY}     實際對話窗看到的名稱是第 4 步取的${NC}"
echo -e "  ${GRAY}  6. 它會回覆一串 token，格式像：${NC}"
echo "     7123456789:AAH-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo -e "  ${GRAY}  7. 複製這串 token${NC}"
echo -e "  ${GRAY}     手機上可以用 email 寄給自己，在電腦收信取得${NC}"
echo ""
echo -e "  ${YELLOW}沒有 Telegram？直接按 Enter 跳過，之後可以用 Web UI（http://localhost:18789）。${NC}"
echo ""
read -rp "  貼上你的 Telegram Bot Token（沒有就直接按 Enter）: " TG_TOKEN
echo ""

echo -e "  ${GREEN}資料收集完成！開始自動安裝...${NC}"
echo ""

# ===========================================================
#  PART 2: 自動安裝
# ===========================================================

step "1" "更新系統套件..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
info "完成。"

step "2" "安裝必要工具..."
sudo apt-get install -y -qq curl git build-essential ca-certificates gnupg unzip jq
info "完成。"

step "3" "安裝 Node.js 22..."
if command -v node &>/dev/null; then
    NODE_MAJOR=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 20 ]; then
        info "Node.js $(node --version) OK"
    else
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
        sudo apt-get install -y -qq nodejs
    fi
else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y -qq nodejs
fi

if [ ! -d "$HOME/.npm-global" ]; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
fi
if ! echo "$PATH" | grep -q "$HOME/.npm-global/bin"; then
    # Write to .profile so it works in both interactive and non-interactive shells
    # (.bashrc has an early exit for non-interactive shells on Ubuntu)
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.profile"
    export PATH="$HOME/.npm-global/bin:$PATH"
fi
info "Node.js $(node --version) 完成。"

step "4" "安裝 OpenClaw..."
if command -v openclaw &>/dev/null; then
    npm install -g openclaw@latest 2>&1 | tail -3
else
    npm install -g openclaw 2>&1 | tail -3
fi
if ! command -v openclaw &>/dev/null; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi
if ! command -v openclaw &>/dev/null; then
    err "OpenClaw 安裝失敗。"
    exit 1
fi
info "OpenClaw $(openclaw --version 2>/dev/null || echo '') 完成。"

step "5" "寫入設定..."
mkdir -p "$OPENCLAW_DIR"

CONFIG='{}'
CONFIG=$(echo "$CONFIG" | jq '
    .env = {} |
    .gateway = {
        "port": 18789,
        "mode": "local",
        "bind": "loopback"
    } |
    .agents.defaults.workspace = "'"$OPENCLAW_DIR"'/workspace" |
    .session.dmScope = "per-channel-peer"
')
if [ -n "${GEMINI_KEY:-}" ]; then
    CONFIG=$(echo "$CONFIG" | jq --arg k "$GEMINI_KEY" '.env.GEMINI_API_KEY = $k')
    info "Gemini API Key 已寫入。"
fi
if [ -n "${TG_TOKEN:-}" ]; then
    CONFIG=$(echo "$CONFIG" | jq --arg t "$TG_TOKEN" '
        .channels.telegram = {
            "enabled": true,
            "dmPolicy": "pairing",
            "botToken": $t,
            "groupPolicy": "allowlist",
            "streaming": "partial"
        }
    ')
    info "Telegram Bot Token 已寫入。"
fi
echo "$CONFIG" > "$OPENCLAW_DIR/openclaw.json"
chmod 600 "$OPENCLAW_DIR/openclaw.json"
info "設定檔已建立。"

step "6" "建立自動重啟機制..."
cat > "$OPENCLAW_DIR/keepalive.sh" << 'KEEPEOF'
#!/usr/bin/env bash
if ! pgrep -f "openclaw.*gateway" > /dev/null 2>&1; then
    echo "[$(date)] Restarting..." >> ~/.openclaw/keepalive.log
    openclaw gateway start >> ~/.openclaw/gateway.log 2>&1 &
fi
KEEPEOF
chmod +x "$OPENCLAW_DIR/keepalive.sh"
if command -v crontab &>/dev/null; then
    (crontab -l 2>/dev/null | grep -v "keepalive.sh"; echo "*/5 * * * * $OPENCLAW_DIR/keepalive.sh") | crontab - 2>/dev/null || true
fi
info "完成。"

step "7" "執行診斷..."
openclaw doctor --fix 2>&1 || true

step "8" "啟動 OpenClaw..."
openclaw gateway start 2>&1 &
sleep 3

if pgrep -f "openclaw.*gateway" > /dev/null 2>&1; then
    echo ""
    echo -e "  ${GREEN}=============================================${NC}"
    echo -e "  ${GREEN} OpenClaw 啟動成功！${NC}"
    echo -e "  ${GREEN}=============================================${NC}"

    # 顯示 Gateway Token，讓使用者可以貼到 Web UI
    GW_TOKEN=$(jq -r '.gateway.auth.token // empty' "$OPENCLAW_DIR/openclaw.json" 2>/dev/null || true)
    if [ -n "$GW_TOKEN" ]; then
        echo ""
        echo -e "  ${YELLOW}=============================================${NC}"
        echo -e "  ${YELLOW} Gateway Token（Web UI 登入用）${NC}"
        echo -e "  ${YELLOW}=============================================${NC}"
        echo ""
        echo -e "  ${RED}請把這串 Token 記下來！截圖或複製到記事本。${NC}"
        echo -e "  ${RED}之後用瀏覽器開 Web UI 時需要它登入。${NC}"
        echo ""
        echo -e "  ${GREEN}$GW_TOKEN${NC}"
        echo ""
        echo -e "  使用方式：打開 ${CYAN}http://localhost:18789${NC}"
        echo -e "  → 進入 ${CYAN}Control UI Settings${NC} → 貼上 Token"
        echo ""
    fi
else
    warn "Gateway 可能沒有正常啟動。"
    warn "執行 openclaw doctor 檢查問題。"
fi

# ===========================================================
#  PART 3: 測試引導
# ===========================================================
echo ""
echo -e "  ${CYAN}=============================================${NC}"
echo -e "  ${CYAN} 接下來：連接 ChatGPT 並開始測試${NC}"
echo -e "  ${CYAN}=============================================${NC}"
echo ""
echo -e "  ${CYAN}【步驟 A】連接你的 ChatGPT 帳號${NC}"
echo ""
echo -e "  ${YELLOW}安全提醒：${NC}"
echo -e "  ${GRAY}  OpenClaw 是開源專案，AI 運算透過 ChatGPT 雲端進行。${NC}"
echo -e "  ${GRAY}  你傳給 AI 的內容會經過 OpenAI 伺服器。${NC}"
echo -e "  ${GRAY}  請勿傳送機密資料（密碼、公司內部文件等）。${NC}"
echo ""
echo -e "  ${GRAY}  接下來會自動開啟瀏覽器，請：${NC}"
echo -e "  ${GRAY}  1. 登入你的 ChatGPT 帳號，按「授權」${NC}"
echo -e "  ${GRAY}  2. 瀏覽器顯示「Authentication successful」就完成了${NC}"
echo -e "  ${YELLOW}  3. 如果畫面顯示「Paste the authorization code」：${NC}"
echo -e "  ${YELLOW}     把瀏覽器網址列的完整網址複製，貼回這裡按 Enter${NC}"
echo -e "  ${GRAY}     （網址開頭像 http://localhost:1455/auth/callback?code=...）${NC}"
echo ""
echo -e "  ${YELLOW}操作提示：${NC}"
echo -e "  ${GRAY}  畫面中如果出現選單：${NC}"
echo -e "  ${GRAY}  - 按${NC} 空白鍵 ${GRAY}選擇／取消選擇項目${NC}"
echo -e "  ${GRAY}  - 按${NC} Enter ${GRAY}確定送出${NC}"
echo ""
echo -e "  ${YELLOW}按 Enter 開始連接 ChatGPT...${NC}"
read -rp "  "
openclaw onboard \
    --auth-choice openai-codex \
    --flow quickstart \
    --accept-risk \
    --skip-channels \
    --skip-skills \
    --skip-search \
    --skip-daemon \
    --skip-ui || true
echo ""

if [ -n "${TG_TOKEN:-}" ]; then
    echo -e "  ${CYAN}【步驟 B】配對 Telegram Bot${NC}"
    echo ""
    echo -e "  ${GRAY}  1. 打開 Telegram，搜尋你剛建立的 bot${NC}"
    echo -e "  ${GRAY}  2. 對它發一條訊息（例如「你好」）${NC}"
    echo -e "  ${GRAY}  3. Bot 會回覆一組配對碼（Pairing Code）${NC}"
    echo ""
    echo -e "  ${YELLOW}  完成後按 Enter，程式會自動幫你配對...${NC}"
    read -rp "  按 Enter 繼續..."
    echo ""

    # 等待配對請求出現
    sleep 3

    # 自動偵測並批准配對請求
    # 配對碼格式：大寫字母與數字組合（6-10 碼），例如 7YQ5LY3Q、S3GXBUW5
    PAIR_CODE=$(openclaw pairing list 2>&1 | grep -oE '[A-Z0-9]{6,10}' | head -1)
    if [ -n "$PAIR_CODE" ]; then
        echo -e "  偵測到配對請求：${GREEN}$PAIR_CODE${NC}"
        openclaw pairing approve "$PAIR_CODE" 2>&1
        echo ""
        echo -e "  ${GREEN}配對完成！之後只有你能跟這個 bot 對話。${NC}"
    else
        warn "沒有偵測到配對請求。"
        echo -e "  ${GRAY}  請確認你已經在 Telegram 對 bot 發了訊息。${NC}"
        echo -e "  ${GRAY}  之後可以手動執行：${NC}"
        echo -e "    ${GREEN}openclaw pairing list${NC}"
        echo -e "    ${GREEN}openclaw pairing approve <配對碼>${NC}"
    fi
    echo ""
fi

echo -e "  ${CYAN}【步驟 C】測試你的 AI 助理${NC}"
echo ""
echo "  配對完成後，對 bot 說這些話試試看："
echo ""
echo -e "  ${GRAY}  「今天天氣如何？」        → 測試搜尋功能${NC}"
echo -e "  ${GRAY}  「幫我摘要這個網頁 ...」  → 測試網頁擷取${NC}"
echo -e "  ${GRAY}  「提醒我明天早上 9 點開會」→ 測試提醒功能${NC}"
echo -e "  ${GRAY}  「你能做什麼？」          → 看完整功能列表${NC}"
echo ""
echo -e "  ${GRAY}控制台：${NC}${CYAN}http://localhost:18789${NC}"
echo ""
echo -e "  ${GRAY}常用指令：${NC}"
echo -e "  ${GRAY}  openclaw gateway status  - 查看狀態${NC}"
echo -e "  ${GRAY}  openclaw gateway stop    - 停止${NC}"
echo -e "  ${GRAY}  openclaw gateway start   - 啟動${NC}"
echo -e "  ${GRAY}  openclaw doctor           - 診斷${NC}"
echo ""
echo -e "  ${GRAY}遇到問題？聯繫 Liam 或到 GitHub 開 issue。${NC}"
echo ""
