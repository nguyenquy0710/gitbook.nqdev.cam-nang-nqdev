---
description: >-
  Hướng dẫn cấu hình Obsidian từ cơ bản đến nâng cao: editor, core plugins,
  hotkeys, backup với Git, template, và automation workflow.
---

# Hướng dẫn cấu hình Obsidian

Obsidian rất linh hoạt nhờ khả năng tuỳ chỉnh sâu. Bài viết này hướng dẫn thiết lập các cấu hình quan trọng giúp bạn tối ưu trải nghiệm ghi chú.

## Cấu hình Editor

**Settings → Editor**

| Tuỳ chọn | Gợi ý | Giải thích |
|----------|-------|------------|
| Spell check | Bật | Phát hiện lỗi chính tả tiếng Anh |
| Vim key bindings | Tuỳ chọn | Nếu quen Vim, bật để thao tác không rời bàn phím |
| Default new tab page | `Empty` hoặc `Your Homepage` | Không mở file cũ mỗi lần tạo tab |
| Show frontmatter | `Show` | Luôn thấy metadata YAML |
| Fold heading | Bật | Thu gọn section theo heading |
| Fold indent | Bật | Thu gọn list lồng nhau |
| Auto pair brackets | Bật | Tự động đóng ngoặc, quote |
| Auto convert HTML | Bật | Dán HTML → Markdown tự động |

## Core Plugins — Nên bật

Vào **Settings → Core plugins**, bật các plugin sau nếu chưa bật:

| Plugin | Công dụng |
|--------|-----------|
| **Daily notes** | Tạo ghi chú mỗi ngày, tích hợp với Periodic Notes |
| **Templates** | Chèn template từ folder chỉ định |
| **Starred** | Đánh dấu file/folder yêu thích |
| **Outline** | Xem cấu trúc heading của ghi chú hiện tại |
| **Workspaces** | Lưu và chuyển đổi giữa các bố cục làm việc |
| **Graph view** | Xem đồ thị liên kết giữa các ghi chú |
| **Page preview** | Hover link → xem trước nội dung |
| **File recovery** | Tự động lưu version — phòng mất dữ liệu |

## Thiết lập Hotkeys

**Settings → Hotkeys** — một số phím tắt nên gán:

| Phím tắt | Hành động | Ghi chú |
|----------|-----------|---------|
| `Cmd/Ctrl + Shift + P` | Command palette | Mặc định, cực kỳ quan trọng |
| `Cmd/Ctrl + N` | New note | Tạo ghi chú mới |
| `Cmd/Ctrl + Shift + D` | Quick switcher | Chuyển file nhanh |
| `Cmd/Ctrl + ,` | Open settings | Mở cài đặt |
| `Cmd/Ctrl + Shift + L` | Toggle checkbox | Đánh dấu task |
| `Cmd/Ctrl + [` hoặc `]` | Indent/outdent list | Thụt lề danh sách |
| `Alt/Option + ←/→` | Go back/forward | Điều hướng lịch sử |
| `Cmd/Ctrl + Shift + F` | Search in all files | Tìm kiếm toàn vault |

> Mẹo: Export hotkeys config ở **Settings → Hotkeys → Export** để đồng bộ giữa các máy.

## Cấu hình Template

1. Tạo folder `_templates/` ở thư mục gốc vault
2. **Settings → Core plugins → Templates → Template folder location**: `_templates`
3. Tạo file template mẫu:

```markdown
---
created: {{date}}
updated: {{date}}
tags:
  - daily
---

# {{title}}

## Việc cần làm

- [ ]

## Ghi chú trong ngày

```

Dùng `Cmd/Ctrl + Shift + T` để chèn template vào ghi chú hiện tại.

## Backups với Obsidian Git

Plugin **Obsidian Git** cho phép tự động commit & push vault lên GitHub.

Cấu hình sau khi cài plugin:

**Settings → Obsidian Git**

| Tuỳ chọn | Gợi ý |
|----------|-------|
| Vault backup interval (minutes) | `15` hoặc `30` |
| Auto pull interval (minutes) | `60` |
| Commit message | `Auto backup {{date}}` |
| Push on backup | Bật |
| Pull on startup | Bật |

Sau khi cấu hình, mỗi 15 phút vault sẽ tự động backup lên GitHub — an tâm tuyệt đối.

## Workspace — Bố cục làm việc

Tính năng **Workspaces** (core plugin) lưu trạng thái: pane nào mở, vị trí, kích thước.

Cách dùng:
1. Sắp xếp giao diện theo ý muốn (ví dụ: 2 pane — trái soạn thảo, phải graph view)
2. `Cmd/Ctrl + P` → gõ `Manage workspace layouts` → **Save** với tên `Writing`
3. Tạo thêm layout `Reading`, `Dashboard`, v.v.
4. Chuyển đổi nhanh qua Command palette

## Automation với Templater + QuickAdd

Đây là combo workflow mạnh nhất trong Obsidian:

### Bước 1: Cài Templater

Tạo template thông minh với JavaScript:

```markdown
---
created: <% tp.date.now("YYYY-MM-DD HH:mm") %>
type: <% await tp.system.suggester(["Article", "Note", "Project"], ["article", "note", "project"]) %>
---
# <% tp.file.title %>

## Context

<% tp.web.daily_quote() %>
```

### Bước 2: Cài QuickAdd

Cấu hình QuickAdd để capture nhanh:
- **Capture to Inbox**: Một phím tắt, mở popup, gõ nội dung, tự động lưu vào `_inbox/<ngày>.md`
- **Template**: Chạy template Templater với một cú nhấp

## CSS Snippets — Tuỳ biến giao diện thủ công

**Settings → Appearance → CSS snippets**

Tạo file `_snippets/custom.css` trong vault:

```css
/* Highlight heading màu sắc */
h1 { color: var(--color-red); }
h2 { color: var(--color-orange); }
h3 { color: var(--color-yellow); }
h4 { color: var(--color-green); }

/* Ẩn scrollbar ngang */
.markdown-preview-view::-webkit-scrollbar { display: none; }

/* Task checkbox to hơn */
input[type="checkbox"] { transform: scale(1.3); }
```

Bật snippet trong Settings → Appearance → CSS snippets → click reload.

## Cấu hình Sync (Obsidian Sync)

Nếu dùng **Obsidian Sync** (trả phí):

**Settings → Sync**
- Bật: `Sync only specified folders` (chọn folder cần sync)
- Remote vault: tạo vault riêng
- Encryption: nhập mật khẩu riêng (kể cả Obsidian cũng không đọc được)

> Thay thế free: **Obsidian Git** + GitHub private repo.

## Kết luận

Obsidian mạnh ở khả năng tuỳ biến. Hãy dành thời gian cấu hình một lần — template, hotkeys, backup — để về sau ghi chú không gián đoạn. Bắt đầu với: bật Daily notes + Templates, cài Obsidian Git, gán hotkeys cơ bản.

📢 Tham khảo: [Obsidian Help](https://help.obsidian.md) | [Learn Anything — Obsidian Plugin](https://learn-anything.vn/kien-thuc/obsidian/su-dung-obsidian-plugin-hieu-qua)
