---
name: viet-bai-gitbook
description: Use when writing, creating, or drafting blog posts, how-to guides, cheat sheets, technical articles, or any documentation content for this GitBook site. Trigger on keywords like "viết bài", "tạo bài", "blog", "guide", "cheat sheet", "hướng dẫn", "so sánh", "tin tức". Also use when updating SUMMARY.md navigation.
---

Viết bài Markdown cho GitBook documentation site (`gitbook.nqdev.cam-nang-nqdev`). Nội dung tiếng Việt, giữ nguyên thuật ngữ kỹ thuật tiếng Anh.

## Yêu cầu tối thiểu

- YAML `description:` front matter (<160 ký tự cho SEO)
- GitBook syntax (`{% code %}`, `{% tabs %}`, `{% endcode %}`)
- Tiếng Việt, giữ nguyên thuật ngữ kỹ thuật tiếng Anh
- Filename lowercase-kebab-case, có dấu tiếng Việt
- Thêm entry vào `SUMMARY.md` của book với path relative từ thư mục book

Tham khảo format từ các bài viết có sẵn trong mỗi book.

## Cấu trúc thư mục

7 books:

| Book gốc | Nội dung |
|---|---|
| `cheat-sheet/` | Bash, Git, HAProxy, Redis, Wireshark, Windows, Ubuntu |
| `cong-nghe/` | .NET, Docker, SQL Server, Linux, Node.js, design patterns |
| `cuoc-song/` | Sách, sức khỏe, đời sống |
| `devsecops/` | Ansible, Docker, VMware |
| `hoi-dap/` | Hỏi đáp, SQL |
| `lien-he/` | Liên hệ, chính sách, sitemap |
| `prompts/` | AI prompts (ChatGPT, Gemini, coding, writing, business) |

Mỗi book có:
- `SUMMARY.md` — bảng mục lục điều hướng
- `README.md` — trang giới thiệu book
- `.gitbook/assets/` — thư mục ảnh của book đó
- Thư mục con chứa bài viết `.md` có sẵn

## Quy tắc lưu file

### Lưu trực tiếp vào book

Bài viết mới lưu **trực tiếp vào thư mục book tương ứng**.

**Ví dụ:** Bài viết thuộc book `cong-nghe/` → lưu tại `cong-nghe/<sub-dir>/bai-viet.md`.

### Book mới (chưa có trong 7 books)

Tạo thư mục book mới ở root với `SUMMARY.md` + `README.md`. Sau đó thêm entry vào root `SUMMARY.md` và kiểm tra root `book.json` có cần cập nhật title/description không.

### Quy trình thêm bài mới

1. Xác định book cho bài viết.
2. Tạo file `.md` trong thư mục book đó (tự tạo sub-dir nếu cần).
3. Thêm entry vào `SUMMARY.md` của book đó với path tương đối từ book.

## Ánh xạ nội dung vào cây thư mục

Mỗi book có cấu trúc thư mục chuẩn. Trước khi viết, đọc `SUMMARY.md` của book đó để xác định vị trí phù hợp.

**Ví dụ — book `cong-nghe/` và nguyên tắc mapping:**

- Bài về **Docker/Podman/Redis/Varnish** → `container-and-infra/`
- Bài về **SQL Server/Elasticsearch/MongoDB** → `databases/`
- Bài về **.NET/C#/ASP.NET/Node.js/React** → `languages-and-frameworks/`
- Bài về **NGINX/HAProxy/VPN/Localtunnel** → `infrastructure-and-networking/`
- Bài về **Ansible/JMeter/ETL** → `devsecops-and-automation/`
- Bài về **Obsidian/Playwright/AI CLI/WinDbg** → `development-tools/`
- Bài về **AI/tin tức/so sánh/hướng dẫn chung** → `general-knowledge/`
- Bài về **thiết kế/microservices/CQRS** → `architecture-and-design/`
- Bài về **CentOS/Ubuntu/Debian/Windows** → `operating-systems/`
- Bài về **open source projects/templates/WordPress** → `open-source-and-templates/`

Nếu không thấy thư mục phù hợp, tạo thư mục con mới trong nhánh gần nhất.

## Quy tắc format Markdown

### Headings
- `#` — Tiêu đề bài viết (1 bài = 1 H1)
- `##` — Section chính
- `###` — Sub-section
- `####` — Sub-sub-section

GitBook tự động sinh anchor từ heading. Không cần thêm HTML anchor.

