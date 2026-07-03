---
name: viet-bai-gitbook
description: Use when writing, creating, or drafting blog posts, how-to guides, cheat sheets, technical articles, or any documentation content for this GitBook site. Trigger on keywords like "viết bài", "tạo bài", "blog", "guide", "cheat sheet", "hướng dẫn", "so sánh", "tin tức". Also use when updating SUMMARY.md navigation.
---

# Skill: Viết bài theo phong cách GitBook

Hướng dẫn viết bài Markdown cho GitBook documentation site (`gitbook.nqdev.cam-nang-nqdev`). Tất cả nội dung tiếng Việt, giữ nguyên thuật ngữ kỹ thuật tiếng Anh.

## Tham chiếu thực tế

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

**Bài viết mới lưu trực tiếp vào thư mục book tương ứng.**

## Quy tắc lưu file

### Lưu trực tiếp vào book

Bài viết mới lưu **trực tiếp vào thư mục book tương ứng**, theo cấu trúc thư mục phù hợp.

**Ví dụ:** Bài viết thuộc book `cong-nghe/` → lưu tại `cong-nghe/<sub-dir>/bai-viet.md`.

### Book mới (chưa có trong 7 books)

Tạo thư mục book mới ở root:
```
<book-name>/bai-viet.md
<book-name>/SUMMARY.md
<book-name>/README.md
```

### Quy trình thêm bài mới

1. Xác định book cho bài viết.
2. Tạo file `.md` trong thư mục book đó (tự tạo sub-dir nếu cần).
3. Thêm entry vào `SUMMARY.md` của book đó với path tương đối từ book.

## Ánh xạ nội dung vào cây thư mục

Mỗi book có cấu trúc thư mục chuẩn. Trước khi viết, đọc `SUMMARY.md` của book đó để xác định vị trí phù hợp.

**Ví dụ — book `cong-nghe/`:**
```
cong-nghe/
├── affiliate/
├── architecture-and-design/
│   └── design-patterns/
├── container-and-infra/
│   ├── docker/
│   └── caching/
├── databases/
│   ├── sql-server/
│   └── elasticsearch/
├── development-tools/
│   ├── playwright/
│   ├── obsidian/
│   └── ai-cli-tools/
├── devsecops-and-automation/
├── general-knowledge/
│   ├── ai/
│   ├── tin-tuc/
│   └── huong-dan/
├── infrastructure-and-networking/
│   ├── nginx-plus/
│   └── haproxy/
├── languages-and-frameworks/
│   ├── dotnet/
│   └── nodejs/
├── open-source-and-templates/
├── operating-systems/
│   ├── linux/
│   └── windows/
└── .gitbook/assets/
```

**Nguyên tắc mapping:**
- Bài về **Docker/Podman/Redis/Varnish** → `container-and-infra/`
- Bài về **SQL Server/Elasticsearch/MongoDB** → `databases/`
- Bài về **.NET/C#/ASP.NET/Node.js/React** → `languages-and-frameworks/`
- Bài về **NGINX/HAProxy/VPN/Localtunnel** → `infrastructure-and-networking/`
- Bài về **Ansible/JMeter/ETL** → `devsecops-and-automation/`
- Bài về **Obsidian/Playwright/AI CLI/WinDbg** → `development-tools/`
- Bài về **AI/tin tức/so sánh/hướng dẫn chung** → `general-knowledge/`
- Bài về **thiết kế/microservices/CQRS** → `architecture-and-design/`
- Bài về **CentOS/Ubuntu/Debian/Windows** → `operating-systems/`

Nếu không thấy thư mục phù hợp, tạo thư mục con mới trong nhánh gần nhất với nội dung bài viết.

## Front Matter

Mỗi bài viết BẮT BUỘC có YAML front matter:

```yaml
---
description: Mô tả ngắn 1-2 câu cho SEO, dưới 160 ký tự
---
```

Hoặc multi-line:
```yaml
---
description: >-
  Mô tả dài hơn cho bài viết phức tạp,
  có thể nhiều dòng.
---
```

## Cấu trúc bài viết

### 1. Bài viết hướng dẫn (How-to Guide)

```markdown
---
description: Mô tả ngắn
---

# Tiêu đề bài hướng dẫn

Mô tả ngắn 2-3 dòng giới thiệu vấn đề và giải pháp.

## 1. Khái niệm cơ bản <a href="#id-1" id="id-1"></a>

Giải thích ngắn gọn lý thuyết cần biết.

* **Thuật ngữ 1:** Giải thích
* **Thuật ngữ 2:** Giải thích

## 2. Yêu cầu <a href="#id-2" id="id-2"></a>

* **Hệ điều hành:** ...
* **Công cụ cần thiết:** ...

## 3. Hướng dẫn thực hiện <a href="#id-3" id="id-3"></a>

### 3.1 Bước con cụ thể

1. Mô tả bước
2. Giải thích lý do

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
lenh-can-thuc-hien
```
{% endcode %}

