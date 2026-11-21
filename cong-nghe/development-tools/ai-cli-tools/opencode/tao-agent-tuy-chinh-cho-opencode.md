---
description: >-
  Tạo agent tùy chỉnh cho OpenCode V2: vị trí, Markdown/JSONC, frontmatter, mode,
  model, permissions, steps, hidden, color và ví dụ reviewer.
---

# Tạo agent tùy chỉnh cho OpenCode

Agent trong OpenCode kết hợp system prompt, model preference, permissions và display details thành một profile có tên. Bài này hướng dẫn tạo agent tùy chỉnh (Markdown hoặc JSONC), các field và ví dụ reviewer read-only.

## Khái niệm cơ bản

* **Agent:** profile trợ lý có system prompt, model, permissions, mode.
* **Mode:** `primary` (chạy chính), `subagent` (chạy trong child session qua tool `subagent`), `all`.
* **Built-ins:** `build` (primary), `plan` (primary), `general` (subagent), `explore` (subagent). V2 không có `scout`.
* **Override:** dùng cùng ID để override built-in; definitions merge theo config order.

## Yêu cầu

* Đã cài OpenCode V2.
* Quen thuộc YAML frontmatter và JSONC.

## Hướng dẫn thực hiện

### Bước 1: Tạo agent Markdown

Lưu global hoặc project:

```text
~/.config/opencode/agents/<name>.md
.opencode/agents/<name>.md
```

Nested path trở thành một phần ID:

```text
.opencode/agents/team/reviewer.md  →  team/reviewer
```

Ví dụ reviewer read-only:

{% code title=".opencode/agents/reviewer.md" overflow="wrap" lineNumbers="true" %}
```md
---
description: Reviews changes for correctness and regressions
mode: subagent
model: anthropic/claude-sonnet-5-5#high
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
---

Review the current changes. List findings in severity order with file and line references.
```
{% endcode %}

Body Markdown trở thành `system` prompt.

### Bước 2: Tạo agent JSONC

Define dưới `agents` trong config file:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agents": {
    "reviewer": {
      "description": "Reviews current changes",
      "mode": "subagent",
      "system": "Report findings in severity order.",
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "deny" },
      ],
    },
  },
}
```
{% endcode %}

### Bước 3: Chọn agent mặc định

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "default_agent": "writer",
  "agents": {
    "writer": { "mode": "primary" },
  },
}
```
{% endcode %}

Default phải tồn tại, visible và support primary. Nếu không, OpenCode dùng `build`, sau đó primary-capable đầu tiên. Changing setting không thay agent lưu trên session hiện có.

### Bước 4: Cấu hình fields

#### Description

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
description: Reviews database migrations for safety
```
{% endcode %}

Quan trọng cho subagent vì OpenCode hiển thị cho model chọn agent.

#### Mode

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
mode: all
```
{% endcode %}

`primary`, `subagent`, `all`. Custom agent mới mặc định `primary`.

#### Model

String form:

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
model: anthropic/claude-sonnet-5-5#high
```
{% endcode %}

Expanded JSON form:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "reviewer": {
      "model": {
        "providerID": "anthropic",
        "model": "claude-sonnet-5-5",
        "variant": "high",
      },
    },
  },
}
```
{% endcode %}

* Subagent dùng model configured, hoặc inherit parent session model nếu không config.
* Session lưu selected model riêng; chọn primary agent by ID không đổi model đó.

#### System

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "reviewer": { "system": "Review only. Do not modify files." },
  },
}
```
{% endcode %}

Non-empty value replaces provider base prompt cho agent đó. Project instructions, skills, references vẫn được thêm. Markdown agent dùng body thay vì `system` frontmatter.

#### Permissions

Ordered rules:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "reviewer": {
      "permissions": [
        { "action": "*", "resource": "*", "effect": "deny" },
        { "action": "read", "resource": "src/**", "effect": "allow" },
      ],
    },
  },
}
```
{% endcode %}

| Field | Ý nghĩa |
|---|---|
| `action` | Tool/permission action, hỗ trợ wildcard |
| `resource` | Path, command, agent ID hoặc giá trị match; hỗ trợ wildcard |
| `effect` | `allow`, `ask`, `deny` |

Last matching rule wins; đặt broad rules trước exceptions. Common actions: `shell`, `edit`, `subagent`, `read`, `glob`, `grep`, `webfetch`, `websearch`, `skill`. Với `read`/`edit`/`external_directory`, OpenCode expand `~` và `$HOME`. Shell resources giữ raw command text.

#### Steps

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
steps: 8
```
{% endcode %}

Positive max model steps. Final step remove tools và yêu cầu model summarize. New user input reset allowance.

#### Hidden

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
hidden: true
```
{% endcode %}

Remove khỏi listings/discovery/subagent catalog. Controls visibility, not security.

#### Color

{% code title="frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
color: "#ff6b6b"
```
{% endcode %}

#### Disabled

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "plan": { "disabled": true },
  },
}
```
{% endcode %}

#### Request

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "reviewer": {
      "request": {
        "headers": { "x-agent": "reviewer" },
        "body": { "temperature": 0.1 },
      },
    },
  },
}
```
{% endcode %}

{% hint style="warning" %}
V2 session runner preserves these values nhưng chưa gửi chúng với model requests. Configure active request settings trên provider/model/model variant.
{% endhint %}

### Bước 5: Subagent permissions và merging

Orchestrator example:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "orchestrator": {
      "permissions": [
        { "action": "subagent", "resource": "*", "effect": "deny" },
        { "action": "subagent", "resource": "reviewer", "effect": "allow" },
      ],
    },
  },
}
```
{% endcode %}

Subagents run fresh context child sessions, always background; parent receives report when child idle và sau mỗi round. Parent's `subagent` permissions control launch; child dùng own permissions.

Merging: later scalar replace earlier; request maps merge by key; permission rules append. Global permissions apply before agent-specific, so later agent rules refine.

### Bước 6: Override built-in

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "build": {
      "permissions": [
        { "action": "shell", "resource": "git push *", "effect": "ask" },
      ],
    },
  },
}
```
{% endcode %}

Hidden `compaction`, `title`, `summary` agents perform maintenance và không select trực tiếp.

## Xác minh kết quả

* Chạy `opencode` và chọn agent (`/` hoặc settings).
* Subagent: yêu cầu primary agent "Use the reviewer subagent...".
* Kiểm tra permissions deny edit/shell cho reviewer.

## Lưu ý quan trọng

{% hint style="danger" %}
Không dùng legacy top-level fields như `temperature`, `top_p`, `prompt`, `permission`, `tools`, `disable`, `maxSteps` trong config V2 mới.
{% endhint %}

* V1 frontmatter fields deprecated; xem migrate guide.
* `hidden` controls visibility, not security.
* `request` chưa được gửi hiện tại.
* Agent file nested path → ID with `/`.

## Tài liệu tham khảo

* [OpenCode V2 — Agents](https://opencode.ai/v2/docs/agents)
* [OpenCode V2 — Permissions](https://opencode.ai/v2/docs/permissions)
* [OpenCode V2 — Migrate V1](https://opencode.ai/v2/docs/migrate-v1)
* {% content-ref url="cau-hinh-chi-tiet-opencode-jsonc.md" %}[Cấu hình chi tiết `opencode.jsonc`](cau-hinh-chi-tiet-opencode-jsonc.md){% endcontent-ref %}