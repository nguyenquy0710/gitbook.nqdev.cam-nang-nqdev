---
description: >-
  Mẫu cấu hình opencode.jsonc đã test ổn định, cân bằng năng suất, an toàn và
  chi phí — kèm giải thích từng phần, lưu ý bảo mật và tinh chỉnh.
---

# Cấu hình thực chiến `opencode.jsonc`: mẫu đã test ổn định

Chia sẻ mẫu `opencode.jsonc` đang dùng thực tế, cân bằng giữa **năng suất**, **an toàn** và **chi phí**. Mẫu này không phải "cấu hình chuẩn" — nó là điểm khởi đầu đã chạy ổn, bạn nên điều chỉnh theo dự án và team của mình.

{% hint style="warning" %}
**Không copy nguyên token/secrets.** Mẫu dưới đây chứa các header `Authorization` dạng placeholder (`sk-...`, `mcp-...-token`) chỉ để minh hoạ cấu trúc. Trong config thật, hãy thay bằng `{env:...}` hoặc `{file:...}` (xem [Variable substitution](cau-hinh-chi-tiet-opencode-jsonc.md)). Hardcode secret trong config là rủi ro bảo mật nghiêm trọng.
{% endhint %}

## Mẫu cấu hình đầy đủ

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "username": "nqdev",
  "snapshots": false,
  "autoupdate": true,
  "formatter": true,
  "lsp": true,
  "model": "9router/claude-sonnet-4-5",
  "small_model": "9router/claude-haiku-4-5",
  "default_agent": "planner",

  "experimental": {
    "todo": true,
    "subagent_depth": 2,
    "image_generate": { "model": "openai/gpt-image-2" },
    "location_idle_timeout": "4 hours"
  },

  "agent": {
    "builder": {
      "mode": "all"
    },
    "planner": {
      "mode": "all",
      "permission": {
        "edit": "allow"
      }
    },
    "reviewer": {
      "mode": "all",
      "model": "anthropic/claude-sonnet-4-5#high",
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "deny" },
        { "action": "shell", "resource": "*", "effect": "deny" }
      ]
    }
  },

  "compaction": {
    "auto": true,
    "keep": { "tokens": 10000 },
    "buffer": "15%"
  },

  "websearch": {
    "provider": "tavily"
  },

  "instructions": [
    "AGENTS.md",
    "CLAUDE.md",
    "GEMINI.md",
    "QWEN.md",
    "docs/**/*.md"
  ],

  "permission": {
    "*": "ask",
    "bash": {
      "*": "allow",
      "rm *": "deny"
    },
    "skill": "allow",
    "webfetch": "allow",
    "websearch": "allow"
  },

  "watcher": {
    "ignore": [
      "node_modules/**",
      "dist/**",
      "coverage/**",
      ".git/**",
      "*.log"
    ]
  },

  "plugin": [
    "opencode-example-plugin",
    "opencode-acme-plugin",
    "opencode-provider-opencode",
    "opencode-config-policy",
    "opencode-concise",
    "opencode-reviewer",
    "opencode-fork-notice",
    "opencode-auto-share",
    "opencode-skill-loader",
    "opencode-mcp-bridge",
    "opencode-formatter-prettier",
    "opencode-warming",
    "opencode-todo-tracker"
  ],

  "providers": {
    "9router": {
      "id": "9router",
      "package": "aisdk:@ai-sdk/openai-compatible",
      "env": [],
      "settings": {
        "baseURL": "https://9router.example.com/v1",
        "apiKey": "{env:ROUTER_9_API_KEY}"
      },
      "models": {
        "claude-sonnet-4-5": {
          "modelID": "claude-sonnet-4-5",
          "name": "Claude Sonnet 4.5 (9router)",
          "limit": { "context": 200000, "output": 8192 }
        },
        "claude-haiku-4-5": {
          "modelID": "claude-haiku-4-5",
          "name": "Claude Haiku 4.5 (9router)",
          "limit": { "context": 200000, "output": 8192 }
        }
      },
      "headers": {
        "Authorization": "Bearer sk-9router-xxxxxxxxxxxxxxxx"
      }
    },
    "kira-ai": {
      "package": "aisdk:@ai-sdk/openai-compatible",
      "settings": {
        "baseURL": "https://api.kira-ai.vn/v1",
        "apiKey": "{env:KIRA_AI_API_KEY}"
      },
      "models": {
        "kira-3.5-pro": {
          "modelID": "kira-3.5-pro",
          "name": "Kira 3.5 Pro",
          "limit": { "context": 128000, "output": 8192 }
        }
      },
      "headers": {
        "Authorization": "Bearer sk-kira-xxxxxxxxxxxxxxxx"
      }
    },
    "omniroute": {
      "package": "aisdk:@ai-sdk/openai-compatible",
      "settings": {
        "baseURL": "https://omniroute.example.com/v1",
        "apiKey": "{env:OMNIROUTE_API_KEY}"
      },
      "models": {
        "gpt-4o": {
          "modelID": "gpt-4o",
          "name": "GPT-4o (OmniRoute)",
          "limit": { "context": 128000, "output": 4096 }
        }
      },
      "headers": {
        "Authorization": "Bearer sk-omni-xxxxxxxxxxxxxxxx"
      }
    },
    "vhs-router": {
      "package": "aisdk:@ai-sdk/openai-compatible",
      "settings": {
        "baseURL": "https://vhs-router.example.com/v1",
        "apiKey": "{env:VHS_ROUTER_API_KEY}"
      },
      "models": {
        "claude-sonnet-4-5": {
          "modelID": "claude-sonnet-4-5",
          "name": "Claude Sonnet 4.5 (VHS)",
          "limit": { "context": 200000, "output": 8192 }
        }
      },
      "headers": {
        "Authorization": "Bearer sk-vhs-xxxxxxxxxxxxxxxx"
      }
    }
  },

  "mcp": {
    "playwright": {
      "type": "remote",
      "url": "https://mcp.playwright.example.com",
      "enabled": false,
      "headers": {
        "Authorization": "Bearer mcp-playwright-token"
      },
      "timeout": 30000
    },
    "jira": {
      "type": "remote",
      "url": "https://mcp.jira.example.com",
      "enabled": false,
      "headers": {
        "Authorization": "Bearer mcp-jira-token"
      },
      "timeout": 30000
    },
    "github": {
      "type": "remote",
      "url": "https://mcp.github.example.com",
      "enabled": false,
      "headers": {
        "Authorization": "Bearer mcp-github-token"
      },
      "timeout": 30000
    }
  },

  "media": {
    "image": {
      "auto_resize": true,
      "max_width": 2000,
      "max_height": 2000,
      "max_base64_bytes": 5242880
    }
  },

  "command": {}
}
```
{% endcode %}

## Giải thích theo nhóm

### 1. Thông tin chung

* **`username`:** tên hiển thị của bạn trong OpenCode (chấp nhận nhưng không hiện trong conversation).
* **`snapshots: false`:** tắt snapshot/rollback để giảm overhead I/O (đổi tên từ V1 `snapshot`).
* **`autoupdate: true`:** tự cập nhật OpenCode. ⚠️ V2 dùng `update` (`"disable"`/`"notify"`/`"auto"`); `autoupdate` là dạng V1 được normalize. Khuyến nghị chuyển sang `"update": "auto"` (xem mục tinh chỉnh).
* **`formatter: true`:** bật formatter tích hợp.
* **`lsp: true`:** bật LSP. ⚠️ V2 accept và giữ config `lsp` nhưng **không chạy language server, không expose LSP tools, không sinh diagnostics**. Nếu cần, thay bằng lint/typecheck command của project.
* **`model` / `small_model`:** model mặc định và model nhỏ dùng cho task phụ (title, summary). Ở đây route qua provider `9router`.
* **`default_agent: "planner"`:** agent mặc định khi mở session.

### 2. Experimental

* **`todo: true`:** bật tool `todowrite` để agent track công việc nhiều bước (mặc định false).
* **`subagent_depth: 2`:** cho phép subagent tự spawn subagent sâu 2 cấp (mặc định 1). ⚠️ Top-level `subagent_depth` trong V1 là "accepted but unsupported" ở V2 — phải đặt trong `experimental`.
* **`image_generate`:** model mặc định cho tool tạo ảnh (`openai/gpt-image-2`).
* **`location_idle_timeout: "4 hours"`:** thời gian location không có session activity trước khi unload services (mặc định `60 minutes`; `false` để không unload).

### 3. Agent

* **`builder` / `planner` / `reviewer`:** ba agent mode `all` (vừa primary vừa subagent).
* **`reviewer`:** dùng model `anthropic/claude-sonnet-4-5#high` (variant `high` gộp sau `#`), với `permissions` deny `edit` và `shell` toàn bộ — read-only reviewer.
* **`planner`:** dùng `permission` (số ít, V1 style) cho phép `edit`.
* ⚠️ V2 agent schema dùng **`permissions`** (plural, mảng có thứ tự). `permission` (singular) là dạng V1 được normalize. Nên chuẩn hoá toàn bộ sang `permissions` để tránh cảnh báo và ambiguity. Xem [Tạo agent tùy chỉnh cho OpenCode](tao-agent-tuy-chinh-cho-opencode.md).

