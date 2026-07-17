---
description: >-
  So sánh và hướng dẫn Claude Code trên Terminal, VS Code, JetBrains, Desktop
  app và Web — chọn platform phù hợp cho workflow của bạn.
---

# Claude Code trên các nền tảng

Claude Code hoạt động trên cùng một engine ở mọi surface — terminal, IDE, desktop, và web. CLAUDE.md, settings, và MCP servers được shared xuyên suốt. Bạn có thể bắt đầu trên terminal, tiếp tục từ desktop, rồi review trên phone.

## Tổng quan

| Nền tảng | Ưu điểm | Phù hợp |
| -------- | -------- | -------- |
| **Terminal CLI** | Đầy đủ tính năng, scripting, pipe | Power user, CI/CD |
| **VS Code** | Inline diffs, @-mentions, plan review | Developer dùng VS Code hàng ngày |
| **JetBrains** | Interactive diff, selection context | IntelliJ, PyCharm, WebStorm |
| **Desktop App** | Visual diff, multi-session, scheduled tasks | Quản lý nhiều sessions |
| **Web** | Không cần local setup, cloud sessions | Long-running tasks, mobile |

## Terminal CLI

Terminal là surface đầy đủ tính năng nhất — mọi feature đều available.

### Khởi động

{% code title="Terminal" overflow="wrap" %}
```bash
cd /path/to/your/project
claude
```
{% endcode %}

### Ưu điểm

* **Scripting:** `claude -p` cho CI/CD, pre-commit hooks
* **Pipe:** `cat error.log | claude -p "Explain this error"`
* **Shell mode:** `!git status` chạy trực tiếp trong session
* **Full control:** permissions, worktrees, subagents

### Khi nào dùng

* Bạn quen terminal và muốn full control
* Cần integrate vào CI/CD pipelines
* Muốn scripting và automation
* Developer làm việc chủ yếu trong terminal

## VS Code Extension

VS Code extension cung cấp inline diffs, @-mentions, và plan review trực tiếp trong editor.

### Cài đặt

{% code title="VS Code" overflow="wrap" %}
```text
Search "Claude Code" trong Extensions view (Cmd+Shift+X / Ctrl+Shift+X)
```
{% endcode %}

Hoặc install từ terminal:

{% code title="Terminal" overflow="wrap" %}
```bash
code --install-extension anthropic.claude-code
```
{% endcode %}

### Tính năng chính

* **Inline diffs:** xem changes trực tiếp trong editor
* **@-mentions:** reference files bằng `@`
* **Plan review:** xem và approve plans
* **Conversation history:** browse sessions
* **Open in New Tab:** `Cmd+Shift+P` → "Claude Code"

### Cursor

VS Code extension cũng hoạt động trên Cursor:

{% code title="Cursor" overflow="wrap" %}
```text
cursor:extension/anthropic.claude-code
```
{% endcode %}

## JetBrains Plugin

Plugin cho IntelliJ IDEA, PyCharm, WebStorm, và các JetBrains IDE khác.

### Cài đặt

1. Install [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) từ JetBrains Marketplace
2. Restart IDE
3. Yêu cầu Claude Code CLI đã cài đặt riêng

### Tính năng chính

* **Interactive diff viewing:** xem changes trong IDE
* **Selection context sharing:** share code selection với Claude
* **Integration với JetBrains workflows**

## Desktop App

Standalone app cho chạy Claude Code ngoài IDE hoặc terminal. Review diffs visual, chạy nhiều sessions side by side, và schedule recurring tasks.

### Download

