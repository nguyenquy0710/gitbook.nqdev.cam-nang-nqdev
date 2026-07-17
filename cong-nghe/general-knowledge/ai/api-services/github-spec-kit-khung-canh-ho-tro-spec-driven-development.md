---
description: >-
  GitHub Spec Kit là toolkit mã nguồn mở hỗ trợ Spec-Driven Development (SDD)
  với AI Coding Agent. Định nghĩa spec trước, code sau, giảm Vibe Coding.
---

# GitHub Spec Kit — Khung cảnh hỗ trợ Spec-Driven Development với AI Coding Agent

Trong thời đại AI Coding bùng nổ, việc "vibe coding" — viết prompt rồi phó mặc cho AI — đang tạo ra nhiều dự án thiếu kiểm soát, yêu cầu bị thất thoát và codebase khó bảo trì. **GitHub Spec Kit** ra đời như một giải pháp mã nguồn mở giúp chuẩn hóa quy trình phát triển phần mềm khi kết hợp với AI Coding Agent.

## Spec Kit là gì?

**Spec Kit** là một toolkit mã nguồn mở (MIT License) được phát triển bởi GitHub, hỗ trợ phương pháp **Spec-Driven Development (SDD)** — phát triển phần mềm驱动 bởi specification. Thay vì bắt đầu từ code, bạn định nghĩa **"cái gì"** và **"tại sao"** trước khi AI bắt tay vào implement.

* **Spec-Driven Development (SDD):** Phương pháp phát triển phần mềm lấy specification làm trung tâm, thay vì code.
* **Specify CLI:** Công cụ dòng lệnh chính của Spec Kit, dùng để khởi tạo project, quản lý extensions, presets và bundles.
* **Extensions:** Hệ thống mở rộng thêm commands và templates mới cho Spec Kit.
* **Presets:** Tùy chỉnh templates và commands có sẵn (đổi format, ngôn ngữ, phương pháp luận).
* **Bundles:** Gói các extensions + presets theo vai trò (Product Manager, Developer, Security Researcher...).

## Tại sao cần Spec Kit?

{% hint style="info" %}
Spec Kit không chỉ là công cụ — nó là một phương pháp luận (methodology) giúp chuyển đổi AI Coding từ "cảm hứng" sang "khoa học".
{% endhint %}

* **Giảm Vibe Coding:** Specification trở thành "nguồn sự thật" (Source of Truth) thay vì phụ thuộc vào lịch sử chat.
* **Kỹ thuật phần mềm thực thụ:** Workflow `Constitution → Specify → Plan → Tasks → Implement` giống quy trình phát triển chuyên nghiệp.
* **Hỗ trợ 30+ AI Coding Agent:** Claude Code, GitHub Copilot, Cursor, Codex CLI, Gemini, Windsurf, Cline và nhiều hơn nữa.
* **Mã nguồn mở:** MIT License, không khóa vào ecosystem nào.

## Yêu cầu

* **Hệ điều hành:** Linux, macOS hoặc Windows
* **Python:** 3.11 trở lên
* **uv:** Package manager cho Python (khuyến nghị) hoặc pipx
* **Git:** Được cài đặt trên máy
* **AI Coding Agent:** Một trong các agent được hỗ trợ

## Hướng dẫn cài đặt

### Bước 1: Cài đặt uv

{% code title="Cài đặt uv trên macOS/Linux" overflow="wrap" lineNumbers="true" %}
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
{% endcode %}

{% code title="Cài đặt uv trên Windows (PowerShell)" overflow="wrap" lineNumbers="true" %}
```powershell
irm https://astral.sh/uv/install.ps1 | iex
```
{% endcode %}

### Bước 2: Cài đặt Specify CLI

{% tabs %}
{% tab title="Cài từ GitHub (khuyến nghị)" %}
{% code title="Cài phiên bản mới nhất từ GitHub" overflow="wrap" lineNumbers="true" %}
```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
```
{% endcode %}