### 4. Compaction

* **`auto: true`:** tự nén context khi gần đầy.
* **`keep.tokens: 10000`:** giữ lại ~10k token gần nhất.
* **`buffer: "15%"`:** reserve 15% context cho response. V2 không có `tail_turns`/`prune` native — dùng token budget.

### 5. Websearch

* **`provider: "tavily"`:** dùng Tavily làm backend tìm kiếm web.

### 6. Instructions

* Danh sách glob file được inject làm hướng dẫn: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `QWEN.md` và `docs/**/*.md`. OpenCode load theo precedence từ current dir lên root.

### 7. Permission

* **`"*": "ask"`:** mặc định hỏi xác nhận mọi action.
* **`bash`:** allow mọi lệnh shell, riêng `rm *` → deny (chặn xoá hàng loạt).
* **`skill` / `webfetch` / `websearch`:** allow.
* ⚠️ V2 dùng top-level **`permissions`** (mảng có thứ tự) thay cho `permission` object theo tool. `permission` (singular) là V1 được normalize. Nên chuyển sang `permissions` native. Xem [Cấu hình chi tiết `opencode.jsonc`](cau-hinh-chi-tiet-opencode-jsonc.md).

### 8. Watcher ignore

* Bỏ qua các thư mục/file sinh ra (`node_modules`, `dist`, `coverage`, `.git`, `*.log`) khi watch file thay đổi.