### Bullet list
Luôn dùng pattern **Bold Lead**:
```
* **Tên thuật ngữ:** Giải thích chi tiết
```

### Code block
Luôn wrap bằng GitBook syntax:
{% code title="Mô tả ngắn" overflow="wrap" lineNumbers="true" %}
```bash
code_here
```
{% endcode %}
- `title`: tên/mô tả code block
- `overflow="wrap"`: tự xuống dòng
- `lineNumbers="true"`: hiển thị số dòng (code dài)
- Language sau ```: `bash`, `json`, `yaml`, `csharp`, `sql`, `powershell`, `dockerfile`

### Tabbed content
```
{% tabs %}
{% tab title="Tên tab 1" %}
Nội dung tab 1
{% endtab %}
{% tab title="Tên tab 2" %}
Nội dung tab 2
{% endtab %}
{% endtabs %}
```

### Hint / Callout
```
{% hint style="info" %}
Nội dung ghi chú
{% endhint %}
```
Các style: `info`, `warning`, `danger`, `success`. Dùng cho lưu ý, cảnh báo, tip.

### Content reference (internal link)
```
{% content-ref url="path/to/bai-viet.md" %}
[bai-viet](path/to/bai-viet.md)
{% endcontent-ref %}
```

### Image
```html
<figure><img src="../.gitbook/assets/image.png" alt="Mô tả"><figcaption><p>Chú thích ảnh</p></figcaption></figure>
```
Hoặc inline: `![alt](../.gitbook/assets/image.png)`

Ảnh lưu tại `./.gitbook/assets/` của book đó. Dùng relative path `../.gitbook/assets/` từ file `.md` ở sub-dir.

### Blockquote
```
> Nội dung trích dẫn hoặc quan trọng.\
> Dòng tiếp theo.
```

### Horizontal rule
```
***
```

### Table
```
| Cột 1 | Cột 2 |
| ----- | ----- |
| A     | B     |
```

## Quy tắc ngôn ngữ

1. **Tiếng Việt** cho tất cả nội dung văn bản
2. **Giữ nguyên tên kỹ thuật tiếng Anh:** Docker, Redis, ASP.NET Core, SQL Server, CQRS, etc.
3. **Không dịch tên công nghệ**, chỉ giải thích bằng tiếng Việt
4. **Ngắn gọn, súc tích** — tránh dài dòng, đi thẳng vào vấn đề
5. **Có ví dụ thực tế** — mỗi khái niệm nên đi kèm code snippet hoặc minh họa
6. **Sử dụng emoji khi cần** nhưng không lạm dụng — `👉` cho emphasis

## Quy tắc đặt tên file

- **lowercase-kebab-case:** `huong-dan-cai-dat-docker.md`
- **Tiếng Việt có dấu:** giữ nguyên dấu
- **Mô tả ngắn gọn** nhưng rõ ý: `so-sanh-varnish-cache-memcached-va-redis.md`
- **Không dùng** underscore hoặc camelCase

## Cấu trúc bài viết

### 1. Bài viết hướng dẫn (How-to Guide)

```markdown
---
description: Mô tả ngắn
---

# Tiêu đề bài hướng dẫn

Mô tả ngắn 2-3 dòng giới thiệu vấn đề và giải pháp.

## Khái niệm cơ bản

Giải thích ngắn gọn lý thuyết cần biết.

* **Thuật ngữ 1:** Giải thích
* **Thuật ngữ 2:** Giải thích

## Yêu cầu

* **Hệ điều hành:** ...
* **Công cụ cần thiết:** ...

## Hướng dẫn thực hiện

### Bước 1: Mô tả

1. Mô tả bước
2. Giải thích lý do

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
lenh-can-thuc-hien
```
{% endcode %}

### Bước 2: Mô tả

...mô tả...

## Xác minh kết quả

Kiểm tra bằng cách chạy lệnh X. Kết quả mong đợi: ...

## Lưu ý quan trọng

{% hint style="warning" %}
Lưu ý quan trọng cần biết khi thực hiện
{% endhint %}

## Tài liệu tham khảo
* [URL](URL)
```

### 2. Bài viết tin tức / Blog explainer

