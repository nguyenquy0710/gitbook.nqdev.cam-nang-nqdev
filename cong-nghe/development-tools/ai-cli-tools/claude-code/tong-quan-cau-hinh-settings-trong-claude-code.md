---
description: >-
  Tổng quan hệ thống Settings trong Claude Code: các scope cấu hình, thứ tự ưu
  tiên, merge rules, server-managed settings và cách troubleshoot hiệu quả.
---

# Tổng quan cấu hình Settings trong Claude Code

Claude Code đọc settings từ nhiều nguồn JSON khác nhau — từ file cá nhân trên máy bạn, file team chia sẻ qua git, đến cấu hình tập trung do tổ chức quản lý. Hiểu rõ kiến trúc hệ thống settings giúp bạn kiểm soát hành vi Claude Code một cách chính xác: model nào được dùng, lệnh nào được phép chạy mà không cần hỏi, và tổ chức của bạn đang enforce chính sách gì.

{% hint style="info" %}
Bài viết này tập trung vào **hệ thống settings** — scope, precedence, delivery, merge rules. Nếu bạn cần tham khảo **chi tiết từng key JSON** trong settings, xem bài viết bổ sung bên dưới.
{% endhint %}

{% content-ref url="cau-hinh-settings-json-claude-code.md" %}
[Hướng dẫn cấu hình settings.json của Claude Code](cau-hinh-settings-json-claude-code.md)
{% endcontent-ref %}

***

## Các Scope của Settings (5 cấp độ ưu tiên)

Claude Code áp dụng settings theo mô hình **5 cấp độ ưu tiên**, từ cao nhất đến thấp nhất. Khi cùng một key xuất hiện ở nhiều nơi, giá trị từ cấp cao hơn luôn thắng.

{% tabs %}
{% tab title="Managed settings (Cao nhất)" %}
* **File:** `managed-settings.json`, MDM policy, hoặc claude.ai console
* **Ai quản lý:** Tổ chức (Admin/Owner)
* **Phạm vi:** Mọi dự án, mọi người trong tổ chức
* **Dùng cho:** Security policy, compliance, enforced permissions

Đây là cấp cấu hình **không thể override** bởi bất kỳ cấp nào thấp hơn. Tổ chức dùng managed settings để enforce các chính sách bảo mật bắt buộc — ví dụ: chặn `rm -rf`, cấm truy cập `.env` files, hoặc giới hạn model được phép dùng.
{% endtab %}
{% tab title="Command line" %}
* **File:** `claude --settings '{"key": "value"}'`
* **Ai quản lý:** Bạn, cho session hiện tại
* **Phạm vi:** Chỉ session đang chạy
* **Dùng cho:** Thử nghiệm tạm thời, test giá trị mới

Chỉ tồn tại trong bộ nhớ, không ghi vào file nào. Session kết thúc thì settings cũng mất. Phù hợp khi muốn test nhanh một model hoặc permission mới mà không muốn sửa file cấu hình.
{% endtab %}
{% tab title="Project local" %}
* **File:** `.claude/settings.local.json`
* **Ai quản lý:** Bạn, riêng từng project
* **Phạm vi:** Chỉ bạn, chỉ project này
* **Dùng cho:** Override cá nhân, test trước khi share

Claude Code tự động thêm file này vào global git excludes khi nó ghi file lần đầu. Nếu bạn tạo thủ công, hãy tự thêm vào `.gitignore`. Các `allow` rules trong file này **không cần chờ workspace trust** vì nó là file cá nhân, không phải của repo.
{% endtab %}
{% tab title="Shared project" %}
* **File:** `.claude/settings.json`
* **Ai quản lý:** Team (commit lên git)
* **Phạm vi:** Mọi người clone repo này
* **Dùng cho:** Team permissions, hooks, plugins chung

Đây là cách **share settings với team**. Commit file này lên git để mọi người trong dự án đều nhận được cùng permissions, hooks, và environment variables. Mỗi người vẫn có thể override trong `.claude/settings.local.json` riêng.
{% endtab %}
{% tab title="User (Thấp nhất)" %}
* **File:** `~/.claude/settings.json`
* **Ai quản lý:** Bạn
* **Phạm vi:** Mọi project trên máy bạn
* **Dùng cho:** Theme, model mặc định, preferences cá nhân

