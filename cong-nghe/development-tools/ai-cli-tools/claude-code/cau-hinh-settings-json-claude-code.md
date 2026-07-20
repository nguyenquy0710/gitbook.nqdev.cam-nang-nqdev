---
description: >-
  Hướng dẫn chi tiết cấu hình settings.json của Claude Code: env vars,
  permissions, hooks, plugins và các tùy chọn nâng cao cho developer.
---

# Hướng dẫn cấu hình settings.json của Claude Code

`settings.json` là file cấu hình trung tâm của Claude Code, cho phép bạn tùy chỉnh env vars, permissions, hooks, plugins, output style và nhiều hơn nữa. File này nằm tại `~/.claude/settings.json` (global — áp dụng cho tất cả projects) hoặc `.claude/settings.json` (project — riêng từng repo).

Việc cấu hình đúng `settings.json` giúp Claude Code hoạt động phù hợp với workflow cá nhân, từ việc tự động cho phép các lệnh Git vô hại, đến chặn các thao tác nguy hiểm như `rm -rf`.

***

## Vị trí file settings.json

Claude Code hỗ trợ hai cấp cấu hình: **global** (toàn bộ projects) và **project** (riêng từng repo).

{% tabs %}
{% tab title="Global (toàn bộ projects)" %}
{% code title="Đường dẫn global settings" overflow="wrap" %}
```
~/.claude/settings.json
```
{% endcode %}

Áp dụng cho **tất cả** projects trên máy tính. Dùng để cấu hình các thiết lập chung như API endpoint, model mặc định, telemetry, v.v.
{% endtab %}
{% tab title="Project (riêng từng project)" %}
{% code title="Đường dẫn project settings" overflow="wrap" %}
```
.claude/settings.json
```
{% endcode %}

Nằm trong **root của repo**. Chỉ áp dụng cho project đó. Dùng để cấu hình permissions, hooks, plugins riêng cho từng dự án.
{% endtab %}
{% endtabs %}

{% hint style="info" %}
**Project settings sẽ override global settings.** Nếu cùng một key được định nghĩa ở cả hai nơi, giá trị trong project settings sẽ được ưu tiên.
{% endhint %}

***

## `$schema` và cấu trúc tổng quan

Mỗi file `settings.json` nên bắt đầu bằng `$schema` để kích hoạt autocomplete và validation trong IDE.

{% code title="Cấu trúc cơ bản của settings.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {},
  "permissions": {},
  "hooks": {},
  "enabledPlugins": [],
  "extraKnownMarketplaces": [],
  "model": "",
  "outputStyle": "concise",
  "verbose": false
}
```
{% endcode %}

{% hint style="info" %}
Khi thêm `$schema`, VS Code và các IDE hỗ trợ JSON Schema sẽ tự động gợi ý các trường hợp lệ, giúp tránh lỗi syntax và nhớ tên key chính xác.
{% endhint %}

***

## Env Variables (`env`)

Block `env` cho phép bạn thiết lập environment variables mà Claude Code sử dụng khi chạy. Các biến ở đây **sẽ override** system environment vars cùng tên.

{% hint style="info" %}
Env vars trong `settings.json` có độ ưu tiên cao hơn env vars hệ thống. Đây là cách tiện lợi để quản lý cấu hình API mà không cần sửa shell profile.
{% endhint %}

### Các env vars phổ biến

{% code title="Ví dụ env block trong settings.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://your-proxy.example.com",
    "ANTHROPIC_MODEL": "claude-sonnet-4-20250514",
    "ANTHROPIC_AUTH_TOKEN": "sk-ant-xxxxx",
    "ANTHROPIC_CUSTOM_HEADERS": "X-Custom-Header: value",
    "API_TIMEOUT_MS": "3000000",
    "BASH_DEFAULT_TIMEOUT_MS": "300000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```
{% endcode %}

### Giải thích từng biến

