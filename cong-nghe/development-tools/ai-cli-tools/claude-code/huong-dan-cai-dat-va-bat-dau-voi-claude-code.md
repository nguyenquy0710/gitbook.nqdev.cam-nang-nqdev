---
description: >-
  Hướng dẫn chi tiết cài đặt Claude Code trên macOS, Linux, Windows và bắt
  đầu phiên làm việc đầu tiên với AI coding agent trong terminal.
---

# Hướng dẫn cài đặt và bắt đầu với Claude Code

Claude Code là một agentic coding tool chạy trong terminal, đọc hiểu codebase và giúp bạn code nhanh hơn thông qua lệnh ngôn ngữ tự nhiên. Hướng dẫn này cover từ cài đặt đến phiên làm việc đầu tiên.

## Yêu cầu hệ thống

Trước khi cài đặt, kiểm tra máy bạn đáp ứng các yêu cầu tối thiểu:

* **Hệ điều hành:** macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+, Alpine 3.19+
* **Phần cứng:** 4 GB+ RAM, vi xử lý x64 hoặc ARM64
* **Mạng:** kết nối internet bắt buộc
* **Shell:** Bash, Zsh, PowerShell, hoặc CMD
* **Vị trí:** các quốc gia được Anthropic hỗ trợ

{% hint style="info" %}
Trên Windows, cài đặt [Git for Windows](https://git-scm.com/downloads/win) để Claude Code sử dụng Bash tool. Nếu không cài, Claude sẽ dùng PowerShell thay thế.
{% endhint %}

## Cài đặt Claude Code

### macOS / Linux / WSL (Recommended)

{% code title="Terminal" overflow="wrap" %}
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
{% endcode %}

### Windows PowerShell

{% code title="PowerShell" overflow="wrap" %}
```powershell
irm https://claude.ai/install.ps1 | iex
```
{% endcode %}

### Windows CMD

{% code title="CMD" overflow="wrap" %}
```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```
{% endcode %}

{% hint style="warning" %}
Nếu gặp lỗi `The token '&&' is not a valid statement separator`, bạn đang ở PowerShell chứ không phải CMD. Nếu thấy `'irm' is not recognized`, bạn đang ở CMD. Prompt `PS C:\` là PowerShell, `C:\` là CMD.
{% endhint %}

### Các phương pháp khác

{% tabs %}
{% tab title="Homebrew (macOS/Linux)" %}
{% code title="Terminal" overflow="wrap" %}
```bash
brew install --cask claude-code
```
{% endcode %}

Homebrew có 2 cask:
* `claude-code` — bản stable (chậm hơn ~1 tuần, skip major regressions)
* `claude-code@latest` — bản mới nhất ngay khi release

Homebrew **không auto-update**. Chạy `brew upgrade claude-code` để cập nhật thủ công.
{% endtab %}

{% tab title="WinGet (Windows)" %}
{% code title="PowerShell" overflow="wrap" %}
```powershell
winget install Anthropic.ClaudeCode
```
{% endcode %}

WinGet **không auto-update**. Chạy `winget upgrade Anthropic.ClaudeCode` để cập nhật.
{% endtab %}

{% tab title="npm (Deprecated)" %}
{% code title="Terminal" overflow="wrap" %}
```bash
npm install -g @anthropic-ai/claude-code
```
{% endcode %}

{% hint style="danger" %}
npm install hiện đã deprecated. Ưu tiên dùng Native Install hoặc Homebrew/WinGet.
{% endhint %}
{% endtab %}
{% endtabs %}

### Cài đặt trên Linux với package manager

Claude Code hỗ trợ apt (Debian/Ubuntu), dnf (Fedora/RHEL), và apk (Alpine):

{% tabs %}
{% tab title="apt (Debian/Ubuntu)" %}
{% code title="Terminal" overflow="wrap" %}
```bash
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
  -o /etc/apt/keyrings/claude-code.asc
echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
  | sudo tee /etc/apt/sources.list.d/claude-code.list
sudo apt update
sudo apt install claude-code
```
{% endcode %}
{% endtab %}

{% tab title="dnf (Fedora/RHEL)" %}
{% code title="Terminal" overflow="wrap" %}
```bash
sudo tee /etc/yum.repos.d/claude-code.repo <<'EOF'
[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://downloads.claude.ai/keys/claude-code.asc
EOF
sudo dnf install claude-code
```
{% endcode %}
{% endtab %}

{% tab title="apk (Alpine)" %}
{% code title="Terminal" overflow="wrap" %}
```sh
wget -O /etc/apk/keys/claude-code.rsa.pub \
  https://downloads.claude.ai/keys/claude-code.rsa.pub
echo "https://downloads.claude.ai/claude-code/apk/stable" >> /etc/apk/repositories
apk add claude-code
```
{% endcode %}
{% endtab %}
{% endtabs %}

## Xác minh cài đặt

Sau khi cài đặt, kiểm tra bằng lệnh:

{% code title="Terminal" overflow="wrap" %}
```bash
claude --version
```
{% endcode %}

Kết quả mong đợi: in ra phiên bản如 `2.1.211 (Claude Code)`.

Để kiểm tra chi tiết hơn:

{% code title="Terminal" overflow="wrap" %}
```bash
claude doctor
```
{% endcode %}

`claude doctor` kiểm tra:
* **Node.js version** — runtime đúng chưa
* **CLI installation** — binary hoạt động chưa
* **Git config** — user.name, user.email
* **MCP servers** — kết nối
* **Permissions** — sandbox, file permissions
* **Disk space** — đủ cho context cache

## Đăng nhập tài khoản

Claude Code yêu cầu tài khoản Claude (Pro, Max, Team, Enterprise) hoặc Console account. Chạy `claude` lần đầu sẽ được hướng dẫn đăng nhập:

{% code title="Terminal" overflow="wrap" %}
```bash
cd /path/to/your/project
claude
```
{% endcode %}

Trình duyệt sẽ mở ra để hoàn tất xác thực. Để chuyển tài khoản sau này, gõ `/login` bên trong session.

{% tabs %}
{% tab title="Claude Subscription" %}
Tài khoản Claude Pro, Max, Team, hoặc Enterprise — recommended.
{% endtab %}

{% tab title="Claude Console" %}
API access với credits prepaid. Khi login lần đầu, Console tự tạo workspace "Claude Code" để track chi phí.
{% endtab %}

{% tab title="Cloud Provider" %}
Amazon Bedrock, Google Cloud Agent Platform, hoặc Microsoft Foundry — cho enterprise.
{% endtab %}
{% endtabs %}

## Cấu hình Release Channel

Claude Code kiểm tra update khi khởi động và chạy periodic. Cấu hình channel bằng `autoUpdatesChannel` trong settings:

{% tabs %}
{% tab title="latest (Mặc định)" %}
Nhận feature mới ngay khi release.
{% endtab %}

{% tab title="stable" %}
Bản ~1 tuần tuổi, skip releases có major regressions. Phù hợp cho production.
{% endtab %}
{% endtabs %}

{% code title="settings.json" overflow="wrap" %}
```json
{
  "autoUpdatesChannel": "stable"
}
```
{% endcode %}

### Tắt auto-update

{% code title="settings.json" overflow="wrap" %}
```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```
{% endcode %}

{% hint style="info" %}
`DISABLE_AUTOUPDATER` chỉ dừng background check. `claude update` vẫn hoạt động. Để block tất cả, dùng `DISABLE_UPDATES`.
{% endhint %}

### Cập nhật thủ công

{% code title="Terminal" overflow="wrap" %}
```bash
claude update
```
{% endcode %}

## Gỡ cài đặt

{% tabs %}
{% tab title="macOS / Linux / WSL" %}
{% code title="Terminal" overflow="wrap" %}
```bash
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude
```
{% endcode %}
{% endtab %}

{% tab title="Windows PowerShell" %}
{% code title="PowerShell" overflow="wrap" %}
```powershell
Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force
```
{% endcode %}
{% endtab %}

{% tab title="Homebrew" %}
{% code title="Terminal" overflow="wrap" %}
```bash
brew uninstall --cask claude-code
```
{% endcode %}
{% endtab %}
{% endtabs %}

Để xóa toàn bộ settings và cached data:

{% hint style="danger" %}
Lệnh này xóa tất cả settings, allowed tools, MCP servers, và session history.
{% endhint %}

{% code title="macOS / Linux" overflow="wrap" %}
```bash
rm -rf ~/.claude
rm ~/.claude.json
rm -rf .claude
rm -f .mcp.json
```
{% endcode %}

## Tài liệu tham khảo

* [Claude Code Overview](https://code.claude.com/docs/en/overview)
* [Advanced Setup](https://code.claude.com/docs/en/setup)
* [Quickstart](https://code.claude.com/docs/en/quickstart)
* [CLI Reference](https://code.claude.com/docs/en/cli-reference)
