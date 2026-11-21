---
description: >-
  Hướng dẫn cài đặt OpenCode V2 trên macOS, Linux, Windows: curl, npm, Homebrew,
  Docker, chạy TUI, automation, service và xác minh paths.
---

# Hướng dẫn cài đặt và bắt đầu với OpenCode V2

OpenCode là coding agent mã nguồn mở, chạy dưới dạng terminal UI, desktop app hoặc web app. OpenCode V2 dùng binary mới và package `@opencode/cli`, khác với V1 dùng `opencode-ai`. Bài này hướng dẫn cài đặt V2, khởi động lần đầu và kiểm tra môi trường.

## Khái niệm cơ bản

* **OpenCode V2:** binary mới với Server/Client API và Plugin API được thiết kế lại; không tương thích ngược với V1.
* **Background service:** mặc định OpenCode dùng một server nền dùng chung cho tài khoản người dùng; service này sở hữu sessions, config, integrations, permissions và tool execution.
* **Terminal khuyến nghị:** Ghostty, WezTerm, Alacritty, Kitty. Truecolor giúp theme hiển thị chính xác; terminal không hỗ trợ sẽ dùng palette gần đúng.
* **Đường dẫn nội bộ:** `opencode debug paths` in ra db, home, data, config, cache, state, tmp, bin, log, repos.

## Yêu cầu

* **Hệ điều hành:** macOS, Linux hoặc Windows.
* **Terminal:** hỗ trợ truecolor (Ghostty/WezTerm/Alacritty/Kitty).
* **Gỡ V1 nếu có:** V1 dùng package `opencode-ai`; hãy gỡ trước khi cài V2 để tránh xung đột lệnh `opencode`.

{% hint style="warning" %}
Nếu đang migrate từ V1, đọc [Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md) trước khi cài đặt.
{% endhint %}

## Hướng dẫn thực hiện

### Bước 1: Cài đặt OpenCode V2

Chọn một trong các cách sau:

{% tabs %}
{% tab title="curl" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
curl -fsSL https://opencode.ai/v2/install | bash
```
{% endcode %}
{% endtab %}
{% tab title="npm" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
npm install -g @opencode/cli
```
{% endcode %}
{% endtab %}
{% tab title="Homebrew" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
brew install anomalyco/tap/opencode-v2
```
{% endcode %}
{% endtab %}
{% tab title="Docker" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
docker pull ghcr.io/anomalyco/opencode:2.0.0
```
{% endcode %}
{% endtab %}
{% endtabs %}

* Package V1 là `opencode-ai`; package V2 là `@opencode/cli`.
* npm dùng postinstall để chọn binary native phù hợp nền tảng.
* Windows không hỗ trợ package manager; dùng binary standalone hoặc installer.
* Docker image dùng tag version, ví dụ `ghcr.io/anomalyco/opencode:2.0.0`.

### Bước 2: Chạy TUI lần đầu

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode
```
{% endcode %}

Làm việc ở project khác:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode ~/code/my-project
```
{% endcode %}

### Bước 3: Chạy automation không mở TUI

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode run "Explain this repository"
```
{% endcode %}

Dùng cho script, CI và workflow cần output trực tiếp.

### Bước 4: Dùng mini interface

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode mini
```
{% endcode %}

Chạy `opencode mini --help` để xem option session, model, agent, prompt và replay.

### Bước 5: Quản lý background service

Chạy với server riêng:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode --standalone
opencode --server http://localhost:4096
```
{% endcode %}

Tắt shared service và dùng private server mặc định:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode service set disabled true
opencode
```
{% endcode %}

Bật lại service tự động:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode service unset disabled
```
{% endcode %}

`--server` vẫn kết nối server được chọn rõ ràng; `opencode service start` vẫn có thể start shared service. Pairing yêu cầu shared service và không khả dụng khi bị tắt.

### Bước 6: Gỡ cài đặt (nếu cần)

Xem trước file và installation sẽ bị xoá:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode uninstall --dry-run
```
{% endcode %}

Gỡ thực sự:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode uninstall
opencode uninstall --force
```
{% endcode %}

`--force` (`-f`) bỏ qua xác nhận, dùng cho noninteractive. Package-manager install dùng package manager đã detect; curl install in ra lệnh cuối để xoá executable thủ công. Session data, config và state không bị xoá.

## Xác minh kết quả

Kiểm tra đường dẫn nội bộ:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode debug paths
opencode debug paths db
sqlite3 "$(opencode debug paths db)"
```
{% endcode %}

Selector hỗ trợ `db`, `home`, `data`, `config`, `cache`, `state`, `tmp`, `bin`, `log`, `repos`. Lệnh không start server hay mở database. Log server tại `~/.local/share/opencode/log/opencode.log`.

## Lưu ý quan trọng

{% hint style="info" %}
Background service sở hữu sessions và tool execution. Nếu cần cô lập, dùng `--standalone`.
{% endhint %}

* Project-level `update` bị ignore; cấu hình update ở global config.
* Settings đơn lẻ không ngăn người dùng thêm provider, MCP server, agent hay plugin; dùng [policies](https://opencode.ai/v2/docs/policies) để enforce.
* Managed preferences trên macOS có precedence cao nhất.

## Tài liệu tham khảo

* [OpenCode V2 — Intro](https://opencode.ai/v2/docs/)
* [OpenCode V2 — CLI](https://opencode.ai/v2/docs/cli)
* [OpenCode V2 — Troubleshooting](https://opencode.ai/v2/docs/troubleshooting)
* {% content-ref url="migrate-opencode-v1-sang-v2.md" %}[Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md){% endcontent-ref %}