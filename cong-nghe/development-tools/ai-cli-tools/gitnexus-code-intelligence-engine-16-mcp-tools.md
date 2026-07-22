---
description: >-
  GitNexus là zero-server code intelligence engine biến codebase thành knowledge
  graph với 16+ MCP tools, chạy hoàn toàn trong trình duyệt hoặc CLI. Mã nguồn
  mở 44.5k sao GitHub.
---

# GitNexus: zero-server code intelligence engine với 16+ MCP tools

Khi AI coding agent làm việc với codebase lạ, nó thường phải grep, glob và đọc từng file để hiểu cấu trúc. **GitNexus** giải quyết triệt để vấn đề này bằng cách tiền tính toán mọi quan hệ trong codebase thành knowledge graph — và expose qua 16+ MCP tools để agent truy vấn tức thì.

Đây là dự án mã nguồn mở do **Abhigyan Patwari** phát triển, đạt **44.500+ sao** trên GitHub chỉ trong chưa đầy một năm. Điểm khác biệt lớn nhất: GitNexus chạy **zero-server** — có cả Web UI chạy hoàn toàn trong trình duyệt (WASM) lẫn CLI + MCP cho AI agent.

> 📎 **GitHub:** [github.com/abhigyanpatwari/GitNexus](https://github.com/abhigyanpatwari/GitNexus)
> 📎 **Web UI Demo:** [gitnexus.vercel.app](https://gitnexus.vercel.app)
> 📎 **npm:** [npmjs.com/package/gitnexus](https://www.npmjs.com/package/gitnexus)

---

## Hai cách dùng GitNexus

GitNexus cung cấp hai bề mặt sử dụng với cùng khả năng graph:

{% tabs %}
{% tab title="Web UI (Zero-Server)" %}
Truy cập [gitnexus.vercel.app](https://gitnexus.vercel.app) — kéo thả file ZIP hoặc dán URL GitHub repository. Toàn bộ quá trình index và phân tích chạy trong browser nhờ **WebAssembly** (Tree-sitter WASM + LadybugDB WASM).

* **Không cần cài đặt** — mở trình duyệt là dùng được ngay
* **Không upload code** — mọi xử lý ở phía client
* **Graph RAG Agent** tích hợp sẵn để chat với codebase
* Giới hạn ~5.000 files do bộ nhớ browser
{% endtab %}
{% tab title="CLI + MCP" %}
Cài đặt global và index repository local:

```bash
npm install -g gitnexus
cd your-project
gitnexus analyze
gitnexus setup   # tự động dò và cấu hình MCP cho agent
```

CLI expose **16+ MCP tools** cho: Claude Code, Cursor, Codex, OpenCode, Antigravity (Google), Windsurf, CodeBuddy (Tencent), Qoder (Alibaba).

* Index toàn bộ repo, không giới hạn kích thước
* Lưu graph tại `.gitnexus/` trong project
* Claude Code và Codex nhận thêm hooks: PreToolUse (enrich context) + PostToolUse (phát hiện stale index)
{% endtab %}
{% endtabs %}

---

## Kiến trúc Precomputed Relational Intelligence

Khác với Graph RAG truyền thống — nơi LLM tự khám phá graph qua nhiều query — GitNexus **tiền tính toán** mọi quan hệ tại index time. Kết quả: 1 tool call trả về complete context, không cần multi-query chain.

Pipeline indexing gồm **6 pha**:

| Pha | Mô tả |
| --- | ----- |
| **Structure** | Xây dựng cây thư mục, tạo CONTAINS edges |
| **Tree-sitter AST Parsing** | Parse từng file thành AST, trích xuất symbol |
| **Resolution** | Phân giải import, mapping symbol xuyên file |
| **Clustering** | Leiden community detection — phân cụm code thành functional groups |
| **Execution Flow Tracing** | Trace luồng thực thi, phát hiện call chain |
| **Hybrid Search** | BM25 + vector + RRF (Reciprocal Rank Fusion) |

Dữ liệu graph được lưu trong **LadybugDB** — embedded graph database có hỗ trợ vector search (trước đây là KuzuDB). Native cho CLI, WASM cho Web UI.

---

## Tính năng chính

* **14 ngôn ngữ:** TypeScript, JavaScript, Python, Java, Kotlin, C#, Go, Rust, PHP, Ruby, Swift, C, C++, Dart
* **16+ MCP tools:** `query`, `context`, `impact`, `detect_changes`, `rename`, `cypher`, `clusters`, `process`, `wiki`, `list_repos`, `status`, `route_map`, `tool_map`, `shape_check`, `api_impact`, `explain`, `pdg_query` + 2 prompts (`detect_impact`, `generate_map`)
* **Multi-repo groups:** Phân tích xuyên repository, trích xuất contracts, tự động phát hiện cross-links
* **Confidence scoring:** Mỗi edge có confidence score dựa trên static type info, constructor inference, import resolution
* **Auto-installed agent skills:** 4 skills mặc định — Exploring, Debugging, Impact Analysis, Refactoring
* **Wiki generation:** Tự động sinh tài liệu từ knowledge graph
* **Privacy-by-design:** CLI chạy local hoàn toàn, Web UI xử lý trong browser — không code nào rời khỏi máy
* **License:** PolyForm Noncommercial

---

## So sánh với các công cụ khác

{% tabs %}
{% tab title="GitNexus" %}
* **Ngôn ngữ gốc:** TypeScript + Node.js
* **Số ngôn ngữ parse:** 14
* **Cơ sở dữ liệu:** LadybugDB (graph + vector)
* **Số MCP tools:** 16+
* **Cài đặt:** `npm install -g gitnexus`
* **Sao GitHub:** ~44.5k
* **Điểm mạnh:** Web UI zero-server, multi-repo groups, confidence scoring, 4 agent skills
* **License:** PolyForm Noncommercial
{% endtab %}
{% tab title="CodeGraph" %}
* **Ngôn ngữ gốc:** TypeScript/Node (kernel Rust)
* **Số ngôn ngữ parse:** 20+
* **Cơ sở dữ liệu:** SQLite + FTS5
* **Số MCP tools:** 1 (`codegraph_explore`)
* **Cài đặt:** `npx @colbymchenry/codegraph`
* **Sao GitHub:** ~61k
* **Điểm mạnh:** Auto-sync, framework routes, iOS/RN bridging, `codegraph affected`
* **License:** MIT
{% endtab %}
{% tab title="codebase-memory-mcp" %}
* **Ngôn ngữ gốc:** C (static binary)
* **Số ngôn ngữ parse:** 158
* **Cơ sở dữ liệu:** SQLite
* **Số MCP tools:** 14
* **Cài đặt:** `curl -fsSL ... | bash`
* **Sao GitHub:** ~33k
* **Điểm mạnh:** Nhiều ngôn ngữ nhất, hybrid LSP, static binary không dependency
* **License:** MIT
{% endtab %}
{% endtabs %}

| Tiêu chí | GitNexus | CodeGraph | codebase-memory-mcp |
|----------|----------|-----------|---------------------|
| **Số ngôn ngữ** | 14 | 20+ | 158 |
| **Engine** | TypeScript + Node | Rust kernel + Node | C static binary |
| **Số MCP tools** | 16+ | 1 (mạnh) | 14 |
| **Web UI** | ✅ Zero-server (WASM) | ❌ | ❌ |
| **Multi-repo** | ✅ Có | ❌ | ❌ |
| **Auto-sync** | ❌ (cần reindex) | ✅ Native OS events | ❌ |
| **Confidence scoring** | ✅ Có | ❌ | ❌ |
| **Agent skills** | 4 skills | ❌ | ❌ |
| **Static binary** | ❌ (cần Node) | ❌ (cần Node) | ✅ |
| **Sao GitHub** | ~44.5k | ~61k | ~33k |

---

## Cách cài đặt

{% code title="Cài đặt GitNexus CLI + MCP" overflow="wrap" lineNumbers="true" %}
```bash
# Cài đặt global
npm install -g gitnexus

# Index repo hiện tại (chạy từ thư mục gốc project)
cd your-project
gitnexus analyze

# Cấu hình MCP tự động cho editor (chạy một lần)
gitnexus setup

# Hoặc dùng npx không cần cài đặt
npx gitnexus analyze
```
{% endcode %}

GitNexus hỗ trợ: **Claude Code**, **Cursor**, **Codex**, **OpenCode**, **Antigravity** (Google), **Windsurf**, **CodeBuddy** (Tencent), **Qoder** (Alibaba) và mọi MCP-compatible tool.

{% hint style="info" %}
**Claude Code** và **Codex** nhận integration sâu nhất: MCP tools + agent skills + PreToolUse hooks (enrich context graph) + PostToolUse hooks (phát hiện stale index sau commit).
{% endhint %}

---

## Kết luận

GitNexus là lựa chọn độc đáo trong hệ sinh thái MCP code intelligence nhờ hai điểm khác biệt: **Web UI zero-server** (mở trình duyệt là phân tích được codebase ngay) và **multi-repo groups** (phân tích xuyên microservices). Với 16+ MCP tools, confidence scoring và agent skills tự động cài đặt, đây là công cụ mạnh cho team có nhiều repository cần phân tích kiến trúc.

Nếu bạn cần auto-sync thời gian thực và cộng đồng lớn, **CodeGraph** (~61k sao) là lựa chọn tốt. Nếu bạn cần nhiều ngôn ngữ nhất (158) và static binary nhẹ, **codebase-memory-mcp** (~33k sao) là đáp án. Còn nếu bạn muốn zero-server Web UI, multi-repo với confidence scoring — GitNexus là lựa chọn chính xác.

> 🔗 **Tài liệu tham khảo:**
> * [GitHub: GitNexus](https://github.com/abhigyanpatwari/GitNexus)
> * [Web UI Demo](https://gitnexus.vercel.app)
> * [npm: gitnexus](https://www.npmjs.com/package/gitnexus)
> * [CodeGraph](https://github.com/colbymchenry/codegraph)
> * [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