```markdown
---
description: >-
  Mô tả SEO 2-3 dòng cho bài phân tích/tin tức
---

# Tiêu đề bài viết

Mở bài 2-3 dòng tóm tắt nội dung chính.

## Bối cảnh

Bối cảnh ra đời / lý do bài viết.

## Nội dung chính

* **Điểm A:** Giải thích ngắn gọn
* **Điểm B:** Giải thích ngắn gọn
* **Điểm C:** Giải thích ngắn gọn

## Phân tích / Đánh giá

Ưu điểm, nhược điểm, tác động.

## Kết luận

1-2 dòng tóm tắt.

**Tài liệu tham khảo:**
* [URL](URL)
```

### 3. Bài viết so sánh

```markdown
---
description: So sánh A và B: ưu nhược điểm
---

# So sánh A và B

Mở bài tóm tắt lý do so sánh.

## Bảng so sánh nhanh

| Tiêu chí       | A              | B              |
| -------------- | -------------- | -------------- |
| Tiêu chí 1     | Ưu điểm A     | Ưu điểm B     |
| Tiêu chí 2     | Nhược A        | Nhược B        |

## Phân tích chi tiết

{% tabs %}
{% tab title="A" %}
Phân tích về A
{% endtab %}
{% tab title="B" %}
Phân tích về B
{% endtab %}
{% endtabs %}

### Tiêu chí 1
...phân tích...

### Tiêu chí 2
...phân tích...

## Kết luận: Nên chọn gì?
...tóm tắt...
```

### 4. Cheat Sheet / Tài liệu tham khảo nhanh

```markdown
---
description: Cheat sheet cho [công cụ]
---

# [Công cụ] Cheat Sheet

## Chủ đề 1

{% tabs %}
{% tab title="Tab 1" %}
{% code title="Mô tả" overflow="wrap" %}
```bash
lenh-1
```
{% endcode %}
{% endtab %}
{% tab title="Tab 2" %}
{% code title="Mô tả" overflow="wrap" %}
```bash
lenh-2
```
{% endcode %}
{% endtab %}
{% endtabs %}

## Chủ đề 2
...
```

### 5. Prompt template

```markdown
---
description: Prompt templates cho [mục đích]
---

# Tiêu đề Prompt

## Chủ đề

{% tabs %}
{% tab title="Ngôn ngữ A" %}
{% code title="Prompt cho A" overflow="wrap" %}
```markdown
Prompt content here
```
{% endcode %}
{% endtab %}
{% tab title="Ngôn ngữ B" %}
{% code title="Prompt cho B" overflow="wrap" %}
```markdown
Prompt content here
```
{% endcode %}
{% endtab %}
{% endtabs %}
```

## Cập nhật SUMMARY.md

Khi thêm bài mới, cập nhật `SUMMARY.md` của book đó. Path relative từ thư mục book:

```markdown
* [Tiêu đề bài viết](path/to/ten-file.md)
```

Với section con:
```markdown
* [Tiêu đề section](path/to/section/README.md)
  * [Bài viết con](path/to/section/bai-viet.md)
```

## CTA cuối bài (tùy chọn)

```html
<img src="https://me.momo.vn/nhquydev" alt="Momo" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
```

## Build & Deploy

Build ở root repo (yêu cầu root `SUMMARY.md` + `book.json` — đã có sẵn):

```bash
# Yêu cầu Node.js v14 (gitbook-cli cần version cũ)
npm install -g gitbook-cli --legacy-peer-deps
gitbook install
gitbook build    # Output: _book/
```

GitHub Actions workflow: `.github/workflows/deploy_gitbook.yml`
- Trigger: `workflow_dispatch`
- Node.js v14, gitbook-cli
- Build tại root → deploy `_book/` lên GitHub Pages

## Checklist trước khi đăng bài

- [ ] Có YAML front matter với description (<160 ký tự)
- [ ] Chỉ có 1 H1 (tiêu đề bài)
- [ ] Sections dùng H2, sub-sections dùng H3+
- [ ] Code block wrap bằng `{% code %}` / `{% endcode %}`
- [ ] Dùng `{% hint %}` cho note/warning nếu cần
- [ ] Dùng `{% content-ref %}` cho internal links nếu cần
- [ ] Bullet list dùng pattern `**Bold Lead:**`
- [ ] Không dùng HTML anchor (GitBook tự gen)
- [ ] Ảnh đặt trong `.gitbook/assets/` của book, dùng relative path `../.gitbook/assets/`
- [ ] File name là lowercase-kebab-case tiếng Việt
- [ ] File lưu đúng vị trí trong cây thư mục của book
- [ ] Entry mới được thêm vào `SUMMARY.md` của book đó
- [ ] Đã kiểm tra lỗi chính tả tiếng Việt
