---
description: >-
  Giải mã cấu trúc thư mục .obsidian và phân tích file JSON cấu hình từ một
  vault thực tế: app.json, core-plugins, daily-notes, hotkeys, workspace layout,
  CSS snippets.
---

# Cấu hình Obsidian thực tế — Giải mã thư mục .obsidian

Sau bài tổng quan plugin và cấu hình cơ bản, bài này đi sâu vào **thư mục `.obsidian`** — nơi lưu toàn bộ cấu hình vault. Tôi sẽ giải thích từng file dựa trên vault thực tế đang dùng.

### Cấu trúc `.obsidian`



```
.obsidian/
├── app.json                 # Cấu hình chung vault
├── appearance.json          # Giao diện (theme, accent, CSS snippets)
├── core-plugins.json        # Bật/tắt plugin mặc định
├── community-plugins.json   # Danh sách plugin cộng đồng đã cài
├── workspaces.json          # Snapshot workspace
├── workspace.json           # Layout workspace hiện tại
├── daily-notes.json         # Cấu hình Daily Notes core plugin
├── templates.json           # Cấu hình Templates core plugin
├── graph.json               # Cấu hình Graph View
├── backlink.json            # Cấu hình Backlink pane
├── switcher.json            # Cấu hình Quick Switcher
├── bookmarks.json           # Bookmarks
├── hotkeys.json             # Phím tắt tùy chỉnh
├── note-composer.json       # Cấu hình Note Composer
├── webviewer.json           # Cấu hình Web Viewer
├── types.json               # Định nghĩa kiểu dữ liệu Properties
│
├── plugins/                 # Plugin cộng đồng (13 plugins)
├── snippets/
│   └── quyit-style.css      # CSS tùy chỉnh
└── themes/
    └── Minimal/             # Theme Minimal
```

Toàn bộ file trong `.obsidian` đều là JSON — có thể chỉnh tay, backup, hoặc đồng bộ qua Git.

### `app.json` — Xương sống vault



```
{
  "showLineNumber": true,
  "alwaysUpdateLinks": true,
  "showUnsupportedFiles": true,
  "newFileLocation": "folder",
  "newFileFolderPath": "/06-notes",
  "attachmentFolderPath": "/assets",
  "trashOption": "local",
  "userIgnoreFilters": ["exports/*.pdf", "00-accounts/"],
  "promptDelete": true,
  "deleteUnlinkedAttachments": "ask"
}
```

| Key                    | Giá trị     | Tác dụng                                           |
| ---------------------- | ----------- | -------------------------------------------------- |
| `showLineNumber`       | `true`      | Số dòng — dễ debug, dễ reference khi hỏi AI        |
| `alwaysUpdateLinks`    | `true`      | **Cực kỳ quan trọng** — rename file không mất link |
| `showUnsupportedFiles` | `true`      | Xem PDF, hình ảnh trực tiếp trong Obsidian         |
| `newFileFolderPath`    | `/06-notes` | File mới mặc định vào `06-notes/`                  |
| `attachmentFolderPath` | `/assets`   | Tất cả ảnh/file đính kèm gom vào `assets/`         |
| `trashOption`          | `"local"`   | Xoá vào thùng rác OS, không giữ lại trong vault    |
| `userIgnoreFilters`    | `[...]`     | Loại `exports/*.pdf` và `00-accounts/` khỏi search |

> `"alwaysUpdateLinks": true` — không có config này, rename file sẽ làm hỏng toàn bộ liên kết.

### `core-plugins.json` — 26 plugin mặc định đang bật



**Bật:** file-explorer, global-search, switcher, graph, backlink, canvas, outgoing-link, tag-pane, footnotes, properties, page-preview, daily-notes, templates, note-composer, command-palette, slash-command, editor-status, bookmarks, outline, word-count, slides, workspaces, file-recovery, sync, bases, webviewer

**Tắt:** markdown-importer, zk-prefixer, random-note, audio-recorder, publish

Đáng chú ý:

* **Slash command** — gõ `/` để trigger command ngay trong editor
* **Properties** — metadata panel mới, thay thế frontmatter raw
* **Web Viewer** — trình duyệt trong Obsidian (hỗ trợ adblock)
* **Sync** — dùng Obsidian Sync (trả phí)
* **Slides** — trình chiếu ghi chú dạng slide

### `daily-notes.json` — Journal cá nhân



```
{
  "folder": "/01-daily-notes",
  "template": "/00-templates/daily_note_template.md",
  "format": "quyit-note-YYYY-MM-DD"
}
```

* Ghi chú hàng ngày lưu riêng folder `01-daily-notes/`
* Dùng template tại `00-templates/daily_note_template.md`
* Format tên file: `quyit-note-YYYY-MM-DD` → prefix riêng để phân biệt với daily note mặc định

> Kết hợp với **Calendar** plugin để click chọn ngày trên lịch, tự động tạo note theo template này.

### `graph.json` — Graph View tinh chỉnh



```
{
  "collapseFilter": true,
  "searchQuery": "",
  "hideUnresolved": true,
  "showOrphans": true,
  "showAttachments": false,
  "showTags": false,
  "arrow": true,
  "nodeSize": 170,
  "lineSize": 1.2,
  "force": { "center": 0.52, "repel": 10, "link": 250 },
  "zoom": { "scale": 0.36 },
  "close": true
}
```

