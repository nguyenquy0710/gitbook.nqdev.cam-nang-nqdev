---
description: >-
  Tổng hợp các lệnh CLI và slash command hữu ích nhất trong Claude Code,
  giúp lập trình viên quản lý context, review code và làm việc Git hiệu quả.
---

# Các lệnh Claude Code hữu ích nhất cho lập trình viên

Claude Code cung cấp hai loại lệnh chính: **CLI commands** (chạy từ terminal) và **slash commands** (dùng bên trong phiên làm việc). Việc nắm vững cả hai sẽ giúp bạn làm việc nhanh hơn, quản lý context hiệu quả và tích hợp Claude Code vào quy trình Dev hàng ngày.

***

## CLI Commands

Đây là các lệnh chạy trực tiếp từ terminal, trước hoặc trong khi khởi động Claude Code.

### `claude` — Mở Claude Code

Khởi động một phiên làm việc tương tác mới trong terminal.

{% code title="Mở Claude Code" overflow="wrap" %}
```bash
claude
```
{% endcode %}

{% hint style="info" %}
Bạn có thể thêm prompt ban đầu ngay sau lệnh: `claude "Explain this repository"` để Claude bắt đầu phân tích ngay khi mở.
{% endhint %}

***

### `claude update` — Cập nhật phiên bản mới

Giữ Claude Code luôn ở phiên bản mới nhất với các tính năng và fix mới nhất.

{% code title="Cập nhật Claude Code" overflow="wrap" %}
```bash
claude update
```
{% endcode %}

***

### `claude -c` — Tiếp tục phiên gần nhất

Tái sử dụng session trước đó, rất hữu ích khi bạn đã thoát Claude Code giữa chừng và muốn quay lại làm tiếp.

{% code title="Tiếp tục phiên trước đó" overflow="wrap" %}
```bash
claude -c
```
{% endcode %}

Kết hợp với prompt mới để tiếp tục task cụ thể:

{% code title="Continue + prompt mới" overflow="wrap" %}
```bash
claude -c -p "Continue fixing the failing tests"
```
{% endcode %}

***

### `claude -r <session-id>` — Mở session cụ thể

Resume một session bất kỳ bằng session ID. Hữu ích khi bạn muốn quay lại một cuộc trò chuyện đã lưu.

{% code title="Resume session theo ID" overflow="wrap" %}
```bash
claude -r "abc123-def456"
```
{% endcode %}

***

### `claude -p "prompt"` — Chạy prompt rồi thoát (One-shot mode)

Chạy một prompt duy nhất, nhận kết quả và thoát. Đây là chế độ lý tưởng cho scripting, CI/CD và automation.

{% code title="One-shot mode" overflow="wrap" %}
```bash
claude -p "Fix TypeScript errors in src/"
```
{% endcode %}

{% hint style="warning" %}
One-shot mode không giữ context giữa các lần chạy. Nếu cần context liên tục, hãy dùng interactive mode với `claude -c`.
{% endhint %}

***

### Pipe dữ liệu vào Claude

Kết hợp `cat` hoặc `git diff` với `claude -p` để phân tích dữ liệu đầu vào.

{% tabs %}
{% tab title="Phân tích log lỗi" %}
{% code title="Đọc log và giải thích lỗi" overflow="wrap" %}
```bash
cat error.log | claude -p "Explain this error"
```
{% endcode %}
{% endtab %}
{% tab title="Review code thay đổi" %}
{% code title="Review git diff" overflow="wrap" %}
```bash
git diff | claude -p "Review this patch for bugs"
```
{% endcode %}
{% endtab %}
{% tab title="Phân tích commit" %}
{% code title="Tạo commit message từ diff" overflow="wrap" %}
```bash
git diff --staged | claude -p "Write a conventional commit message"
```
{% endcode %}
{% endtab %}
{% tab title="Phân tích log Git" %}
{% code title="Tạo release notes" overflow="wrap" %}
```bash
git log --oneline main..HEAD | claude -p "Generate release notes"
```
{% endcode %}
{% endtab %}
{% endtabs %}

***

### `claude mcp` — Quản lý MCP servers

Quản lý Model Context Protocol servers — cơ chế mở rộng khả năng của Claude Code qua các server bên ngoài.

{% tabs %}
{% tab title="Thêm server" %}
{% code title="Thêm MCP server mới" overflow="wrap" %}
```bash
claude mcp add <server_name> <server_url>
```
{% endcode %}

Ví dụ thực tế:

