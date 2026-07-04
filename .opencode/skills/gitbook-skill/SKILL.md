---
name: gitbook-skill
description: 
---

# Skill: gitbook-skill

Hướng dẫn toàn diện về chỉnh sửa tài liệu GitBook trong môi trường external (CLI, IDE, Git-sync). Cung cấp syntax format, cấu hình và best practices để tạo và duy trì nội dung GitBook bên ngoài web UI.

Dựa trên tài liệu chính thức từ GitBook: https://gitbook.com/docs/skill.md

## Khi nào dùng skill này

Dùng khi làm việc với GitBook content qua:
- Git-synced repositories (GitHub, GitLab)
- Local markdown editors
- IDE integrations
- Command-line tools
- Bất kỳ môi trường nào edit GitBook content dạng file thay vì qua UI

## Cấu trúc GitBook

```
/
  .gitbook/
    assets/              # GitBook-managed images and files
    includes/            # Reusable content blocks
    vars.yaml            # Space-level variables
  .gitbook.yaml          # Configuration
  README.md              # Homepage
  SUMMARY.md             # Table of contents
  getting-started/       # Section folder
    installation.md
    quickstart.md
```

## Configuration Files

### .gitbook.yaml

```yaml
root: ./

structure:
  readme: ./README.md
  summary: ./SUMMARY.md

redirects:
  old-page: new-page.md
  help: support.md
```

Options:
- `root`: Root directory for docs (default: `./`)
- `structure.readme`: Path to homepage (default: `./README.md`)
- `structure.summary`: Path to TOC (default: `./SUMMARY.md`)
- `redirects`: Key-value old URL → new page path

### SUMMARY.md

```markdown
# Summary

## Use headings to create page groups

* [First page](page1/README.md)
    * [Child page](page1/page1-1.md)
* [Second page](page2/README.md)
```

Rules:
- `#` main title
- `##` headings = page groups (sidebar sections)
- `*` for pages, indent for nesting
- Paths relative to root from `.gitbook.yaml`
- Option: `[Title](page.md "Link title")` for different nav text

### Lưu ý cho dự án này

Xem `viet-bai-gitbook` skill để biết quy tắc cụ thể: 7 books gốc, bài viết lưu trực tiếp vào thư mục book, SUMMARY.md path relative từ book.

## Frontmatter

```markdown
---
description: Page description for SEO
icon: book-open
hidden: true
vars:
  page_variable: value
if: visitor.claims.unsigned.condition
layout:
  width: default  # or 'wide'
  title:
    visible: true
  description:
    visible: true
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
  metadata:
    visible: true
---
```

Fields:
- `description`: SEO description (<160 chars). Multi-line: `>-` syntax
- `icon`: Font Awesome icon name (e.g., `book-open`, `bolt`, `stars`)
- `hidden: true`: Ẩn khỏi TOC khi publish
- `vars:`: Page-level variables (key-value)
- `if:`: Adaptive content visibility condition (JS expression)
- `layout.width`: `default` or `wide`
- `layout.*.visible`: Toggle elements (title, description, tableOfContents, outline, pagination, metadata)

## Variables & Expressions

**Space-level:** `/.gitbook/vars.yaml`
```yaml
latest_version: v3.0.4
company_name: Acme Corp
```

**Page-level:** Frontmatter `vars:`
```yaml
vars:
  version: v2.1.0
```

**Expression syntax:**
```markdown
<code class="expression">space.vars.latest_version</code>
<code class="expression">page.vars.version</code>
<code class="expression">1 + 1</code>
<code class="expression">"v" + space.vars.latest_version</code>
```

## Custom Blocks

### Tabs — alternatives (languages, platforms)

````markdown
{% tabs %}
{% tab title="JavaScript" %}
```javascript
console.log('Hello');
```
{% endtab %}
{% tab title="Python" %}
```python
print("Hello")
```
{% endtab %}
{% endtabs %}
````

### Stepper — sequential multi-step processes

```markdown
{% stepper %}
{% step %}
## First step
Description...
{% endstep %}
{% step %}
## Second step
Description...
{% endstep %}
{% endstepper %}
```

### Hint — callouts with colored styling

```markdown
{% hint style="info" %}
Informational hint
{% endhint %}

{% hint style="warning" %}
Warning
{% endhint %}

{% hint style="danger" %}
Danger
{% endhint %}

{% hint style="success" %}
Success
{% endhint %}
```

