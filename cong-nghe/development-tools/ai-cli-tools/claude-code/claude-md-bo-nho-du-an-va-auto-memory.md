---
description: >-
  Cách viết CLAUDE.md hiệu quả, quản lý auto memory, tổ chức rules với
  .claude/rules/ và troubleshoot khi Claude không follow instructions.
---

# CLAUDE.md — Bộ nhớ dự án và Auto Memory trong Claude Code

Mỗi session Claude Code đều bắt đầu với context window mới. Hai cơ chế mang kiến thức xuyên suốt các session: **CLAUDE.md files** (bạn viết) và **Auto Memory** (Claude tự ghi). Hiểu và tận dụng hai cơ chế này giúp Claude làm việc chính xác hơn đáng kể.

## Tổng quan

{% tabs %}
{% tab title="CLAUDE.md files" %}
* **Ai viết:** Bạn
* **Nội dung:** Instructions và rules
* **Scope:** Project, user, hoặc org
* **Load vào:** Mỗi session
* **Dùng cho:** Coding standards, workflows, architecture
{% endtab %}

{% tab title="Auto Memory" %}
* **Ai viết:** Claude
* **Nội dung:** Learnings và patterns
* **Scope:** Per repository, share qua worktrees
* **Load vào:** Mỗi session (200 dòng đầu hoặc 25KB)
* **Dùng cho:** Build commands, debugging insights, preferences
{% endtab %}
{% endtabs %}

## Vị trí CLAUDE.md

CLAUDE.md có thể đặt ở nhiều vị trí, mỗi vị trí có scope khác nhau:

| Scope | Vị trí | Mục đích | Chia sẻ với |
| ----- | ------ | -------- | ----------- |
| **Managed policy** | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS), `/etc/claude-code/CLAUDE.md` (Linux) | Company-wide instructions | Tất cả users trong org |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences | Chỉ bạn (mọi project) |
| **Project** | `./CLAUDE.md` hoặc `./.claude/CLAUDE.md` | Team-shared instructions | Team qua git |
| **Local** | `./CLAUDE.local.md` | Personal project notes | Chỉ bạn (project hiện tại) |

{% hint style="warning" %}
Thêm `CLAUDE.local.md` vào `.gitignore` — file này chứa preferences cá nhân, không nên commit.
{% endhint %}

### Load order

Claude Code load CLAUDE.md theo thứ tự:
1. **Parent directories trước** — từ root đến working directory
2. **CLAUDE.local.md sau CLAUDE.md** —在同一 directory
3. **Subdirectories on-demand** — chỉ khi Claude đọc file trong thư mục đó

## Cách viết CLAUDE.md hiệu quả

### Nên và không nên đưa vào

| Nên đưa vào | Không nên đưa vào |
| ----------- | ----------------- |
| Bash commands Claude không guess được | Anything Claude tự đọc code biết được |
| Code style rules khác defaults | Standard language conventions |
| Testing instructions, preferred test runners | Detailed API documentation |
| Repo etiquette (branch naming, PR conventions) | Information thay đổi thường xuyên |
| Architecture decisions đặc thù project | Long explanations, tutorials |
| Developer environment quirks | File-by-file descriptions |
| Common gotchas, non-obvious behaviors | "Write clean code" |

{% hint style="info" %}
Target dưới 200 dòng mỗi file CLAUDE.md. File dài consuming more context và reduce adherence.
{% endhint %}

### Ví dụ CLAUDE.md

{% code title="CLAUDE.md" overflow="wrap" %}
```markdown
# Code style
- Use ES modules (import/export), not CommonJS (require)
- Destructure imports when possible
- Use 2-space indentation

# Workflow
- Run `pnpm lint` before committing
- Run `pnpm typecheck` after code changes
- Prefer running single tests, not whole test suite

# Architecture
- Monorepo with apps/web and packages/core
- API handlers live in src/api/handlers/
- Use zod for validation

# Git
- Branch naming: feature/, fix/, chore/
- Commit: conventional commits format
- No console.log in production code
```
{% endcode %}

### Import file với @ syntax

CLAUDE.md có thể import thêm files:

{% code title="CLAUDE.md" overflow="wrap" %}
```markdown
See @README.md for project overview and @package.json for available commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```
{% endcode %}

Import được expand và load vào context khi session start. Hỗ trợ relative và absolute paths, max depth 4 hops.

