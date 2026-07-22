---
description: >-
  So sánh chi tiết CodeGraph, GitNexus và codebase-memory-mcp — ba MCP server code
  intelligence giúp AI coding agent hiểu codebase. Bảng so sánh, use cases và
  cách chọn.
---

# So sánh CodeGraph, GitNexus và codebase-memory-mcp

Hiện nay có ba công cụ MCP code intelligence nổi bật: CodeGraph (~61k sao), GitNexus (~44.5k sao) và codebase-memory-mcp (~33k sao). Cả ba đều biến codebase thành knowledge graph cho AI agent, nhưng mỗi công cụ có thế mạnh riêng.

## Bảng so sánh tổng quan

| Tiêu chí | CodeGraph | GitNexus | codebase-memory-mcp |
|---|---|---|---|
| **Tác giả** | colbymchenry | Abhigyan Patwari | DeusData |
| **Ngôn ngữ gốc** | Rust kernel + Node.js | TypeScript + Node.js | C (static binary) |
| **Số ngôn ngữ parse** | 20+ | 14 | 158 |
| **Type resolution** | Tree-sitter | Tree-sitter + confidence scoring | Hybrid LSP (C, nhúng sẵn) |
| **Cơ sở dữ liệu** | SQLite + FTS5 | LadybugDB (graph + vector) | SQLite |
| **Số MCP tools** | 1 (`codegraph_explore`) | 16+ | 14 |
| **Cài đặt** | `npx @colbymchenry/codegraph` | `npm install -g gitnexus` | `curl -fsSL ... \| bash` |
| **Sao GitHub** | ~61k | ~44.5k | ~33k |
| **License** | MIT | PolyForm Noncommercial | MIT |

## So sánh tính năng

{% tabs %}
{% tab title="Ngôn ngữ hỗ trợ" %}
| Công cụ | Chi tiết |
|---|---|
| **codebase-memory-mcp** | Dẫn đầu với **158 ngôn ngữ** nhờ tree-sitter + hybrid LSP. Bao gồm cả ngôn ngữ hiếm: Zig, Elixir, OCaml, Perl, SQL, Dockerfile... |
| **CodeGraph** | **20+ ngôn ngữ** phổ biến: TypeScript, Python, Go, Rust, Java, C#, PHP, Swift, Kotlin, Dart, C/C++, Ruby, Lua, Svelte, Vue, Astro, Terraform... |
| **GitNexus** | **14 ngôn ngữ** cốt lõi: TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++, Dart |
{% endtab %}
{% tab title="MCP Tools" %}
| Công cụ | Chi tiết |
|---|---|
| **CodeGraph** | 1 tool duy nhất (`codegraph_explore`) nhưng cực kỳ mạnh — tự động follow dynamic dispatch, trả về symbol, call paths và code snippets trong 1 lần gọi. |
| **GitNexus** | **16+ tools** chia làm 3 nhóm: query, context, impact, detect_changes, rename, cypher, clusters, process, wiki... + 2 prompts + 4 agent skills tự động cài. |
| **codebase-memory-mcp** | **14 tools** chia 3 nhóm: indexing (4), querying (8), quản lý (2). Hỗ trợ Cypher query trực tiếp. |
{% endtab %}
{% tab title="Tính năng đặc biệt" %}
| Tính năng | CodeGraph | GitNexus | codebase-memory-mcp |
|---|---|---|---|
| **Auto-sync** | ✅ Native OS events | ❌ (cần reindex) | ❌ |
| **Framework routes** | ✅ 17+ frameworks | ❌ | ❌ |
| **iOS/RN bridging** | ✅ Swift-ObjC-RN-Expo | ❌ | ❌ |
| **Web UI** | ❌ | ✅ Zero-server (WASM) | ❌ |
| **Multi-repo groups** | ❌ | ✅ | ❌ |
| **Static binary** | ❌ (cần Node) | ❌ (cần Node) | ✅ |
| **Hybrid LSP** | ❌ | ❌ | ✅ |
| **Agent skills** | ❌ | ✅ 4 skills | ❌ |
| **Confidence scoring** | ❌ | ✅ | ❌ |
| **Git diff impact** | ✅ risk-classified | ✅ | ✅ risk-classified |
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Cả ba công cụ đều 100% local, không cần API key, không gửi dữ liệu ra ngoài.
{% endhint %}