### Columns — side-by-side (max 2)

```markdown
{% columns %}
{% column %}
### Left
Content...
{% endcolumn %}
{% column %}
### Right
Content...
{% endcolumn %}
{% endcolumns %}
```

### Updates — changelog/release notes

```markdown
{% updates format="full" %}
{% update date="2024-01-15" %}
# Version 2.0 Released
New features including dark mode.
{% endupdate %}
{% endupdates %}
```

### Cards — visual clickable navigation

```markdown
<table data-view="cards">
    <thead>
        <tr>
            <th>Title</th>
            <th data-card-target data-type="content-ref">Target</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Getting Started</td>
            <td><a href="getting-started/quickstart.md">Quick Start</a></td>
        </tr>
    </tbody>
</table>
```

### Embeds

```markdown
{% embed url="https://www.youtube.com/watch?v=VIDEO_ID" %}
```

### File download

```markdown
{% file src="https://example.com/doc.pdf" %}
Description of file.
{% endfile %}
```

### Buttons

```markdown
<a href="https://example.com" class="button primary">Download</a>
<a href="https://example.com" class="button secondary">Learn More</a>
<a href="https://github.com/user/repo" class="button primary" data-icon="github">View on GitHub</a>
```

### Icons (inline)

```markdown
<i class="fa-check">check</i> Feature enabled
<i class="fa-warning">warning</i> Requires configuration
```

### Expandable

```markdown
<details>
<summary>Click to expand</summary>

Hidden content here...
</details>
```

### Reusable content

```markdown
{% include "/reusable-content/rc12345" %}
```

### OpenAPI

```markdown
{% openapi src="https://api.example.com/openapi.json" path="/users" method="get" %}
[https://api.example.com/openapi.json](https://api.example.com/openapi.json)
{% endopenapi %}
```

Note: OpenAPI specs must be uploaded via API/CLI/UI, not embedded in markdown.

## Code blocks

````markdown
{% code title="index.js" %}
```javascript
const foo = 'bar';
```
{% endcode %}
````

## Links

- External: `[text](https://example.com)`
- Internal: relative paths `[text](page.md)` or `[text](../folder/page.md)`
- Email: `[text](mailto:email@example.com)`

## Math/TeX

```markdown
Inline: $$E = mc^2$$

Block:
$$
E = mc^2
$$
```

## Khi nào dùng block nào

| Need | Use | Why |
|---|---|---|
| Sequential instructions | `{% stepper %}` | Multi-step process |
| Alternatives | `{% tabs %}` | Languages, platforms |
| Optional details | `<details>` | Keep page scannable |
| Warnings/tips | `{% hint %}` | Colored callouts |
| Side-by-side | `{% columns %}` | Parallel info (max 2) |
| Changelog | `{% updates %}` | Reverse chronological |
| Navigation cards | `<table data-view="cards">` | Clickable card grid |
| Downloadable files | `{% file %}` | Files with captions |
| CTA links | `<a class="button">` | Primary/secondary actions |
| Reusable content | `{% include %}` | Consistency across pages |
| Dynamic content | `<code class="expression">` | Auto-updating variables |

## Common Pitfalls

- Không reference cùng 1 file `.md` 2 lần trong SUMMARY.md
- File path trong SUMMARY.md phải consistent với file location thực tế
- Luôn đóng custom blocks properly (`{% endtab %}`, `{% endhint %}`, etc.)
- Test custom blocks trong GitBook sau khi edit local
- Với Git Sync: manage README.md chỉ qua repository tránh conflict
- Tables và columns trong markdown thuần bị hạn chế — dùng custom blocks
- Mix tab/space trong SUMMARY.md gây lỗi

## Git Sync Workflow

1. Changes in Git → tự động update GitBook
2. Changes in GitBook → tự động commit lên Git
3. GitBook maintain SUMMARY.md dựa trên UI edits
4. Resolve merge conflicts trong Git

Best practices:
- Structural changes (navigation) qua SUMMARY.md trong Git
- Content changes: consistent giữa Git hoặc GitBook UI
- Review auto-generated commits từ GitBook
- Branch-based workflow cho significant updates
- Test preview trước khi merge main

## Xem thêm

Skill `viet-bai-gitbook` trong cùng project — chứa quy tắc viết tiếng Việt, cấu trúc 7 books, và quy trình đăng bài cụ thể cho dự án này.