Áp dụng cho tất cả projects trên máy tính. Dùng để cấu hình các thiết lập chung mà bạn muốn luôn luôn có hiệu lực, bất kể đang làm project nào.
{% endtab %}
{% endtabs %}

### Bảng so sánh nhanh

| Cấp độ | File | Phạm vi | Dùng cho |
|:---|:---|:---|:---|
| **Managed** | `managed-settings.json`, MDM, claude.ai console | Tổ chức | Security policy, compliance |
| **Command line** | `claude --settings` | Session hiện tại | Thử nghiệm tạm thời |
| **Project local** | `.claude/settings.local.json` | Cá nhân, 1 project | Override cá nhân |
| **Shared project** | `.claude/settings.json` | Team, mọi người trong project | Team permissions, hooks |
| **User** | `~/.claude/settings.json` | Cá nhân, mọi project | Theme, model mặc định |

{% hint style="warning" %}
Managed settings **luôn luôn thắng**. Không có cách nào — kể cả `--settings` flag hay environment variable — override được managed key. Only một vài security-sensitive keys cho phép lower-level value chặt hơn được giữ lại (xem phần Exceptions bên dưới).
{% endhint %}

***

## Cách thay đổi Settings

Claude Code cung cấp nhiều cách để thay đổi settings tùy theo nhu cầu.

{% tabs %}
{% tab title="/config menu" %}
Chạy `/config` bên trong Claude Code và mở tab **Config**. Menu này liệt kê một số personal options phổ biến: theme, editor mode, verbose output.

* Hầu hết options → ghi vào `~/.claude/settings.json`
* Một vài options (ví dụ: Show tips) → ghi vào `.claude/settings.local.json`
* Global config options → ghi vào `~/.claude.json`

Để set nhanh một option: `/config verbose=true`
{% endtab %}
{% tab title="Edit file JSON trực tiếp" %}
Mở file settings trong editor và thêm/sửa key. Settings files là **strict JSON** — comment `//` hay trailing comma đều gây lỗi syntax.

