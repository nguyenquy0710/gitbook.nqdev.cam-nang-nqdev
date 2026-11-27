# CLAUDE.md

Before doing any significant work in this repository, read `AGENTS.md`.

- `AGENTS.md` is the canonical source of project knowledge (architecture, conventions, commands, gotchas).
- Do not duplicate project knowledge here — this file is only a pointer.
- Whenever you learn something durable about this project, update `AGENTS.md` accordingly.

## Agent guidance files

| File | Purpose |
|---|---|
| `AGENTS.md` | Canonical project knowledge (content tree, writing rules, image hosting, deploy) |
| `.claude/rules/code-rules.md` | Testing, comment, DB/Git/Workflow/Task policies — applies to every agent |
| `.claudeignore` | Files agents should not read (build artifacts, secrets, media) |
| `.rtk-usage.md` | Conventions for the `.rtk/` runtime scratch directory |

Skill guidance lives in `.opencode/skills/`; agents are declared in `.opencode/opencode.jsonc` + `.opencode/agents/*.md`.

## Local-only files (never committed)

| File | Purpose |
|---|---|
| `.env`, `.env.local` | Tokens (`GITBOOK_MCP_TOKEN`, `GITHUB_TOKEN`, `S3_001_TOKEN`); template in `.env.example` |
| `.claude/dev.local.json` | Per-dev comment label (current: `nqdev`) |

## Scratch directories

`draft/` chứa file nháp tạm (không commit), `draft/docs/` chứa nháp tài liệu; chỉ `.gitkeep` được commit.

`.rtk/` là thư mục runtime cho file tạm, cache và log khi chạy script/agent — nội dung không commit, xem `.rtk-usage.md`.

---

> ⚠️ **Database Safety** — Never run SQL against any database (CLI, ORM migration, MCP connector). Write DDL/DML into the chat prefixed with `-- NOT run by Claude — cần DBA review` and stop; a human DBA reviews and executes. Read-only `SELECT` is the only exemption. Details: `.claude/rules/code-rules.md` → Database Execution Policy.

> ⚠️ **Git Safety** — No `git commit` (including `--amend`), `git push`, force-push, `reset --hard`, branch/tag create-or-delete without explicit dev approval; ask again on every commit and state the file list + message. Details: `.claude/rules/code-rules.md` → Git Commit Policy.

> ⚠️ **Workflow Safety** — While discussing: analyse and clarify only, never write code. Write a plan (scope, files, steps), stop for approval, then code one task at a time inside the approved file list. Details: `.claude/rules/code-rules.md` → Development Workflow Policy and Task Execution Policy.
