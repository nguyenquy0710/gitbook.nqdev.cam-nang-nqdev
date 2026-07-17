---
description: >-
  Hướng dẫn chi tiết về sự khác biệt trong cấu trúc Agents, Skills, Commands
  giữa OpenCode và Claude Code, kèm cách chuyển đổi cấu hình giữa hai công cụ.
---

# Cấu trúc Agents, Skills, Commands: OpenCode vs Claude Code — và cách chuyển đổi

OpenCode và Claude Code đều cho phép tùy chỉnh agent, skill và command nhưng dùng cấu trúc thư mục, frontmatter và cơ chế hoạt động khác nhau. Bài viết này phân tích chi tiết từng thành phần và hướng dẫn cách migrate cấu hình giữa hai công cụ.

### Bảng so sánh tổng quan

| Thành phần              | OpenCode                                                        | Claude Code                                               |
| ----------------------- | --------------------------------------------------------------- | --------------------------------------------------------- |
| **Agents**              | `opencode.json` hoặc `.opencode/agents/*.md`                    | `.claude/agents/*.md`                                     |
| **Skills**              | `.opencode/skills/<name>/SKILL.md`                              | `.claude/skills/<name>/SKILL.md`                          |
| **Commands**            | `.opencode/commands/<name>.md` hoặc `opencode.json` + `command` | `.claude/commands/<name>.md` (legacy) — merged vào skills |
| **Config JSON**         | `opencode.json` / `opencode.jsonc`                              | `.claude/settings.json` / `.claude/settings.local.json`   |
| **Global path**         | `~/.config/opencode/`                                           | `~/.claude/`                                              |
| **Compatibility layer** | Đọc luôn `.claude/skills/` và `.claude/agents/`                 | Không đọc `.opencode/`                                    |

### 1. Agents

#### Cách OpenCode định nghĩa Agent

**JSON config:**

{% code title="opencode.json" overflow="wrap" lineNumbers="true" %}
```
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices and potential issues",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a code reviewer. Focus on security, performance, and maintainability.",
      "permission": {
        "edit": "deny"
      }
    }
  }
}
```
{% endcode %}

**Markdown file:**

{% code title=".opencode/agents/code-reviewer.md" overflow="wrap" lineNumbers="true" %}
```
---
description: Reviews code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
permission:
  edit: deny
  bash: deny
---
You are in code review mode. Focus on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations
```
{% endcode %}

**Built-in agents:**

* `build` — primary, full tool access
* `plan` — primary, restricted (read-only)
* `general` — subagent, full tools
* `explore` — subagent, read-only, fast
* `scout` — subagent, đọc docs external

**Key concepts:**

* `mode`: `primary` | `subagent` | `all`
* `permission` kiểm soát tool access per-agent: `allow` | `ask` | `deny`
* Dùng `@agent-name` để gọi subagent
* Primary agents dùng **Tab** để chuyển đổi

#### Cách Claude Code định nghĩa Agent

{% code title=".claude/agents/code-reviewer.md" overflow="wrap" lineNumbers="true" %}
```
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---
You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```
{% endcode %}

**Built-in subagents:**

* `Explore` — read-only, search codebase
* `Plan` — read-only, research for plan mode
* `General-purpose` — full tools

**Key concepts:**

* `tools` field là allowlist (tools cho phép)
* `disallowedTools` field là denylist
* `permissionMode`: `default` | `acceptEdits` | `auto` | `bypassPermissions` | `plan`
* `model` dùng alias: `sonnet` | `opus` | `haiku` | `fable`
* Dùng `@agent-name` (xuất hiện trong typeahead) hoặc `@agent-<name>`
* `--agent <name>` flag để chạy cả session như một agent
* Hỗ trợ `memory`, `hooks`, `mcpServers`, `isolation: worktree`, `background`

#### So sánh chi tiết Agent

| Field         | OpenCode                                                         | Claude Code                                                                              |
| ------------- | ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Mode          | `primary` / `subagent` / `all`                                   | Không có mode tường minh — dùng frontmatter + CLI flag                                   |
| Permission    | `permission` per-tool + glob patterns                            | `permissionMode` enum + `tools` / `disallowedTools` allowlist                            |
| Model format  | `provider/model-id`                                              | Alias (`sonnet`, `opus`) hoặc model ID                                                   |
| System prompt | Body markdown hoặc `prompt` field                                | Body markdown                                                                            |
| Scope         | Global `~/.config/opencode/agents/`, project `.opencode/agents/` | Managed > CLI `--agents` > project `.claude/agents/` > user `~/.claude/agents/` > plugin |
| Hooks         | ✗ (dùng Rules)                                                   | ✓ `hooks` trong frontmatter                                                              |
| Memory        | ✗                                                                | ✓ `memory: user`/`project`/`local`                                                       |
| MCP scoping   | ✓ permission glob patterns                                       | ✓ `mcpServers` field trong frontmatter                                                   |
| Isolation     | ✗                                                                | ✓ `isolation: worktree`                                                                  |
| Task spawning | ✓ `task` tool + `permission.task`                                | ✓ `Agent` tool + `Agent(type)` allowlist                                                 |