Thay `vX.Y.Z` bằng tag release mới nhất từ [Releases](https://github.com/github/spec-kit/releases) (ví dụ: `v0.12.11`).
{% endtab %}
{% tab title="Cài từ PyPI" %}
{% code title="Cài từ PyPI" overflow="wrap" lineNumbers="true" %}
```bash
uv tool install specify-cli
```
{% endcode %}
{% endtab %}
{% endtabs %}

### Bước 3: Khởi tạo project

{% code title="Tạo project mới với Specify CLI" overflow="wrap" lineNumbers="true" %}
```bash
specify init my-project --integration copilot
cd my-project
```
{% endcode %}

{% hint style="warning" %}
Trong môi trường không tương tác (CI, script), `specify init` mặc định sử dụng GitHub Copilot. Chỉ định `--integration` để chọn agent khác.
{% endhint %}

### Bước 4: Kiểm tra bản cập nhật

{% code title="Quản lý cập nhật Specify CLI" overflow="wrap" lineNumbers="true" %}
```bash
# Kiểm tra có bản mới không
specify self check

# Xem trước khi upgrade
specify self upgrade --dry-run

# Upgrade lên phiên bản mới nhất
specify self upgrade

# Pin phiên bản cụ thể
specify self upgrade --tag vX.Y.Z
```
{% endcode %}

## Quy trình Spec-Driven Development

Spec Kit định nghĩa 7 bước rõ ràng cho quy trình phát triển:

### Bước 1: Thiết lập nguyên tắc project

Sử dụng lệnh `/speckit.constitution` trong AI Coding Agent để tạo các nguyên tắc quản trị cho project.

```
/speckit.constitution Create principles focused on code quality, testing standards,
user experience consistency, and performance requirements.
```

File `.specify/memory/constitution.md` sẽ được tạo — đây là tài liệu nền tảng mà tất cả các bước sau đều tham chiếu.

### Bước 2: Tạo specification

Sử dụng `/speckit.specify` để mô tả **bạn muốn xây cái gì** và **tại sao**.

```
/speckit.specify Build a team productivity platform with Kanban boards,
task assignment, and real-time collaboration features.
```

{% hint style="info" %}
Tập trung vào **"what"** và **"why"**, chưa cần đề cập tech stack ở bước này.
{% endhint %}

### Bước 3: Làm rõ specification (tùy chọn)

Sử dụng `/speckit.clarify` để AI đặt câu hỏi và làm rõ các yêu cầu chưa rõ ràng. Nên chạy bước này **trước** khi tạo plan.

```
/speckit.clarify
```

### Bước 4: Tạo kế hoạch kỹ thuật

Sử dụng `/speckit.plan` để chỉ định tech stack và kiến trúc.

```
/speckit.plan The application uses .NET Aspire with PostgreSQL.
Frontend uses Blazor Server with real-time updates.
REST API with Projects, Tasks, and Notifications endpoints.
```

### Bước 5: Phân tích và kiểm tra plan

Sử dụng `/speckit.analyze` để kiểm tra tính nhất quán giữa specification, plan và tasks.

```
/speckit.analyze
```

### Bước 6: Phân task

Sử dụng `/speckit.tasks` để tạo danh sách task chi tiết từ plan.

```
/speckit.tasks
```

File `tasks.md` sẽ chứa:
* **Phân task theo user story** — mỗi story thành phase riêng
* **Quản lý dependency** — task được sắp xếp theo thứ tự phụ thuộc
* **Ký hiệu song song `[P]`** — các task có thể chạy đồng thời
* **Đường dẫn file cụ thể** — mỗi task ghi rõ file path cần implement

### Bước 7: Triển khai

Sử dụng `/speckit.implement` để thực thi toàn bộ tasks theo plan.

```
/speckit.implement
```

## Bảng tóm tắt Slash Commands

| Lệnh | Mô tả |
| ----- | ----- |
| `/speckit.constitution` | Tạo/cập nhật nguyên tắc quản trị project |
| `/speckit.specify` | Định nghĩa yêu cầu và user stories |
| `/speckit.clarify` | Làm rõ các vùng chưa cụ thể trong spec |
| `/speckit.plan` | Tạo kế hoạch triển khai kỹ thuật |
| `/speckit.analyze` | Kiểm tra tính nhất quán giữa các tài liệu |
| `/speckit.tasks` | Phân task chi tiết từ plan |
| `/speckit.implement` | Triển khai toàn bộ tasks |
| `/speckit.converge` | Đánh giá codebase và bổ sung task còn thiếu |
| `/speckit.taskstoissues` | Chuyển tasks thành GitHub Issues |
| `/speckit.checklist` | Tạo checklist kiểm tra chất lượng |

## Extensions & Presets

Spec Kit hỗ trợ hai hệ thống mở rộng để tùy chỉnh theo nhu cầu:

{% tabs %}
{% tab title="Extensions" %}
**Extensions** thêm năng lực mới cho Spec Kit — commands, templates, workflows mới.

{% code title="Tìm và cài extensions" overflow="wrap" lineNumbers="true" %}
```bash
# Tìm extensions có sẵn
specify extension search

# Cài extension
specify extension add <extension-name>
```
{% endcode %}

Ví dụ: Jira integration, code review sau implement, V-Model test traceability.
{% endtab %}
{% tab title="Presets" %}
**Presets** thay đổi cách Spec Kit hoạt động — đổi format templates, ngôn ngữ, phương pháp luận.

{% code title="Tìm và cài presets" overflow="wrap" lineNumbers="true" %}
```bash
# Tìm presets có sẵn
specify preset search

# Cài preset
specify preset add <preset-name>
```
{% endcode %}

Ví dụ: Agile workflow,强制 compliance format, localized tiếng Việt.
{% endtab %}
{% endtabs %}

**Ưu tiên resolution:** Project-Local Overrides → Presets → Extensions → Spec Kit Core.

##undles: Gói theo vai trò

**Bundles** gom多个 extensions + presets thành gói theo vai trò, cài đặt bằng một lệnh duy nhất.

{% code title="Quản lý bundles" overflow="wrap" lineNumbers="true" %}
```bash
# Tìm bundles
specify bundle search [query]

# Xem chi tiết bundle
specify bundle info <bundle-id>

# Cài bundle
specify bundle install <bundle-id>

# Quản lý
specify bundle list
specify bundle update <bundle-id>
specify bundle remove <bundle-id>
```
{% endcode %}

Bốn bundle mẫu: Product Manager, Business Analyst, Security Researcher, Developer.

## Các giai đoạn phát triển

| Giai đoạn | Tập trung | Hoạt động chính |
| --------- | --------- | --------------- |
| **0-to-1 Development** | Tạo mới từ đầu | Bắt đầu từ yêu cầu cấp cao → spec → plan → build |
| **Creative Exploration** | Khám phá song song | Thử nghiệm nhiều giải pháp, nhiều tech stack |
| **Iterative Enhancement** | Nâng cấp dần | Thêm tính năng, hiện đại hóa hệ thống cũ |

## Kết luận

GitHub Spec Kit là bước tiến quan trọng trong việc chuẩn hóa AI Coding thành quy trình kỹ thuật phần mềm chuyên nghiệp. Thay vì "vibe coding" đầy rủi ro, SDD giúp bạn kiểm soát đầu ra, giảm sai lệch và xây dựng hệ thống bền vững hơn.

**Tài liệu tham khảo:**
* [GitHub Spec Kit](https://github.com/github/spec-kit)
* [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
* [Supported AI Coding Agent Integrations](https://github.github.io/spec-kit/reference/integrations.html)
* [CLI Reference](https://github.github.io/spec-kit/reference/overview.html)
