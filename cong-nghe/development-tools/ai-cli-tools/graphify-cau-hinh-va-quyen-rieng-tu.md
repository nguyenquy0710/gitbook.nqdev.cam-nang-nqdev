---
description: >-
  Cấu hình Graphify: .graphifyrc, .graphifyignore, biến môi trường và quyền riêng tư
  khi parse code, docs, media.
---

# Graphify: cấu hình, biến môi trường và quyền riêng tư

Bài này gom các thiết lập thực chiến của Graphify: loại trừ file, `.graphifyrc`, biến môi trường và quyền riêng tư. Đọc sau [Tính năng nâng cao](graphify-tinh-nang-nang-cao.md) hoặc khi cần tùy chỉnh Graphify cho dự án/team.

---

## 1. Loại trừ thư mục rác bằng `.graphifyignore`

Tương tự `.gitignore`, tạo `.graphifyignore` ở thư mục gốc để ngăn Graphify quét thư mục sinh mã tự động, dữ liệu giả (mock), tệp migration cũ hoặc thư mục build làm loãng đồ thị:

{% code title=".graphifyignore" overflow="wrap" lineNumbers="true" %}
```text
# .graphifyignore
**/migrations/**
**/__fixtures__/**
**/*.generated.ts
docs/archive/
```
{% endcode %}

---

## 2. Ignoring files

Graphify honor `.gitignore` và hỗ trợ `--exclude` patterns + project `.graphifyignore`. Chi tiết: [Configuration](https://docs.graphify.com/reference/configuration).

---

## 3. Project config `.graphifyrc`

Tạo `.graphifyrc` ở scan root cho settings thuộc project:

{% code title=".graphifyrc" overflow="wrap" lineNumbers="true" %}
```text
# Ambiguous extensions:
language.inc=php
language.tpl=.ts

# Viz:
viz_node_limit=0

# Query defaults:
query_budget=4000
query_depth=3
```
{% endcode %}

`query_budget` (positive int) và `query_depth` (1-6) cho `graphify query`; explicit `--budget`/`--depth` override. Default: budget 2000, depth 2. Các key này không đổi MCP server defaults.

---

## 4. Biến môi trường

Backends, API keys, hook behavior, tuning controlled by env vars. Bảng đầy đủ: [Configuration](https://docs.graphify.com/reference/configuration).

* **Claude API prompt caching:** `GRAPHIFY_CLAUDE_PROMPT_CACHE` controls system-prompt caching cho `--backend claude`. Unset/blank giữ caching enabled; `1/true/yes/on` enable, `0/false/no/off` disable. Ví dụ: `GRAPHIFY_CLAUDE_PROMPT_CACHE=0 graphify extract . --backend claude` khi endpoint Anthropic-compatible reject `cache_control`.
* **Claude CLI model:** `GRAPHIFY_CLAUDE_CLI_MODEL` override model cho `claude-cli` backend (default Opus). `haiku`/`sonnet` thường đủ cho community naming.
* **Backend selection:** `graphify extract` auto-detect provider theo API key set (priority: Gemini → Kimi → Claude → OpenAI → DeepSeek → Azure → Bedrock → Ollama), in ra env var đã chọn. Chọn explicit qua `--backend` hoặc `GRAPHIFY_BACKEND=<name>`; `GRAPHIFY_BACKEND=none` disable mọi LLM backend (code-only graph). Data-residency: `GRAPHIFY_BACKEND=ollama` / `--backend ollama` (fully local). Kimi (`MOONSHOT_API_KEY`) route tới Moonshot AI servers ở Trung Quốc.

---

## 5. Quyền riêng tư (Privacy)

* **Code files:** xử lý cục bộ qua tree-sitter. Không rời máy. Code-only corpus không cần API key: `graphify extract` chạy fully offline. Mixed repo: thêm `--code-only` để chỉ index code, skip docs/PDFs/images cần LLM.
* **Video/audio:** transcribe cục bộ bằng faster-whisper. Không rời máy.
* **Docs, PDFs, images:** gửi tới AI assistant cho semantic extraction (qua `/graphify` skill, dùng model của IDE session). Headless `graphify extract` cần `GEMINI_API_KEY`/`GOOGLE_API_KEY` (Gemini), `MOONSHOT_API_KEY` (Kimi), `ANTHROPIC_API_KEY` (Claude), `OPENAI_API_KEY` (OpenAI), `DEEPSEEK_API_KEY` (DeepSeek), AWS credentials (Bedrock), hoặc `claude` CLI binary (Claude Code subscription), hoặc Ollama local.
* **No telemetry**, no usage tracking, no analytics.
* **Query logging:** mọi `graphify query/path/explain` và MCP `query_graph` được log vào `~/.cache/graphify-queries.log` (JSON Lines: timestamp, question, corpus, nodes returned, duration). Full subgraph response **không** lưu mặc định. Set `GRAPHIFY_QUERY_LOG_DISABLE=1` để opt out, hoặc `GRAPHIFY_QUERY_LOG=/dev/null` để silence.

---

## Bước tiếp theo

* 👉 **[Tính năng nâng cao](graphify-tinh-nang-nang-cao.md)** — chế độ offline, God Nodes, liên kết PRD với code
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)** — export, Graphify Cloud, xử lý lỗi
* 👉 **[Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md)** — quay lại sử dụng
* 👉 **[Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md)** — quay lại tổng quan

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
> * [Configuration](https://docs.graphify.com/reference/configuration)
