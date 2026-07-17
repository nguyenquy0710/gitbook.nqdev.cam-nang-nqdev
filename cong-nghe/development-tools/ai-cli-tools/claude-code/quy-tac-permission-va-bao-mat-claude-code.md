---
description: >-
  Permission modes, allowlist/denylist, sandboxing, auto mode và best
  practices bảo mật khi dùng Claude Code trong dự án thực tế.
---

# Quy tắc Permission và Bảo mật trong Claude Code

Claude Code có thể sửa file, chạy lệnh, và thực thi thay đổi trên hệ thống. Hệ thống permission đảm bảo bạn luôn control được những gì Claude được phép làm — từ basic approval đến OS-level sandboxing.

## Permission modes

Claude Code có 4 chế độ permission, quyết định tần suất hỏi bạn trước khi thực thi:

| Mode | Mô tả | Khi nào dùng |
| ---- | ----- | ------------- |
| **default** | Hỏi trước mỗi file edit và bash command | Bắt đầu, khi cần control chặt |
| **acceptEdits** | Tự động approve file edits, vẫn hỏi về bash | Đã tin tưởng Claude sửa file |
| **plan** | Chỉ đọc và đề xuất, không sửa gì | Research, explore, trước khi implement |
| **auto** | Classifier tự review, block chỉ risky actions | Đã quen, muốn tốc độ cao |

### Chuyển mode

Nhấn `Shift+Tab` để cycle giữa các modes. Thanh trạng thái hiển thị mode hiện tại:

{% code title="Claude Code" overflow="wrap" %}
```text
⏸ plan mode on
```
{% endcode %}

Hoặc start session với mode cụ thể:

{% code title="Terminal" overflow="wrap" %}
```bash
claude --permission-mode plan
claude --permission-mode auto
```
{% endcode %}

{% hint style="info" %}
Bắt đầu với **default** để hiểu cách Claude hoạt động. Khi quen, chuyển **acceptEdits** để tăng tốc. Dùng **plan** khi research, **auto** khi đã tin tưởng.
{% endhint %}

## Permission rules

Rules được config trong `settings.json` tại `permissions.allow` và `permissions.deny`.

### Allow list

Các tools và commands Claude được phép dùng **không cần hỏi**:

{% code title="settings.json" overflow="wrap" %}
```json
{
  "permissions": {
    "allow": [
      "Glob",
      "Grep",
      "Read",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm test:*)",
      "Bash(npm run lint:*)"
    ]
  }
}
```
{% endcode %}

* **Built-in tools:** `Glob`, `Grep`, `Read`, `ToolSearch` — read-only, an toàn
* **Bash patterns:** `Bash(git status)` — đúng lệnh cụ thể
* **Wildcard:** `Bash(git diff:*)` — git diff với bất kỳ arguments

### Deny list

Các tools và commands Claude **tuyệt đối KHÔNG được phép**:

{% code title="settings.json" overflow="wrap" %}
```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push)",
      "Bash(npm publish)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)",
      "Read(./node_modules/**)",
      "Read(./dist/**)",
      "Read(./.next/**)"
    ]
  }
}
```
{% endcode %}

{% hint style="danger" %}
Luôn deny file nhạy cảm (.env, secrets, credentials) và destructive commands (rm -rf, git push, npm publish). Đây là layers bảo mật cuối cùng.
{% endhint %}

### Wildcard patterns

| Pattern | Match |
| ------- | ----- |
| `Bash(git status)` | Đúng lệnh `git status` |
| `Bash(git diff:*)` | `git diff` với bất kỳ args |
| `Bash(pnpm lint:*)` | `pnpm lint` với bất kỳ args |
| `Read(./.env.*)` | Any file starts with `.env.` |
| `Read(./secrets/**)` | Any file trong secrets/ và subdirectories |

## Sandbox mode

Sandboxing enable OS-level isolation — restrict filesystem và network access:

{% code title="settings.json" overflow="wrap" %}
```json
{
  "sandbox": {
    "enabled": true
  }
}
```
{% endcode %}

Sandbox cho phép Claude work tự do hơn trong boundaries đã define mà không cần approve mỗi action.

{% hint style="info" %}
Sandboxing chỉ supported trên WSL 2 và Linux. Native Windows không hỗ trợ sandboxing.
{% endhint %}

## Auto mode

Auto mode dùng classifier model review commands trước khi chạy. Chỉ block scope escalation, unknown infrastructure, và hostile-content-driven actions. Mọi thứ khác proceed without prompts.

{% code title="Terminal" overflow="wrap" %}
```bash
claude --permission-mode auto -p "fix all lint errors"
```
{% endcode %}

### Khi nào dùng auto

* **Task lặp lại:** lint fix, dependency update, refactor theo pattern
* **CI/CD pipeline:** `claude -p` trong automation
* **Đã verify direction:** biết task đúng scope, chỉ cần execute

### Fallback behavior

Khi classifier repeatedly block actions trong non-interactive mode (`-p`), auto mode abort — không có user để fallback. Trong interactive mode, nó sẽ hỏi bạn.

## Managed settings cho team

Organizations có thể deploy managed settings apply cho tất cả users:

| Setting | Ví dụ | Mục đích |
| ------- | ----- | -------- |
| `permissions.deny` | `Bash(rm -rf *)` | Block destructive commands |
| `sandbox.enabled` | `true` | Force sandbox |
| `forceLoginMethod` | `"claude"` | Bắt buộc login method |
| `requiredMinimumVersion` | `"2.1.100"` | Minimum version floor |

Managed settings **không thể override** bởi user hoặc project settings.

## Best practices bảo mật

### Bắt đầu an toàn

1. **Bắt đầu với default mode** — approve mỗi action
2. **Dần chuyển acceptEdits** khi tin Claude sửa file
3. **Chuyển auto** khi đã verify workflow
4. **Luôn deny** .env, secrets, destructive commands

### Cấu hình deny list chuẩn

{% code title="settings.json" overflow="wrap" %}
```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push)",
      "Bash(git push:*)",
      "Bash(npm publish)",
      "Bash(npm publish:*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)",
      "Read(./node_modules/**)",
      "Read(./dist/**)",
      "Read(./build/**)",
      "Read(./coverage/**)",
      "Read(./.next/**)"
    ]
  }
}
```
{% endcode %}

### Review permissions thường xuyên

* Chạy `/permissions` để xem current permission rules
* Kiểm tra deny list có đủ broad không
* Đảm bảo không có permission quá rộng trong allow list
* Với team: dùng managed settings để enforce policy

### Với CI/CD

{% code title="Terminal" overflow="wrap" %}
```bash
git diff main | claude -p "Review for security issues" \
  --allowedTools "Read,Grep,Glob"
```
{% endcode %}

Dùng `--allowedTools` để scope permissions khi chạy non-interactive.

## Tài liệu tham khảo

* [Permissions](https://code.claude.com/docs/en/permissions)
* [Permission Modes](https://code.claude.com/docs/en/permission-modes)
* [Sandboxing](https://code.claude.com/docs/en/sandboxing)
* [Settings](https://code.claude.com/docs/en/settings)