* [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect) (Intel và Apple Silicon)
* [Windows](https://claude.ai/api/desktop/win32/x64/setup/latest/redirect) (x64)
* [Windows ARM64](https://claude.ai/api/desktop/win32/arm64/setup/latest/redirect)

### Tính năng chính

* **Visual diff:** review changes với diff viewer
* **Multi-session:** chạy nhiều sessions cùng lúc
* **Scheduled tasks:** tự động chạy tasks theo lịch
* **Background agents:** monitor nhiều agents từ 1 screen
* **Desktop scheduled tasks:** chạy trên máy local, access files trực tiếp

### Khi nào dùng

* Muốn visual diff review trước khi commit
* Cần chạy nhiều sessions song song
* Muốn schedule recurring tasks (morning PR reviews, nightly CI analysis)

## Web (claude.ai/code)

Chạy Claude Code trên browser, không cần setup local. Kick off long-running tasks rồi check back khi done.

### Truy cập

[claude.ai/code](https://claude.ai/code)

### Tính năng chính

* **No local setup:** chạy trên cloud infrastructure
* **Long-running tasks:** kick off task rồi leave
* **Multiple parallel tasks:** chạy nhiều tasks cùng lúc
* **Claude iOS app:** tiếp tục từ iPhone/iPad

## Remote Control và Teleport

### Remote Control

Tiếp tục session từ phone hoặc bất kỳ browser nào:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/remote-control
```
{% endcode %}

### Teleport

Chuyển session từ web/mobile về terminal:

{% code title="Terminal" overflow="wrap" %}
```bash
claude --teleport
```
{% endcode %}

### Handoff giữa các surface

* **Terminal → Desktop:** gõ `/desktop` để handoff visual diff review
* **Web → Terminal:** `claude --teleport`
* **Phone → Desktop:** message Dispatch task từ phone
* **Slack → PR:** mention `@Claude` trong Slack với bug report

## So sánh chi tiết

| Tính năng | Terminal | VS Code | JetBrains | Desktop | Web |
| --------- | -------- | ------- | --------- | ------- | --- |
| Inline diffs | `diff` command | Yes | Yes | Visual | No |
| @-mentions | Type `@` | Yes | Yes | Yes | Yes |
| Plan mode | `--permission-mode plan` | Yes | Yes | Yes | Yes |
| Multi-session | Worktrees | No | No | Yes | Yes |
| Scheduled tasks | No | No | No | Yes | Yes (Routines) |
| Background agents | No | No | No | Yes | Yes |
| Pipe/scripting | Full | No | No | No | No |
| Sandboxing | WSL 2, Linux | WSL 2 | No | No | No |
| Remote access | Remote Control | No | No | No | Native |
| CLAUDE.md | Yes | Yes | Yes | Yes | Yes |
| MCP servers | Yes | Yes | Yes | Yes | Yes |
| Auto mode | Yes | Yes | Yes | Yes | Yes |

## Chọn platform phù hợp

{% tabs %}
{% tab title="Terminal là home base" %}
Dùng terminal làm chính. VS Code hoặc Desktop làm auxiliary khi cần visual diff. Web cho long-running tasks.
{% endtab %}

{% tab title="VS Code là home base" %}
VS Code extension cho daily coding. Terminal cho scripting và CI/CD. Desktop cho multi-session.
{% endtab %}

{% tab title="Desktop là home base" %}
Desktop cho visual review và multi-session. Terminal cho automation. Web cho mobile access.
{% endtab %}

{% tab title="Team workflow" %}
Mọi người dùng surface ưa thích. CLAUDE.md, settings, và MCP servers shared qua git. Managed settings enforce org policies.
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Mọi surface kết nối cùng Claude Code engine. Bạn có thể switch giữa chúng mà không mất context.
{% endhint %}

## Tài liệu tham khảo

* [Overview](https://code.claude.com/docs/en/overview)
* [VS Code](https://code.claude.com/docs/en/vs-code)
* [JetBrains](https://code.claude.com/docs/en/jetbrains)
* [Desktop App](https://code.claude.com/docs/en/desktop)
* [Claude Code on the Web](https://code.claude.com/docs/en/claude-code-on-the-web)
* [Remote Control](https://code.claude.com/docs/en/remote-control)
