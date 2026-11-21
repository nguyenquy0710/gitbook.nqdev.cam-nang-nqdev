---
description: >-
  Hướng dẫn sử dụng CLI và TUI OpenCode V2: chạy TUI, automation, mini, service,
  paths, uninstall, concepts và cli.json.
---

# Hướng dẫn sử dụng CLI và TUI OpenCode

CLI OpenCode dùng cho cả interactive TUI và automation. Bài này tóm tắt cách chạy TUI, các khái niệm chính trong giao diện và cấu hình CLI settings (`cli.json`) chỉ áp dụng cho terminal client.

## Khái niệm cơ bản

* **TUI:** giao diện terminal full-screen, chạy bằng `opencode`.
* **Automation:** `opencode run "..."` gửi prompt mà không mở TUI, phù hợp script/CI.
* **Mini:** `opencode mini` là giao diện tương tác tối giản.
* **Background service:** mặc định dùng chung server nền; sở hữu sessions, config, integrations, permissions, tool execution.
* **CLI settings:** lưu tại `~/.config/opencode/cli.json` (global only), không có project-local.

## Yêu cầu

* Đã cài OpenCode V2 (xem [Hướng dẫn cài đặt và bắt đầu với OpenCode V2](huong-dan-cai-dat-va-bat-dau-voi-opencode-v2.md)).
* Terminal hỗ trợ truecolor.

## Hướng dẫn thực hiện

### Bước 1: Chạy TUI và automation

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode
opencode ~/code/my-project
opencode run "Explain this repository"
opencode mini
```
{% endcode %}

### Bước 2: Dùng slash commands và command palette

* Gõ `/` trong TUI để chạy slash command (ví dụ `/review src/auth.ts`).
* Nhấn `Ctrl+P` để mở command palette / settings.
* Slash commands có thể khai báo agent, model, subagent; xem [Hướng dẫn tạo slash command cho OpenCode](tao-command-slash-cho-opencode.md).

### Bước 3: Quản lý sessions, agents, models, tabs

* **Sessions:** mỗi session lưu lịch sử; tab strip hiển thị sessions đang mở (scope `cwd` hoặc `global`).
* **Agents:** `build`, `plan`, `general`, `explore` và agent tùy chỉnh; primary/subagent/all.
* **Models:** chọn theo `provider/model` hoặc `provider/model#variant`.
* **Tabs:** cấu hình `tabs.mode`, `tabs.scope`, `tabs.layout`, `tabs.indicators` trong `cli.json`.
* **Keybinds:** override binding theo command ID, leader key timeout.

### Bước 4: Background service và remote server

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode --standalone
opencode --server http://localhost:4096
opencode service set disabled true
opencode service unset disabled
```
{% endcode %}

* Shared service dùng chung cho mọi client local.
* `--standalone` chạy server riêng.
* `--server` kết nối URL cụ thể.
* Pairing yêu cầu shared service.

### Bước 5: Kiểm tra paths và gỡ cài đặt

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode debug paths
opencode debug paths db
opencode uninstall --dry-run
opencode uninstall --force
```
{% endcode %}

## Cấu hình CLI settings (`cli.json`)

File global duy nhất:

```text
~/.config/opencode/cli.json
```

Nếu `$XDG_CONFIG_HOME` được set, dùng `$XDG_CONFIG_HOME/opencode/cli.json`. Không có project-local. Thêm `$schema`:

{% code title="cli.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://opencode.ai/v2/cli.json"
}
```
{% endcode %}

Có thể set inline qua `OPENCODE_CLI_CONFIG_CONTENT`:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
OPENCODE_CLI_CONFIG_CONTENT='{"tabs":{"mode":"off"}}' opencode
```
{% endcode %}

### Các nhóm cấu hình chính

* **Appearance:** `theme.name`, `theme.mode`, `animations`, `cursor.style`, `cursor.blinking`.
* **Input:** `mouse`, `scroll.speed`, `scroll.acceleration`, `prompt.editor`, `prompt.paste`, `prompt.image_preview`.
* **Sessions:** `session.sidebar`, `session.scrollbar`, `session.submit_scroll`, `session.thinking`, `session.grouping`, `session.image_preview`, `session.tps`, `session.markdown`, `session.new_location`, `session.permissions`.
* **Tabs:** `tabs.mode`, `tabs.scope`, `tabs.layout`, `tabs.indicators`.
* **Diffs:** `diffs.source`, `diffs.wrap`, `diffs.tree`, `diffs.single`, `diffs.view`.
* **Alerts:** `attention.notifications`, `attention.sound`, `attention.volume`, `attention.sound_pack`, `attention.sounds`.
* **Terminal:** `terminal.title`, `terminal.copy`.
* **Mini:** `mini.thinking`, `mini.tools`, `mini.shell_output`, `mini.turn_summary`, `mini.footer`, `mini.splash`, `mini.work_spinner`, `mini.mono`, `mini.replay`, `mini.replay_limit`.
* **Keybinds:** `keybinds.leader`, `keybinds.<command>`, `leader.timeout`.
* **Plugins:** `plugins` (TUI-only plugins).
* **Debug/experimental:** `debug.devtools`, `debug.timing`, `debug.turn_tokens`, `experimental`.

### Plugins TUI-only

TUI-only plugin (chỉ có TUI part) cấu hình trong `cli.json` để vẫn active khi kết nối remote server:

{% code title="cli.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "plugins": ["opencode-acme-plugin"]
}
```
{% endcode %}

## Lưu ý quan trọng

{% hint style="warning" %}
CLI settings chỉ điều khiển terminal client, tách biệt với server/project settings trong `opencode.json(c)`.
{% endhint %}

* Remote server: khi kết nối `--server`, TUI-only plugins từ `cli.json` vẫn active.
* Shared service sở hữu sessions; tắt service sẽ dừng server nền.
* Unknown settings bị ignore; giữ `$schema` để editor báo lỗi.
* In-view choices (ví dụ scope trong `/diff`) chỉ kéo dài đến khi thoát TUI, không ghi `cli.json`.

## Tài liệu tham khảo

* [OpenCode V2 — CLI](https://opencode.ai/v2/docs/cli)
* [OpenCode V2 — CLI Settings](https://opencode.ai/v2/docs/cli/config)
* [OpenCode V2 — CLI Keybinds](https://opencode.ai/v2/docs/cli/keybinds)
* {% content-ref url="huong-dan-cai-dat-va-bat-dau-voi-opencode-v2.md" %}[Hướng dẫn cài đặt và bắt đầu với OpenCode V2](huong-dan-cai-dat-va-bat-dau-voi-opencode-v2.md){% endcontent-ref %}