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

### Chỉnh cấu hình `settings.json`

* pre-tool hook
* status line live

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

#### Thêm MCP server

**Add server vào workspace hiện tại:**

```bash
claude mcp add <server_name> <server_url>
```

*   \*\*Ví dụ:

    * Thêm `slim-tools` server:

    ```bash
    claude mcp add slim-tools https://slim.tools/mcp
    ```

    * Thêm Atlassian MCP server với HTTP transport và API token:

    ```bash
    claude mcp add atlassian https://mcp.atlassian.com/v1/mcp \
      --transport http \
      --header "Authorization: Basic $(echo -n 'your-*****@gmail.com:your-api-token' | base64)" \
      --scope user
    ```

    * Thêm với username/password:

    ```bash
    claude mcp add my-server https://my-mcp.com \
      --transport http \
      --username YOUR_USER \
      --password YOUR_PASS
    ```

#### Xoá MCP server

**Remove server khỏi workspace hiện tại:**

```bash
claude mcp remove <server_name>
```

*   **Ví dụ:**

    ```bash
    claude mcp remove slim-tools
    ```

#### Kiểm tra MCP server

Xem danh sách MCP server đã add:

```bash
claude mcp list              # scope user (mặc định)
claude mcp list --scope project  # scope project
```

> **Lưu ý:** Nếu hiện `Needs authentication` khi add Atlassian MCP server, server chính thức (mcp.atlassian.com) **chỉ hỗ trợ OAuth**, không nhận API token trực tiếp. Cần dùng MCP server thay thế hỗ trợ API token.

***

### `/diff`

Mở interactive diff viewer trong terminal.

Cho phép:

* **xem file changes** — toàn bộ file đã sửa trong session
* **per-turn diffs** — xem thay đổi theo từng turn
* **inspect generated edits** — kiểm tra diff trước khi apply
* **staged diffs** — xem changes đã stage cho commit

Phím tắt trong diff viewer:

* `j/k` — điều hướng lên/xuống
* `q` — đóng viewer
* `/` — search trong diff

Hữu ích để review trước khi commit hoặc kiểm tra Claude đã sửa đúng chưa.

***

### `/doctor`

Diagnose installation và environment. Tương tự `claude doctor` CLI.

Kiểm tra:

* **Node.js version** — có đúng runtime không
* **CLI installation** — claude-code binary có hoạt động không
* **Git config** — user.name, user.email đã set chưa
* **MCP servers** — kiểm tra kết nối các MCP server đã add
* **Permissions** — sandbox mode, file permissions
* **Disk space** — đủ cho context cache
* **Proxy/Network** — nếu dùng qua corporate network

Dùng khi:

* Claude không khởi động được
* MCP server báo lỗi kết nối
* Cần debug environment trước khi report issue

***

### `/sandbox`

Toggle sandbox mode.

***

### `/security-review`

Review security vulnerabilities trong diff hiện tại.

Công cụ này **chỉ hoạt động với các diff mới được tạo ra** (ví dụ: sau `git diff` hoặc ngay trước khi commit).

Nó sẽ scan code diff để tìm các lỗ hổng tiềm ẩn như:

* **Injection vulnerabilities**: SQL injection, Command injection, XSS.
* **Sensitive data exposure**: Credentials, API keys bị lộ.
* **Insecure Deserialization**.
* **Use of insecure or outdated libraries**.
* **Hardcoded secrets**.

Dùng trước khi:

* Commit code mới
* Tạo Pull Request
* Push code lên production

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

### Atlassian MCP — API Token (HTTP transport)

Cài Atlassian MCP server dùng HTTP transport thay vì SSE:

```bash
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp \
  --header "Authorization: Basic $(echo -n 'your-*****@gmail.com:your-api-token' | base64)" \
  --scope user
```

Thay `your-*****@gmail.com` và `your-api-token` bằng thông tin thực. Ví dụ:

```bash
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp \
  --header "Authorization: Basic $(echo -n 'nhq****@gmail.com:ATATT3x...' | base64)" \
  --scope user
```

#### Windows PowerShell — base64

Trên PowerShell, lệnh base64 khác:

```powershell
$cred = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("your-*****@gmail.com:your-api-token"))
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp --header "Authorization: Basic $cred" --scope user
```

#### Kiểm tra

```bash
claude mcp list
```

> **Lưu ý:** Nếu hiện `Needs authentication`, Atlassian MCP server chính thức (mcp.atlassian.com) **chỉ hỗ trợ OAuth**, không nhận API token trực tiếp. Trong trường hợp đó cần dùng MCP server thay thế hỗ trợ API token.

***

## 8. CLAUDE.md Best Practices

### CLAUDE.md là gì?

Persistent project memory.

Claude sẽ load file này khi vào repo.

***

### Nên chứa gì?

#### Project structure

```markdown
# Architecture
- apps/web
- packages/core
- packages/ui
```

***

#### Coding conventions

```markdown
# Rules
- Use pnpm
- Prefer functional components
- Use zod for validation
```

***

#### Useful commands

```markdown
# Commands
pnpm test
pnpm lint
pnpm build
```

***

#### Workflow

```markdown
# PR checklist
- run tests
- update docs
- no console.log
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
Phase 1: analyze
Phase 2: plan
Phase 3: implement
Phase 4: test
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
Explain bug → ask plan → implement → run tests
```

***

### Feature lớn

```
analyze → architecture proposal → incremental implementation → verification → cleanup
```

***

### Safe refactor

```
write tests first → refactor → run tests → review diff
```

***

## 14. Tài liệu chính thức

* [Claude Code Commands Docs](https://code.claude.com/docs/en/commands?utm_source=chatgpt.com)
* [Claude CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference?utm_source=chatgpt.com)
* [Claude Code Cheatsheet](https://support.claude.com/en/articles/14553413-claude-code-cheatsheet?utm_source=chatgpt.com)
* [Model Context Protocol](https://modelcontextprotocol.io/?utm_source=chatgpt.com)

***
