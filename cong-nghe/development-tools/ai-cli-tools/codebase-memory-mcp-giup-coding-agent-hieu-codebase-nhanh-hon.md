---
description: >-
  codebase-memory-mcp là MCP server biến codebase thành knowledge graph, giúp AI
  coding agent hiểu cấu trúc code với tốc độ gần như tức thời và tiết kiệm đến
  99% token.
---

# codebase-memory-mcp: giúp coding agent hiểu codebase nhanh hơn ⚡

Bạn đã bao giờ thấy AI coding agent của mình đọc đi đọc lại cùng một file, grep hàng chục lần chỉ để trả lời một câu hỏi đơn giản như "hàm này được gọi ở đâu?"? Đó chính là vấn đề mà **codebase-memory-mcp** ra đời để giải quyết.

Đây là một MCP server mã nguồn mở do **DeusData** phát triển, biến toàn bộ codebase thành một **knowledge graph** có thể truy vấn gần như tức thời — giúp AI coding agent tiết kiệm đến **99% token** so với cách đọc file truyền thống. Dự án đã đạt **33.000+ sao** trên GitHub và có bài báo khoa học trên arXiv (arXiv:2603.27277).

> 📎 **GitHub:** [github.com/DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)

---

## Vấn đề: AI coding agent đang "lãng phí" token để khám phá codebase

Khi AI coding agent cần hiểu một codebase, nó phải đọc từng file một. Mỗi câu hỏi về cấu trúc kích hoạt một chuỗi hành động: **grep → đọc file → grep lại → đọc thêm file**. Chi phí token tăng lên theo cấp số nhân.

Kết quả benchmark từ chính đội ngũ DeusData cho thấy:

* **Năm câu hỏi cấu trúc** trên một codebase thực tế tiêu tốn khoảng **412.000 token** nếu đọc file truyền thống
* **Cùng năm câu hỏi** khi truy vấn từ knowledge graph chỉ tốn **~3.400 token** — giảm ~120 lần

Vấn đề không chỉ là context window, mà còn là **chi phí** (3–15 USD/triệu token), **độ trễ** (truy vấn graph chỉ mất sub-millisecond so với hàng giây đọc file), và **độ chính xác** (ít nhiễu hơn đồng nghĩa với câu trả lời tốt hơn).

{% hint style="info" %}
codebase-memory-mcp không phải là chatbot, không có LLM nhúng và không cần API key. Nó là một backend phân tích cấu trúc — MCP client (Claude Code, Cursor, Codex...) là tầng suy luận, còn codebase-memory-mcp xây dựng và phục vụ graph. Mọi xử lý đều diễn ra local, code của bạn không bao giờ rời khỏi máy.
{% endhint %}

---

## Tính năng chính

### Parse 158 ngôn ngữ với tree-sitter

Sử dụng **tree-sitter** — bộ parser AST cực nhanh — để phân tích cú pháp 158 ngôn ngữ lập trình, từ Python, JavaScript, TypeScript, Go, Rust, Java, C#, C/C++, PHP cho đến các ngôn ngữ ít phổ biến hơn như Zig, Elixir, OCaml, Perl, SQL và Dockerfile.

### Hybrid LSP — hiểu type sâu hơn

Tree-sitter chỉ cho AST cú pháp. Nó không thể biết rằng `user.profile.display_name()` thực sự trỏ tới `Profile.display_name` được khai báo ở module khác. **Hybrid LSP** — một tầng phân giải kiểu dữ liệu được viết bằng C, nhúng trực tiếp vào binary — giúp giải quyết vấn đề này.

Hoạt động theo hai lớp:

1. **Tree-sitter pass** — nhanh, phân tích cú pháp, trích xuất định nghĩa, lời gọi, import
2. **Hybrid LSP pass** — phân giải type-aware, tinh chỉnh các edge CALLS, USAGE và RESOLVED_CALLS bằng thông tin kiểu dữ liệu

