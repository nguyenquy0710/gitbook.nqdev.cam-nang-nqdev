---
description: >-
  Tài liệu tổng hợp nhanh các lệnh, workflow và mẹo dùng [Claude Code
  Docs](https://code.claude.com/docs/en/commands) và CLI thực chiến.
---

# Claude Code Cheatsheet (2026)

## 1. Cài đặt

### Install

```
npm install -g @anthropic-ai/claude-code
```

### Update

```
claude update
```

### Kiểm tra cài đặt

```
claude doctor
```

***

## 2. Chạy Claude Code

### Interactive mode

```
claude
```

Mở phiên làm việc tương tác trong terminal.

***

### Start với prompt ban đầu

```
claude "Explain this repository"
```

***

### One-shot mode

```
claude -p "Fix TypeScript errors"
```

Chạy 1 lần rồi thoát.

Rất hữu ích cho:

* scripting
* CI/CD
* automation
* shell pipeline

***

### Pipe dữ liệu vào Claude

```
cat logs.txt | claude -p "Analyze this error log"
```

```
git diff | claude -p "Review this patch"
```

***

## 3. Session Management

### Continue phiên gần nhất

```
claude -c
```

### Continue + prompt mới

```
claude -c -p "Continue fixing tests"
```

### Resume bằng session ID

```
claude -r "session-id"
```

### Export conversation

```
/export
```

Hoặc:

```
/export session.md
```

***

## 4. Slash Commands Quan Trọng

### `/help`

Hiển thị toàn bộ commands.

***

### `/clear`

Xoá toàn bộ conversation context.

Alias:

* `/reset`
* `/new`

***

### `/compact`

Compress context hiện tại.

Tác dụng:

* giảm token usage
* giữ summary quan trọng
* tránh full context window

Có thể thêm hướng dẫn:

```
/compact focus on architecture decisions
```

***

### `/btw`

Hỏi câu phụ mà không pollute main context.

Ví dụ:

```
/btw where is the auth middleware?
```

***

### `/init`

Cho Claude scan repo và tạo:

```
CLAUDE.md
```

Rất nên chạy khi vào project mới.

***

### `/memory`

Quản lý project memory.

Thường dùng để refine:

* coding conventions
* architecture
* workflow
* commands

***

### `/permissions`

Cấu hình permission behavior.

Useful khi:

* cho phép auto edit
* auto run commands
* sandbox setup

***

### `/agents`

Quản lý subagents / agent configs.

***

### `/mcp`

Quản lý MCP servers.

```
https://code.claude.com/docs/en/mcp for help
```

`claude mcp list --scope project`

***

### `/diff`

Mở interactive diff viewer.

Cho phép:

* xem file changes
* xem per-turn diffs
* inspect generated edits

***

### `/doctor`

Diagnose installation và environment.

***

### `/sandbox`

Toggle sandbox mode.

***

### `/security-review`

Review security vulnerabilities trong diff hiện tại.

Useful trước khi merge PR.

***

## 6. Shell Mode

### Chạy shell command trực tiếp

```
!git status
```

```
!npm test
```

```
!docker ps
```

Dùng `!` để execute shell command mà không cần thoát Claude.

***

## 7. MCP (Model Context Protocol)

### Kiểm tra danh sách MCP hiện có

```bash
claude mcp list  
```

### Thêm MCP server qua HTTP

```bash
claude mcp add slim-tools \  
--transport http \  
'https://slim.tools/mcp'  
```

### Xoá MCP server

```bash
claude mcp remove slim-tools  
```

### Xác thực bằng API Key

```bash
claude mcp add slim-tools \  
--transport http \  
--auth-token YOUR_API_KEY \  
'https://slim.tools/mcp'  
```

### Xác thực bằng username/password

```bash
claude mcp add slim-tools \  
--transport http \  
--username YOUR_USER \  
--password YOUR_PASS \  
'https://slim.tools/mcp'  
```

***

## 8. CLAUDE.md Best Practices

### CLAUDE.md là gì?

Persistent project memory.

Claude sẽ load file này khi vào repo.

***

### Nên chứa gì?

#### Project structure

```
# Architecture- apps/web- packages/core- packages/ui
```

***

#### Coding conventions

```
# Rules- Use pnpm- Prefer functional components- Use zod for validation
```

***

#### Useful commands

```
# Commandspnpm testpnpm lintpnpm build
```

***

#### Workflow

```
# PR checklist- run tests- update docs- no console.log
```

***

## 9. Workflow Khuyên Dùng

### Khi vào repo mới

```
/init
```

Sau đó:

```
Analyze architecture first
```

***

### Khi context dài

```
/compact
```

***

### Khi Claude bắt đầu “ngu”

```
/clear
```

Rồi restate task ngắn gọn.

***

### Với task lớn

Chia phase:

```
Phase 1: analyzePhase 2: planPhase 3: implementPhase 4: test
```

***

### Với refactor nguy hiểm

Yêu cầu:

```
Make minimal changes
```

```
Do not change behavior
```

***

## 10. Tips Thực Chiến

### 1. Prompt tốt hơn

Bad:

```
Fix this
```

Good:

```
Fix failing tests without changing public API
```

***

### 2. Luôn yêu cầu plan trước

```
First explain your plan before editing files
```

***

### 3. Hạn chế hallucination

```
Do not invent APIs
```

```
Only use existing dependencies
```

***

### 4. Force search trước khi edit

```
Search the codebase first
```

***

### 5. Với monorepo

Add extra dirs:

```
claude --add-dir ../shared-lib
```

***

## 11. Automation Examples

### Git diff review

```
git diff main | claude -p "Review this PR"
```

***

### Generate commit message

```
git diff --staged | claude -p "Write a conventional commit message"
```

***

### Analyze logs

```
cat error.log | claude -p "Find root cause"
```

***

### Generate release notes

```
git log --oneline main..HEAD | claude -p "Generate release notes"
```

***

## 12. Context Window Tips

Context gồm:

* prompts
* responses
* opened files
* command outputs
* tool calls

Khi đầy:

* Claude sẽ compact
* hoặc quên context cũ

Dùng:

* `/compact`
* `/clear`
* task decomposition

***

## 13. Recommended Workflow

### Small fix

```
Explain bug→ ask plan→ implement→ run tests
```

***

### Feature lớn

```
analyze→ architecture proposal→ incremental implementation→ verification→ cleanup
```

***

### Safe refactor

```
write tests first→ refactor→ run tests→ review diff
```

***

## 14. Tài liệu chính thức

* [Claude Code Commands Docs](https://code.claude.com/docs/en/commands?utm_source=chatgpt.com)
* [Claude CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference?utm_source=chatgpt.com)
* [Claude Code Cheatsheet](https://support.claude.com/en/articles/14553413-claude-code-cheatsheet?utm_source=chatgpt.com)
* [Model Context Protocol](https://modelcontextprotocol.io/?utm_source=chatgpt.com)