#### Cách chuyển đổi Agent từ Claude Code sang OpenCode

Chuyển định dạng field:

{% code title="Claude Code → OpenCode" overflow="wrap" lineNumbers="true" %}
```
# Claude Code format
---
name: code-reviewer
description: Reviews code
tools: Read, Glob, Grep
model: sonnet
permissionMode: plan
---

# OpenCode format
---
description: Reviews code
mode: subagent
model: anthropic/claude-sonnet-4-20250514
permission:
  edit: deny
  bash: deny
  glob: allow
  grep: allow
  read: allow
---
```
{% endcode %}

**Mapping model alias:**

* `sonnet` → `anthropic/claude-sonnet-4-20250514`
* `opus` → `anthropic/claude-opus-4-5-20250514`
* `haiku` → `anthropic/claude-haiku-4-20250514`

**Lưu ý khi chuyển:**

* OpenCode **không hỗ trợ** `hooks` per-agent, phải dùng `rules` hoặc custom tool
* OpenCode **không hỗ trợ** `memory` per-agent
* OpenCode **không hỗ trợ** `isolation: worktree`
* OpenCode **có** `scout` agent riêng để đọc docs — Claude Code không có built-in tương đương
* Claude Code Explore agent có mức thoroughness (`quick`/`medium`/`very thorough`) — OpenCode Explore không có

### 2. Skills

#### Agent Skills Standard

