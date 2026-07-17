---
description: >-
  Hướng dẫn mở rộng Claude Code với Skills (workflow tái sử dụng), Hooks
  (tự động hóa), Subagents (agent riêng) và MCP (kết nối công cụ bên
  ngoài).
---

# Mở rộng Claude Code — Skills, Hooks, Subagents và MCP

Claude Code có 4 cơ chế mở rộng chính, mỗi loại phù hợp với mục đích khác nhau. Hiểu lúc nào dùng cái nào giúp bạn build workflow hiệu quả và maintainable.

## Tổng quan 4 cơ chế

| Cơ chế | Ai trigger | Load khi nào | Dùng cho |
| ------ | ---------- | ------------ | -------- |
| **Skills** | Claude auto hoặc bạn `/skill` | On-demand, khi relevant | Workflow tái sử dụng, domain knowledge |
| **Hooks** | Claude lifecycle events | Mỗi lần event trigger | Deterministic actions, auto-format, lint |
| **Subagents** | Bạn yêu cầu Claude | Khi bạn ask "use subagent" | Research trong context riêng |
| **MCP** | Claude dùng tool | Session start, khi cần data | Kết nối external services |

## Skills

Skills extend Claude's knowledge với project-specific hoặc domain-specific information. Claude tự động apply khi relevant, hoặc bạn invoke trực tiếp.

### Tạo skill

Tạo thư mục với file `SKILL.md` trong `.claude/skills/`:

{% code title=".claude/skills/api-conventions/SKILL.md" overflow="wrap" %}
```markdown
---
name: api-conventions
description: REST API design conventions for our services
---
# API Conventions
- Use kebab-case for URL paths
- Use camelCase for JSON properties
- Always include pagination for list endpoints
- Version APIs in the URL path (/v1/, /v2/)
```
{% endcode %}

### Skill với workflow

Skills có thể define repeatable workflows bạn invoke trực tiếp:

{% code title=".claude/skills/fix-issue/SKILL.md" overflow="wrap" %}
```markdown
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---
Analyze and fix the GitHub issue: $ARGUMENTS.

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR
```
{% endcode %}

Gọi skill:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/fix-issue 1234
```
{% endcode %}

{% hint style="info" %}
Dùng `disable-model-invocation: true` cho workflows có side effects mà bạn muốn trigger manually, không để Claude tự invoke.
{% endhint %}

## Hooks

Hooks chạy shell commands tại các lifecycle events cụ thể. Khác với CLAUDE.md (advisory), hooks **deterministic** — guarantee action happen.

### Lifecycle events

| Event | Khi nào trigger |
| ----- | --------------- |
| `PreToolUse` | Trước khi tool được execute |
| `PostToolUse` | Sau khi tool hoàn thành |
| `SessionStart` | Session bắt đầu |
| `SessionEnd` | Session kết thúc |
| `UserPromptSubmit` | User submit prompt |
| `PreCompact` | Trước khi compact context |
| `PostCompact` | Sau khi compact |
| `Stop` | Claude dừng respond |
| `SubagentStop` | Subagent dừng |
| `Notification` | Có notification |

### Ví dụ hook

{% code title=".claude/settings.json" overflow="wrap" %}
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "eslint --fix $CLAUDE_FILE_PATH"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm test"
          }
        ]
      }
    ]
  }
}
```
{% endcode %}

### Tạo hook bằng Claude

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Write a hook that runs eslint after every file edit
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Write a hook that blocks writes to the migrations folder
```
{% endcode %}

Dùng `/hooks` để browse all configured hooks.

{% hint style="warning" %}
Stop hook chạy check và block turn từ ending nếu check fails. Claude sẽ override hook sau 8 consecutive blocks.
{% endhint %}

## Subagents

Subagents chạy trong context riêng với tools riêng. Hữu ích cho tasks đọc nhiều files hoặc cần specialized focus mà không clutter main conversation.

### Tạo subagent

{% code title=".claude/agents/security-reviewer.md" overflow="wrap" %}
```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```
{% endcode %}

### Sử dụng subagent

{% code title="Claude Code prompt" overflow="wrap" %}
```text
use a subagent to review this code for security issues
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
use subagents to investigate how our authentication system
handles token refresh
```
{% endcode %}

### Writer/Reviewer pattern

Dùng 2 sessions — 1 viết, 1 review:

| Session A (Writer) | Session B (Reviewer) |
| ------------------- | -------------------- |
| `Implement a rate limiter for our API` | |
| | `Review the rate limiter in @src/middleware/rateLimiter.ts` |
| `Address the review feedback: [output from B]` | |

## MCP (Model Context Protocol)

MCP là open standard kết nối AI tools với external data sources. Claude Code có thể read Google Drive, update Jira tickets, query databases, tích hợp Figma designs qua MCP.

### Thêm MCP server

{% code title="Terminal" overflow="wrap" %}
```bash
claude mcp add <server-name> <server-url>
```
{% endcode %}

Ví dụ:

{% code title="Terminal" overflow="wrap" %}
```bash
claude mcp add atlassian https://mcp.atlassian.com/v1/mcp \
  --transport http \
  --header "Authorization: Basic $(echo -n 'user@email.com:api-token' | base64)" \
  --scope user
```
{% endcode %}

### Quản lý MCP

{% code title="Terminal" overflow="wrap" %}
```bash
claude mcp list              # Xem danh sách servers
claude mcp remove <name>     # Xóa server
```
{% endcode %}

### Dùng MCP resources

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Show me the data from @github:repos/owner/repo/issues
```
{% endcode %}

Format: `@server:resource` — fetch data từ connected MCP servers.

## Plugins

Plugins bundle skills, hooks, subagents, và MCP servers thành installable units từ community và Anthropic.

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/plugin
```
{% endcode %}

Browse marketplace và cài đặt one-click. Đặc biệt hữu ích:
* **Code intelligence plugin** — precise symbol navigation, auto error detection
* **commit-commands** — Git commit helpers
* **code-review** — Automated code review

## Khi nào dùng cái nào?

| Nhu cầu | Dùng |
| ------- | ---- |
| Claude cần biết coding conventions | **CLAUDE.md** hoặc **Skill** |
| Workflow có thể tái sử dụng | **Skill** |
| Auto-format sau mỗi file edit | **Hook** |
| Block action deterministic | **Hook** |
| Research codebase không làm sạch context | **Subagent** |
| Review code trong context riêng | **Subagent** |
| Kết nối Jira, Notion, Figma | **MCP** |
| Query database từ Claude | **MCP** |
| Cài đặt bundle tools | **Plugin** |

## Tài liệu tham khảo

* [Skills](https://code.claude.com/docs/en/skills)
* [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
* [Subagents](https://code.claude.com/docs/en/sub-agents)
* [MCP Quickstart](https://code.claude.com/docs/en/mcp-quickstart)
* [Plugins](https://code.claude.com/docs/en/plugins)
* [Extend Claude Code](https://code.claude.com/docs/en/features-overview)