## Use cases: Chọn công cụ nào?

### Chọn CodeGraph nếu...

* Bạn cần **auto-sync thời gian thực** — graph tự cập nhật khi save file
* Dự án của bạn dùng nhiều **web frameworks** (Django, FastAPI, Express, NestJS, Spring...)
* Bạn làm việc với **iOS/React Native** codebase (Swift-ObjC-RN-Expo bridging)
* Bạn muốn cộng đồng lớn nhất (~61k sao) và benchmark chi tiết

### Chọn GitNexus nếu...

* Bạn muốn **Web UI** để khám phá codebase trực quan trong trình duyệt
* Team bạn có **nhiều microservices** cần phân tích xuyên repo
* Bạn cần **confidence scoring** để biết mức độ tin cậy của từng quan hệ
* Bạn muốn **agent skills** tự động cài đặt cho Claude Code / Codex
* Bạn chấp nhận license PolyForm Noncommercial

### Chọn codebase-memory-mcp nếu...

* Dự án của bạn dùng **ngôn ngữ hiếm** (Zig, Elixir, OCaml, Perl...)
* Bạn cần **static binary** không dependency — chạy được mọi nơi không cần runtime
* Bạn cần **hybrid LSP** để type resolution chính xác hơn tree-sitter đơn thuần
* Bạn muốn nhiều MCP tools (14) với Cypher query support
* Bạn muốn giải pháp nhẹ nhất, nhanh nhất

## Bảng quyết định nhanh

| Nếu bạn cần... | Chọn... |
|---|---|
| Hỗ trợ nhiều ngôn ngữ nhất | codebase-memory-mcp |
| Auto-sync & Framework routes | CodeGraph |
| Web UI & Multi-repo | GitNexus |
| Static binary, không cần runtime | codebase-memory-mcp |
| Cộng đồng lớn nhất | CodeGraph |
| Nhiều MCP tools nhất | GitNexus (16+) |
| Type resolution tốt nhất | codebase-memory-mcp (hybrid LSP) |
| Zero-server, chạy trong browser | GitNexus |
| iOS/React Native | CodeGraph |
| License MIT tự do | CodeGraph hoặc codebase-memory-mcp |

{% hint style="success" %}
**Không có công cụ "tốt nhất" — chỉ có công cụ phù hợp nhất.** Cả ba đều giải quyết cùng vấn đề (AI agent hiểu codebase) nhưng theo cách tiếp cận khác nhau. Hãy chọn dựa trên ngôn ngữ dự án, workflow và yêu cầu cụ thể của team bạn.
{% endhint %}

## Tổng kết

Cả ba công cụ đại diện cho hướng đi mới trong code intelligence: thay vì để AI agent tự mò mẫm grep/glob/Read từng file, chúng xây dựng knowledge graph và cho phép truy vấn có cấu trúc. Sự khác biệt nằm ở triết lý thiết kế:

* **CodeGraph** — "Một tool làm tất cả" với auto-sync và framework awareness
* **GitNexus** — "Hệ sinh thái đầy đủ" với Web UI, multi-repo và confidence scoring
* **codebase-memory-mcp** — "Nhẹ nhất, nhanh nhất" với static binary và 158 ngôn ngữ

Dù chọn công cụ nào, việc trang bị MCP code intelligence cho AI agent là khoản đầu tư xứng đáng — giúp tiết kiệm token, thời gian và tăng độ chính xác khi làm việc với codebase lớn.

> 🔗 **Tài liệu tham khảo:**
> * [CodeGraph](https://github.com/colbymchenry/codegraph)
> * [GitNexus](https://github.com/abhigyanpatwari/GitNexus)
> * [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