### 9. Plugins

* Danh sách 13 plugin load qua config. Local plugin path phải là **thư mục**. ⚠️ V2 dùng field **`plugins`** (plural); `plugin` (singular) là V1 được normalize — khuyến nghị đổi sang `plugins` (xem mục tinh chỉnh).

### 10. Providers

* Bốn provider openai-compatible: **9router**, **kira-ai**, **omniroute**, **vhs-router**. Mỗi provider có `package: "aisdk:@ai-sdk/openai-compatible"`, `settings.baseURL`, `settings.apiKey`, `models`, và `headers`.
* **`9router`** có thêm field `id` (redundant — provider ID giờ là key trong map) và `env: []` (V1-style). Cả hai có thể bỏ để gọn config.
* ⚠️ Các `headers.Authorization` đang **hardcode** placeholder. Nên thay bằng `{env:...}` hoặc `{file:...}` để tránh leak secret.

### 11. MCP

* Ba remote MCP server: **playwright**, **jira**, **github** — `enabled: false` (tắt mặc định, bật khi cần), kèm `headers` và `timeout`.
* ⚠️ V2 gom server dưới **`mcp.servers`** và dùng `disabled` (phủ định của `enabled`), timeout tách `catalog`/`execution`. Form hiện tại là V1 được normalize. Nên chuyển sang `mcp.servers` native khi migrate.

### 12. Media image resize

* Tự resize ảnh: max 2000×2000, tối đa 5MB base64. Giúp tiết kiệm token và tránh lỗi payload quá lớn.

### 13. Command

* **`command: {}`** — không khai báo slash command nào trong config (commands đặt ở `.opencode/commands/`).

## Điểm cần lưu ý / tinh chỉnh

{% tabs %}
{% tab title="Tinh chỉnh chuẩn V2" %}

Các field dạng V1 (singular/legacy) trong mẫu trên vẫn chạy vì V2 normalize trong memory, nhưng để config "native" và tránh warning, hãy chuẩn hoá:

* **`plugin` → `plugins`** (V2 field là `plugins`). V1 dùng `plugin`.
* **`agent` → `agents`** (V2 map là `agents`). V1 dùng `agent`.
* **`permission` (singular) → `permissions`** (mảng có thứ tự). V1 gom theo tool.
* **`autoupdate: true` → `"update": "auto"`**. V2 dùng `update` với giá trị `"disable"`/`"notify"`/`"auto"`.
* **`lsp: true`** — V2 accept nhưng không chạy LSP. Nếu workflow phụ thuộc diagnostics, chuyển sang lint/typecheck command.
* **`subagent_depth` top-level → `experimental.subagent_depth`** (top-level bị ignore).
* **MCP `enabled` → `disabled`** (phủ định) và gom dưới `mcp.servers`, timeout tách `catalog`/`execution`.
* **Provider `id` và `env: []`** có thể bỏ (provider ID là key; `env` là V1-style).