* **`ANTHROPIC_BASE_URL`:** URL endpoint tùy chỉnh khi dùng proxy hoặc API gateway (ví dụ: 9router, LiteLLM). Thay vì gọi trực tiếp api.anthropic.com, Claude Code sẽ gọi đến URL này.
* **`ANTHROPIC_MODEL`:** Override model mặc định. Dùng khi bạn muốn mặc định dùng một model cụ thể thay vì model gốc của Claude Code.
* **`ANTHROPIC_AUTH_TOKEN`:** Custom auth token. Hữu ích khi dùng proxy yêu cầu token riêng.
* **`ANTHROPIC_CUSTOM_HEADERS`:** Thêm HTTP headers tùy chỉnh vào mỗi request. Định dạng `key: value`, phân cách bằng dấu phẩy nếu nhiều header.
* **`API_TIMEOUT_MS`:** Thời gian chờ API (đơn vị milliseconds). Ví dụ `3000000` = 50 phút — hữu ích khi dùng proxy chậm hoặc model lớn.
* **`BASH_DEFAULT_TIMEOUT_MS`:** Thời gian chờ cho các lệnh Bash. Mặc định là 300s (5 phút). Tăng lên khi cần chạy các build/test dài.
* **`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`:** Tắt các request không cần thiết (telemetry, usage reporting...). Đặt `"1"` để bật.
* **`CLAUDE_CODE_GIT_BASH_PATH`:** Đường dẫn đến Git Bash trên Windows. Cần thiết khi Claude Code không tự detect được.

***

## Permissions (`permissions`)

Hệ thống permissions của Claude Code hoạt động theo mô hình **allow/deny** — cho phép trước, chặn sau. Đây là phần quan trọng nhất để kiểm soát Claude Code không thực hiện các thao tác nguy hiểm.

### Allow list

Danh sách các tool và lệnh mà Claude Code được phép sử dụng **không cần hỏi**.

{% code title="Ví dụ allow list" overflow="wrap" lineNumbers="true" %}
```json
{
  "permissions": {
    "allow": [
      "Glob",
      "Grep",
      "Read",
      "ToolSearch",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git branch:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm test:*)",
      "Bash(pnpm build:*)",
      "Bash(pnpm run:*)"
    ]
  }
}
```
{% endcode %}

* **Tool names:** `Glob`, `Grep`, `Read`, `ToolSearch` — các tool đọc dữ liệu, an toàn tuyệt đối.
* **Bash patterns:** `Bash(git status)` — cho phép chính xác lệnh `git status`.
* **Wildcard `:*`:** `Bash(git diff:*)` — cho phép `git diff` với **bất kỳ tham số nào** (ví dụ: `git diff main`, `git diff --staged`, v.v.).

### Deny list

Danh sách các tool và lệnh mà Claude Code **tuyệt đối không được phép** sử dụng, bất kể allow list có bao gồm hay không.

{% hint style="danger" %}
Deny list luôn có độ ưu tiên cao hơn allow list. Nếu một lệnh nằm trong cả hai danh sách, lệnh đó sẽ **bị chặn**.
{% endhint %}

{% code title="Ví dụ deny list" overflow="wrap" lineNumbers="true" %}
```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push:*)",
      "Bash(npm publish:*)",
      "Bash(npx publish:*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./node_modules/**)",
      "Read(./dist/**)",
      "Read(./.next/**)"
    ]
  }
}
```
{% endcode %}

* **Destructive commands:** `Bash(rm -rf *)`, `Bash(git push:*)`, `Bash(npm publish:*)` — các lệnh có thể phá huỷ dữ liệu hoặc push code lên remote.
* **Sensitive files:** `Read(./.env)`, `Read(./secrets/**)` — tránh để Claude đọc file chứa secrets, API keys.
* **Build artifacts:** `Read(./node_modules/**)`, `Read(./dist/**)` — không cần Claude đọc các thư mục build output, tiết kiệm context window.

{% hint style="warning" %}
Wildcard trong deny list cũng hoạt động tương tự allow: `Read(./secrets/**)` sẽ chặn mọi file trong thư mục `secrets/`, bao gồm cả file con.
{% endhint %}

***

## Hooks (`hooks`)

Hooks là các script được chạy tự động tại các **lifecycle event** cụ thể của Claude Code. Đây là cách để tích hợp custom logic — ví dụ: ghi log, gọi external tool, hay chạy memory hub script.

### Các lifecycle events