Kết quả là một knowledge graph đủ chính xác để truy vết lời gọi xuyên qua các package, hệ thống phân cấp kế thừa và stdlib — mà không cần chạy một language server process riêng.

### Lưu codebase thành knowledge graph

Toàn bộ codebase được index thành graph với các node (Function, Class, Method, Route, File, Package...) và edge (CALLS, IMPORTS, EXTENDS, HTTP_CALLS...), lưu trong SQLite. Dữ liệu tồn tại ngay cả khi restart session hay context compaction.

{% hint style="success" %}
**Hiệu năng ấn tượng:** Codebase trung bình được index trong vài giây. Toàn bộ Linux kernel (28M LOC, 75K files) chỉ mất ~3 phút.
{% endhint %}

### 14 MCP tools cho coding agent

Các MCP tools được chia thành ba nhóm:

* **Indexing:** `index_repository`, `list_projects`, `delete_project`, `index_status`
* **Querying:** `search_graph`, `trace_path`, `detect_changes`, `query_graph`, `get_graph_schema`, `get_code_snippet`, `get_architecture`, `search_code`
* **Quản lý:** `manage_adr`, `ingest_traces`

### Chạy dưới dạng static binary duy nhất

Được viết bằng **C**, codebase-memory-mcp là một static binary duy nhất — **không cần Docker, không cần runtime dependencies, không cần API key**. Hỗ trợ macOS, Linux và Windows.

{% code title="Cài đặt một lệnh duy nhất" overflow="wrap" lineNumbers="true" %}
```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
```
{% endcode %}

Sau đó chỉ cần nói với AI agent: *"Index this project"* — và mọi thứ đã sẵn sàng.

---

## Những câu hỏi codebase-memory-mcp giúp trả lời

* **Function này được gọi ở đâu?** → Dùng `trace_path` với direction "upstream"
* **Class này liên quan tới những phần nào?** → Dùng `search_graph` tìm class, sau đó `trace_path` xem các edge EXTENDS, IMPLEMENTS
* **Dependency giữa các module ra sao?** → Dùng `get_architecture` trả về languages, packages, entry points, routes, hotspots, boundaries, layers và clusters
* **Thay đổi git này ảnh hưởng tới file nào?** → Dùng `detect_changes` mapping uncommitted changes tới graph symbols + blast radius với risk classification (CRITICAL/HIGH/MEDIUM/LOW)
* **Có route REST nào trong hệ thống?** → Dùng `search_graph` với label "Route"
* **Hàm nào có fan-out cao nhất (gọi nhiều hàm khác nhất)?** → Graph query với Cypher subset

{% hint style="info" %}
codebase-memory-mcp hỗ trợ **Cypher query** — bạn có thể viết truy vấn graph trực tiếp như `MATCH (f:Function)-[:CALLS]->() RETURN f.name, count(*) ORDER BY count(*) DESC` để tìm hàm gọi nhiều nhất.
{% endhint %}

---

## So sánh nhanh: codebase-memory-mcp vs CodeGraph vs Repowise

Hiện có nhiều công cụ giúp AI coding agent hiểu codebase. Dưới đây là so sánh ba công cụ nổi bật:

