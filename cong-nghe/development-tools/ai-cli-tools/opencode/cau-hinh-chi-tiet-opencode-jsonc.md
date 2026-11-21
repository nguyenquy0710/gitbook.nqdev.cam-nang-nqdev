---
description: >-
  Cấu hình chi tiết opencode.jsonc: format JSON/JSONC, vị trí, precedence, managed
  preferences, các field chính, biến và experimental.
---

# Cấu hình chi tiết `opencode.jsonc`

OpenCode dùng `opencode.jsonc` (hoặc `opencode.json`) để cấu hình server và project. Bài này tổng hợp format, vị trí, thứ tự ưu tiên, các field chính, variable substitution và experimental settings.

## Khái niệm cơ bản

* **Format:** JSON hoặc JSONC (hỗ trợ comment và trailing comma).
* **Schema:** `https://opencode.ai/config.json` để validate/autocomplete.
* **Merge:** OpenCode merge nhiều config file theo thứ tự precedence; settings không xung đột được bảo toàn.
* **Policies:** settings đơn lẻ không ngăn người dùng thêm provider/MCP/agent/plugin; dùng `policies` để enforce.

## Yêu cầu

* Đã cài OpenCode V2.
* Editor hỗ trợ JSON Schema (khuyến nghị).

## Hướng dẫn thực hiện

### Bước 1: Tạo file config cơ bản

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-5-5",
}
```
{% endcode %}

### Bước 2: Chọn vị trí file

| Phạm vi | Đường dẫn |
|---|---|
| System (machine-wide) | `/etc/opencode` (Linux), `/Library/Application Support/opencode` (macOS), `%ProgramData%\opencode` (Windows) |
| Global | `~/.config/opencode/opencode.json(c)` |
| Project | `<project>/opencode.json(c)` hoặc `<project>/.opencode/opencode.json(c)` |

System directory cũng load `agents/`, `commands/`, `skills/`, `plugins/` cho mọi user.

### Bước 3: Managed preferences (macOS MDM)

OpenCode đọc managed preferences domain `ai.opencode.managed`:

```text
/Library/Managed Preferences/<user>/ai.opencode.managed.plist
/Library/Managed Preferences/ai.opencode.managed.plist
```

User-specific profile thay thế machine-wide. Managed settings có precedence cao nhất; user/project không override được giá trị chúng set. Managed preferences override system directory.

### Bước 4: Hiểu precedence và merge

Ví dụ chạy từ `/home/user/projects/acme/packages/web`, OpenCode áp dụng từ thấp đến cao:

1. `~/.config/opencode/opencode.json`
2. `/home/user/projects/acme/opencode.json`
3. `/home/user/projects/acme/packages/web/opencode.json`
4. `/etc/opencode/opencode.json`

OpenCode search từ current directory đến root. Nó merge direct `opencode.json(c)` từ xa nhất đến gần nhất, sau đó merge `.opencode` cùng thứ tự. Vì vậy mọi `.opencode` config override mọi direct config. System config override tất cả. Settings không xung đột được bảo toàn.

Policies từ global/project evaluate theo thứ tự ngược lại; system policies outrank all.

### Bước 5: Cấu hình các field chính

#### Shell

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "shell": "/bin/zsh",
}
```
{% endcode %}

#### Model

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "model": "anthropic/claude-sonnet-5-5",
}
```
{% endcode %}

Root default không retain `#variant`; agent/command model reference có thể chọn variant.

#### Agent mặc định

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "default_agent": "build",
}
```
{% endcode %}

#### Updates

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "update": "notify",
}
```
{% endcode %}

Giá trị: `disable`, `notify`, `auto`. Mặc định `notify`. Auto install không restart server đang chạy. Project-level bị ignore.

#### Username

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "username": "alice",
}
```
{% endcode %}

OpenCode chấp nhận nhưng không hiển thị trong conversations.

#### Permissions

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "permissions": [
    { "action": "shell", "resource": "git push *", "effect": "ask" },
  ],
}
```
{% endcode %}

Ordered rules allow/deny/ask trước khi agent dùng tool trên resource matching.

#### Policies

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "policies": [
    { "action": "provider.use", "resource": "*", "effect": "deny" },
    { "action": "provider.use", "resource": "anthropic", "effect": "allow" },
    { "action": "tool.use", "resource": "shell:git push *", "effect": "deny" },
  ],
}
```
{% endcode %}

Cho phép/từ chối provider, hard-deny permission check, block MCP server/skill/plugin.

#### Agents

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "reviewer": {
      "description": "Review changes without editing files",
      "mode": "subagent",
      "system": "Focus on correctness, security, and missing tests.",
      "permissions": [{ "action": "edit", "resource": "*", "effect": "deny" }],
    },
  },
}
```
{% endcode %}

#### Snapshots

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "snapshots": false,
}
```
{% endcode %}

#### Watcher

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "watcher": {
    "ignore": ["dist/**", "coverage/**"],
  },
}
```
{% endcode %}

