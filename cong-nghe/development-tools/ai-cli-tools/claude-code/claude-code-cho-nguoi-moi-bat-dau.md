---
description: >-
  Hướng dẫn toàn diện cho người mới: từ đặt câu hỏi đầu tiên đến quản lý
  permission, git workflow và best practices khi dùng Claude Code.
---

# Claude Code cho người mới bắt đầu

Claude Code là một AI coding agent chạy trực tiếp trong terminal. Nó đọc được toàn bộ codebase, sửa file, chạy lệnh và giúp bạn hoàn thành task — tất cả bằng ngôn ngữ tự nhiên. Bài này hướng dẫn từ zero đến làm việc hiệu quả.

## Claude Code là gì?

Claude Code không phải chatbot thông thường. Nó là **agentic coding tool** — có thể đọc file, chạy command, sửa code, tạo commit, và tự giải quyết vấn đề trong khi bạn quan sát hoặc rời đi.

* **Terminal CLI:** đầy đủ tính năng, phù hợp power user
* **IDE extension:** VS Code, JetBrains — inline diffs, @-mentions
* **Desktop app:** visual diff, multi-session, scheduled tasks
* **Web:** chạy trên browser, cloud sessions

{% hint style="info" %}
Claude Code hoạt động trên cùng một engine ở mọi surface. CLAUDE.md, settings, và MCP servers được share xuyên suốt.
{% endhint %}

## Bắt đầu làm việc

Sau khi cài đặt (xem [Hướng dẫn cài đặt](huong-dan-cai-dat-va-bat-dau-voi-claude-code.md)), mở terminal trong thư mục dự án:

{% code title="Terminal" overflow="wrap" %}
```bash
cd /path/to/your/project
claude
```
{% endcode %}

Giao diện hiện ra với version, model, và working directory. Bây giờ bạn có thể đặt câu hỏi:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what does this project do?
```
{% endcode %}

Claude sẽ phân tích files và trả lời. Thử thêm:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what technologies does this project use?
where is the main entry point?
explain the folder structure
```
{% endcode %}

{% hint style="info" %}
Claude tự đọc project files khi cần. Bạn không cần thêm context thủ công.
{% endhint %}

## Các lệnh shell cơ bản

Đây là các lệnh chạy từ terminal để khởi động hoặc quản lý Claude Code:

| Lệnh | Tác dụng | Ví dụ |
| ----- | -------- | ----- |
| `claude` | Khởi động interactive mode | `claude` |
| `claude "task"` | Chạy 1 task rồi thoát | `claude "fix the build error"` |
| `claude -p "query"` | Chạy query rồi exit | `claude -p "explain this function"` |
| `claude -c` | Tiếp tục session gần nhất | `claude -c` |
| `claude -r` | Chọn session để resume | `claude -r` |

### One-shot mode với pipe

{% code title="Terminal" overflow="wrap" %}
```bash
cat error.log | claude -p "Explain this error"
git diff | claude -p "Review this patch"
git log --oneline -20 | claude -p "summarize these recent commits"
```
{% endcode %}

Rất hữu ích cho scripting, CI/CD, và automation.

## Slash commands thiết yếu

Bên trong Claude Code, gõ `/` để xem toàn bộ commands. Đây là các lệnh quan trọng nhất:

| Command | Tác dụng |
| ------- | -------- |
| `/help` | Hiển thị tất cả commands |
| `/clear` | Xóa toàn bộ conversation context |
| `/compact` | Nén context để tiết kiệm token |
| `/init` | Tạo file CLAUDE.md cho project |
| `/memory` | Quản lý project memory |
| `/context` | Xem mức sử dụng context |
| `/diff` | Xem các thay đổi hiện tại |
| `/resume` | Chọn session trước đó để tiếp tục |
| `/login` | Đăng nhập lại hoặc chuyển tài khoản |
| `/exit` hoặc `Ctrl+D`×2 | Thoát Claude Code |

{% hint style="warning" %}
`/clear` xóa toàn bộ context — dùng giữa các task không liên quan để giữ performance tốt.
{% endhint %}

## Permission modes