{% tabs %}
{% tab title="codebase-memory-mcp" %}
* **Ngôn ngữ:** C
* **Số ngôn ngữ parse:** 158 (tree-sitter)
* **Type resolution:** Hybrid LSP (C, nhúng sẵn)
* **Cơ sở dữ liệu:** SQLite
* **License:** MIT
* **Sao GitHub:** ~33k
* **Điểm mạnh:** Tốc độ index cực nhanh, binary đơn, sub-ms queries, nhiều tools nhất
{% endtab %}
{% tab title="CodeGraph" %}
* **Ngôn ngữ:** Rust
* **Số ngôn ngữ parse:** ~15+
* **Type resolution:** Tree-sitter cơ bản
* **Cơ sở dữ liệu:** File-based
* **License:** MIT
* **Sao GitHub:** ~58k
* **Điểm mạnh:** Một tool duy nhất (`codegraph_explore`) rất mạnh, cộng đồng lớn, tự động follow dynamic dispatch
{% endtab %}
{% tab title="Repowise" %}
* **Ngôn ngữ:** Python
* **Số ngôn ngữ parse:** ~15
* **Type resolution:** Tree-sitter
* **Cơ sở dữ liệu:** SQLite + Vector
* **License:** AGPL-3.0
* **Sao GitHub:** ~3.5k
* **Điểm mạnh:** 5 layer intelligence (graph, git, docs, decisions, code health), deterministic code health scoring, PR bot
{% endtab %}
{% endtabs %}

| Tiêu chí | codebase-memory-mcp | CodeGraph | Repowise |
|---|---|---|---|
| **Tốc độ index** | ⚡ Rất nhanh (vài giây) | Nhanh | Trung bình (dưới 30s) |
| **Số MCP tools** | 14 tools | 1 tool (mạnh) | 9 tools |
| **Hybrid type resolution** | ✅ Có | ❌ | ❌ |
| **Số ngôn ngữ** | 158 | ~15+ | ~15 |
| **Static binary** | ✅ Có | ❌ | ❌ |
| **Git diff impact** | ✅ Risk-classified | ✅ Có | ✅ Có |
| **Code health scoring** | ❌ | ❌ | ✅ 25 biomarkers |
| **ADR management** | ✅ Có | ❌ | ✅ Có |

{% hint style="success" %}
**Điểm mạnh nhất của codebase-memory-mcp là tốc độ và sự gọn nhẹ.** Với 158 ngôn ngữ, hybrid type resolution, static binary không dependency, và sub-millisecond query — đây là lựa chọn mạnh mẽ nhất nếu bạn cần một MCP server code intelligence tổng quát, nhanh và dễ cài đặt.
{% endhint %}

---

## Cách sử dụng với Claude Code

{% code title="Cài đặt và cấu hình với Claude Code" overflow="wrap" lineNumbers="true" %}
```bash
# Bước 1: Cài đặt
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash

# Bước 2: Restart Claude Code và chạy lệnh
# "Install this MCP server: https://github.com/DeusData/codebase-memory-mcp"
# Hoặc nếu đã cài binary:
claude mcp add codebase-memory -- codebase-memory-mcp

# Bước 3: Yêu cầu index
# "Index this project"

# Bước 4: Truy vấn
# "Trace what calls the function Search in this project"
# "Get the architecture overview of this codebase"
# "What functions call validate_user?"
```
{% endcode %}

---

## Kết luận

Khi AI coding agent ngày càng tham gia sâu hơn vào quy trình phát triển phần mềm, khả năng **hiểu codebase nhanh và chính xác** trở thành yếu tố quyết định hiệu suất. **codebase-memory-mcp** giải quyết triệt để bottleneck này bằng cách biến codebase thành một knowledge graph có thể truy vấn gần như tức thời.

Với 158 ngôn ngữ, hybrid type resolution, static binary không dependency, và 14 MCP tools mạnh mẽ — đây là một trong những công cụ đáng chú ý nhất trong hệ sinh thái MCP hiện tại, đặc biệt cho các AI coding agent như Claude Code, Cursor, Codex và Gemini CLI.

> 🔗 **Tài liệu tham khảo:**
> * [GitHub: codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
> * [Trang chủ dự án](https://deusdata.github.io/codebase-memory-mcp/)
> * [arXiv paper: Codebase-Memory: Tree-Sitter-Based Knowledge Graphs for LLM Code Exploration via MCP](https://arxiv.org/abs/2603.27277)
> * [CodeGraph](https://github.com/colbymchenry/codegraph)
> * [Repowise](https://github.com/repowise-dev/repowise)
