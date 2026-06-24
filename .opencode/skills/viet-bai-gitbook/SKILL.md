---
name: viet-bai-gitbook
description: Use when writing, creating, or drafting blog posts, how-to guides, cheat sheets, technical articles, or any documentation content for this GitBook site. Trigger on keywords like "viết bài", "tạo bài", "blog", "guide", "cheat sheet", "hướng dẫn", "so sánh", "tin tức". Also use when updating SUMMARY.md navigation.
---

# Skill: Viết bài theo phong cách GitBook

Hướng dẫn viết bài Markdown cho GitBook documentation site (`gitbook.nqdev.cam-nang-nqdev`). Tất cả nội dung tiếng Việt, giữ nguyên thuật ngữ kỹ thuật tiếng Anh.

## Cấu trúc thư mục

Mỗi book (thư mục cấp 1) có:
- `SUMMARY.md` — bảng mục lục điều hướng
- `README.md` — trang giới thiệu book
- Thư mục con chứa bài viết `.md` (bài viết có sẵn, không phải bài mới)
- Ảnh lưu tại `.gitbook/assets/` theo book

**Bài viết mới do opencode tạo LUÔN lưu vào `opcode/`**, không ghi đè vào thư mục book gốc.

### Quy tắc lưu file

Khi viết bài cho book nào, tạo sub-directory tương ứng trong `opcode/`:

| Book gốc        | Lưu vào                          |
| --------------- | -------------------------------- |
| `cheat-sheet/`  | `opcode/cheat-sheet/`            |
| `cong-nghe/`    | `opcode/cong-nghe/`              |
| `cuoc-song/`    | `opcode/cuoc-song/`              |
| `devsecops/`    | `opcode/devsecops/`              |
| `hoi-dap/`      | `opcode/hoi-dap/`                |
| `lien-he/`      | `opcode/lien-he/`                |
| `prompts/`      | `opcode/prompts/`                |
| Khác (mới)      | `opcode/<book-name>/`            |

Bài viết mới cần:
1. Tạo file `.md` trong `opcode/<book>/` (tự tạo sub-dir nếu chưa có)
2. Thêm entry vào `SUMMARY.md` của book đó, path trỏ đến `opcode/<book>/file.md`
3. Đặt ảnh trong `.gitbook/assets/`, tham chiếu bằng relative path

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

Ảnh lưu tại `.gitbook/assets/` và tham chiếu relative.

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

Khi thêm bài mới, cập nhật `SUMMARY.md` của book đó. **Path luôn trỏ đến file trong `opcode/`:**

```markdown
* [Tiêu đề bài viết](opcode/<book>/ten-file.md)
```

Với section con:
```markdown
* [Tiêu đề section](path/to/section/README.md)
  * [Bài viết con](opcode/<book>/path/to/bai-viet.md)
```

Ví dụ thực tế — thêm bài về Docker vào `cong-nghe/SUMMARY.md`:
```markdown
* [Docker](docker/README.md)
  * [Hướng dẫn Docker Compose mới](opcode/cong-nghe/huong-dan-docker-compose-moi.md)
```

### Nguyên tắc
- **File `.md`** lưu ở `opcode/<book>/` — không lưu vào thư mục book gốc
- **Entry SUMMARY.md** thêm vào thư mục book gốc — path phải bắt đầu bằng `opcode/<book>/`
- **Không modify** file `.md` có sẵn trong thư mục book gốc

## CTA cuối bài (tùy chọn)

Đặt ở cuối bài viết nếu muốn kêu gọi đóng góp:

```html
<img src="https://..." alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
```

## Checklist trước khi đăng bài

- [ ] Có YAML front matter với description
- [ ] Chỉ có 1 H1 (tiêu đề bài)
- [ ] Sections dùng H2, sub-sections dùng H3+
- [ ] Code block wrap bằng `{% code %}` / `{% endcode %}`
- [ ] Bullet list dùng pattern `**Bold Lead:**`
- [ ] Anchor IDs nhất quán nếu dùng manual anchor
- [ ] Ảnh đặt trong `.gitbook/assets/` với relative path
- [ ] File name là lowercase-kebab-case tiếng Việt
- [ ] File lưu trong `opcode/<book>/` — không lưu vào thư mục book gốc
- [ ] Entry mới được thêm vào `SUMMARY.md` của book gốc, path trỏ đến `opcode/<book>/`
- [ ] Đã kiểm tra lỗi chính tả tiếng Việt