{% code title="Thêm Atlassian MCP với HTTP transport" overflow="wrap" %}
```bash
claude mcp add atlassian https://mcp.atlassian.com/v1/mcp \
  --transport http \
  --header "Authorization: Basic $(echo -n 'user@gmail.com:api-token' | base64)" \
  --scope user
```
{% endcode %}
{% endtab %}
{% tab title="Xem danh sách" %}
{% code title="Liệt kê các MCP server" overflow="wrap" %}
```bash
claude mcp list              # scope user (mặc định)
claude mcp list --scope project  # scope project
```
{% endcode %}
{% endtab %}
{% tab title="Xoá server" %}
{% code title="Xoá MCP server" overflow="wrap" %}
```bash
claude mcp remove <server_name>
```
{% endcode %}
{% endtab %}
{% endtabs %}

***

## Slash Commands

Đây là các lệnh dùng bên trong phiên làm việc Claude Code (interactive mode). Gõ `/` kèm tên lệnh để thực thi.

### `/help` — Hiển thị tất cả lệnh

Hiển thị danh sách toàn bộ slash commands hiện có.

{% code title="Xem danh sách lệnh" overflow="wrap" %}
```
/help
```
{% endcode %}

***

### `/init` — Tạo CLAUDE.md cho dự án

Yêu cầu Claude scan repo và tạo file `CLAUDE.md` — project memory persistent. Đây là lệnh **đầu tiên nên chạy** khi bắt đầu làm việc với một repo mới.

{% code title="Khởi tạo project memory" overflow="wrap" %}
```
/init
```
{% endcode %}

File `CLAUDE.md` thường chứa:

* **Project structure:** Cấu trúc thư mục chính
* **Coding conventions:** Quy tắc code, style guide
* **Useful commands:** Lệnh build, test, lint
* **Architecture:** Kiến trúc và quyết định thiết kế quan trọng

{% hint style="success" %}
Sau khi tạo `CLAUDE.md`, hãy chỉnh sửa thủ công để bổ sung thông tin chính xác mà Claude có thể chưa detect được.
{% endhint %}

***

### `/clear` — Xoá toàn bộ context

Xoá sạch conversation context hiện tại. Dùng khi Claude bắt đầu "ngu" hoặc bạn muốn bắt đầu task mới hoàn toàn.

{% code title="Xoá context" overflow="wrap" %}
```
/clear
```
{% endcode %}

Alias: `/reset`, `/new`

***

### `/compact` — Nén context để tiết kiệm token

Compress context hiện tại, giữ lại các thông tin quan trọng và loại bỏ chi tiết thừa. Rất hữu ích khi context window sắp đầy.

{% code title="Nén context" overflow="wrap" %}
```
/compact
```
{% endcode %}

Có thể thêm hướng dẫn nén:

{% code title="Nén context với hướng dẫn" overflow="wrap" %}
```
/compact focus on architecture decisions
```
{% endcode %}

{% hint style="info" %}
`/compact` giúp bạn tiết kiệm token và tránh bị full context window, nhưng vẫn giữ được tóm tắt quan trọng của cuộc trò chuyện.
{% endhint %}

***

### `/review` — Review code hoặc PR

Yêu cầu Claude review code hiện tại hoặc toàn bộ thay đổi.

{% code title="Review code" overflow="wrap" %}
```
/review
```
{% endcode %}

***

### `/commit` — Tạo git commit

Tạo commit message và thực hiện commit trực tiếp từ Claude Code.

{% code title="Tạo commit" overflow="wrap" %}
```
/commit
```
{% endcode %}

***

### `/diff` — Xem thay đổi hiện tại

Mở interactive diff viewer trong terminal để xem toàn bộ file đã sửa trong session.

{% code title="Xem diff" overflow="wrap" %}
```
/diff
```
{% endcode %}

Phím tắt trong diff viewer:

* **j/k** — điều hướng lên/xuống
* **q** — đóng viewer
* **/** — search trong diff

***

### `/config` — Mở cấu hình

Truy cập menu cấu hình của Claude Code.

{% code title="Mở cấu hình" overflow="wrap" %}
```
/config
```
{% endcode %}

***

### `/model` — Đổi mô hình

Chuyển đổi sang mô hình AI khác đang khả dụng.

{% code title="Đổi model" overflow="wrap" %}
```
/model
```
{% endcode %}

{% hint style="info" %}
Bạn có thể dùng `/model` để switch giữa các model khi cần cân nhắc giữa tốc độ và chất lượng phản hồi.
{% endhint %}

***

### `/usage` — Xem mức sử dụng token

Hiển thị thống kê token đã sử dụng trong phiên hiện tại.

{% code title="Xem token usage" overflow="wrap" %}
```
/usage
```
{% endcode %}

***

### `/upgrade` — Mở trang nâng cấp

Mở trang upgrade trên trình duyệt để cập nhật phiên bản mới.

{% code title="Mở trang upgrade" overflow="wrap" %}
```
/upgrade
```
{% endcode %}

***

### `/memory` — Quản lý project memory

Quản lý nội dung trong `CLAUDE.md`. Dùng để cập nhật coding conventions, architecture, workflow.

{% code title="Quản lý memory" overflow="wrap" %}
```
/memory
```
{% endcode %}

***

### `/agents` — Quản lý Agents

Quản lý subagents và cấu hình agent.

{% code title="Quản lý agents" overflow="wrap" %}
```
/agents
```
{% endcode %}

***

### `/permissions` — Thiết lập quyền thực thi

Cấu hình permission cho các thao tác: auto edit, auto run commands, sandbox mode.

{% code title="Cấu hình permissions" overflow="wrap" %}
```
/permissions
```
{% endcode %}

***

### `/context` — Xem mức sử dụng context

Hiển thị thông tin chi tiết về context window đang dùng.

{% code title="Xem context usage" overflow="wrap" %}
```
/context
```
{% endcode %}

***

### `/rewind` — Quay lại checkpoint trước

Đưa trạng thái code về checkpoint trước đó. Rất hữu ích khi muốn undo thay đổi mà Claude đã thực hiện.

{% code title="Quay lại checkpoint" overflow="wrap" %}
```
/rewind
```
{% endcode %}

{% hint style="warning" %}
`/rewind` sẽ undo các thay đổi file mà Claude đã thực hiện. Hãy dùng `/diff` trước để xem xét thay đổi trước khi rewind.
{% endhint %}

***

### `/branch` — Tạo nhánh hội thoại mới

Tạo một nhánh mới từ điểm hiện tại trong cuộc trò chuyện, cho phép thử nghiệm mà không mất context gốc.

{% code title="Tạo nhánh mới" overflow="wrap" %}
```
/branch
```
{% endcode %}

***

### `/btw` — Hỏi câu phụ

Đặt một câu hỏi phụ mà không làm ô nhiễm main context. Rất hữu ích khi bạn đang trong một task lớn và có thắc mắc nhanh.

{% code title="Hỏi câu phụ" overflow="wrap" %}
```
/btw where is the auth middleware?
```
{% endcode %}

{% hint style="info" %}
`/btw` giúp bạn giữ main context sạch — câu hỏi phụ và câu trả lời sẽ không ảnh hưởng đến task chính đang xử lý.
{% endhint %}

***

## Lệnh được dùng nhiều nhất

Dưới đây là các lệnh mà developer sử dụng thường xuyên nhất, sắp xếp theo tần suất thực tế:

| Lệnh | Mục đích | Khi nào dùng |
| ----- | -------- | ------------ |
| **`/init`** | Tạo `CLAUDE.md` | Vào repo mới |
| **`/compact`** | Nén context | Context sắp đầy, muốn tiết kiệm token |
| **`/context`** | Xem mức context | Kiểm tra còn bao nhiêu context window |
| **`/review`** | Review code | Trước khi commit hoặc tạo PR |
| **`/commit`** | Tạo git commit | Hoàn thành task, muốn commit |
| **`/diff`** | Xem thay đổi | Kiểm tra code trước khi commit |
| **`/rewind`** | Undo thay đổi | Claude sửa sai, muốn quay lại |
| **`/model`** | Đổi model | Cần model mạnh hơn hoặc nhanh hơn |
| **`/usage`** | Xem token usage | Kiểm tra chi phí / giới hạn token |

{% hint style="success" %}
💡 **Mẹo:** Gõ `/help` bất kỳ lúc nào để xem danh sách đầy đủ các lệnh khả dụng. Claude Code cũng hỗ trợ tab completion — chỉ cần gõ `/` rồi nhấn Tab để xem gợi ý.
{% endhint %}

***

## Workflow khuyến nghị

{% tabs %}
{% tab title="Vào repo mới" %}
{% code title="Workflow cơ bản" overflow="wrap" %}
```
/init
/model
Analyze the architecture first
```
{% endcode %}
{% endtab %}
{% tab title="Code review" %}
{% code title="Review trước commit" overflow="wrap" %}
```
/diff
/review
/commit
```
{% endcode %}
{% endtab %}
{% tab title="Khi context đầy" %}
{% code title="Quản lý context" overflow="wrap" %}
```
/compact
# hoặc nếu cần bắt đầu lại:
/clear
```
{% endcode %}
{% endtab %}
{% tab title="Thử nghiệm an toàn" %}
{% code title="Thử nghiệm với branch" overflow="wrap" %}
```
/branch
# Thử nghiệm code mới
# Nếu ok:
/commit
# Nếu không:
/rewind
```
{% endcode %}
{% endtab %}
{% endtabs %}

***

## Tài liệu tham khảo

* [Claude Code Commands Docs](https://code.claude.com/docs/en/commands)
* [Claude CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference)
* [Claude Code Cheatsheet](https://support.claude.com/en/articles/14553413-claude-code-cheatsheet)
* [Model Context Protocol](https://modelcontextprotocol.io/)