{% code title="Ví dụ edit ~/.claude/settings.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```
{% endcode %}

Sau khi lưu, chạy `/status` để xác nhận file đã load thành công.
{% endtab %}
{% tab title="Command line --settings" %}
Thử giá trị mới mà không cần lưu vào file:

{% code title="Start Claude Code với model cụ thể cho 1 session" overflow="wrap" %}
```bash
claude --settings '{"model": "claude-opus-4-8"}'
```
{% endcode %}

Giá trị này áp dụng **trên** user, project, và local settings nhưng **dưới** managed settings. Chỉ tồn tại trong session hiện tại.
{% endtab %}
{% tab title="Environment variable" %}
Một số key có environment variable tương ứng, ví dụ:

* `ANTHROPIC_MODEL` → override key `model`
* `ANTHROPIC_BASE_URL` → override API endpoint

Environment variables **không phải là một level** trong precedence stack. Mỗi pair được quyết định riêng, không theo thứ tự cấp bậc.
{% endtab %}
{% endtabs %}

### Khi nào reload tự động vs cần restart

* **Reload tự động:** Claude Code watch settings files và reload khi thay đổi, bao gồm `permissions`, `hooks`, và `apiKeyHelper`. Không cần restart.
* **Cần restart hoặc `/clear`:**
  * `model` → dùng `/model` để switch mid-session
  * `effortLevel` và `modelSettings` → dùng `/effort`
  * `outputStyle` → apply sau `/clear` hoặc restart (làm part của system prompt)
* **Managed settings từ MDM/claude.ai console:** arrives theo lịch polling, không phải ngay lập tức khi save.

***

## Settings Precedence và Merge Rules

### Thứ tự ưu tiên (Precedence)

Khi cùng một key xuất hiện ở nhiều nơi, Claude Code lấy giá trị từ **cấp cao nhất** đặt key đó:

1. **Managed settings** (cao nhất) — cấu hình từ tổ chức
2. **Command line** `--settings` — cho session hiện tại
3. **Project local** `.claude/settings.local.json` — cá nhân, 1 project
4. **Shared project** `.claude/settings.json` — team share qua git
5. **User** `~/.claude/settings.json` (thấp nhất) — cá nhân, mọi project

### Lists merge thay vì override

Đây là điểm quan trọng nhất cần hiểu: khi bạn set cùng một **list key** (ví dụ: `permissions.allow`) ở nhiều file, Claude Code **combine** các list thay vì chọn một cái.

Điều này có nghĩa: mỗi file có thể **thêm entries** mà không xóa entries từ file khác.

{% code title="Ví dụ: User settings có allow A, Project settings có allow B" overflow="wrap" %}
```json
// ~/.claude/settings.json
{
  "permissions": {
    "allow": ["Glob", "Grep", "Read"]
  }
}

// .claude/settings.json (project)
{
  "permissions": {
    "allow": ["Bash(git status)", "Bash(git diff:*)"]
  }
}
```
{% endcode %}

Kết quả: cả 5 entries đều có hiệu lực — user glob/grep/read + project git status/diff.

### Các exception không merge

Một số keys giữ nguyên giá trị từ **cấp cao nhất** thay vì merge, vì vị trí trong list mang ý nghĩa:

* **`fallbackModel`:** Ordered chain, lấy toàn bộ giá trị từ cấp cao nhất define nó
* **`modelPicker`:** Không merge rows từ 2 sources; lấy từ managed > `--settings` > user
* **`availableModels`:** Managed list apply as-is, ignores entries từ user/project/local
* **`modelSettings`:** Resolve từng model một, kết hợp với `effortLevel`

### Environment variables — quyết định theo key

Environment variables **không theo level** trong precedence stack. Khi behavior có cả shell variable và settings key, quyết định được làm **theo từng pair**:

* `ANTHROPIC_MODEL` trong shell → override `model` từ BẤT KỲ file nào
* `ANTHROPIC_DEFAULT_MODEL` → chỉ áp dụng khi không file nào set `model`

`env` block bên trong settings file là key bình thường, theo levels ở trên.

### Exceptions to Managed Settings Precedence

Đối với một vài **security-sensitive keys**, Claude Code giữ giá trị restrictive hơn từ lower level:

* **`disableClaudeAiConnectors`:** Project setting `true` stays on, even if managed is `false`
* **Các sandbox security keys:** Managed restrictions always win, lower-level relaxations don't override

***

## Các Settings File cụ thể

Claude Code sử dụng 5 file settings. Mỗi file có mục đích và phạm vi riêng.

{% tabs %}
{% tab title="~/.claude/settings.json (User)" %}
File settings cá nhân, áp dụng cho **tất cả projects** trên máy.

{% code title="Ví dụ user settings" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-20250514",
  "outputStyle": "concise",
  "permissions": {
    "allow": [
      "Glob", "Grep", "Read", "ToolSearch",
      "Bash(git status)", "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(./.env)", "Read(./.env.*)"
    ]
  },
  "telemetry": false,
  "autoUpdates": true
}
```
{% endcode %}

Claude Code ghi file này lần đầu khi bạn thay đổi option trong `/config` menu mà nó lưu ở user settings, ví dụ như theme.
{% endtab %}
{% tab title=".claude/settings.json (Shared project)" %}
File settings **team share** — commit lên git để mọi người nhận được.

{% code title="Ví dụ shared project settings" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "API_TIMEOUT_MS": "300000",
    "BASH_DEFAULT_TIMEOUT_MS": "60000"
  },
  "permissions": {
    "allow": [
      "Bash(npm run lint:*)", "Bash(npm run test:*)",
      "Bash(npm run build:*)"
    ],
    "deny": [
      "Bash(npm publish:*)", "Bash(npx publish:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "./scripts/lint-staged.sh" }
        ]
      }
    ]
  }
}
```
{% endcode %}

{% hint style="info" %}
Một số keys **không apply từ repository file**: `permissions.defaultMode` giá trị `auto` và `bypassPermissions` không take effect từ project hoặc local settings. Các `allow` rules chờ mỗi người [trust folder](https://code.claude.com/docs/en/permissions#project-allow-rules-and-workspace-trust) trước khi áp dụng.
{% endhint %}
{% endtab %}
{% tab title=".claude/settings.local.json (Project local)" %}
File settings **cá nhân** cho 1 project. Claude Code tự động gitignore file này.

{% code title="Ví dụ local settings — override model cho project này" overflow="wrap" lineNumbers="true" %}
```json
{
  "model": "claude-opus-4-8",
  "permissions": {
    "allow": [
      "Bash(npm run dev:*)"
    ]
  }
}
```
{% endcode %}

* **Claude Code cũng ghi file này** khi bạn chọn "Yes, and don't ask again" trên permission prompt
* File này **không cần chờ workspace trust** khi nó là untracked
* Nếu cả `.claude/settings.json` và `.claude/settings.local.json` set cùng key → **local wins**
{% endtab %}
{% tab title="~/.claude.json (Global config)" %}
File Claude Code ghi cho chính nó — bạn **không cần edit** file này thủ công. Chứa:

* Sign-in session và authentication state
* MCP server configurations
* Per-project state (trust decisions)
* Global config keys mà `/config` ghi cho bạn

{% hint style="danger" %}
Nếu `~/.claude.json` bị corrupt, Claude Code sẽ backup file cũ vào `~/.claude/backups/` và hỏi bạn có muốn reset về default. Bạn có thể recover từ 5 file backup gần nhất.
{% endhint %}
{% endtab %}
{% endtabs %}

### On Windows

`~/.claude` tương đương `%USERPROFILE%\.claude`. Để đổi vị trí, set env var `CLAUDE_CONFIG_DIR` — Claude Code sẽ lưu settings, session history, và plugins ở đó.

***

## Server-Managed Settings (Cấu hình tập trung cho tổ chức)

Server-managed settings cho phép organization Owners **cấu hình trung tâm** Claude Code từ admin console mà không cần MDM hay device management.

### Yêu cầu

* **Plan:** Claude for Teams hoặc Claude for Enterprise
* **Role:** Owner hoặc Primary Owner trong tổ chức
* **Network:** Truy cập được `api.anthropic.com`

### Cách cấu hình

1. Vào [**Admin Settings > Claude Code > Managed settings**](https://claude.ai/admin-settings/claude-code) trên claude.ai console
2. Thêm cấu hình dạng JSON — hỗ trợ tất cả settings keys trừ một vài OS-level policy keys
3. Lưu — Claude Code clients sẽ fetch settings ở lần startup tiếp theo hoặc trong vòng 1 giờ

{% code title="Ví dụ managed settings — enforce deny list và restricted permissions" overflow="wrap" lineNumbers="true" %}
```json
{
  "permissions": {
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "disableBypassPermissionsMode": "disable"
  },
  "allowManagedPermissionRulesOnly": true
}
```
{% endcode %}

{% code title="Ví dụ managed hooks — audit script sau mỗi file edit" overflow="wrap" lineNumbers="true" %}
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "/usr/local/bin/audit-edit.sh" }
        ]
      }
    ]
  }
}
```
{% endcode %}

### Settings Delivery — Cách settings đến client

| Giai đoạn | Hành vi |
|:---|:---|
| **First launch (no cache)** | Chờ fetch tối đa 5 giây trước khi mở session. Nếu policy arrive kịp → enforce ngay. Nếu timeout → mở session, fetch tiếp tục trong background |
| **First launch (có cache)** | Cache apply ngay tại startup. Fetch mới chạy trong background |
| **Polling** | Fetch mới mỗi **1 giờ** trong session đang chạy |
| **Fetch fail** | Cache cũ tiếp tục apply. Nếu không có cache → không enforce managed settings. Endpoint-managed settings (MDM) vẫn apply |

{% hint style="warning" %}
Claude Code **withhold** một số env vars từ cache cho đến khi server confirm payload: proxy settings (`HTTPS_PROXY`, `ANTHROPIC_BASE_URL`), authentication credentials (`ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`), và routing vars. Điều này ngăn cached proxy redirect settings fetch.
{% endhint %}

### `forceRemoteSettingsRefresh` — Fail-closed startup

Đặt `"forceRemoteSettingsRefresh": true` trong managed settings để enforced **fail-closed behavior**: nếu fetch fail khi startup, Claude Code **thoát** thay vì tiếp tục với cache.

{% code title="Enable fail-closed startup" overflow="wrap" %}
```json
{
  "forceRemoteSettingsRefresh": true
}
```
{% endcode %}

{% hint style="danger" %}
Trước khi enable, đảm bảo network policy cho phép truy cập `api.anthropic.com`. Nếu endpoint không reachable, Claude Code sẽ exit ở startup và users không thể start Claude Code.
{% endhint %}

### Security Approval Dialogs

Khi managed settings chứa các cấu hình có rủi ro bảo mật, users sẽ thấy **dialog yêu cầu approve** trước khi Claude Code áp dụng:

* **Shell command settings:** `apiKeyHelper`, `statusLine`, `otelHeadersHelper`
* **Sandbox binary settings:** `sandbox.bwrapPath`, `sandbox.socatPath`
* **Hook configurations:** mọi hook definition
* **Proxy/env vars:** `HTTPS_PROXY`, `ANTHROPIC_BASE_URL`, credentials

Nếu user **reject**, Claude Code thoát. Approval được lưu trong `~/.claude` và không cần approve lại cho đến khi settings thay đổi.

### So sánh: Server-managed vs Endpoint-managed (MDM)

{% tabs %}
{% tab title="Server-managed settings" %}
* **Cách delivery:** Claude Code fetch từ Anthropic servers
* **Phù hợp:** Tổ chức không có MDM, hoặc users trên unmanaged devices
* **Security model:** Settings fetched at startup, hourly polling
* **Reach cloud sessions:** ✅ Có
* **Yêu cầu:** Team/Enterprise plan, network access `api.anthropic.com`
{% endtab %}
{% tab title="Endpoint-managed settings (MDM)" %}
* **Cách delivery:** Deploy qua MDM config profiles, registry policies, hoặc `managed-settings.json`
* **Phù hợp:** Tổ chức có MDM hoặc endpoint management
* **Security model:** Settings được protect ở OS level, user không thể modify
* **Reach cloud sessions:** ❌ Không (chỉ device-local)
* **Yêu cầu:** MDM infrastructure (macOS managed prefs, Windows registry)
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Cả hai đều occupy **cấp cao nhất** trong settings hierarchy. Nếu dùng cả hai, server-managed check trước, endpoint-managed là fallback. Tổ chức nên configure **cả hai** nếu có cả managed devices và cloud sessions.
{% endhint %}

### Platform Availability

* **Yêu cầu:** Direct connection đến `api.anthropic.com`
* **Authentication:** Team/Enterprise OAuth login, `CLAUDE_CODE_OAUTH_TOKEN`, hoặc direct API key
* **Skip fetch:** Nếu export `CLAUDE_CODE_USE_*` provider variable hoặc non-default `ANTHROPIC_BASE_URL` trong shell → Claude Code skip fetch
* **Cowork sessions:** Không fetch server-managed settings từ admin console
* **Gateway:** Claude apps gateway cung cấp equivalent remote delivery cho Bedrock/Vertex deployments

***

## Ví dụ thực tế

### User Settings — Theme và Permissions cơ bản

{% code title="~/.claude/settings.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-20250514",
  "outputStyle": "concise",
  "permissions": {
    "allow": [
      "Glob", "Grep", "Read", "ToolSearch",
      "Bash(git status)", "Bash(git diff:*)",
      "Bash(git log:*)", "Bash(git branch:*)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(git push:*)",
      "Read(./.env)", "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "autoUpdates": true,
  "telemetry": false
}
```
{% endcode %}

