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
echo -e "  ${GRAY}申請方式：${NC}"
echo -e "  ${GRAY}  1. 用瀏覽器打開 https://aistudio.google.com${NC}"
echo -e "  ${GRAY}  2. 用你的 Google 帳號登入${NC}"
echo -e "  ${GRAY}  3. 點左邊選單的「Get API Key」${NC}"
echo -e "  ${GRAY}  4. 點「Create API Key」${NC}"
echo -e "  ${GRAY}  5. 選一個 Google Cloud 專案（或建立新的）${NC}"
echo -e "  ${GRAY}  6. 複製產生的 key（開頭是 AIza...）${NC}"
echo ""
read -rp "  貼上你的 Gemini API Key: " GEMINI_KEY
echo ""

# --- Telegram Bot ---
echo -e "  ${CYAN}--- Telegram Bot Token（免費）---${NC}"
echo ""
echo "  這讓你可以用 Telegram App 跟 AI 助理對話。"
echo ""
echo -e "  ${GRAY}建立方式：${NC}"
echo -e "  ${GRAY}  1. 打開 Telegram（手機或電腦都可以）${NC}"
echo -e "  ${GRAY}  2. 搜尋 ${NC}@BotFather${GRAY} 並打開對話${NC}"
echo -e "  ${GRAY}  3. 傳送 ${NC}/newbot"
echo -e "  ${GRAY}  4. BotFather 會問你 bot 的名稱${NC}"
echo -e "  ${GRAY}     輸入一個名稱（例如 My AI Assistant）${NC}"
echo -e "  ${GRAY}  5. 再問 username${NC}"
echo -e "  ${GRAY}     輸入一個名稱，必須以 bot 結尾${NC}"
echo -e "  ${GRAY}     （例如 my_ai_helper_bot）${NC}"
echo -e "  ${GRAY}  6. BotFather 會回覆一串 token，格式像：${NC}"
echo "     7123456789:AAH-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo -e "  ${GRAY}  7. 長按（手機）或選取（電腦）複製這串 token${NC}"
echo ""
read -rp "  貼上你的 Telegram Bot Token: " TG_TOKEN
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
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
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
CONFIG=$(echo "$CONFIG" | jq '.env = {}')
if [ -n "${GEMINI_KEY:-}" ]; then
    CONFIG=$(echo "$CONFIG" | jq --arg k "$GEMINI_KEY" '.env.GEMINI_API_KEY = $k')
    info "Gemini API Key 已寫入。"
fi
if [ -n "${TG_TOKEN:-}" ]; then
    export TELEGRAM_BOT_TOKEN="$TG_TOKEN"
    info "Telegram Bot Token 已設定。"
fi
echo "$CONFIG" > "$OPENCLAW_DIR/openclaw.json"
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
echo "  執行以下指令："
echo -e "    ${GREEN}openclaw onboard --auth-choice openai-codex${NC}"
echo ""
echo -e "  ${GRAY}  1. 瀏覽器會自動打開 ChatGPT 登入頁面${NC}"
echo -e "  ${GRAY}  2. 登入你的 ChatGPT 帳號，按「授權」${NC}"
echo -e "  ${GRAY}  3. 瀏覽器顯示「Authentication successful」${NC}"
echo -e "  ${YELLOW}  4. 如果 terminal 沒有自動繼續：${NC}"
echo -e "  ${YELLOW}     把瀏覽器網址列的完整網址複製，${NC}"
echo -e "  ${YELLOW}     貼回這裡按 Enter${NC}"
echo ""

if [ -n "${TG_TOKEN:-}" ]; then
    echo -e "  ${CYAN}【步驟 B】配對 Telegram Bot${NC}"
    echo ""
    echo -e "  ${GRAY}  1. 打開 Telegram，搜尋你剛建立的 bot${NC}"
    echo -e "  ${GRAY}  2. 對它發一條訊息（例如「你好」）${NC}"
    echo -e "  ${GRAY}  3. Bot 會回覆一段配對網址${NC}"
    echo -e "  ${YELLOW}  4. 把那段網址複製，貼回 terminal 按 Enter${NC}"
    echo -e "  ${GRAY}  5. 配對完成！之後只有你能跟這個 bot 對話${NC}"
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
