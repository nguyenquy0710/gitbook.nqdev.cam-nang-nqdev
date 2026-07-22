---
description: >-
  CodeGraph là MCP server biến codebase thành knowledge graph, giúp AI coding
  agent truy vấn cấu trúc code tức thì, tiết kiệm đến 89% tool calls.
---

# CodeGraph: 'bản đồ tư duy' giúp AI agent hiểu codebase siêu tốc

Khi AI coding agent làm việc với codebase lạ, nó phải dùng grep, glob, Read để mò mẫm từng file. Mỗi câu hỏi về cấu trúc kích hoạt hàng loạt tool calls tốn token. **CodeGraph** giải quyết triệt để vấn đề này.

Đây là MCP server mã nguồn mở do **colbymchenry** phát triển, xây dựng knowledge graph cho toàn bộ codebase — giúp AI agent truy vấn cấu trúc code trong 1-2 lần gọi thay vì phải đọc từng file. Dự án đạt **61.000+ sao** trên GitHub.

> 📎 **GitHub:** [github.com/colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
> 📎 **Docs:** [colbymchenry.github.io/codegraph](https://colbymchenry.github.io/codegraph/)

---

## Vấn đề: AI agent đang "mò mẫm" trong codebase

Agent phải tự khám phá cấu trúc: grep → glob → Read → grep lại → đọc thêm file. Hàng chục tool calls trước khi bắt đầu xử lý thực sự.

CodeGraph thay đổi điều đó: thay vì mò mẫm, agent chỉ cần hỏi graph một câu và nhận được chính xác code cần.

---

## Tính năng chính

### Rust kernel siêu nhanh

CodeGraph dùng **Rust kernel** cho parsing engine, hỗ trợ 20+ ngôn ngữ: TypeScript, JavaScript, Python, Go, Rust, Java, C#, VB.NET, PHP, Ruby, C, C++, CUDA, Objective-C, Swift, Kotlin, Scala, Dart, Lua, Svelte, Vue, Astro, Terraform...

Mỗi ngôn ngữ được verify byte-for-byte identical với reference engine trên real repository. File bị lỗi syntax tự động fallback per-file.

### Framework-aware Routes

Nhận diện routing files của 17+ web frameworks và link URL pattern tới handler:

{% tabs %}
{% tab title="Web Frameworks" %}
* **Django:** `path()`, `re_path()`, `url()` trong `urls.py`
* **Flask:** `@app.route()`, blueprint routes
* **FastAPI:** `@app.get()`, `@router.post()`
* **Express:** `app.get()`, `router.post()`
* **NestJS:** `@Controller` + `@Get`, `@Resolver` + `@Query`
* **Laravel:** `Route::get()`, `Route::resource()`
* **Spring:** `@GetMapping`, `@PostMapping`, `@RequestMapping`
* **ASP.NET:** `[HttpGet("/x")]` attributes
* **Gin/chi/gorilla:** `r.GET()`, `router.HandleFunc()`
* **Rails:** `get '/x', to: 'users#index'`
* **React Router / SvelteKit / Vue Router / Astro**
{% endtab %}
{% endtabs %}

### Mixed iOS / React Native / Expo Bridging

Kết nối cross-language flows: Swift ↔ ObjC, React Native legacy bridge + TurboModules + Fabric, native → JS event emitters, Expo Modules.

### Auto-sync thời gian thực

File watcher dùng native OS events (FSEvents/inotify/ReadDirectoryChangesW), debounce auto-sync. Graph luôn fresh — không cần chạy lại gì cả.

### Impact Analysis & codegraph affected

Trace callers, callees, blast radius. Riêng lệnh `codegraph affected` tìm test files bị ảnh hưởng từ git diff — chạy đúng test cần thiết trong CI.

### 100% Local

SQLite database, không API key, không data rời khỏi máy.

---

## Benchmark: 89% fewer tool calls

Kết quả benchmark trên Claude Opus 4.8 với 7 codebase thực tế:

| Codebase | WITH CodeGraph | WITHOUT | Savings |
|---|---|---|---|
| **VS Code** (~11k files) | 2 tools / 41s / $0.36 | 40 tools / 3m24s / $1.41 | 83% tokens, 75% cost |
| **Excalidraw** (~640 files) | 3 tools / 36s / $0.40 | 55 tools / 23s / $1.81 | 89% tokens, 78% cost |
| **Django** (~3k files) | 2 tools / 42s / $0.35 | 29 tools / 1m8s / $1.13 | 78% tokens, 69% cost |
| **Tokio** (Rust, ~790 files) | 3 tools / 46s / $0.44 | 57 tools / 2m11s / $3.04 | 91% tokens, 86% cost |
| **OkHttp** (Java, ~645 files) | 1 tool / 27s / $0.23 | 5 tools / 30s / $0.20 | 33% tokens |
| **Gin** (Go, ~110 files) | 3 tools / 30s / $0.27 | 10 tools / 1m10s / $0.46 | 18% tokens, 41% cost |
| **Alamofire** (Swift, ~110 files) | 3 tools / 49s / $0.35 | 53 tools / 31s / $2.51 | 90% tokens, 86% cost |

**Trung bình: 89% fewer tool calls · 60% rẻ hơn · 69% fewer tokens · 0 file reads.**

---

## So sánh: CodeGraph vs codebase-memory-mcp

Cả hai đều là MCP server cho code intelligence, nhưng có điểm mạnh khác nhau:

{% tabs %}
{% tab title="CodeGraph" %}
* **Ngôn ngữ:** TypeScript/Node (kernel Rust)
* **Số ngôn ngữ:** 20+
* **Type resolution:** Tree-sitter
* **Cơ sở dữ liệu:** SQLite + FTS5
* **Cài đặt:** `npx @colbymchenry/codegraph`
* **Sao GitHub:** ~61k
* **Điểm mạnh:** Auto-sync, framework routes, iOS/RN bridging, `codegraph affected`, cộng đồng lớn
{% endtab %}
{% tab title="codebase-memory-mcp" %}
* **Ngôn ngữ:** C (static binary)
* **Số ngôn ngữ:** 158 (tree-sitter)
* **Type resolution:** Hybrid LSP
* **Cơ sở dữ liệu:** SQLite
* **Cài đặt:** `curl -fsSL ... | bash`
* **Sao GitHub:** ~33k
* **Điểm mạnh:** Nhiều ngôn ngữ nhất, static binary không dependency, hybrid type resolution, 14 MCP tools
{% endtab %}
{% endtabs %}

| Tiêu chí | CodeGraph | codebase-memory-mcp |
|---|---|---|
| **Số ngôn ngữ** | 20+ | 158 |
| **Engine** | Rust kernel + Node | C static binary |
| **Auto-sync** | ✅ Native OS events | ❌ |
| **Framework routes** | ✅ 17+ frameworks | ❌ |
| **iOS/RN bridging** | ✅ | ❌ |
| **Hybrid LSP** | ❌ | ✅ |
| **MCP tools** | 1 (codegraph_explore) | 14 tools |
| **Static binary** | ❌ (cần Node) | ✅ |
| **Sao GitHub** | ~61k | ~33k |

{% hint style="info" %}
Chọn **CodeGraph** nếu bạn cần auto-sync, framework routes, và cộng đồng lớn. Chọn **codebase-memory-mcp** nếu bạn cần nhiều ngôn ngữ, static binary, và nhiều MCP tools hơn.
{% endhint %}

---

## Cách cài đặt

{% code title="Cài đặt CodeGraph" overflow="wrap" lineNumbers="true" %}
```bash
# Bước 1: Chạy installer (tự động dò agent đang dùng)
npx @colbymchenry/codegraph

# Bước 2: Index project
cd your-project
codegraph init

# Bước 3: Dùng với Claude Code / Cursor / Codex / opencode
# Agent tự động dùng codegraph_explore để truy vấn

# Bước 4: (Không cần) Auto-sync tự động cập nhật graph khi code thay đổi
```
{% endcode %}

CodeGraph hỗ trợ: Claude Code, Cursor, Codex CLI, opencode, Hermes Agent, Gemini CLI, Antigravity IDE, Kiro.

---

## Kết luận

CodeGraph là công cụ mạnh mẽ giúp AI coding agent tiết kiệm token và thời gian đáng kể khi làm việc với codebase lớn. Với Rust kernel nhanh, auto-sync thời gian thực, framework-aware routes và khả năng impact analysis — đây là lựa chọn hàng đầu cho team dùng AI coding agent trên dự án thực tế.

> 🔗 **Tài liệu tham khảo:**
> * [GitHub: CodeGraph](https://github.com/colbymchenry/codegraph)
> * [Documentation](https://colbymchenry.github.io/codegraph/)
> * [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