### Project Settings — Team hooks và env vars

{% code title=".claude/settings.json (commit lên git)" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "API_TIMEOUT_MS": "600000",
    "BASH_DEFAULT_TIMEOUT_MS": "120000"
  },
  "permissions": {
    "allow": [
      "Bash(pnpm lint:*)", "Bash(pnpm test:*)",
      "Bash(pnpm build:*)", "Bash(pnpm run:*)"
    ],
    "deny": [
      "Bash(pnpm publish:*)", "Bash(npx publish:*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "./scripts/check-command.sh" }
        ]
      }
    ]
  },
  "enabledPlugins": [
    "commit-commands@claude-plugins-official",
    "code-review@claude-plugins-official"
  ]
}
```
{% endcode %}

### Managed Settings — Organization-wide deny rules

{% code title="Managed settings qua claude.ai console" overflow="wrap" lineNumbers="true" %}
```json
{
  "permissions": {
    "deny": [
      "Bash(curl *)", "Bash(wget *)",
      "Read(./.env)", "Read(./.env.*)",
      "Read(./secrets/**)", "Read(./.aws/**)",
      "Read(./.kube/**)"
    ],
    "disableBypassPermissionsMode": "disable"
  },
  "allowManagedPermissionRulesOnly": true,
  "forceRemoteSettingsRefresh": true,
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "/usr/local/bin/audit-edit.sh" }
        ]
      }
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```
{% endcode %}

***

## Verify và Troubleshoot

### Kiểm tra settings đang active

{% tabs %}
{% tab title="/status" %}
Chạy `/status` bên trong Claude Code. Tab **Status** hiển thị dòng `Setting sources` — liệt kê mỗi settings file Claude Code đã load cho session hiện tại.

Khi managed settings đang enforce, managed entry hiển thị trong ngoặc cách nó đến máy bạn (ví dụ: "server-managed").
{% endtab %}
{% tab title="claude doctor" %}
Chạy `claude doctor` bên ngoài terminal để debug chi tiết. Dòng `Managed settings (remote)` cho thấy 1 trong 4 kết quả:

* **Delivered settings loaded** — ✅ Settings đã load thành công
* **No server-managed settings configured** — Tổ chức chưa cấu hình
* **Fetch failed** — Lỗi fetch, cache đang apply
* **Fetch skipped** — Vì provider variable hoặc custom base URL

Yêu cầu Claude Code v2.1.248 trở lên.
{% endtab %}
{% endtabs %}

### Xử lý file JSON bị lỗi

| Loại lỗi | Claude Code xử lý thế nào |
|:---|:---|
| **Settings Error** — JSON invalid hoặc value bị schema reject | Hiển thị dialog ở startup: fix với Claude, exit, hoặc continue không có broken settings |
| **Settings Warning** — Chỉ 1 vài entries lỗi (permission rule sai, hook event name lạ) | Skip entries lỗi, giữ rest của file |
| **Managed settings error** | Tiếp tục enforce phần còn lại. Invalidate entries bị drop, keys fallback về stricter value |
| **~/.claude.json corrupt** | Backup vào `~/.claude/backups/`, hỏi reset hoặc fix thủ công |

### Common issues

{% hint style="warning" %}
**Key bị ignored:** Kiểm tra higher level có set cùng key không. Dùng `/status` xem file nào đang apply, và `claude doctor` để biết chi tiết rejection.
{% endhint %}

{% hint style="warning" %}
**Managed change chưa đến:** Managed settings arrive theo lịch polling (mỗi 1 giờ). Restart session trước, rồi chạy `/status` để verify source.
{% endhint %}

{% hint style="warning" %}
**Committed key không reach teammates:** Hai nguyên nhân phổ biến:
1. **Key chỉ apply từ user/managed scope** — kiểm tra Scope column trong settings reference
2. **Key chờ workspace trust** — `allow` rules, `env` values cần mỗi người trust folder trước khi apply
{% endhint %}

{% hint style="info" %}
**Debug nâng cao:** Dùng `claude --debug-file <path>` và search log cho `Remote settings` để trace delivery issues. Luôn validate payload change với `claude doctor` trên test machine trước khi rollout.
{% endhint %}

***

## Tài liệu tham khảo

* [Claude Code Settings](https://code.claude.com/docs/en/settings) — Scopes, precedence, how to change settings
* [Claude Code Settings Reference](https://code.claude.com/docs/en/settings-reference) — Complete reference cho mọi settings key
* [Server-Managed Settings](https://code.claude.com/docs/en/server-managed-settings) — Cấu hình tập trung cho tổ chức
* [Managed Settings](https://code.claude.com/docs/en/managed-settings) — Endpoint-managed settings và delivery mechanisms
* [Environment Variables Reference](https://code.claude.com/docs/en/env-vars) — Danh sách env vars và precedence