| Event | Khi nào chạy |
| ----- | ------------ |
| **`PreToolUse`** | Trước khi một tool được thực thi |
| **`PostToolUse`** | Sau khi một tool hoàn thành |
| **`SessionStart`** | Khi phiên làm việc bắt đầu |
| **`SessionEnd`** | Khi phiên làm việc kết thúc |
| **`UserPromptSubmit`** | Khi user gửi prompt |
| **`PreCompact`** | Trước khi nén context |
| **`PostCompact`** | Sau khi nén context |
| **`Stop`** | Khi Claude dừng phản hồi |
| **`SubagentStop`** | Khi subagent dừng |
| **`Notification`** | Khi có sự kiện notification |

### Cấu trúc hooks

{% code title="Cấu trúc hooks trong settings.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "rtk hook claude"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts post-tool"
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts session-start"
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts session-end"
      }
    ]
  }
}
```
{% endcode %}

### Giải thích `matcher`

* **`"matcher": "Bash"`** — Chỉ chạy hook khi tool được gọi là `Bash`. Các tool khác (Read, Write, Glob...) sẽ bị bỏ qua.
* **`"matcher": ""`** — Matcher rỗng nghĩa là **match tất cả** các tool. Hook sẽ chạy mỗi khi bất kỳ tool nào được gọi.

{% hint style="info" %}
Hooks chạy bằng shell command — bạn có thể dùng bất kỳ ngôn ngữ nào (bash, bun, python...) miễn là nó tồn tại trên hệ thống. Hook sẽ nhận context qua command-line arguments.
{% endhint %}

***

## Plugins (`enabledPlugins`)

Claude Code hỗ trợ hệ thống plugin để mở rộng tính năng. Plugin được cài từ các marketplace và kích hoạt bằng cách thêm vào `enabledPlugins`.

### Các plugin phổ biến

{% code title="Ví dụ enabledPlugins" overflow="wrap" lineNumbers="true" %}
```json
{
  "enabledPlugins": [
    "commit-commands@claude-plugins-official",
    "frontend-design@claude-plugins-official",
    "code-review@claude-plugins-official",
    "feature-dev@claude-plugins-official",
    "claude-code-wakatime@wakatime"
  ]
}
```
{% endcode %}

* **`commit-commands@claude-plugins-official`:** Hỗ trợ tạo git commit message và thực hiện commit.
* **`frontend-design@claude-plugins-official`:** Hỗ trợ thiết kế frontend, tạo UI components.
* **`code-review@claude-plugins-official`:** Tích hợp code review tự động.
* **`feature-dev@claude-plugins-official`:** Hỗ trợ phát triển feature mới với workflow chuẩn.
* **`claude-code-wakatime@wakatime`:** Theo dõi thời gian coding bằng WakaTime.

### Third-party marketplace

Nếu plugin không nằm trong marketplace chính thức, bạn cần thêm来源 qua `extraKnownMarketplaces`.

{% code title="Thêm marketplace bên thứ ba" overflow="wrap" lineNumbers="true" %}
```json
{
  "extraKnownMarketplaces": [
    {
      "name": "wakatime",
      "source": "https://github.com/wakatime/claude-code-wakatime"
    }
  ],
  "enabledPlugins": [
    "claude-code-wakatime@wakatime"
  ]
}
```
{% endcode %}

{% hint style="info" %}
Định dạng plugin là `tên-plugin@tên-marketplace`. Nếu marketplace là `claude-plugins-official` (marketplace mặc định), bạn không cần thêm vào `extraKnownMarketplaces`.
{% endhint %}

***

## Các tùy chọn khác

Ngoài các block chính ở trên, `settings.json` còn nhiều tùy chọn khác giúp tinh chỉnh hành vi của Claude Code.

### Model và output

* **`model`** — Model mặc định khi khởi động. Ví dụ: `"claude-sonnet-4-20250514"`. Nếu không set, Claude Code dùng model gốc.
* **`outputStyle`** — `"concise"` (mặc định, ngắn gọn) hoặc `"verbose`" (chi tiết hơn).
* **`maxTokens`** — Số token tối đa cho mỗi response. Hữu ích khi muốn giới hạn output length.

### Tính năng

