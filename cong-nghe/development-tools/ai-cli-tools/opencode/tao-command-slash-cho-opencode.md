---
description: >-
  Tạo slash command cho OpenCode V2: Markdown/JSON, fields, arguments, shell blocks,
  attachments, execution và background subagent.
---

# Tạo slash command cho OpenCode

Slash command biến một prompt template thành lệnh `/name` trong TUI. Bài này hướng dẫn tạo command bằng Markdown hoặc JSON, dùng arguments, shell blocks, attachments và chạy background.

## Khái niệm cơ bản

* **Command:** prompt template có thể có arguments, agent, model, subagent.
* **Markdown command:** file `.md` trong `commands/`; body là template.
* **JSON command:** định nghĩa dưới `commands` trong config; bắt buộc `template`.
* **Nested path:** `.opencode/commands/team/review.md` → `/team/review`.

## Yêu cầu

* Đã cài OpenCode V2.
* Quen thuộc YAML frontmatter/JSONC.

## Hướng dẫn thực hiện

### Bước 1: Tạo command Markdown

Global/project:

```text
~/.config/opencode/commands/<name>.md
.opencode/commands/<name>.md
```

Ví dụ review:

{% code title=".opencode/commands/review.md" overflow="wrap" lineNumbers="true" %}
```md
---
description: Review code for correctness
agent: plan
model: anthropic/claude-sonnet-5-5#high
---

Review $ARGUMENTS. Report bugs first.
```
{% endcode %}

Chạy: `/review src/auth.ts`.

### Bước 2: Tạo command JSON

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "commands": {
    "review": {
      "description": "Review code for correctness",
      "template": "Review $ARGUMENTS. Report bugs first.",
    },
  },
}
```
{% endcode %}

### Bước 3: Fields

| Field | Bắt buộc | Behavior |
|---|---|---|
| `template` | JSON only | Prompt template |
| `description` | No | Text trong command lists/discovery |
| `agent` | No | Agent selected khi command chạy |
| `model` | No | Model override `provider/model` hoặc `provider/model#variant` |
| `subagent` | No | `true` chạy background child session; `false` force current session |
| `subtask` | No | Deprecated alias cho `subagent` |

Ví dụ đầy đủ:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "commands": {
    "audit": {
      "template": "Audit $ARGUMENTS.",
      "description": "Audit a package",
      "agent": "general",
      "model": "anthropic/claude-sonnet-5-5#high",
      "subagent": true,
    },
  },
}
```
{% endcode %}

Markdown không đặt `template` trong frontmatter; body cung cấp.

### Bước 4: Arguments

`$ARGUMENTS` cho toàn bộ argument string:

{% code title=".opencode/commands/component.md" overflow="wrap" lineNumbers="true" %}
```md
Create a typed React component named $ARGUMENTS.
```
{% endcode %}

Positions `$1`, `$2`, ...; quote grouping:

{% code title=".opencode/commands/check.md" overflow="wrap" lineNumbers="true" %}
```md
Check $1. Focus on $2.
```
{% endcode %}

Highest-numbered placeholder consumes arg đó và mọi thứ sau. Missing positions → empty string.

Fallback: nếu template không có placeholder, OpenCode append non-empty arguments sau blank line.

### Bước 5: Shell blocks

Wrap shell command trong `!` + backticks để insert output trước khi submit prompt:

{% code title=".opencode/commands/review-diff.md" overflow="wrap" lineNumbers="true" %}
```md
Review this diff:

!`git diff --stat && git diff`
```
{% endcode %}

Argument placeholders expand trước:

{% code title=".opencode/commands/history.md" overflow="wrap" lineNumbers="true" %}
```md
Summarize these commits:

!`git log --oneline -$1`
```
{% endcode %}

{% hint style="warning" %}
Shell blocks chạy khi OpenCode evaluate command, ngoài agent tool permission flow. Chỉ dùng command từ nguồn tin cậy. Không đặt untrusted arguments trong shell blocks.
{% endhint %}

### Bước 6: Attachments

Stored templates không expand `@path`; nó là ordinary prompt text. Để attach file, thêm qua composer khi invoke command; OpenCode preserve attachments khi submit.

### Bước 7: Execution model selection

Commands expand args/shell blocks trước khi submit durable user prompt. Chạy current session mặc định.

Model selection rules:
1. Command `model` override mọi model khác.
2. Nếu không, selected command agent's configured model override model active at invocation.
3. Nếu không, current session model remains.

Ví dụ chọn agent + model:

{% code title=".opencode/commands/design.md" overflow="wrap" lineNumbers="true" %}
```md
---
agent: plan
model: openai/gpt-6.1-sol#high
---

Design $ARGUMENTS.
```
{% endcode %}

### Bước 8: Background subagent

Set `subagent: true` để chạy trong background child session:

{% code title=".opencode/commands/audit.md" overflow="wrap" lineNumbers="true" %}
```md
---
description: Audit changes
agent: general
subagent: true
---

Audit $ARGUMENTS for bugs and missing tests.
```
{% endcode %}

Parent stays available, giữ agent/model. OpenCode gửi child result/failure về parent khi child finish.

| Value | Behavior |
|---|---|
| `true` | Luôn dùng child, kể cả agent mode primary |
| `false` | Luôn dùng current session, kể cả agent mode subagent |
| Omitted | Dùng child chỉ khi selected agent mode subagent |

Child dùng command model, sau đó selected agent's model, sau đó parent's model. Legacy `subtask` accepted; nếu cả hai, `subagent` wins.

### Bước 9: Loading precedence và auto reload

Markdown và JSON commands share một registry. Later sources replace earlier commands cùng name.

```text
~/.config/opencode/commands/review.md   # Lower priority
.opencode/commands/review.md           # Replaces global
```

Project sources precedence over global; nearer project over ancestor. Custom definition có thể replace built-in. OpenCode reload command files và config changes automatically.

## Xác minh kết quả

* Gõ `/review` trong TUI; kiểm tra prompt submitted.
* Test arguments positions.
* Kiểm tra shell block output.
* Test `subagent: true` parent remains responsive.

## Lưu ý quan trọng

{% hint style="warning" %}
Shell blocks chạy outside permission flow. Chỉ trust sources.
{% endhint %}

* Legacy singular directory `command/` cũng discovered, nhưng dùng `commands/` cho mới.
* Nested command name uses `/`.
* `subtask` deprecated; `subagent` wins.
* Stored templates không expand `@path`.

## Tài liệu tham khảo

* [OpenCode V2 — Commands](https://opencode.ai/v2/docs/commands)
* [OpenCode V2 — Agents](https://opencode.ai/v2/docs/agents)
* {% content-ref url="tao-agent-tuy-chinh-cho-opencode.md" %}[Tạo agent tùy chỉnh cho OpenCode](tao-agent-tuy-chinh-cho-opencode.md){% endcontent-ref %}