* **Ẩn unresolved nodes** — không hiện file chưa tạo
* **Hiện orphans** — phát hiện note không có liên kết
* **Có arrow** — thấy chiều liên kết
* **Không hiện attachment/tag** — giữ graph sạch
* `close: true` — graph mặc định tắt (tránh hao RAM)

### `backlink.json` — Backlink trong nội dung



```
{ "backlinkInDocument": true }
```

Backlink hiển thị ngay cuối editor (backlinks pane), không cần mở sidebar — tiết kiệm thao tác.

### `switcher.json` — Quick Switcher



```
{
  "showExistingOnly": true,
  "showAttachments": true,
  "showAllFileTypes": false
}
```

Quick Switcher (`Cmd/Ctrl + O`) chỉ hiện file đã tồn tại, có hiện cả attachment. Phù hợp workflow **mở nhanh**, không gợi ý tạo mới.

### `types.json` — Properties gõ mạnh



Đây là file ít người biết nhưng rất hữu ích. Nó định nghĩa **kiểu dữ liệu** cho metadata:

```
{
  "Text": {
    "aliases": true,
    "week": true
  },
  "Multitext": {
    "cssclasses": true,
    "tags": true,
    "status": true
  },
  "Date": {
    "created": true,
    "updated": true,
    "date_from": true
  },
  "Number": {
    "priority": true,
    "cli_cycle_days": true
  },
  "Checkbox": {
    "done": true
  }
}
```

Bao gồm cả properties của **Tasks plugin** (`TQ_explain`, `TQ_show_*`...) — nhờ đó Tasks hiển thị đúng kiểu checkbox/date trong Properties view.

### `workspace.json` — Layout 3 panel



```
┌───────────────────┬──────────────────────┬──────────────────┐
│  Left sidebar     │  Main area           │  Right sidebar   │
│  (250px)          │  (split dọc)         │  (300px)         │
│                   │                      │                  │
│ • File explorer   │  Stack chính         │ • Backlink       │
│ • Search          │  (nhiều tab .md)     │ • Outgoing links │
│ • Bookmarks       │  + Stack phụ         │ • Tags           │
│                   │                      │ • Properties     │
│                   │                      │ • Outline        │
│                   │                      │ • Footnotes      │
│                   │                      │ • Git view       │
│                   │                      │ • Calendar       │
└───────────────────┴──────────────────────┴──────────────────┘
```

Main area chia làm 2 stack dọc — thường mở một note chính bên trái, note tham khảo bên phải.

### CSS Snippets — `quyit-style.css`



Snippet duy nhất đang dùng, ghi đè giao diện mặc định. Ví dụ thường thấy trong snippet cá nhân:

```
/* Highlight heading màu sắc */
h1 { color: var(--color-red); }
h2 { color: var(--color-orange); }
h3 { color: var(--color-yellow); }

/* Ẩn clutter không cần thiết */
.sidebar .search-input-container { margin-bottom: 4px; }

/* Task checkbox to hơn */
input[type="checkbox"] { transform: scale(1.3); cursor: pointer; }
```

### 13 Plugin cộng đồng đang dùng



| Plugin                | Vai trò                           |
| --------------------- | --------------------------------- |
| Calendar              | Lịch + click tạo daily note       |
| Cmdr                  | Gán command vào ribbon/status bar |
| CSV Obsidian          | Mở file CSV dạng bảng             |
| Dataview              | Query metadata như database       |
| Obsidian Git          | Auto backup lên GitHub            |
| Kanban                | Quản lý dự án board               |
| Mindmap NextGen       | Mindmap từ bullet list            |
| Tasks                 | To-do list nâng cao               |
| Recent Files          | Mở nhanh file vừa dùng            |
| Show All Hidden Files | Hiển thị `_index.md`, `.hidden`   |
| Templater             | Template với JavaScript           |
| Text Snippets         | Gõ tắt — `;td` → nội dung dài     |
| VSCode Editor         | Phím tắt VSCode trong Obsidian    |

Kết hợp: **Templater** + **Text Snippets** + **QuickAdd** = automation workflow gần như không chạm chuột.

### Mẹo sao lưu cấu hình



Vì `.obsidian/` là thư mục ẩn, nếu dùng **Obsidian Git** nhớ kiểm tra `.gitignore` không loại trừ nó:

```
# .gitignore — đảm bảo dòng này KHÔNG có
# .obsidian/
```

Hoặc config `app.json` → `userIgnoreFilters` để giữ cấu hình nhưng exclude file nhạy cảm.

### Kết luận



Thư mục `.obsidian` không phải "ma thuật đen" — mỗi file JSON đều có thể chỉnh tay, backup, đồng bộ. Hiểu được nó giúp bạn:

* Debug khi cấu hình lỗi
* Đồng bộ cấu hình giữa nhiều máy qua Git
* Tối ưu vault theo đúng workflow cá nhân

📢 Tham khảo: [Obsidian Help — Config folder](https://help.obsidian.md/Advanced+topics/How+Obsidian+stores+data) | [Bài 1 — Plugin](https://github.com/nguyenquy0710/gitbook.nqdev.cam-nang-nqdev/blob/opcode/minipc/opcode/obsidian/huong-dan-su-dung-obsidian-plugin-hieu-qua.md) | [Bài 2 — Cấu hình cơ bản](https://github.com/nguyenquy0710/gitbook.nqdev.cam-nang-nqdev/blob/opcode/minipc/opcode/obsidian/huong-dan-cau-hinh-obsidian.md)