{% endtab %}
{% tab title="Bảo mật" %}

* **Không hardcode secret:** thay mọi `headers.Authorization` và `apiKey` literal bằng `{env:VAR}` hoặc `{file:~/path}`.
* **MCP mặc định tắt** (`enabled: false`) — chỉ bật server khi thực sự cần, giảm attack surface.
* **Reviewer read-only:** deny `edit`/`shell` cho agent review để tránh sửa code ngoài ý muốn.
* **`rm *` deny** trong shell permission — chặn xoá hàng loạt do agent thực hiện.
* **Default `ask`:** mọi action không được allow rõ ràng đều hỏi xác nhận.

{% endtab %}
{% tab title="Chi phí & năng suất" %}

* **`small_model`** cho task phụ (title/summary) giúp giảm chi phí.
* **`compaction`** với `keep.tokens: 10000` + `buffer: 15%` giữ context hợp lý trong session dài.
* **`location_idle_timeout: "4 hours"`** unload services khi không dùng, tiết kiệm tài nguyên.
* **`media.image` resize** giảm token payload khi gửi ảnh.
* **`snapshots: false`** giảm I/O overhead (đổi lại mất khả năng rollback nhanh).

{% endtab %}
{% endtabs %}

## Gợi ý profile theo nhu cầu

{% tabs %}
{% tab title="Minimal" %}

Chỉ giữ những gì cần thiết cho coding hàng ngày:

* `model`, `default_agent`, `permissions` (ask mặc định + deny `rm *`), `watcher.ignore`.
* Bỏ experimental, MCP, plugins thừa. Phù hợp máy yếu / team nhỏ.

{% endtab %}
{% tab title="Balanced (mẫu này)" %}

Mẫu trong bài: cân bằng năng suất (todo, subagent_depth, image_generate), an toàn (reviewer read-only, default ask, MCP tắt) và chi phí (small_model, compaction, resize ảnh).

{% endtab %}
{% tab title="Secure" %}

* Default deny mọi thứ, chỉ allow tool cần thiết; MCP tắt hoàn toàn; không hardcode secret; reviewer read-only; tắt `autoupdate` (`"update": "disable"`); bật policies để enforce restrictions ở org level.
* Phù hợp môi trường production/enterprise.

{% endtab %}
{% endtabs %}

## Cách áp dụng

1. Copy mẫu vào `~/.config/opencode/opencode.jsonc` (global) hoặc `<project>/opencode.jsonc` / `<project>/.opencode/opencode.jsonc` (project).
2. Thay toàn bộ placeholder secret bằng `{env:...}` / `{file:...}` và set env tương ứng.
3. Chuẩn hoá các field legacy sang native V2 (xem tab "Tinh chỉnh chuẩn V2") nếu muốn config sạch.
4. Validate bằng `$schema` trong editor (autocomplete + lint).
5. Khởi động lại service: `opencode service restart`.
6. Kiểm tra log tại `~/.local/share/opencode/log/opencode.log` nếu config lỗi; chạy `opencode` và verify model/agent mặc định.

## Tài liệu tham khảo

* [OpenCode V2 — Config](https://opencode.ai/v2/docs/config)
* [OpenCode V2 — Agents](https://opencode.ai/v2/docs/agents)
* [OpenCode V2 — Permissions](https://opencode.ai/v2/docs/permissions)
* [OpenCode V2 — Providers](https://opencode.ai/v2/docs/providers)
* [OpenCode V2 — MCP servers](https://opencode.ai/v2/docs/mcp-servers)
* [OpenCode V2 — Plugins](https://opencode.ai/v2/docs/plugins)
* [OpenCode V2 — Compaction](https://opencode.ai/v2/docs/compaction)
* [OpenCode V2 — Migrate from V1](https://opencode.ai/v2/docs/migrate-v1)
* {% content-ref url="cau-hinh-chi-tiet-opencode-jsonc.md" %}[Cấu hình chi tiết `opencode.jsonc`](cau-hinh-chi-tiet-opencode-jsonc.md){% endcontent-ref %}
* {% content-ref url="migrate-opencode-v1-sang-v2.md" %}[Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md){% endcontent-ref %}