* **`enableAllProjectMcpServers`** — Tự động chấp nhận tất cả MCP servers trong project mà không hỏi xác nhận.
* **`enableWorkflows`** — Bật tính năng workflows (nếu có).
* **`toolSearch`** — Bật/tắt tính năng tool search.
* **`contextWindowStrategy`** — Chiến lược quản lý context window, ví dụ: `"smart"`.

### Hệ thống

* **`autoUpdates`** — Bật/tắt tự động cập nhật.
* **`autoUpdatesChannel`** — Kênh cập nhật: `"stable"` (mặc định) hoặc các kênh khác.
* **`telemetry`** — Bật/tắt telemetry. Nếu muốn tắt hoàn toàn, kết hợp với env var `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`.
* **`verbose`** — Bật logging chi tiết, hữu ích khi debug.
* **`awaySummaryEnabled`** — Tự động tóm tắt khi bạn rời khỏi phiên.

{% code title="Ví dụ các tùy chọn khác" overflow="wrap" lineNumbers="true" %}
```json
{
  "model": "claude-sonnet-4-20250514",
  "outputStyle": "concise",
  "enableAllProjectMcpServers": true,
  "enableWorkflows": true,
  "autoUpdates": true,
  "autoUpdatesChannel": "stable",
  "verbose": false,
  "telemetry": false,
  "maxTokens": 16384,
  "contextWindowStrategy": "smart"
}
```
{% endcode %}

***

## Ví dụ thực chiến

### Cấu hình tối thiểu cho developer

Một `settings.json` đơn giản nhưng đủ dùng cho hầu hết developer:

{% code title="settings.json tối thiểu" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-20250514",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "permissions": {
    "allow": [
      "Glob",
      "Grep",
      "Read",
      "ToolSearch",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm test:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push:*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./node_modules/**)"
    ]
  },
  "autoUpdates": true,
  "telemetry": false
}
```
{% endcode %}

### Cấu hình đầy đủ (full featured)

Đây là ví dụ thực tế với env vars cho proxy, hooks, plugins và toàn bộ tùy chọn:

{% code title="settings.json đầy đủ với proxy, hooks và plugins" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_BASE_URL": "https://proxy.example.com",
    "ANTHROPIC_MODEL": "claude-sonnet-4-20250514",
    "ANTHROPIC_AUTH_TOKEN": "sk-ant-xxxxx",
    "ANTHROPIC_CUSTOM_HEADERS": "X-Custom-Header: value",
    "API_TIMEOUT_MS": "3000000",
    "BASH_DEFAULT_TIMEOUT_MS": "300000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  },
  "permissions": {
    "allow": [
      "Glob",
      "Grep",
      "Read",
      "ToolSearch",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git branch:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm test:*)",
      "Bash(pnpm build:*)",
      "Bash(pnpm run:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push:*)",
      "Bash(npm publish:*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./node_modules/**)",
      "Read(./dist/**)",
      "Read(./.next/**)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "rtk hook claude"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts post-tool"
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts session-start"
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "command": "bun run ~/.config/opencode/scripts/memory-hub.ts session-end"
      }
    ]
  },
  "enabledPlugins": [
    "commit-commands@claude-plugins-official",
    "frontend-design@claude-plugins-official",
    "code-review@claude-plugins-official",
    "feature-dev@claude-plugins-official",
    "claude-code-wakatime@wakatime"
  ],
  "model": "claude-sonnet-4-20250514",
  "outputStyle": "concise",
  "enableAllProjectMcpServers": true,
  "enableWorkflows": true,
  "autoUpdates": true,
  "autoUpdatesChannel": "stable",
  "verbose": false,
  "telemetry": false,
  "maxTokens": 16384,
  "contextWindowStrategy": "smart"
}
```
{% endcode %}

{% hint style="warning" %}
Không copy nguyên xi cấu hình đầy đủ vào project của bạn. Chỉ lấy các phần cần thiết và điều chỉnh cho phù hợp với workflow riêng.
{% endhint %}

***

## Tài liệu tham khảo

* [Claude Code Settings](https://code.claude.com/docs/en/settings)
* [Claude Code Environment Variables](https://code.claude.com/docs/en/env-vars)
