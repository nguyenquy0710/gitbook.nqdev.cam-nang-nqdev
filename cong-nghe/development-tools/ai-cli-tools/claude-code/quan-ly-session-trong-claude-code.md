---
description: >-
  Quản lý cuộc hội thoại trong Claude Code: resume, rewind, checkpoints,
  branching, worktrees và cách quản lý context window hiệu quả.
---

# Quản lý Session trong Claude Code

Claude Code lưu mọi conversation locally. Bạn có thể resume, rewind, branch, và manage context xuyên suốt các session — giúp task phức tạp kéo dài nhiều ngày vẫn giữ được continuity.

## Session là gì?

Mỗi lần bạn chạy `claude` là một session mới. Session chứa:
* Toàn bộ conversation (messages, responses)
* Files đã đọc
* Command outputs
* Tool calls

Session được save locally và có thể resume bất cứ lúc nào.

## Resume session

### Tiếp tục session gần nhất

{% code title="Terminal" overflow="wrap" %}
```bash
claude --continue
```
{% endcode %}

Hoặc từ trong session:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/resume
```
{% endcode %}

### Chọn session từ list

{% code title="Terminal" overflow="wrap" %}
```bash
claude --resume
```
{% endcode %}

Hiển thị list các sessions trước đó để bạn chọn.

### Đặt tên session

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/rename oauth-migration
```
{% endcode %}

Đặt tên descriptive giúp tìm lại session sau này. Treat sessions như branches — mỗi workstream có persistent context riêng.

## Checkpoints và Rewind

Mỗi prompt bạn gửi tạo một checkpoint. Claude tự snapshot files trước mỗi change, nên checkpoint có thể restore cả conversation, code, hoặc cả hai.

### Rewind

{% code title="Claude Code" overflow="wrap" %}
```text
Esc + Esc
```
{% endcode %}

Hoặc:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/rewind
```
{% endcode %}

Rewind menu hiển thị list checkpoints. Bạn có thể:

* **Restore conversation only** — quay lại context tại thời điểm đó
* **Restore code only** — revert files về state tại checkpoint
* **Restore both** — cả conversation và code
* **Summarize from here** — tóm tắt từ thời điểm đó, giữ context gần
* **Summarize up to here** — tóm tắt trước đó, giữ context gần

{% hint style="info" %}
Thay vì plan carefully mọi move, hãy bảo Claude thử something risky. Nếu không work, rewind và thử approach khác. Checkpoints save với conversation — bạn có thể close terminal, resume sau, và vẫn rewind được.
{% endhint %}

{% hint style="warning" %}
Checkpoints chỉ track changes qua Claude's file editing tools. Changes qua Bash commands hoặc external processes **không được capture**. Đây không phải replacement cho git.
{% endhint %}

## Branching session

Tạo nhánh hội thoại mới để explore approach khác nhau mà không mất context hiện tại:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/branch
```
{% endcode %}

Branching hữu ích khi:
* Muốn thử 2 approaches khác nhau
* Đang làm task A nhưng cần research task B
* Muốn experiment mà không sợ mất context sạch

## /clear vs /compact

### /clear

Xóa toàn bộ context. Context window trở về trạng thái sạch.

**Dùng khi:**
* Chuyển task không liên quan
* Session quá dài, performance giảm
* Đã sửa hơn 2 lần cùng vấn đề — cần fresh start

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/clear
```
{% endcode %}

### /compact

Nén context hiện tại — giữ summary quan trọng, giải phóng space.

**Dùng khi:**
* Context gần đầy
* Muốn tiếp tục task hiện tại nhưng cần thêm space
* Muốn giữ context nhưng giảm token usage

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/compact
```
{% endcode %}

Có thể thêm hướng dẫn cho compact:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/compact Focus on the API changes
```
{% endcode %}

{% hint style="info" %}
Customize compaction behavior trong CLAUDE.md: `"When compacting, always preserve the full list of modified files and any test commands"`.
{% endhint %}

### So sánh

| Tính năng | `/clear` | `/compact` |
| --------- | -------- | ---------- |
| Xóa context | Hoàn toàn | Nén, giữ summary |
| Session tiếp tục | Cần re-explain | Tiếp tục với summary |
| Khi nào dùng | Switch task | Giữ task, thêm space |
| CLAUDE.md survives | Yes (re-reads từ disk) | Yes (re-reads từ disk) |

## Worktrees — chạy song song

Làm feature trong một terminal trong khi Claude fix bug trong terminal khác, không conflict:

{% code title="Terminal" overflow="wrap" %}
```bash
claude --worktree feature-auth
```
{% endcode %}

Mỗi worktree là git checkout riêng trên branch riêng. Chạy lệnh trên với tên khác trong terminal thứ 2 để start isolated parallel session.

{% hint style="warning" %}
Worktree yêu cầu ít nhất 1 commit trong repository. Nếu chưa có commit, lệnh sẽ fail.
{% endhint %}

## Quản lý Context Window

Context window là resource quan trọng nhất cần manage. Nó chứa:
* Prompts và responses
* Files đã đọc
* Command outputs
* Tool calls

### Theo dõi usage

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/context
```
{% endcode %}

Hiển thị breakdown context đang dùng.

### Quản lý context hiệu quả

* **Dùng subagents** để research trong context riêng
* **`/clear` giữa unrelated tasks**
* **`/compact` khi context gần đầy**
* **`/btw`** cho quick questions không cần giữ trong context

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/btw what's the default port for this API?
```
{% endcode %}

Câu trả lời xuất hiện trong dismissible overlay, không enter conversation history.

## Resume giữa các thiết bị

### Remote Control

Tiếp tục session từ phone hoặc browser khác:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/remote-control
```
{% endcode %}

### Teleport

Chuyển session từ web/mobile về terminal:

{% code title="Terminal" overflow="wrap" %}
```bash
claude --teleport
```
{% endcode %}

Teleport yêu cầu claude.ai subscription.

## Tài liệu tham khảo

* [Manage Sessions](https://code.claude.com/docs/en/sessions)
* [Checkpointing](https://code.claude.com/docs/en/checkpointing)
* [Context Window](https://code.claude.com/docs/en/context-window)
* [Worktrees](https://code.claude.com/docs/en/worktrees)
* [Remote Control](https://code.claude.com/docs/en/remote-control)