Claude Code có 4 chế độ permission, quyết định khi nào cần hỏi bạn trước khi thực thi:

| Mode | Mô tả |
| ---- | ----- |
| **default** | Hỏi trước mỗi thay đổi file/command |
| **acceptEdits** | Tự động approve file edits, vẫn hỏi về bash |
| **plan** | Chỉ đọc và đề xuất, không sửa file |
| **auto** | Classifier tự review, block lệnh risky |

Nhấn `Shift+Tab` để chuyển giữa các mode. Thanh trạng thái hiển thị mode hiện tại.

{% hint style="info" %}
Bắt đầu với **default** để hiểu cách Claude hoạt động. Khi quen, chuyển **acceptEdits** hoặc **auto** để tăng tốc.
{% endhint %}

## Làm việc với Git

Claude Code tích hợp sâu với Git. Bạn có thể yêu cầu bằng ngôn ngữ tự nhiên:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what files have I changed?
commit my changes with a descriptive message
create a new branch called feature/quickstart
show me the last 5 commits
help me resolve merge conflicts
```
{% endcode %}

Claude sẽ:
1. Chạy `git status`, `git diff` để hiểu thay đổi
2. Tạo commit message mô tả
3. Stage files và commit
4. Push nếu bạn yêu cầu

## Sử dụng @ reference files

Thay vì mô tả đường dẫn, dùng `@` để include trực tiếp file hoặc directory vào conversation:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Explain the logic in @src/utils/auth.js
What's the structure of @src/components?
```
{% endcode %}

* `@path/to/file` — include toàn bộ nội dung file
* `@path/to/dir` — hiển thị directory listing
* Gõ `@` để mở suggestion menu, Enter để accept

## Dùng images trong Claude Code

Bạn có thể paste screenshot hoặc drag-and-drop image vào Claude Code:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
[paste screenshot] What does this error mean?
Generate CSS to match this design mockup
```
{% endcode %}

Hoặc reference file image:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Analyze this image: /path/to/screenshot.png
```
{% endcode %}

## Mẹo cho người mới

### Be specific

{% tabs %}
{% tab title="Không nên" %}
{% code title="Prompt không tốt" overflow="wrap" %}
```text
fix the bug
```
{% endcode %}
{% endtab %}

{% tab title="Nên" %}
{% code title="Prompt tốt" overflow="wrap" %}
```text
fix the login bug where users see a blank screen
after entering wrong credentials
```
{% endcode %}
{% endtab %}
{% endtabs %}

### Break tasks thành steps

{% code title="Claude Code prompt" overflow="wrap" %}
```text
1. create a new database table for user profiles
2. create an API endpoint to get and update user profiles
3. build a webpage that allows users to see and edit their information
```
{% endcode %}

### Để Claude explore trước khi code

{% code title="Claude Code prompt" overflow="wrap" %}
```text
analyze the database schema first
then implement the migration
```
{% endcode %}

### Course-correct sớm

* **`Esc`**: dừng Claude giữa chừng, giữ context
* **`Esc + Esc`** hoặc **`/rewind`**: quay lại checkpoint trước
* **"Undo that"**: yêu cầu revert changes

{% hint style="danger" %}
Nếu đã sửa hơn 2 lần cùng một vấn đề trong session, dùng `/clear` và viết prompt mới tốt hơn. Session dài với corrections nhiều sẽ giảm performance.
{% endhint %}

### Tóm tắt workflow cho người mới

1. **cd vào project** → `claude`
2. **Explore**: `give me an overview of this codebase`
3. **Task**: mô tả task bằng ngôn ngữ tự nhiên
4. **Verify**: yêu cầu chạy test/lint sau khi sửa
5. **Commit**: `commit my changes`
6. **Clear**: `/clear` khi chuyển task mới

## Tài liệu tham khảo

* [Quickstart](https://code.claude.com/docs/en/quickstart)
* [Common Workflows](https://code.claude.com/docs/en/common-workflows)
* [Best Practices](https://code.claude.com/docs/en/best-practices)
* [Commands Reference](https://code.claude.com/docs/en/commands)