### 3.2 Bước tiếp theo

...mô tả...

## 4. Xác minh kết quả <a href="#id-4" id="id-4"></a>

Kiểm tra bằng cách chạy lệnh X. Kết quả mong đợi: ...

## 5. Lưu ý quan trọng

* **Lưu ý 1:** ...
* **Lưu ý 2:** ...

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

## **Tiêu đề section 1**

* **Điểm A:** Giải thích ngắn gọn
* **Điểm B:** Giải thích ngắn gọn
* **Điểm C:** Giải thích ngắn gọn

## **Tiêu đề section 2**

* ... (cùng pattern bullet list)

## **Kết luận**

1-2 dòng tóm tắt lại.

**Tài liệu tham khảo:**
* [URL](URL)

<img src="https://..." alt="☕️" data-size="line">
<img src="https://..." alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
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

## Quy tắc format Markdown

### Headings
- `#` — Tiêu đề bài viết (1 bài = 1 H1)
- `##` — Section chính, thường có anchor: `## Tiêu đề <a href="#id" id="id"></a>`
- `###` — Sub-section
- `####` — Sub-sub-section

### Bullet list
Luôn dùng pattern **Bold Lead**:
```
* **Tên thuật ngữ:** Giải thích chi tiết
* **Tên thuật ngữ 2:** Giải thích chi tiết
```

### Code block
Luôn wrap bằng GitBook syntax:
```
{% code title="Mô tả ngắn" overflow="wrap" lineNumbers="true" %}
```bash
code_here
```
{% endcode %}
```
- `title`: tên/mô tả code block
- `overflow="wrap"`: tự xuống dòng
- `lineNumbers="true"`: hiển thị số dòng (dùng cho code dài)

### Tabbed content (nhiều tùy chọn)
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

### Image
```html
<figure><img src="path/to/image.png" alt="Mô tả"><figcaption><p>Chú thích ảnh</p></figcaption></figure>
```
Hoặc inline: `![alt](path/to/image.png)`

Ảnh lưu tại `./.gitbook/assets/` của book đó. Relative path từ file `.md` đến thư mục assets cùng book.

### Blockquote (trích dẫn / nổi bật)
```
> Nội dung trích dẫn hoặc quan trọng.\
> Dòng tiếp theo.
```

### Horizontal rule (phân cách section)
```
***
```

### Table
```
| Cột 1 | Cột 2 | Cột 3 |
| ----- | ----- | ----- |
| A     | B     | C     |
```

### Anchor (mục lục jump link)
```
## Tiêu đề <a href="#id-tieu-de" id="id-tieu-de"></a>
```

## Quy tắc ngôn ngữ

1. **Tiếng Việt** cho tất cả nội dung văn bản
2. **Giữ nguyên tên kỹ thuật tiếng Anh:** Docker, Redis, ASP.NET Core, SQL Server, CQRS, etc.
3. **Không dịch tên công nghệ**, chỉ giải thích bằng tiếng Việt
4. **Ngắn gọn, súc tích** — tránh dài dòng, đi thẳng vào vấn đề
5. **Có ví dụ thực tế** — mỗi khái niệm nên đi kèm code snippet hoặc minh họa
6. **Sử dụng emoji khi cần** nhưng không lạm dụng — `👉` cho emphasis, `☕️` cho CTA

## Quy tắc đặt tên file

- **lowercase-kebab-case:** `huong-dan-cai-dat-docker.md`
- **Tiếng Việt có dấu:** giữ nguyên dấu
- **Mô tả ngắn gọn** nhưng rõ ý: `so-sanh-varnish-cache-memcached-va-redis.md`
- **Không dùng** underscore hoặc camelCase

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

Đặt ở cuối bài viết nếu muốn kêu gọi đóng góp:

```html
<img src="https://..." alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
```

## Build & Deploy

CI/CD chạy tại root repo (không phải per-book):

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

- [ ] Có YAML front matter với description
- [ ] Chỉ có 1 H1 (tiêu đề bài)
- [ ] Sections dùng H2, sub-sections dùng H3+
- [ ] Code block wrap bằng `{% code %}` / `{% endcode %}`
- [ ] Bullet list dùng pattern `**Bold Lead:**`
- [ ] Anchor IDs nhất quán nếu dùng manual anchor
- [ ] Ảnh đặt trong `./.gitbook/assets/` của book với relative path đúng
- [ ] File name là lowercase-kebab-case tiếng Việt
- [ ] File lưu đúng vị trí trong cây thư mục của book
- [ ] Entry mới được thêm vào `SUMMARY.md` của book đó
- [ ] Đã kiểm tra lỗi chính tả tiếng Việt