### Tạo CLAUDE.md với /init

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/init
```
{% endcode %}

`/init` phân tích codebase và tự tạo CLAUDE.md với build commands, test instructions, và project conventions. Nếu đã có CLAUDE.md, nó gợi ý improvements thay vì overwrite.

{% hint style="info" %}
Set `CLAUDE_CODE_NEW_INIT=1` để bật interactive multi-phase flow — `/init` sẽ hỏi cần setup artifact nào, explore codebase với subagent, và presentation proposal trước khi ghi file.
{% endhint %}

## Auto Memory

Auto Memory cho phép Claude tích lũy kiến thức xuyên suốt các session mà bạn không cần viết gì.

### Cách hoạt động

* Claude tự quyết định gì值得记忆 dựa trên corrections và preferences
* Lưu tại `~/.claude/projects/<project>/memory/`
* `MEMORY.md` acts as index, được load mỗi session (200 dòng đầu)
* Topic files (debugging.md, patterns.md...) chỉ load on-demand

### Bật/tắt Auto Memory

{% code title="settings.json" overflow="wrap" %}
```json
{
  "autoMemoryEnabled": true
}
```
{% endcode %}

Hoặc dùng environment variable:

{% code title="Terminal" overflow="wrap" %}
```bash
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude
```
{% endcode %}

### Audit và edit memory

Gõ `/memory` trong session để:
* Liệt kê tất cả CLAUDE.md và memory file locations
* Toggle auto memory on/off
* Mở auto memory folder để edit thủ công

Auto memory files là plain markdown — bạn có thể edit hoặc delete bất cứ lúc nào.

## Tổ chức rules với .claude/rules/

Cho projects lớn, organize instructions thành nhiều files trong `.claude/rules/`:

{% code title="Cấu trúc thư mục" overflow="wrap" %}
```text
your-project/
├── .claude/
│   ├── CLAUDE.md
│   └── rules/
│       ├── code-style.md
│       ├── testing.md
│       └── security.md
```
{% endcode %}

### Path-specific rules

Rules có thể scoped theo file paths bằng YAML frontmatter:

{% code title=".claude/rules/api-design.md" overflow="wrap" %}
```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All endpoints must include input validation
- Use standard error response format
- Include OpenAPI documentation comments
```
{% endcode %}

Rules có `paths` chỉ load khi Claude làm việc với files match pattern. Rules không có `paths` load unconditionally.

| Pattern | Match |
| ------- | ----- |
| `**/*.ts` | Tất cả file TypeScript |
| `src/**/*` | Tất cả files trong src/ |
| `*.md` | Markdown files trong project root |

### User-level rules

Personal rules tại `~/.claude/rules/` apply cho mọi project:

{% code title="~/.claude/rules/" overflow="wrap" %}
```text
~/.claude/rules/
├── preferences.md
└── workflows.md
```
{% endcode %}

User-level rules load trước project rules — project rules có higher priority.

## Troubleshoot

### Claude không follow CLAUDE.md

1. Chạy `/context` để verify CLAUDE.md đã load
2. Kiểm tra file có ở đúng vị trí không
3. Instructions có quá vague không? Thay `"Format code nicely"` bằng `"Use 2-space indentation"`
4. Có conflicting instructions giữa các CLAUDE.md files không?

{% hint style="info" %}
Nếu instruction phải chạy tại thời điểm nhất định (trước mỗi commit, sau mỗi file edit), dùng **hooks** thay vì CLAUDE.md. Hooks execute deterministic, không phụ thuộc Claude decide.
{% endhint %}

### CLAUDE.md quá lớn

* Target dưới 200 dòng
* Dùng path-scoped rules để load instructions only khi cần
* Split content với `@path` imports (nhưng imported files vẫn load vào context)

### Instructions mất sau /compact

Project-root CLAUDE.md **survives compaction** — Claude re-reads từ disk sau `/compact`. Nhưng nested CLAUDE.md files trong subdirectories **không re-inject tự động** — chúng reload khi Claude đọc file trong thư mục đó.

## Tài liệu tham khảo

* [Memory Documentation](https://code.claude.com/docs/en/memory)
* [Skills](https://code.claude.com/docs/en/skills)
* [Settings](https://code.claude.com/docs/en/settings)
* [Debug Your Config](https://code.claude.com/docs/en/debug-your-config)
