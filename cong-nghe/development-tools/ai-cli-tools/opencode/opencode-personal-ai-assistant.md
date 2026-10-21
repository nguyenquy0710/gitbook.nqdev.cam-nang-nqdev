---
description: >-
  Tổng quan OpenCode - Personal AI Assistant: cài đặt, TUI, CLI, environment
  variables, tools, permissions, AGENTS.md, config, commands, plugins.
---

# OpenCode - Personal AI Assistant

**OpenCode** là một AI coding agent mã nguồn mở, chạy trực tiếp trong terminal. Nó đọc codebase của bạn, tự chọn model phù hợp từ hơn 75 LLM providers, rồi thực hiện thay đổi bằng chính các công cụ thật của máy — đọc file, tìm kiếm, chạy lệnh, sửa code — thay vì chỉ gợi ý như một chatbot.

Bài viết này là **trang tổng quan và bản đồ tài liệu**: đi từ cài đặt đến CLI, tools, permissions, rules, config, formatters, commands và plugins. Mỗi mục đều dẫn link tới trang tài liệu chính thức tiếng Việt để bạn đào sâu thêm.

{% hint style="info" %}
Hai bản tài liệu song song hành:

* **OpenCode v1** — bản đang dùng ổn định: [https://opencode.ai/docs](https://opencode.ai/docs)
* **OpenCode v2** — bản thế hệ mới: [https://opencode.ai/v2/docs](https://opencode.ai/v2/docs)

Bản tiếng Việt (bao gồm CLI và Environment Variables): [https://opencode.io.vn/docs](https://opencode.io.vn/docs)
{% endhint %}

***

## OpenCode là gì?

Theo định nghĩa từ tài liệu chính thức, OpenCode là **một AI coding agent mã nguồn mở**, được cung cấp dưới ba hình thức:

* **Terminal-based interface (TUI):** giao diện terminal tương tác, chạy trực tiếp trong shell.
* **Desktop app:** ứng dụng desktop cho macOS, Windows và Linux.
* **IDE extension:** tiện ích mở rộng cho VS Code, JetBrains IDE và Neovim.

Điểm khác biệt cốt lõi so với chatbot AI thông thường: OpenCode **thực thi** thay vì chỉ **trả lời**. Nó có quyền gọi tool thật trong dự án của bạn, và bạn kiểm soát mức độ tự do đó bằng hệ thống `permission`.

### Các tính năng nổi bật

* **Mã nguồn mở:** khoảng 63K+ GitHub stars, phát triển bởi team Anomaly.
* **Đa provider:** hỗ trợ **75+ LLM providers** thông qua AI SDK và [Models.dev](https://models.dev).
* **TUI + CLI + Web:** dùng được cả tương tác trong terminal, headless qua script, hay trên trình duyệt.
* **Permissions chi tiết:** mặc định cho phép, nhưng có thể hạ từng tool, từng lệnh `bash`, từng MCP server về chế độ `ask` hoặc `deny`.
* **Tương thích Claude Code:** đọc sẵn `CLAUDE.md`, `~/.claude/skills/` — dễ chuyển đổi từ hệ sinh thái cũ.
* **Mở rộng được:** MCP servers, custom tools, custom commands, plugins, agent skills, LSP servers.
* **Quản trị tập trung:** remote config qua `.well-known/opencode` và managed settings cho tổ chức.

***

## Phiên bản: v1 và v2

Hai bản hiện hành khác nhau khá nhiều về cách đóng gói. Đây là những khác biệt bạn cần biết trước khi cài.

{% tabs %}
{% tab title="OpenCode v1 (đang dùng ổn định)" %}
Tài liệu: [https://opencode.ai/docs](https://opencode.ai/docs)

* **npm package:** `opencode-ai`
* **Homebrew tap:** `anomalyco/tap/opencode`
* **Cài đặt:** `curl -fsSL https://opencode.ai/install | bash`
* **Docker:** `ghcr.io/anomalyco/opencode`
* **Hỗ trợ Windows:** có — qua Chocolatey, Scoop, npm, hoặc tốt nhất là chạy qua **WSL**
* **Giao diện:** TUI, Desktop app, Web, IDE extension
* **Server:** `opencode serve` (headless HTTP API), `opencode web`, `opencode attach`
* **ACP:** `opencode acp` (Agent Client Protocol qua stdin/stdout)
{% endtab %}
{% tab title="OpenCode v2 (thế hệ mới)" %}
Tài liệu: [https://opencode.ai/v2/docs](https://opencode.ai/v2/docs)

* **npm package:** `@opencode/cli` (đổi tên, khác scope)
* **Homebrew tap:** `anomalyco/tap/opencode-v2`
* **Cài đặt:** `curl -fsSL https://opencode.ai/v2/install | bash`
* **Lưu ý:** **không hỗ trợ** các Windows package managers
* **Vite+:** hỗ trợ `vp install -g @opencode/cli`
* **AUR:** `paru -S opencode-beta`
* **Giao diện:** TUI, Desktop app, Web app
* **Lệnh mới:** `opencode pair` — sinh cặp URL + username/password để truy cập web interface
* **Desktop build:** có bản `.dmg`, `.exe`, `.deb`, `.rpm`, `.AppImage`
* **Docker tags:** theo phiên bản, ví dụ `ghcr.io/anomalyco/opencode:2.0.0`
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
npm package của v2 (`@opencode/cli`) dùng **postinstall script** để chọn binary native theo nền tảng. Với Bun và pnpm bạn phải cho phép script chạy (`--trust`, `--allow-build`), còn Vite+ thì không cần cờ bổ sung.
{% endhint %}

***

## Cài đặt

### Yêu cầu trước khi bắt đầu

1. **Terminal emulator hiện đại:** WezTerm, Alacritty, Ghostty hoặc Kitty.
2. **API key** của ít nhất một LLM provider.

{% hint style="warning" %}
Tránh terminal mặc định của Windows (PowerShell cũ, Command Prompt) — TUI sẽ hiển thị lỗi. Nếu buộc phải dùng Windows, hãy chạy OpenCode trong **WSL**.
{% endhint %}

### Các cách cài đặt

{% tabs %}
{% tab title="Install script (nhanh nhất)" %}
{% code title="Cài đặt OpenCode bằng install script" overflow="wrap" lineNumbers="true" %}
```bash
curl -fsSL https://opencode.ai/install | bash
```
{% endcode %}
{% endtab %}
{% tab title="Node.js" %}
{% code title="Cài đặt OpenCode qua npm/bun/pnpm/yarn" overflow="wrap" lineNumbers="true" %}
```bash
npm install -g opencode-ai
# hoặc
bun install -g opencode-ai
# hoặc
pnpm install -g opencode-ai
# hoặc
yarn global add opencode-ai
```
{% endcode %}
{% endtab %}
{% tab title="Homebrew" %}
{% code title="Cài đặt OpenCode trên macOS và Linux" overflow="wrap" lineNumbers="true" %}
```bash
brew install anomalyco/tap/opencode
```
{% endcode %}

{% hint style="success" %}
Nên dùng tap chính thức `anomalyco/tap` vì được cập nhật thường xuyên. Công thức `brew install opencode` do Homebrew team bảo trì, cập nhật ít hơn.
{% endhint %}
{% endtab %}
{% tab title="Windows" %}
{% code title="Cài đặt OpenCode trên Windows" overflow="wrap" lineNumbers="true" %}
```bash
# Khuyến nghị: dùng WSL
# Chocolatey
choco install opencode

# Scoop
scoop install opencode

# npm
npm install -g opencode-ai

# Mise
mise use -g github:anomalyco/opencode

# Docker
docker run -it --rm ghcr.io/anomalyco/opencode
```
{% endcode %}
{% endtab %}
{% tab title="Arch Linux" %}
{% code title="Cài đặt OpenCode trên Arch Linux" overflow="wrap" lineNumbers="true" %}
```bash
sudo pacman -S opencode          # Arch Linux (Stable)
paru -S opencode-bin             # Arch Linux (Latest from AUR)
```
{% endcode %}
{% endtab %}
{% tab title="Binary thủ công" %}
Tải trực tiếp từ [GitHub Releases](https://github.com/anomalyco/opencode/releases).

Với v2, binary được phân phối theo từng nền tảng tại `https://opencode.ai/files/bin/<version>/`, ví dụ:

* **macOS:** `opencode-darwin-arm64.zip`, `opencode-darwin-x64.zip`
* **Windows:** `opencode-windows-x64.zip`, `opencode-windows-arm64.zip`
* **Linux (glibc):** `opencode-linux-x64.tar.gz`
* **Linux (musl):** `opencode-linux-x64-musl.tar.gz`
{% endtab %}
{% endtabs %}

### Cấu hình Provider

OpenCode lấy danh sách providers từ [Models.dev](https://models.dev), nên bạn có thể cấu hình API key cho **bất kỳ** provider nào.

{% tabs %}
{% tab title="OpenCode Zen (khuyến nghị)" %}
Danh sách model đã được test và verify bởi team OpenCode — phù hợp nhất cho người mới.

1. Chạy `/connect` trong TUI, chọn **opencode**
2. Truy cập [opencode.ai/auth](https://opencode.ai/auth)
3. Đăng nhập, thêm billing, copy API key
4. Paste API key vào terminal
{% endtab %}
{% tab title="Anthropic Claude" %}
{% code title="Kết nối Anthropic" overflow="wrap" %}
```text
/connect
```
{% endcode %}

Chọn **Anthropic** → chọn **Claude Pro/Max** hoặc nhập API key trực tiếp.
{% endtab %}
{% tab title="OpenAI GPT" %}
{% code title="Kết nối OpenAI" overflow="wrap" %}
```text
/connect
```
{% endcode %}

Chọn **OpenAI** → chọn **ChatGPT Plus/Pro** hoặc nhập API key trực tiếp.
{% endtab %}
{% tab title="Google Gemini" %}
{% code title="Cấu hình Gemini bằng environment variables" overflow="wrap" lineNumbers="true" %}
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
export GOOGLE_CLOUD_PROJECT=your-project-id
```
{% endcode %}
{% endtab %}
{% tab title="Ollama (local)" %}
Thêm provider local vào `opencode.json`:

{% code title="Kết nối Ollama chạy local" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "llama2": { "name": "Llama 2" }
      }
    }
  }
}
```
{% endcode %}
{% endtab %}
{% endtabs %}

### Khởi tạo dự án

{% code title="Khởi động OpenCode trong project" overflow="wrap" lineNumbers="true" %}
```bash
cd /path/to/project
opencode
```
{% endcode %}

Lần đầu tiên trong mỗi project, chạy lệnh `/init` để OpenCode phân tích codebase và tạo file `AGENTS.md`.

{% hint style="success" %}
**Hãy commit `AGENTS.md` vào Git.** Đây là cách chia sẻ ngữ cảnh dự án cho toàn bộ team, và giúp OpenCode hiểu cấu trúc project tốt hơn ở mọi máy.
{% endhint %}

### Cấu trúc thư mục

{% code title="Cấu trúc thư mục của OpenCode" overflow="wrap" lineNumbers="true" %}
```text
~/.config/opencode/          # Config global
├── opencode.json            # Config file
├── AGENTS.md                # Rules global
├── agents/                  # Custom agents
├── commands/                # Custom commands
├── plugins/                 # Plugins
├── skills/                  # Agent skills
└── themes/                  # Themes

~/.local/share/opencode/     # Data
├── auth.json                # API keys
└── sessions/                # Conversation history

./opencode.json              # Config per-project (optional)
./AGENTS.md                  # Project context
./.opencode/                 # Project-level config, agents, commands, plugins
```
{% endcode %}

### Xử lý sự cố cài đặt

* **Kiểm tra credentials:** `opencode auth list`
* **Không thấy model trong danh sách:** chạy `/connect`, hoặc kiểm tra provider config trong `opencode.json`.
* **TUI hiển thị lỗi:** đảm bảo terminal hỗ trợ TUI (WezTerm, Alacritty, Ghostty, Kitty), tránh terminal mặc định của Windows.

***

## Terminal UI (TUI)

Chạy `opencode` không có tham số sẽ khởi động TUI cho thư mục hiện tại. Bạn cũng có thể trỏ thẳng vào một thư mục cụ thể:

{% code title="Khởi động TUI" overflow="wrap" lineNumbers="true" %}
```bash
opencode
# hoặc
opencode /path/to/project
```
{% endcode %}

### Hai cú pháp tương tác nhanh

* **Tham chiếu file bằng `@`:** gõ `@` để mở fuzzy search trong thư mục làm việc, chọn file, nội dung file được tự động thêm vào hội thoại.
* **Chạy lệnh shell bằng `!`:** bắt đầu tin nhắn bằng `!` để chạy lệnh shell, output được đưa vào hội thoại như một kết quả tool.

{% code title="Cú pháp @ và ! trong TUI" overflow="wrap" lineNumbers="true" %}
```text
Auth được xử lý như thế nào trong @packages/functions/src/api/index.ts?
!ls -la
```
{% endcode %}

### Slash commands

Hầu hết lệnh có keybind dùng `ctrl+x` làm **leader key**.

| Lệnh | Mô tả | Keybind |
|:---|:---|:---|
| `/connect` | Thêm provider và API key | — |
| `/init` | Tạo hoặc cập nhật `AGENTS.md` | `ctrl+x i` |
| `/compact` | Nén context (alias `/summarize`) | `ctrl+x c` |
| `/details` | Bật/tắt chi tiết thực thi tool | `ctrl+x d` |
| `/editor` | Mở editor ngoài để viết tin nhắn | `ctrl+x e` |
| `/export` | Xuất hội thoại ra file Markdown | `ctrl+x x` |
| `/help` | Hiện hộp thoại trợ giúp | `ctrl+x h` |
| `/models` | Liệt kê model có sẵn | `ctrl+x m` |
| `/new` | Bắt đầu session mới (alias `/clear`) | `ctrl+x n` |
| `/redo` | Làm lại thay đổi đã undo | `ctrl+x r` |
| `/sessions` | Liệt kê / chuyển session (alias `/resume`) | `ctrl+x l` |
| `/share` | Chia sẻ session hiện tại | `ctrl+x s` |
| `/unshare` | Hủy chia sẻ session | — |
| `/theme` | Liệt kê theme | `ctrl+x t` |
| `/thinking` | Bật/tắt hiển thị khối reasoning | — |
| `/undo` | Hoàn tác thay đổi gần nhất | `ctrl+x u` |
| `/exit` | Thoát (alias `/quit`, `/q`) | `ctrl+x q` |

{% hint style="warning" %}
`/undo` và `/redo` dùng Git ở bên trong để quản lý thay đổi file — **project của bạn bắt buộc phải là một Git repository**.
{% endhint %}

### Cấu hình biến môi trường `EDITOR`

Cả `/editor` và `/export` đều gọi editor nằm trong biến môi trường `EDITOR`.

{% tabs %}
{% tab title="Linux / macOS" %}
{% code title="Thiết lập EDITOR trên Linux/macOS" overflow="wrap" lineNumbers="true" %}
```bash
export EDITOR=nano
export EDITOR=vim

# GUI editor (VS Code, Cursor, VSCodium, Windsurf, Zed...) cần thêm --wait
export EDITOR="code --wait"
```
{% endcode %}
{% endtab %}
{% tab title="Windows (CMD)" %}
{% code title="Thiết lập EDITOR trong CMD" overflow="wrap" lineNumbers="true" %}
```bat
set EDITOR=notepad
set EDITOR=code --wait
```
{% endcode %}
{% endtab %}
{% tab title="Windows (PowerShell)" %}
{% code title="Thiết lập EDITOR trong PowerShell" overflow="wrap" lineNumbers="true" %}
```powershell
$env:EDITOR = "notepad"
$env:EDITOR = "code --wait"
```
{% endcode %}
{% endtab %}
{% endtabs %}

Các editor phổ biến: `code`, `cursor`, `windsurf`, `nvim`, `vim`, `nano`, `notepad`, `subl`.

### Tuỳ chỉnh hành vi TUI

{% code title="Cấu hình TUI trong opencode.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "tui": {
    "scroll_speed": 3,
    "scroll_acceleration": { "enabled": true },
    "diff_style": "auto"
  }
}
```
{% endcode %}

* **`scroll_acceleration.enabled`:** cuộn kiểu macOS. **Thắng và ghi đè `scroll_speed`** khi được bật.
* **`scroll_speed`:** hệ số tốc độ cuộn (mặc định `3`, tối thiểu `1`). Bị bỏ qua nếu `scroll_acceleration.enabled` là `true`.
* **`diff_style`:** `auto` tự điều chỉnh theo độ rộng terminal, `stacked` luôn hiển thị một cột.

Ngoài ra, các tuỳ biến giao diện khác truy cập qua command palette (`ctrl+x h` hoặc `/help`) — ví dụ bật/tắt hiển thị username. Các thiết lập này được lưu lại giữa các lần khởi động.

***

## CLI

Ngoài TUI, CLI cho phép tương tác với OpenCode một cách có lập trình — rất phù hợp cho scripting và automation.

{% code title="Chạy OpenCode không tương tác" overflow="wrap" lineNumbers="true" %}
```bash
opencode run "Giải thích cách closures hoạt động trong JavaScript"
```
{% endcode %}

### Các lệnh chính

| Lệnh | Mô tả |
|:---|:---|
| `opencode [project]` | Khởi động TUI |
| `opencode run [message..]` | Chế độ non-interactive, truyền prompt trực tiếp |
| `opencode serve` | Khởi động HTTP server headless cho API access |
| `opencode web` | HTTP server headless kèm giao diện web |
| `opencode attach [url]` | Kết nối terminal tới backend server đang chạy |
| `opencode agent` | Quản lý agents (`create`, `list`) |
| `opencode auth` | Quản lý credentials (`login`, `list`/`ls`, `logout`) |
| `opencode mcp` | Quản lý MCP servers (`add`, `list`/`ls`, `auth`, `logout`, `debug`) |
| `opencode models [provider]` | Liệt kê model theo định dạng `provider/model` |
| `opencode session` | Quản lý sessions (`list`) |
| `opencode stats` | Thống kê token usage và chi phí |
| `opencode export [sessionID]` | Xuất session ra JSON |
| `opencode import <file>` | Import session từ file JSON hoặc share URL |
| `opencode github` | GitHub agent cho automation (`install`, `run`) |
| `opencode acp` | Khởi chạy ACP server (Agent Client Protocol) |
| `opencode upgrade [target]` | Nâng cấp lên phiên bản mới nhất hoặc bản cụ thể |
| `opencode uninstall` | Gỡ cài đặt và xoá files liên quan |

### Global flags

| Flag | Viết tắt | Mô tả |
|:---|:---|:---|
| `--help` | `-h` | Hiển thị trợ giúp |
| `--version` | `-v` | In số phiên bản |
| `--print-logs` | — | In logs ra `stderr` |
| `--log-level` | — | Mức log: `DEBUG`, `INFO`, `WARN`, `ERROR` |

### Vài flag đáng chú ý

{% code title="Các flag thường dùng của lệnh run" overflow="wrap" lineNumbers="true" %}
```bash
# Chạy bằng model và agent cụ thể
opencode run --model anthropic/claude-sonnet-4-5 --agent plan "Phân tích kiến trúc dự án"

# Đính kèm file vào message
opencode run -f ./screenshot.png "Dựng lại UI theo ảnh này"

# Output dạng JSON raw events để xử lý bằng script
opencode run --format json "Liệt kê các TODO còn tồn đọng"

# Tránh cold boot MCP server: attach vào server đang chạy
opencode run --attach http://localhost:4096 "Giải thích async/await"
```
{% endcode %}

`opencode models --refresh` làm mới cache models từ Models.dev — hữu ích khi provider vừa thêm model mới. `opencode models --verbose` hiện thêm metadata như chi phí.

***

## Environment Variables

Đây là phần **cấu hình quan trọng nhất** nếu bạn định dùng OpenCode trong CI, container hoặc môi trường team. Toàn bộ hành vi runtime đều điều khiển được qua biến môi trường.

### Cấu hình và hành vi

{% tabs %}
{% tab title="Đường dẫn config" %}
| Biến | Kiểu | Mô tả |
|:---|:---|:---|
| `OPENCODE_CONFIG` | string | Đường dẫn tới config file — load giữa global config và project config |
| `OPENCODE_CONFIG_DIR` | string | Đường dẫn tới config directory — thay thế thư mục `.opencode` |
| `OPENCODE_CONFIG_CONTENT` | string | Nội dung config JSON inline, ghi đè lúc runtime |
| `OPENCODE_PERMISSION` | string | Config permissions JSON inline |
| `EDITOR` | string | Editor dùng cho lệnh `/editor` và `/export` |
{% endtab %}
{% tab title="Bật/tắt tính năng" %}
| Biến | Kiểu | Mô tả |
|:---|:---|:---|
| `OPENCODE_AUTO_SHARE` | boolean | Tự động chia sẻ sessions |
| `OPENCODE_DISABLE_AUTOUPDATE` | boolean | Tắt kiểm tra cập nhật tự động |
| `OPENCODE_DISABLE_AUTOCOMPACT` | boolean | Tắt automatic context compaction |
| `OPENCODE_DISABLE_PRUNE` | boolean | Tắt pruning dữ liệu cũ |
| `OPENCODE_DISABLE_TERMINAL_TITLE` | boolean | Tắt cập nhật terminal title tự động |
| `OPENCODE_DISABLE_DEFAULT_PLUGINS` | boolean | Tắt default plugins |
| `OPENCODE_DISABLE_LSP_DOWNLOAD` | boolean | Tắt tự động download LSP server |
| `OPENCODE_ENABLE_EXPERIMENTAL_MODELS` | boolean | Bật experimental models |
| `OPENCODE_ENABLE_EXA` | boolean | Bật Exa web search tools (`websearch`) |
| `OPENCODE_GIT_BASH_PATH` | string | Đường dẫn Git Bash executable trên Windows |
{% endtab %}
{% tab title="Tương thích Claude Code" %}
| Biến | Kiểu | Mô tả |
|:---|:---|:---|
| `OPENCODE_DISABLE_CLAUDE_CODE` | boolean | Tắt toàn bộ hỗ trợ `.claude` (prompt + skills) |
| `OPENCODE_DISABLE_CLAUDE_CODE_PROMPT` | boolean | Chỉ tắt đọc `~/.claude/CLAUDE.md` |
| `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS` | boolean | Chỉ tắt loading `.claude/skills` |
{% endtab %}
{% tab title="Server & client" %}
| Biến | Kiểu | Mô tả |
|:---|:---|:---|
| `OPENCODE_SERVER_PASSWORD` | string | Bật HTTP basic auth cho `serve` / `web` |
| `OPENCODE_SERVER_USERNAME` | string | Ghi đè basic auth username (mặc định `opencode`) |
| `OPENCODE_CLIENT` | string | Client identifier (mặc định `cli`) |
{% endtab %}
{% tab title="Experimental" %}
Các biến này bật tính năng đang phát triển, **có thể thay đổi hoặc bị xoá không báo trước**.

| Biến | Kiểu | Mô tả |
|:---|:---|:---|
| `OPENCODE_EXPERIMENTAL` | boolean | Bật tất cả tính năng experimental |
| `OPENCODE_EXPERIMENTAL_ICON_DISCOVERY` | boolean | Bật icon discovery |
| `OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT` | boolean | Tắt copy on select trong TUI |
| `OPENCODE_EXPERIMENTAL_BASH_MAX_OUTPUT_LENGTH` | number | Độ dài output tối đa cho bash commands |
| `OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS` | number | Timeout mặc định cho bash commands (ms) |
| `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` | number | Số output tokens tối đa cho LLM responses |
| `OPENCODE_EXPERIMENTAL_FILEWATCHER` | boolean | Bật file watcher cho toàn bộ directory |
| `OPENCODE_EXPERIMENTAL_OXFMT` | boolean | Bật oxfmt formatter |
| `OPENCODE_EXPERIMENTAL_LSP_TOOL` | boolean | Bật experimental LSP tool |
{% endtab %}
{% endtabs %}

### Cách dùng thực tế

{% hint style="danger" %}
**Tuyệt đối không** đặt API key trực tiếp trong `opencode.json`. Hãy dùng cú pháp thay thế `{env:...}` hoặc `{file:...}` để giữ secret ngoài repo (xem phần [Thay thế biến trong config](#thay-the-bien-trong-config)).
{% endhint %}

{% code title="Khoá cấu hình hành vi cho môi trường CI" overflow="wrap" lineNumbers="true" %}
```bash
# Không cho agent chạy lệnh nguy hiểm mà không hỏi
export OPENCODE_PERMISSION='{"bash":"ask","edit":"ask","webfetch":"allow"}'

# Bật web search và không tự cập nhật trong container
export OPENCODE_ENABLE_EXA=1
export OPENCODE_DISABLE_AUTOUPDATE=1

# Chạy 1 task headless, không đụng tới file local
OPENCODE_CONFIG_CONTENT='{"model":"anthropic/claude-sonnet-4-5","tools":{"write":false}}' \
  opencode run "Tóm tắt diff này: $(git diff | head -200)"
```
{% endcode %}

{% code title="Dùng cấu hình inline cho CI job" overflow="wrap" lineNumbers="true" %}
```bash
export OPENCODE_CONFIG_CONTENT='{
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5",
  "compaction": { "auto": true, "prune": true }
}'
opencode run --format json "Kiểm tra các thay đổi trong staging area"
```
{% endcode %}

{% hint style="info" %}
`OPENCODE_CLIENT` nên được đặt khi bạn tích hợp OpenCode vào sản phẩm riêng qua SDK hoặc server mode — nó giúp server nhận diện đúng nguồn gọi. Ví dụ: `OPENCODE_CLIENT=my-internal-tool`.
{% endhint %}

***

## Tools

Tools là các hành động LLM được phép thực hiện trong codebase. **Mặc định tất cả tools đều bật và không cần quyền** — bạn kiểm soát thông qua `permission`.

| Tool | Mô tả | Permission key |
|:---|:---|:---|
| `bash` | Chạy lệnh shell (`npm install`, `git status`,...) | `bash` |
| `edit` | Sửa file bằng thay thế chuỗi chính xác | `edit` |
| `write` | Tạo file mới hoặc ghi đè file hiện có | `edit` |
| `patch` | Áp dụng patch files vào codebase | `edit` |
| `read` | Đọc nội dung file, hỗ trợ đọc khoảng dòng cụ thể | `read` |
| `grep` | Tìm kiếm nội dung bằng regular expressions | `grep` |
| `glob` | Tìm file bằng glob patterns, sắp xếp theo thời gian sửa | `glob` |
| `list` | Liệt kê file/thư mục, chấp nhận glob để lọc | `list` |
| `skill` | Load một skill (`SKILL.md`) vào hội thoại | `skill` |
| `todowrite` | Quản lý danh sách todo trong session | `todowrite` |
| `todoread` | Đọc danh sách todo hiện có | `todoread` |
| `websearch` | Tìm kiếm web qua Exa AI (cần `OPENCODE_ENABLE_EXA`) | `websearch` |
| `webfetch` | Lấy và đọc nội dung trang web | `webfetch` |
| `question` | Hỏi người dùng câu hỏi trong quá trình thực thi | `question` |
| `lsp` | Code intelligence (experimental) | `lsp` |

{% hint style="info" %}
Tool `write`, `patch`, `multiedit` đều bị kiểm soát bởi **cùng một** permission key `edit`. `todowrite` và `todoread` mặc định bị tắt cho subagents.
{% endhint %}

### Tìm kiếm và ignore patterns

Bên trong, `grep`, `glob` và `list` dùng [ripgrep](https://github.com/BurntSushi/ripgrep) và **tuân theo `.gitignore`**. Muốn tìm trong các thư mục thường bị ignore, tạo file `.ignore` ở thư mục gốc project:

{% code title="File .ignore để mở rộng phạm vi tìm kiếm" overflow="wrap" lineNumbers="true" %}
```text
!node_modules/
!dist/
!build/
```
{% endcode %}

### Mở rộng tools

* **Custom tools:** định nghĩa function riêng trong config file.
* **MCP servers:** tích hợp database, API và dịch vụ bên thứ ba qua Model Context Protocol.

***

## Permissions

Permissions kiểm soát chính xác những gì agent được phép làm, với ba mức:

* **`allow`** — cho phép, không hỏi
* **`ask`** — hỏi người dùng trước khi thực hiện
* **`deny`** — từ chối hoàn toàn

{% code title="Cấu hình permissions cơ bản" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "webfetch": "allow"
  }
}
```
{% endcode %}

### Wildcard cho MCP servers

{% code title="Yêu cầu phê duyệt mọi tool từ một MCP server" overflow="wrap" lineNumbers="true" %}
```json
{
  "permission": {
    "mymcp_*": "ask"
  }
}
```
{% endcode %}

### Kiểm soát từng lệnh bash

{% code title="Permission theo pattern lệnh bash" overflow="wrap" lineNumbers="true" %}
```json
{
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "git push": "ask"
        }
      }
    }
  }
}
```
{% endcode %}

{% hint style="warning" %}
**Rule khớp cuối cùng thắng.** Luôn đặt wildcard `*` **trước**, các rules cụ thể **sau**.
{% endhint %}

### Per-agent và Task permissions

{% tabs %}
{% tab title="Per-agent" %}
{% code title="Ghi đè permissions theo từng agent" overflow="wrap" lineNumbers="true" %}
```json
{
  "permission": { "edit": "deny" },
  "agent": {
    "build": { "permission": { "edit": "ask" } }
  }
}
```
{% endcode %}
{% endtab %}
{% tab title="Trong file markdown agent" %}
{% code title="Permissions khai báo trong front matter của agent" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Code review without edits
mode: subagent
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
  webfetch: deny
---
```
{% endcode %}
{% endtab %}
{% tab title="Task permissions" %}
{% code title="Kiểm soát subagent nào được phép gọi" overflow="wrap" lineNumbers="true" %}
```json
{
  "agent": {
    "orchestrator": {
      "permission": {
        "task": {
          "*": "deny",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```
{% endcode %}
{% endtab %}
{% endtabs %}

***

## Rules (AGENTS.md)

`AGENTS.md` là nơi bạn cung cấp hướng dẫn tùy chỉnh — tương tự như rules của Cursor. Nội dung file được đưa vào context của LLM.

### Khởi tạo

Chạy `/init` trong OpenCode để quét dự án và tạo `AGENTS.md` tự động. Nếu file đã tồn tại, lệnh sẽ bổ sung nội dung vào file hiện có.

{% code title="Ví dụ cấu trúc AGENTS.md" overflow="wrap" lineNumbers="true" %}
```markdown
# SST v3 Monorepo Project

This is an SST v3 monorepo with TypeScript. The project uses bun workspaces
for package management.

## Project Structure

- `packages/` - Contains all workspace packages (functions, core, web, etc.)
- `infra/` - Infrastructure definitions split by service
- `sst.config.ts` - Main SST configuration with dynamic imports

## Code Standards

- Use TypeScript with strict mode enabled
- Shared code goes in `packages/core/` with proper exports configuration
- Functions go in `packages/functions/`
- Infrastructure should be split into logical files in `infra/`

## Monorepo Conventions

- Import shared modules using workspace names: `@my-app/core/example`
```
{% endcode %}

### Thứ tự ưu tiên

Khi khởi động, OpenCode tìm rules theo thứ tự:

1. **File cục bộ** — duyệt ngược lên từ thư mục hiện tại (`AGENTS.md`, `CLAUDE.md`, hoặc `CONTEXT.md`)
2. **File toàn cục** — `~/.config/opencode/AGENTS.md`
3. **File Claude Code** — `~/.claude/CLAUDE.md` (trừ khi bị tắt)

{% hint style="info" %}
Trong **mỗi** danh mục, chỉ file đầu tiên khớp được dùng. Nếu có cả `AGENTS.md` và `CLAUDE.md` cùng cấp, `AGENTS.md` thắng.
{% endhint %}

### Tương thích Claude Code

* **Project rules:** `CLAUDE.md` trong thư mục dự án (dùng khi không có `AGENTS.md`)
* **Global rules:** `~/.claude/CLAUDE.md` (dùng khi không có `~/.config/opencode/AGENTS.md`)
* **Skills:** `~/.claude/skills/`

Tắt hỗ trợ này bằng `OPENCODE_DISABLE_CLAUDE_CODE=1` (hoặc hai biến con nếu chỉ muốn tắt một phần).

### Custom instructions

Trường `instructions` cho phép tái sử dụng rules có sẵn thay vì sao chép vào `AGENTS.md`:

{% code title="Khai báo custom instructions" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "packages/*/AGENTS.md",
    "https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"
  ]
}
```
{% endcode %}

Các instructions từ xa được fetch với **timeout 5 giây**. Tất cả các file instruction đều được **kết hợp** với các file `AGENTS.md` của bạn.

{% hint style="success" %}
Với monorepo hoặc dự án có tiêu chuẩn chung, dùng `opencode.json` kèm glob patterns (ví dụ `packages/*/AGENTS.md`) dễ bảo trì hơn hướng dẫn thủ công bằng `@file` trong `AGENTS.md`.
{% endhint %}

***

## Cấu hình (opencode.json)

OpenCode hỗ trợ cả **JSON** và **JSONC** (JSON có comments), với schema công khai tại [opencode.ai/config.json](https://opencode.ai/config.json) để editor validate và autocomplete.

{% code title="Ví dụ opencode.json hoàn chỉnh" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  "theme": "opencode",
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5",
  "autoupdate": "notify",
  "default_agent": "build",
  "share": "manual",

  "permission": {
    "edit": "ask",
    "bash": "ask"
  },

  "instructions": ["docs/guidelines.md"],

  "provider": {
    "anthropic": {
      "options": { "timeout": 600000, "setCacheKey": true }
    }
  },

  "compaction": { "auto": true, "prune": true },
  "watcher": { "ignore": ["node_modules/**", "dist/**", ".git/**"] },
  "formatter": { "prettier": { "disabled": true } },
  "plugin": ["opencode-wakatime"],

  "disabled_providers": ["openai"]
}
```
{% endcode %}

### Thứ tự ưu tiên

{% hint style="info" %}
Các file cấu hình được **gộp lại với nhau**, không phải thay thế. Config sau chỉ ghi đè config trước cho các key bị trùng; các thiết lập không trùng đều được giữ lại.
{% endhint %}

Nguồn config được load theo thứ tự, nguồn sau ghi đè nguồn trước:

1. **Remote config** — `.well-known/opencode`, mặc định của tổ chức
2. **Global config** — `~/.config/opencode/opencode.json`
3. **Custom config** — biến `OPENCODE_CONFIG`
4. **Project config** — `opencode.json` trong project
5. **Thư mục `.opencode`** — agents, commands, plugins
6. **Inline config** — biến `OPENCODE_CONFIG_CONTENT`, ghi đè lúc runtime

Các thư mục `.opencode` và `~/.config/opencode` dùng **tên số nhiều** cho thư mục con: `agents/`, `commands/`, `modes/`, `plugins/`, `skills/`, `tools/`, `themes/`.

### Các option chính

{% tabs %}
{% tab title="Model & provider" %}
| Option | Mô tả |
|:---|:---|
| `model` | Model chính, định dạng `provider/model` |
| `small_model` | Model cho tác vụ nhẹ (tạo tiêu đề...) |
| `small_model` fallback | Mặc định dùng model rẻ hơn cùng provider, nếu không có thì fallback về `model` |
| `provider.<id>.options.timeout` | Timeout request (ms, mặc định `300000`, đặt `false` để tắt) |
| `provider.<id>.options.setCacheKey` | Luôn đặt cache key cho provider |
| `enabled_providers` | Chỉ cho phép các provider trong danh sách |
| `disabled_providers` | Chặn provider — **thắng** `enabled_providers` |
| `default_agent` | Agent mặc định, phải là primary agent |
{% endtab %}
{% tab title="Hành vi" %}
| Option | Mô tả |
|:---|:---|
| `theme` | Theme giao diện |
| `share` | `manual` (mặc định), `auto`, hoặc `disabled` |
| `autoupdate` | `true`, `false`, hoặc `"notify"` — chỉ hoạt động nếu không cài qua package manager |
| `compaction.auto` | Tự nén session khi context đầy (mặc định `true`) |
| `compaction.prune` | Xoá output tool cũ để tiết kiệm tokens (mặc định `true`) |
| `tools` | Bật/tắt từng tool, ví dụ `{ "write": false }` |
| `permission` | Chính sách allow/ask/deny |
| `keybinds` | Phím tắt tuỳ chỉnh |
| `shell` | Shell dùng cho terminal tương tác, ví dụ `"pwsh"` |
{% endtab %}
{% tab title="Tích hợp" %}
| Option | Mô tả |
|:---|:---|
| `mcp` | Cấu hình MCP servers |
| `plugin` | Load plugin từ npm, ví dụ `["opencode-wakatime"]` |
| `command` | Định nghĩa custom commands |
| `agent` | Định nghĩa custom agents |
| `instructions` | Mảng đường dẫn/glob tới file hướng dẫn |
| `formatter` | Cấu hình code formatters |
| `server` | `port`, `hostname`, `mdns`, `cors` cho `serve` / `web` |
{% endtab %}
{% endtabs %}

### Thay thế biến trong config

{% hint style="danger" %}
Đừng bao giờ hardcode API key trong `opencode.json` — file này thường được commit vào Git. Luôn dùng `{env:...}` hoặc `{file:...}`.
{% endhint %}

{% code title="Thay thế biến môi trường và nội dung file" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "{env:OPENCODE_MODEL}",
  "instructions": ["./custom-instructions.md"],
  "provider": {
    "anthropic": {
      "options": { "apiKey": "{env:ANTHROPIC_API_KEY}" }
    },
    "openai": {
      "options": { "apiKey": "{file:~/.secrets/openai-key}" }
    }
  }
}
```
{% endcode %}

Nếu biến môi trường không được đặt, giá trị được thay bằng **chuỗi rỗng**. Đường dẫn file có thể tương đối với thư mục chứa config, hoặc tuyệt đối bắt đầu bằng `/` hoặc `~`.

### Managed settings cho tổ chức

{% tabs %}
{% tab title="File-based" %}
| Nền tảng | Đường dẫn |
|:---|:---|
| macOS | `/Library/Application Support/opencode/` |
| Linux | `/etc/opencode/` |
| Windows | `%ProgramData%\opencode` |
{% endtab %}
{% tab title="macOS MDM" %}
OpenCode đọc managed preferences từ domain `ai.opencode.managed`, deploy qua MDM (Jamf, Kandji, FleetDM). Các key trong plist map trực tiếp tới field trong `opencode.json`.

Kiểm tra bằng: `opencode debug config`
{% endtab %}
{% endtabs %}

Các thư mục này yêu cầu quyền admin/root để ghi — người dùng không thể sửa, kể cả khi project config cố ghi đè.

***

## Formatters

OpenCode tự động format files sau khi viết hoặc edit, bảo đảm code được generate đúng coding style của project.

### Formatter tích hợp sẵn

| Formatter | Extensions | Yêu cầu |
|:---|:---|:---|
| `prettier` | `.js .jsx .ts .tsx .html .css .md .json .yaml` | `prettier` trong `package.json` |
| `biome` | `.js .jsx .ts .tsx .html .css .md .json` | file config `biome.json(c)` |
| `gofmt` | `.go` | lệnh `gofmt` |
| `rustfmt` | `.rs` | lệnh `rustfmt` |
| `cargofmt` | `.rs` | lệnh `cargo fmt` |
| `ruff` | `.py .pyi` | lệnh `ruff` |
| `dart` | `.dart` | lệnh `dart` |
| `shfmt` | `.sh .bash` | lệnh `shfmt` |
| `clang-format` | `.c .cpp .h .hpp` | file config `.clang-format` |

### Cách hoạt động

Khi OpenCode viết hoặc edit file, nó kiểm tra extension với tất cả formatters đã bật, chạy formatter command phù hợp, rồi áp dụng thay đổi. Nếu project có `prettier` trong `package.json`, OpenCode tự động dùng nó.

### Cấu hình

{% code title="Tắt và tùy biến formatters" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": { "disabled": true },
    "custom-prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "environment": { "NODE_ENV": "development" },
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    },
    "custom-md": {
      "command": ["deno", "fmt", "$FILE"],
      "extensions": [".md"]
    }
  }
}
```
{% endcode %}

Tắt toàn bộ: `{ "formatter": false }`. Biến `$FILE` được thay bằng đường dẫn file đang format.

***

## Custom Commands

Custom commands là prompt dựng sẵn để chạy bằng `/tên-lệnh`, thay vì gõ lại prompt dài mỗi lần. Chúng hoạt động song song với các lệnh built-in.

### Hai cách định nghĩa

{% tabs %}
{% tab title="Markdown (khuyến nghị)" %}
Đặt file `.md` vào `.opencode/commands/` (per-project) hoặc `~/.config/opencode/commands/` (global). **Tên file trở thành tên command** — `test.md` cho phép chạy `/test`.

{% code title=".opencode/commands/test.md" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Chạy tests với coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

Chạy full test suite với coverage report và hiển thị các test failures.
Tập trung vào các test lỗi và đề xuất cách fix.
```
{% endcode %}
{% endtab %}
{% tab title="JSON config" %}
{% code title="Định nghĩa commands trong opencode.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "test": {
      "template": "Chạy full test suite với coverage report.",
      "description": "Chạy tests với coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022",
      "subtask": true
    }
  }
}
```
{% endcode %}
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Custom command trùng tên với built-in command sẽ **ghi đè** (override) built-in command đó. Commands được load theo thứ tự: project > global.
{% endhint %}

### Cú pháp trong prompt

* **`$ARGUMENTS`** — toàn bộ tham số. Ví dụ `/component Button` → `$ARGUMENTS` = `Button`.
* **`$1`, `$2`, `$3`...** — từng tham số theo vị trí.
* **`` !`command` ``** — chèn output của lệnh shell vào prompt.
* **`@path/to/file`** — include nội dung file vào prompt.

### Các option

| Option | Mô tả |
|:---|:---|
| `template` | Prompt gửi đến LLM khi command thực thi (bắt buộc) |
| `description` | Mô tả ngắn hiển thị trong TUI |
| `agent` | Agent thực thi command (`build`, `plan`,...) |
| `model` | Override model mặc định cho command này |
| `subtask` | Chạy như subagent để không làm ô nhiễm context chính |

### Ví dụ thực tế

{% tabs %}
{% tab title="Review PR" %}
{% code title=".opencode/commands/pr-review.md" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Review Pull Request hiện tại
agent: plan
---

Xem các thay đổi trong PR hiện tại:
!`git diff main...HEAD`

Review code và đề xuất:
1. Potential bugs
2. Performance issues
3. Code style improvements
4. Missing tests
```
{% endcode %}
{% endtab %}
{% tab title="Generate tests" %}
{% code title=".opencode/commands/gen-tests.md" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Generate tests cho file
---

Phân tích file @$1 và generate unit tests bao gồm:
- Happy path tests
- Edge cases
- Error handling tests

Sử dụng testing framework hiện có trong project.
```
{% endcode %}

Chạy: `/gen-tests src/utils/calculator.ts`
{% endtab %}
{% tab title="Deploy check" %}
{% code title=".opencode/commands/deploy-check.md" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Kiểm tra trước khi deploy
subtask: true
---

Thực hiện pre-deploy checklist:

1. Build status:
!`npm run build`

2. Test results:
!`npm test`

3. Lint check:
!`npm run lint`

Tổng hợp và báo cáo các issues cần fix trước khi deploy.
```
{% endcode %}
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Dùng `subtask: true` cho các lệnh chỉ cần **kết quả cuối cùng** — nó giữ context chính gọn, nhất là với các lệnh sinh output dài.
{% endhint %}

***

## Plugin System

Plugins cho phép hook vào các events của OpenCode để thêm tính năng, tích hợp dịch vụ bên ngoài, hoặc sửa đổi behavior mặc định.

### Cài đặt plugin

{% tabs %}
{% tab title="Local files" %}
Đặt file JavaScript/TypeScript vào:

* `.opencode/plugins/` — project-level
* `~/.config/opencode/plugins/` — global

Files tự động load khi khởi động.
{% endtab %}
{% tab title="Từ npm" %}
{% code title="Load plugin từ npm" overflow="wrap" lineNumbers="true" %}
```json
{
  "plugin": ["opencode-helicone-session", "opencode-wakatime"]
}
```
{% endcode %}

npm plugins được Bun tự động cài, cache tại `~/.cache/opencode/node_modules/`. Local plugins load trực tiếp và có thể dùng `package.json` trong thư mục config.

Thứ tự load: global config → project config → global plugins → project plugins.
{% endtab %}
{% endtabs %}

### Cấu trúc plugin

Plugin là module JavaScript/TypeScript export một function:

{% code title="Cấu trúc plugin và context object" overflow="wrap" lineNumbers="true" %}
```ts
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async (ctx) => {
  // ctx: { project, client, $, directory, worktree }
  return {
    // hooks go here
  }
}
```
{% endcode %}

| Property | Mô tả |
|:---|:---|
| `project` | Thông tin project hiện tại |
| `directory` | Thư mục làm việc |
| `worktree` | Git worktree path |
| `client` | SDK client để tương tác với AI |
| `$` | Bun shell API |

### Danh sách events

* **Command:** `command.executed`
* **File:** `file.edited`, `file.watcher.updated`
* **Message:** `message.updated`, `message.removed`
* **Permission:** `permission.asked`, `permission.replied`
* **Session:** `session.created`, `session.compacted`, `session.deleted`, `session.idle`, `session.error`
* **Tool:** `tool.execute.before`, `tool.execute.after`
* **TUI:** `tui.prompt.append`, `tui.command.execute`, `tui.toast.show`

### Các ví dụ plugin

{% tabs %}
{% tab title="Notification" %}
{% code title="Gửi notification khi session idle" overflow="wrap" lineNumbers="true" %}
```js
export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`osascript -e 'display notification "Done!"'`
      }
    },
  }
}
```
{% endcode %}
{% endtab %}
{% tab title="Bảo vệ .env" %}
{% code title="Chặn đọc file .env" overflow="wrap" lineNumbers="true" %}
```js
export const EnvProtection = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("Do not read .env files")
      }
    },
  }
}
```
{% endcode %}
{% endtab %}
{% tab title="Custom tool" %}
{% code title="Đăng ký custom tool từ plugin" overflow="wrap" lineNumbers="true" %}
```ts
import { type Plugin, tool } from "@opencode-ai/plugin"

export const CustomToolsPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      mytool: tool({
        description: "Custom tool",
        args: { foo: tool.schema.string() },
        async execute(args) {
          return `Hello ${args.foo}`
        },
      }),
    },
  }
}
```
{% endcode %}
{% endtab %}
{% tab title="Inject env" %}
{% code title="Inject environment variables vào shell" overflow="wrap" lineNumbers="true" %}
```js
export const InjectEnvPlugin = async () => {
  return {
    "shell.env": async (input, output) => {
      output.env.MY_API_KEY = "secret"
    },
  }
}
```
{% endcode %}
{% endtab %}
{% endtabs %}

### Logging

{% code title="Logging trong plugin" overflow="wrap" lineNumbers="true" %}
```ts
await client.app.log({
  body: {
    service: "my-plugin",
    level: "info",
    message: "Plugin initialized",
  },
})
```
{% endcode %}

Các level: `debug`, `info`, `warn`, `error`.

***

## Tính năng mới và ChangeLog

* **Changelog chính thức (v1):** [https://opencode.ai/docs/changelog](https://opencode.ai/docs/changelog)
* **Tính năng mới (tiếng Việt):** [https://opencode.io.vn/docs/features-moi/](https://opencode.io.vn/docs/features-moi/)
* **What's new (v2):** [https://opencode.ai/v2/docs](https://opencode.ai/v2/docs)

### Các nhóm tính năng đáng chú ý

* **Multi-model support:** 75+ providers qua AI SDK và Models.dev; đổi model bằng `/models` hoặc `ctrl+t` để chuyển qua lại giữa variants có/không reasoning.
* **MCP integration:** 200+ MCP servers, cả remote (Context7, Vercel Grep) và local.
* **Agent Skills:** reusable instructions dạng `.opencode/skills/<name>/SKILL.md` — agent tự load khi cần.
* **Plan mode vs Build mode:** chuyển qua lại bằng phím **Tab**. Plan mode chỉ đề xuất approach, Build mode thực thi thay đổi.
* **File references & images:** `@` để tham chiếu file (fuzzy search), kéo-thả ảnh trực tiếp vào terminal.
* **Undo/Redo:** `/undo` và `/redo` nhiều lần được; thay đổi file được quản lý bằng Git.
* **Share conversations:** `/share` tạo link chia sẻ session với team. **Mặc định không tự động chia sẻ.**
* **Tích hợp IDE & Git:** VS Code, JetBrains, Neovim, GitHub Actions, GitLab Duo.

***

## Lộ trình gợi ý

Nếu bạn mới bắt đầu, thứ tự học hợp lý là:

1. **Cài đặt + `/connect`** — có provider, xem `/models` để chọn model.
2. **`/init`** — tạo `AGENTS.md` và **commit vào Git**.
3. **Tập quen với `@` và `!`** — tham chiếu file, chạy lệnh shell.
4. **Workflow Plan → Build** — luôn lập kế hoạch (Tab) trước khi yêu cầu sửa code.
5. **Thiết lập `permission`** — đặt `edit` và `bash` là `ask` cho tới khi tin tưởng agent hơn.
6. **Tạo `AGENTS.md` có cấu trúc** — mô tả project structure, code standards, conventions.
7. **Viết custom commands** cho các tác vụ lặp lại (`/review`, `/gen-tests`, `/deploy-check`).
8. **Chuyển sang `opencode.json`** — gom permissions, formatter, instructions vào file để commit.
9. **Thêm MCP servers và plugins** khi cần tích hợp hệ thống bên ngoài.

{% hint style="warning" %}
**Luôn commit `opencode.json` và `AGENTS.md` vào Git.** Đây là cách team chia sẻ cùng một trải nghiệm AI coding, thay vì mỗi người tự cấu hình một kiểu.
{% endhint %}

***

## Bài viết liên quan

{% content-ref url="../so-sanh-opencode-va-claude-code-nen-chon-ai-coding-agent-nao.md" %}
[So sánh OpenCode và Claude Code: Nên chọn AI Coding Agent nào?](so-sanh-opencode-va-claude-code-nen-chon-ai-coding-agent-nao.md)
{% endcontent-ref %}

{% content-ref url="../cau-truc-agents-skills-commands-opencode-vs-claude-code-va-cach-chuyen-doi.md" %}
[Cấu trúc Agents, Skills, Commands: OpenCode vs Claude Code — và cách chuyển đổi](cau-truc-agents-skills-commands-opencode-vs-claude-code-va-cach-chuyen-doi.md)
{% endcontent-ref %}

{% content-ref url="../claude-code/quy-tac-permission-va-bao-mat-claude-code.md" %}
[Quy tắc Permission và Bảo mật trong Claude Code](claude-code/quy-tac-permission-va-bao-mat-claude-code.md)
{% endcontent-ref %}

{% content-ref url="../claude-code/claude-md-bo-nho-du-an-va-auto-memory.md" %}
[CLAUDE.md — Bộ nhớ dự án và Auto Memory](claude-code/claude-md-bo-nho-du-an-va-auto-memory.md)
{% endcontent-ref %}

{% content-ref url="../so-sanh-codegraph-gitnexus-codebase-memory-mcp.md" %}
[So sánh CodeGraph, GitNexus và codebase-memory-mcp](so-sanh-codegraph-gitnexus-codebase-memory-mcp.md)
{% endcontent-ref %}

***

## Tài liệu tham khảo

### Tài liệu chính thức (tiếng Việt)

* [Tổng quan tài liệu OpenCode tiếng Việt](https://opencode.io.vn/docs/)
* [Cài đặt OpenCode](https://opencode.io.vn/docs/cai-dat/)
* [Terminal UI (TUI)](https://opencode.io.vn/docs/tui/)
* [CLI Commands](https://opencode.io.vn/docs/cli/) — *phần Environment Variables nằm ở cuối trang*
* [Tools](https://opencode.io.vn/docs/tools/)
* [Permissions](https://opencode.io.vn/docs/permissions/)
* [Rules (AGENTS.md)](https://opencode.io.vn/docs/rules/)
* [Cấu hình (opencode.json)](https://opencode.io.vn/docs/config/)
* [Formatters](https://opencode.io.vn/docs/formatters/)
* [Custom Commands](https://opencode.io.vn/docs/custom-commands/)
* [Plugin System](https://opencode.io.vn/docs/plugins/)
* [Tính năng mới](https://opencode.io.vn/docs/features-moi/)

### Tài liệu chính thức (tiếng Anh)

* [OpenCode v1 — https://opencode.ai/docs](https://opencode.ai/docs)
* [OpenCode v2 — https://opencode.ai/v2/docs](https://opencode.ai/v2/docs)
* [Schema cấu hình — https://opencode.ai/config.json](https://opencode.ai/config.json)
* [Models.dev](https://models.dev)

### Mã nguồn

* [GitHub — anomalyco/opencode](https://github.com/anomalyco/opencode)
* [Releases](https://github.com/anomalyco/opencode/releases)