Cả OpenCode và Claude Code đều tuân theo [Agent Skills](https://agentskills.io) open standard. Điều này có nghĩa: **SKILL.md format cơ bản tương thích giữa hai công cụ**.

SKILL.md cơ bản hoạt động trên cả hai:

{% code title="SKILL.md (cross-compatible)" overflow="wrap" lineNumbers="true" %}
```
---
name: git-release
description: Create consistent releases and changelogs
---
Draft release notes from merged PRs. Propose a version bump.
```
{% endcode %}

#### Cách OpenCode xử lý Skills

* **Path:** `.opencode/skills/<name>/SKILL.md` hoặc `~/.config/opencode/skills/<name>/SKILL.md`
* **Compatibility layer:** OpenCode cũng đọc `.claude/skills/<name>/SKILL.md` và `.agents/skills/<name>/SKILL.md`
* **Cơ chế:** Dùng `skill` tool để discover skills.
* **Permission:** Kiểm soát bằng `permission.skill` với glob patterns:

{% code title="opencode.json" overflow="wrap" lineNumbers="true" %}
```
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```
{% endcode %}

* **Override per-agent:**

{% code title="opencode.json" overflow="wrap" lineNumbers="true" %}
```
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```
{% endcode %}

* **Frontmatter fields hỗ trợ:** `name`, `description`, `license`, `compatibility`, `metadata`

#### Cách Claude Code xử lý Skills

* **Path:** `.claude/skills/<name>/SKILL.md`, `~/.claude/skills/<name>/SKILL.md`, `~/.claude/commands/<name>.md` (legacy)
* **Bundled skills:** `/code-review`, `/batch`, `/debug`, `/loop`, `/run`, `/verify`
* **Commands merged vào skills:** File `.claude/commands/deploy.md` và skill `.claude/skills/deploy/SKILL.md` đều tạo `/deploy`
* **Frontmatter fields phong phú hơn:**

{% code title="Claude Code skill" overflow="wrap" lineNumbers="true" %}
```
---
name: deploy
description: Deploy to production
disable-model-invocation: true
allowed-tools: Bash(gh *)
context: fork
agent: Explore
arguments: [environment, version]
---
Deploy $environment to version $version.
```
{% endcode %}

| Field                                | Mô tả                                          |
| ------------------------------------ | ---------------------------------------------- |
| `allowed-tools`                      | Tool auto-approved khi skill active            |
| `disable-model-invocation`           | Chỉ user mới gọi được                          |
| `user-invocable`                     | Chỉ Claude mới gọi được                        |
| `context: fork`                      | Chạy trong subagent riêng                      |
| `agent`                              | Chọn agent type khi fork                       |
| `arguments`                          | Named argument mapping                         |
| `allowed-tools` / `disallowed-tools` | Danh sách tools cho phép/cấm                   |
| `paths`                              | Glob pattern giới hạn khi skill được kích hoạt |
| `hooks`                              | Lifecycle hooks scoped                         |

#### So sánh chi tiết Skills

| Field                      | OpenCode                          | Claude Code                               |
| -------------------------- | --------------------------------- | ----------------------------------------- |
| Path                       | `.opencode/skills/`               | `.claude/skills/`                         |
| Commands                   | `.opencode/commands/`             | `.claude/commands/` (legacy, merged)      |
| Cross-compat               | Đọc `.claude/skills/`             | Không đọc `.opencode/skills/`             |
| Bundled skills             | Theo plugin                       | 10+ built-in (`/code-review`, `/run`,...) |
| `disable-model-invocation` | ✗                                 | ✓                                         |
| `context: fork`            | ✗                                 | ✓                                         |
| `allowed-tools`            | ✗ (dùng permission)               | ✓                                         |
| `arguments`                | ✗                                 | ✓                                         |
| `paths`                    | ✗                                 | ✓                                         |
| Shell injection            | ✗                                 | ✓ (`` `!`command` ``)                     |
| Permission control         | Glob patterns, `permission.skill` | `Skill(name)` syntax, `skillOverrides`    |
| Live reload                | ✓                                 | ✓                                         |

#### Cách chuyển đổi Skills giữa hai công cụ

**Từ Claude Code sang OpenCode:**

* Skill ở `.claude/skills/` đã được OpenCode đọc tự động — **không cần migrate** nếu bạn dùng OpenCode
* Nếu muốn chuyển hẳn: copy từ `.claude/skills/` sang `.opencode/skills/`
* Loại bỏ các field không tương thích: `disable-model-invocation`, `context: fork`, `agent`, `allowed-tools`, `arguments`, `paths`, `hooks`
* Thay `allowed-tools` bằng `permission` pattern trong `opencode.json` nếu cần

**Từ OpenCode sang Claude Code:**

* Copy từ `.opencode/skills/` sang `.claude/skills/`
* SKILL.md cơ bản hoạt động ngay — frontmatter lạ bị ignore
* Thêm `disable-model-invocation: true` cho các skill có side-effect
* Dùng `allowed-tools` để pre-approve tool cụ thể

### 3. Commands

#### OpenCode Commands

OpenCode có hệ thống commands riêng biệt với skills:

{% code title="JSON config" overflow="wrap" lineNumbers="true" %}
```
{
  "command": {
    "test": {
      "template": "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```
{% endcode %}

{% code title="Markdown format" overflow="wrap" lineNumbers="true" %}
```
---
description: Run tests with coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---
Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.
```
{% endcode %}

**Tính năng đặc biệt:**

* `$ARGUMENTS` / `$1`, `$2` — positional arguments
* `` `!`command` `` — inject shell output trực tiếp vào prompt
* `@filename` — file reference, nội dung được include tự động
* `agent` field — chọn agent thực thi command
* `subtask: true` — force chạy trong subagent context

#### Claude Code Commands

Claude Code **đã merge commands vào skills**. File `.claude/commands/deploy.md` vẫn hoạt động, nhưng khuyến nghị dùng `.claude/skills/deploy/SKILL.md` thay thế.

Tính năng commands đặc biệt của Claude Code:

* `$N` và `$ARGUMENTS[N]` — indexed arguments
* `$name` — named arguments (khai báo trong frontmatter `arguments`)
* `${CLAUDE_SESSION_ID}` — session ID variable
* `${CLAUDE_SKILL_DIR}` — skill directory path
* `${CLAUDE_PROJECT_DIR}` — project root path
* `` `!`command` `` — shell injection (giống OpenCode)
* ` ```! ` — multi-line command block
* User-invocable check via `user-invocable: false`
* Skill stacking: `/code-review /fix-issue 123`

#### So sánh Commands

| Field             | OpenCode                  | Claude Code                                  |
| ----------------- | ------------------------- | -------------------------------------------- |
| File format       | JSON + Markdown           | Markdown (skills supersede)                  |
| Arguments         | `$ARGUMENTS`, `$1`-`$9`   | `$ARGUMENTS`, `$1`, `$ARGUMENTS[N]`, `$name` |
| Shell inject      | `` `!`command` ``         | `` `!`command` `` + ` ```! `                 |
| File reference    | `@filename`               | ✗ (dùng `$ARGUMENTS`)                        |
| Agent binding     | `agent` field + `subtask` | `context: fork` + `agent`                    |
| Override built-in | ✓                         | ✓                                            |
| Environment vars  | ✗                         | `${CLAUDE_*}` variables                      |
| Skill stacking    | ✗                         | ✓ (từ v2.1.199)                              |
| Path              | `.opencode/commands/`     | `.claude/commands/` (legacy)                 |

#### Cách chuyển đổi Commands

**OpenCode → Claude Code:**

{% code title="OpenCode command" overflow="wrap" lineNumbers="true" %}
```
---
description: Create a new component
agent: build
---
Create a new React component named $ARGUMENTS with TypeScript support.
```
{% endcode %}

{% code title="Chuyển sang Claude Code skill" overflow="wrap" lineNumbers="true" %}
```
---
description: Create a new React component
context: fork
agent: general-purpose
disable-model-invocation: true
---
Create a new React component named $ARGUMENTS with TypeScript support.
Include proper typing and basic structure.
```
{% endcode %}

**Claude Code → OpenCode:**

{% code title="Claude Code skill" overflow="wrap" lineNumbers="true" %}
```
---
description: Deploy to production
disable-model-invocation: true
allowed-tools: Bash(gh *)
---
Deploy $ARGUMENTS to production. Run tests first.
```
{% endcode %}

{% code title="Chuyển sang OpenCode command" overflow="wrap" lineNumbers="true" %}
```
---
description: Deploy to production
---
Deploy $ARGUMENTS to production. Run tests first.
```
{% endcode %}

> Lưu ý: OpenCode không hỗ trợ `disable-model-invocation`. Agent luôn có thể tự động gọi skill/command. Để giới hạn, dùng `permission` trong config.

### 4. Compatibility Layer — OpenCode đọc cấu hình Claude Code

Đây là điểm mạnh nhất khi migrate từ Claude Code sang OpenCode: **OpenCode có compatibility layer đọc cấu hình Claude Code**.

OpenCode tự động phát hiện:

* `.claude/skills/<name>/SKILL.md`
* `.claude/agents/*.md`
* `~/.claude/skills/<name>/SKILL.md`
* `.agents/skills/<name>/SKILL.md`
* `~/.agents/skills/<name>/SKILL.md`

Điều này có nghĩa: **nếu bạn đã có cấu hình Claude Code trong project, OpenCode sẽ dùng được ngay mà không cần sửa đổi gì**.

Tuy nhiên, chiều ngược lại **không đúng**: Claude Code **không đọc** `.opencode/` directory. Nếu bạn muốn dùng cả hai công cụ, hãy đặt cấu hình ở `.claude/` để cả OpenCode và Claude Code đều đọc được.

### 5. Migration Strategy Tổng Thể

#### Strategy A: Dùng cả hai (khuyến nghị)

Đặt tất cả cấu hình ở `.claude/` — OpenCode đọc được, Claude Code đọc được.

```
project-root/
├── .claude/
│   ├── agents/
│   │   └── code-reviewer.md
│   ├── skills/
│   │   └── git-release/
│   │       └── SKILL.md
│   └── settings.json
└── opencode.json      # Chỉ chứa OpenCode-specific config (model, provider, ...)
```

#### Strategy B: Chỉ dùng OpenCode

Đặt skill ở `.opencode/skills/` và `.claude/skills/` mirror, hoặc tận dụng compatibility layer.

**Không khuyến nghị** vì gây duplicate.

#### Strategy C: Chỉ dùng Claude Code

Đặt mọi thứ ở `.claude/`. Bỏ qua `.opencode/`.

#### Checklist migrate

| Item          | Claude Code → OpenCode                                                                             | OpenCode → Claude Code                                                            |
| ------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Agents        | Copy `.claude/agents/` → `.opencode/agents/`; chỉnh `model` format, thay `tools` bằng `permission` | Copy `.opencode/agents/` → `.claude/agents/`; thêm `name`, `tools`, `model` alias |
| Skills        | **Không cần** — OpenCode đọc `.claude/skills/`                                                     | Copy `.opencode/skills/` → `.claude/skills/`; thêm field nâng cao nếu muốn        |
| Commands      | Copy `.opencode/commands/` → `.claude/commands/` hoặc `.claude/skills/`                            | Copy `.claude/commands/` → `.opencode/commands/`; chỉnh `template`                |
| Config        | Viết lại hoàn toàn — format JSON khác nhau                                                         | Viết lại hoàn toàn                                                                |
| MCP           | Cấu hình trong `opencode.json`                                                                     | Cấu hình trong `.mcp.json` hoặc `.claude/settings.json`                           |
| Global config | `~/.config/opencode/`                                                                              | `~/.claude/`                                                                      |

### 6. Các vấn đề thường gặp và cách khắc phục

#### Vấn đề 1: Skill không hiển thị trong OpenCode dù đã đặt đúng path

**Nguyên nhân:** Skill đặt trong `.opencode/skills/` nhưng thiếu `name` hoặc `description` trong frontmatter, hoặc tên skill trùng với skill khác.

**Fix:**

```
# Kiểm tra frontmatter — cần có name và description
cat .opencode/skills/my-skill/SKILL.md

# Kiểm tra permission cho phép skill
# "permission": { "skill": { "*": "allow" } }
```

#### Vấn đề 2: Claude Code skill dùng `context: fork` không hoạt động trên OpenCode

**Nguyên nhân:** OpenCode không hỗ trợ `context: fork` và `agent` field trong skill frontmatter.

**Fix:** Chuyển skill thành command của agent:

{% code title="OpenCode command thay thế" overflow="wrap" lineNumbers="true" %}
```
---
description: Run research in explore mode
agent: explore
subtask: true
---
Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings
```
{% endcode %}

#### Vấn đề 3: `allowed-tools` trong Claude Code skill không có hiệu lực trên OpenCode

**Nguyên nhân:** OpenCode không có field này — dùng `permission` system thay thế.

**Fix:**

{% code title="opencode.json" overflow="wrap" lineNumbers="true" %}
```
{
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "gh *": "allow"
        }
      }
    }
  }
}
```
{% endcode %}

#### Vấn đề 4: Claude Code dùng model alias (`sonnet`), OpenCode yêu cầu full ID

**Fix:** Map alias sang full ID:

* `sonnet` → `anthropic/claude-sonnet-4-20250514` hoặc model mới hơn
* `opus` → `anthropic/claude-opus-4-5-20250514`
* `haiku` → `anthropic/claude-haiku-4-20250514`

#### Vấn đề 5: Command arguments không hoạt động giống nhau

**OpenCode:**

* `$1`, `$2` — positional
* `$ARGUMENTS` — tất cả

**Claude Code:**

* `$0`, `$1` — positional
* `$name` — named arguments (khai báo trong frontmatter)
* `$ARGUMENTS[N]` — indexed
* `${CLAUDE_*}` — environment variables

**Fix:** Dùng `$ARGUMENTS` là format chung hoạt động trên cả hai.

### 7. Tóm tắt nhanh

#### Agent config mapping

```
# Claude Code
name: my-agent
description: ...
tools: Read, Grep
model: sonnet
permissionMode: plan

→ OpenCode (đặt tay)  
description: ...
mode: subagent
model: anthropic/claude-sonnet-4-20250514
permission:
  edit: deny
  bash: deny
  read: allow
  grep: allow
```

#### File path mapping

| Component    | OpenCode                           | Claude Code             | Cross-compat                     |
| ------------ | ---------------------------------- | ----------------------- | -------------------------------- |
| Agent        | `.opencode/agents/`                | `.claude/agents/`       | OpenCode đọc `.claude/agents/`   |
| Skill        | `.opencode/skills/`                | `.claude/skills/`       | OpenCode đọc `.claude/skills/`   |
| Command      | `.opencode/commands/`              | `.claude/commands/`     | Không                            |
| Global skill | `~/.config/opencode/skills/`       | `~/.claude/skills/`     | OpenCode đọc `~/.claude/skills/` |
| Config       | `opencode.json` / `opencode.jsonc` | `.claude/settings.json` | Không                            |

#### Golden rule

> Muốn dùng cả hai → đặt cấu hình ở `.claude/`. OpenCode đọc được, Claude Code đọc được. Chỉ OpenCode-specific config (model, provider) mới để trong `opencode.json`.

**Tài liệu tham khảo:**

* [OpenCode Agents Docs](https://opencode.ai/docs/agents/)
* [OpenCode Skills Docs](https://opencode.ai/docs/skills/)
* [OpenCode Commands Docs](https://opencode.ai/docs/commands/)
* [Claude Code Sub-agents Docs](https://code.claude.com/docs/en/sub-agents)
* [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
* [Agent Skills Open Standard](https://agentskills.io)