#### Formatter

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "formatter": true,
}
```
{% endcode %}

#### Media

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "media": {
    "image": {
      "auto_resize": true,
      "max_width": 2000,
      "max_height": 2000,
      "max_base64_bytes": 5242880,
    },
  },
}
```
{% endcode %}

#### Tool output

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "tool_output": {
    "max_lines": 2000,
    "max_bytes": 51200,
  },
}
```
{% endcode %}

#### Web search

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "websearch": {
    "provider": "random",
  },
}
```
{% endcode %}

#### MCP

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "mcp": {
    "servers": {
      "playwright": {
        "type": "local",
        "command": ["bunx", "@playwright/mcp"],
      },
    },
  },
}
```
{% endcode %}

#### Compaction

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "compaction": {
    "auto": true,
    "keep": { "tokens": 15000 },
    "buffer": "15%",
  },
}
```
{% endcode %}

#### Warming

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "warming": {
    "prompt": "Do not perform any work. Reply with exactly: OK",
    "interval": "auto",
    "duration": "30 minutes",
  },
}
```
{% endcode %}

#### Skills

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "skills": ["./team-skills", "https://example.com/.well-known/skills/"],
}
```
{% endcode %}

#### Commands

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "commands": {
    "review": {
      "description": "Review the current changes",
      "template": "Review the current diff for correctness and missing tests.",
    },
  },
}
```
{% endcode %}

#### Instructions

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "instructions": ["CONTRIBUTING.md", "docs/guidelines/*.md"],
}
```
{% endcode %}

#### References

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "references": {
    "docs": { "path": "../product-docs", "description": "Product behavior and terminology" },
    "effect": { "repository": "Effect-TS/effect", "branch": "main" },
  },
}
```
{% endcode %}

#### Worktree

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "worktree": {
    "directory": "../worktrees",
  },
}
```
{% endcode %}

#### Plugins

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "plugins": [
    "opencode-example-plugin",
    { "package": "./plugins/local", "options": { "enabled": true } },
  ],
}
```
{% endcode %}

#### Providers

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "providers": {
    "openai": {
      "models": {
        "gpt-6.1-sol-custom": {
          "modelID": "gpt-6.1-sol",
          "name": "GPT-6.1 Sol Custom",
          "limit": { "context": 200000, "output": 32000 },
        },
      },
    },
  },
}
```
{% endcode %}

### Bước 6: Variable substitution

Trong JSON string có thể dùng:

* `{env:VARIABLE_NAME}` — thay bằng env var; nếu unset thì rỗng.
* `{file:path/to/file}` — thay bằng nội dung file; path relative config dir, absolute hoặc `~/`. Nếu file không tồn tại thì rỗng.

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "{env:OPENCODE_MODEL}",
  "providers": {
    "anthropic": { "settings": { "apiKey": "{env:ANTHROPIC_API_KEY}" } },
    "openai": { "settings": { "apiKey": "{file:~/.secrets/openai-key}" } },
  },
}
```
{% endcode %}

### Bước 7: Experimental settings

Tất cả experimental nằm dưới `experimental`:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "experimental": {
    "todo": true,
    "subagent_depth": 2,
    "image_generate": { "model": "openai/gpt-image-2" },
    "location_idle_timeout": "4 hours",
  },
}
```
{% endcode %}

* `todo`: bật tool `todowrite` cho agent track multi-step work; mặc định false.
* `subagent_depth`: độ sâu subagent tự spawn subagent; mặc định 1.
* `image_generate`: model mặc định cho tool image generate (`providerID/modelID`, optional `#variant`).
* `location_idle_timeout`: thời gian location không có session activity trước khi unload services; mặc định `60 minutes`; `false` để không unload.
* `experimental.policies` deprecated; dùng top-level `policies`.

## Xác minh kết quả

* Mở file với `$schema` để editor validate.
* Chạy `opencode` và kiểm tra model/agent mặc định.
* Log tại `~/.local/share/opencode/log/opencode.log` nếu config lỗi.

## Lưu ý quan trọng

{% hint style="warning" %}
Settings đơn lẻ không ngăn người dùng thêm providers, MCP servers, agents hay plugins. Dùng policies để enforce restrictions.
{% endhint %}

* Project-level `update` bị ignore.
* Managed preferences (macOS MDM) có precedence cao nhất.
* Experimental settings có thể thay đổi/bị xoá mà không báo trước.
* `.opencode` config override direct config; dùng một form xuyên suốt tree trừ khi cần behavior đó.

## Tài liệu tham khảo

* [OpenCode V2 — Config](https://opencode.ai/v2/docs/config)
* [OpenCode V2 — Policies](https://opencode.ai/v2/docs/policies)
* [OpenCode V2 — Permissions](https://opencode.ai/v2/docs/permissions)
* {% content-ref url="huong-dan-su-dung-cli-va-tui-opencode.md" %}[Hướng dẫn sử dụng CLI và TUI OpenCode](huong-dan-su-dung-cli-va-tui-opencode.md){% endcontent-ref %}