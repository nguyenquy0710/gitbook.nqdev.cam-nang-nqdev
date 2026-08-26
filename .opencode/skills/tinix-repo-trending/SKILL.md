---
name: tinix-repo-trending
description: Tra cứu và lấy dữ liệu từ TiniX Repo Trending (https://repo.tinix.ai/vi) — dự án mã nguồn mở thịnh hành, dự án mới, AI models/datasets từ GitHub & HuggingFace, bài viết blog tiếng Việt, thống kê nền tảng. Dùng skill này bất cứ khi nào người dùng muốn tìm dự án trending, "top GitHub", "dự án mới nổi", "xu hướng mã nguồn mở", lọc theo danh mục (LLM, AI Agent, RAG, MCP, DevOps...), ngôn ngữ (Rust, Python...), tìm kiếm dự án, xem bài viết đánh giá dự án, hoặc số liệu thống kê của repo.tinix.ai — kể cả khi người dùng chỉ gõ URL mà không nói rõ muốn lấy gì. Cũng dùng khi cần ví dụ dự án thực tế để viết bài hướng dẫn, so sánh công cụ, hoặc bổ sung thông tin mới vào cẩm nang.
---

# TiniX Repo Trending

Skill truy cập **TiniX Repo Trending** — nền tảng theo dõi dự án nguồn mở thịnh hành (GitHub & HuggingFace), cập nhật hàng giờ. Site render phần lớn nội dung tĩnh (blog, project detail) nhưng **bảng trending tải bằng server action** nên phải gọi qua API — đừng chỉ `webfetch` trang chủ vì sẽ không thấy danh sách dự án.

## Nguồn dữ liệu & cách lấy

| Nguồn | Cách truy cập | Dùng khi |
|---|---|---|
| Bảng xếp hạng dự án / model / dataset | Server action `fetchDynamicRankings` qua script | Muốn danh sách dự án theo xu hướng, mới, filter, sort |
| Thống kê nền tảng | Server action `fetchGlobalStats` | Muốn tổng số dự án đang theo dõi |
| Bộ lọc phổ biến | Server action `fetchPopularFilters` | Muốn danh sách ngôn ngữ / hashtag / danh mục hợp lệ |
| Gợi ý tìm kiếm | Server action `actionSearchProjectsSuggestions` | Muốn gợi ý tên dự án theo từ khoá |
| Bài viết blog | `webfetch https://repo.tinix.ai/vi/blog` | Muốn bài viết đánh giá/hướng dẫn tiếng Việt |
| Chi tiết dự án | `webfetch https://repo.tinix.ai/vi/project/<slug>` | Muốn thông tin đầy đủ một dự án (badge, lịch sử, dự án tương tự) |

## Truy vấn dữ liệu xếp hạng (quan trọng nhất)

Script: `scripts/tinix_api.py` (chỉ dùng Python stdlib, không cần cài gì).

```bash
python3 .opencode/skills/tinix-repo-trending/scripts/tinix_api.py rankings --type trending --days 7 --limit 10
```

Tham số chính:

- `--type trending|all|new` — trending (thịnh hành), all (tất cả), new (dự án mới)
- `--days` — khoảng thời gian (mặc định 7; preset của site: 1, 7, 30)
- `--limit`, `--offset` — phân trang
- `--source github|huggingface` — nguồn (mặc định github)
- `--category` — danh mục theo **tên hiển thị**, VD `"LLM"`, `"AI Agent"`, `"Developer Tools"` (xem `references/categories.md`)
- `--tag` — hashtag, VD `MCP`, `RAG`, `AI Agent`
- `--language` — ngôn ngữ chính, VD `Rust`, `Python`, `Go`
- `--search` — tìm kiếm tự do theo tên/mô tả
- `--sort trend|stars|likes|views|recent|updated` — sắp xếp
- `--order asc|desc` — chiều sắp xếp
- `--min-stars`, `--min-downloads`, `--license` — lọc thêm
- `--list` — in bảng gọn thay vì JSON đầy đủ

Ví dụ:

```bash
# Top 5 dự án AI Agent nổi nhất tuần
python3 tinix_api.py rankings --type trending --days 7 --limit 5 --category "AI Agent" --list

# 20 dự án mới nhất hôm nay
python3 tinix_api.py rankings --type new --days 1 --limit 20 --sort updated --list

# Tìm dự án về RAG/vector search
python3 tinix_api.py rankings --type all --days 30 --limit 10 --search "vector" --list

# Model HuggingFace trending
python3 tinix_api.py rankings --source huggingface --type trending --days 3 --limit 10 --list
```

### Cấu trúc phản hồi

Mỗi project trả về object gồm (chọn lọc):

- `fullName` — `owner/repo` (hoặc `org/model` cho HF)
- `description`, `primaryLanguage`, `license`, `source` (`github`/`huggingface`), `projectType` (`repository`/`model`/`dataset`)
- `stars`, `starsGained`, `forks`, `forksGained`, `downloads`, `downloadsGained`, `views`, `watchers`, `openIssues`, `contributorsCount`, `mentionsCount`
- `momentumScore`, `velocityScore`, `score`, `rank`
- `categories` — mảng `{name, slug, icon}` (dùng `name` khi lọc `--category`)
- `tags`, `topics`, `countryCode`, `sourceUrl`, `slug`, `createdAt`, `sourceUpdatedAt`, `lastCrawledAt`, `sparklineData` (lịch sử tăng trưởng 30 ngày)

Kết quả có kèm `total` — tổng số kết quả khớp (để tính phân trang).

## Thống kê & bộ lọc

```bash
python3 tinix_api.py stats     # {"totalProjects": 490169, "trendingProjects": 252754, "newProjects": 720}
python3 tinix_api.py filters   # languages, hashtags, categories, topics hợp lệ
```

## Bài viết blog & chi tiết dự án (dùng webfetch)

- **Danh sách bài viết:** `https://repo.tinix.ai/vi/blog` — lọc theo `?topic=LLM`, `?subtopic=Rust`, `?tag=javascript`, phân trang `?page=2`. Trang `/vi/blog` có ~500 trang (chú ý giới hạn).
- **Nội dung bài viết:** `https://repo.tinix.ai/vi/blog/<slug>` — gồm tóm lược dự án, môi trường chuẩn bị, quy trình cài đặt, dự án tương tự, bài viết liên quan. Lấy được slug từ danh sách.
- **Chi tiết dự án:** `https://repo.tinix.ai/vi/project/<slug>-<id>` — ghép trường `slug` và `id` (UUID) lấy từ kết quả `rankings`, VD `.../vi/project/yc-software-qm-5bfda3ca-...`. Trang gồm sao/fork/issue/views, thành tựu (badge #1 Repository Của Tuần), phân loại, tab Giới thiệu/Cộng đồng/Thành tựu/Bài viết, dự án tương tự.

## Ghi chú kỹ thuật

- Server action là POST tới `https://repo.tinix.ai/vi` với header `Next-Action: <id>`; body là JSON array chứa argument. Action IDs có thể đổi khi site được deploy lại — nếu gọi script lỗi 404 hoặc không ra dữ liệu, kiểm tra lại ID trong file script (và thử fetch lại chunk JS của trang để tìm ID mới qua chuỗi `createServerReference`).
- Kết quả server action theo định dạng Flight `N:<json>` theo từng dòng — script đã tự parse, **không** dùng `grep` raw.
- `--category` nhận **tên hiển thị** (VD `Ecosystem (Global)`, `Robotics & IoT`), không nhận slug. Xem danh sách đầy đủ trong `references/categories.md`.
- HuggingFace trending hiện có thể trả về 0 dự án (tuỳ dữ liệu tại thời điểm gọi) — nếu rỗng, hãy thử `--source huggingface` kèm `--type all` hoặc không `--source`.
- Site có giới hạn tốc độ nhẹ; nên gọi `--limit` vừa phải và cache kết quả nếu cần dùng lại trong cùng phiên.

## Xử lý sự cố

- **Không thấy danh sách dự án khi webfetch trang chủ** → đúng, đó là trang client-side; phải dùng script `rankings`.
- **Lỗi thời gian chờ / 429** → thử lại sau vài giây, giảm `--limit`.
- **Action ID hết hạn** → đọc hướng dẫn cập nhật trong `references/action-ids.md`.
