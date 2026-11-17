---
description: >-
  Hướng dẫn cài đặt Graphify: yêu cầu hệ thống, cài CLI graphifyy, đăng ký skill cho
  AI assistant, và build knowledge graph lần đầu từ codebase.
---

# Graphify: cài đặt và bắt đầu

Bài này hướng dẫn từng bước để cài đặt Graphify và build knowledge graph lần đầu. Đọc sau [Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md).

---

## Yêu cầu hệ thống

| Thành phần | Tối thiểu | Kiểm tra | Cài đặt |
| --- | --- | --- | --- |
| Python | 3.11+ | `python --version` | [python.org](https://www.python.org/downloads/) |
| uv (khuyến nghị) | any | `uv --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| pipx (thay thế) | any | `pipx --version` | `pip install pipx` |
| AI Coding Assistant | ít nhất 1 | — | Claude Code, Cursor, Codex, Gemini CLI, … |

**macOS nhanh (Homebrew):**

{% code title="macOS" overflow="wrap" lineNumbers="true" %}
```bash
brew install python@3.12 uv
```
{% endcode %}

**Windows:**

{% code title="Windows" overflow="wrap" lineNumbers="true" %}
```bash
winget install astral-sh.uv
```
{% endcode %}

**Ubuntu/Debian:**

{% code title="Ubuntu/Debian" overflow="wrap" lineNumbers="true" %}
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# hoặc dùng system Python với pipx:
sudo apt install python3 python3-pip pipx
```
{% endcode %}

---

## Cài đặt

{% hint style="warning" %}
**Gói chính thức trên PyPI là `graphifyy` (hai chữ y).** Các gói `graphify*` khác trên PyPI không liên quan. Lệnh CLI vẫn là `graphify`. Source chính thức: [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify).
{% endhint %}

Quy trình cài đặt được thiết kế tối giản, tích hợp trực tiếp vào workflow của AI Coding Assistant thông qua cơ chế Skill.

**Bước 1: Cài CLI (chọn một):**

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
uv tool install graphifyy      # khuyến nghị, isolated env
# nếu 'graphify' không tìm thấy sau khi cài, chạy: uv tool update-shell

pipx install graphifyy         # thay thế
pip install graphifyy          # có thể cần setup PATH, xem Troubleshooting
```
{% endcode %}

**Bước 2: Kiểm tra cài đặt:**

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify --version
```
{% endcode %}

Đảm bảo lệnh được nhận diện thành công trước khi tiếp tục.

**Bước 3: Đăng ký Skill vào AI Assistant:**

Di chuyển vào thư mục gốc của dự án (hoặc chạy global tùy cấu hình) và thực thi:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify install
```
{% endcode %}

Cơ chế: lệnh tự động quét các AI assistant hiện có trên máy (Claude Code, Cursor, Gemini CLI, …) và chép tệp hướng dẫn skill (`/graphify`) vào đúng thư mục cấu hình tương ứng — không cần setup per-assistant.

```bash
# Hoặc chỉ định platform:
graphify install --platform cursor
```

`graphify install` detect assistant bạn đang dùng và đăng ký skill. Mở AI assistant và gõ `/graphify .`

**Cài đặt scoped vào repo (để commit cùng project):**

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify install --project
graphify install --project --platform codex
```
{% endcode %}

Project-scoped install ghi file dưới thư mục hiện tại (ví dụ `.claude/skills/graphify/SKILL.md` hoặc `.agents/skills/graphify/SKILL.md` + sidecar `references/`), và in gợi ý `git add` cho các file có thể commit.

---

## Build graph lần đầu

Mở AI assistant tại thư mục dự án và gõ slash command:

{% code title="assistant" overflow="wrap" lineNumbers="true" %}
```text
/graphify .
```
{% endcode %}

Quá trình xử lý gồm hai pha:

* **Code (AST Pass):** dùng Tree-sitter phân tích cú pháp mã nguồn — chạy **cục bộ hoàn toàn**, miễn phí, không gửi code ra ngoài.
* **Docs / Media (Semantic Pass):** nếu dự án có PDF, Markdown, hình ảnh hoặc lược đồ SQL, hệ thống phân tích ngữ nghĩa và liên kết chúng vào cùng một đồ thị.

Hoặc từ CLI:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify .            # build graph cho thư mục hiện tại
```
{% endcode %}

Kết quả: thư mục `graphify-out/` với 3 file:

{% code title="graphify-out/" overflow="wrap" lineNumbers="true" %}
```text
graphify-out/
├── graph.html       mở bằng browser: click node, filter, search
├── GRAPH_REPORT.md  highlights: god nodes, surprising connections, suggested questions
└── graph.json       full graph: truy vấn bất cứ lúc nào không cần re-read file
```
{% endcode %}

Graph persisted bao gồm `graph.schema_version` và `graph.graphify_version` để integration detect format change.

---

## Thiết lập duy nhất nên làm thêm

Để đồ thị không bị lỗi thời khi bắt đầu viết code mới, chạy một lệnh duy nhất:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify hook install
```
{% endcode %}

Lệnh này gắn hook vào Git để mỗi lần `git commit`, Graphify tự động cập nhật phần code vừa sửa vào `graphify-out/` trong tích tắc, không cần nhớ chạy lại `/graphify .` thủ công.

---

## Bước tiếp theo

* 👉 **[Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md)** — chat với AI, graph.html, lệnh chuyên sâu, cập nhật
* 👉 **[Tính năng nâng cao](graphify-tinh-nang-nang-cao.md)** — chế độ offline, God Nodes, .graphifyignore, export
* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)** — .graphifyrc, env, privacy
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)** — export, Graphify Cloud, xử lý lỗi
* 👉 **[Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md)** — quay lại tổng quan

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
> * [Installation](https://docs.graphify.com/installation)
> * [Troubleshooting](https://docs.graphify.com/troubleshooting)