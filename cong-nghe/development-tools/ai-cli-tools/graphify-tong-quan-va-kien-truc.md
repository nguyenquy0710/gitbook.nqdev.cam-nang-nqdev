---
description: >-
  Graphify là knowledge graph cho codebase: biến code, docs, PDF, media thành đồ thị
  truy vấn được, giúp AI agent hiểu cấu trúc và giảm token. Apache 2.0.
---

# Graphify: tổng quan và kiến trúc

**Graphify** biến codebase (kèm docs, SQL schema, config, PDF, hình ảnh, audio/video) thành một **knowledge graph** có thể truy vấn, để AI coding agent hỏi graph thay vì mò mẫm từng file bằng grep/glob/Read.

Dự án mã nguồn mở do **Graphify Labs** phát triển (YC S26), đạt **~149.000 sao** trên GitHub và **11 triệu lượt tải** trên PyPI, với **15,2 triệu repository** đã được index. Điểm khác biệt lớn nhất: Graphify chạy **local-first** — code được parse bằng tree-sitter AST, không LLM, không upload, không telemetry — và hỗ trợ **20+ AI assistant** (Claude Code, Cursor, Codex, Gemini CLI, Copilot, Aider, …).

> 📎 **Website:** [graphify.com](https://graphify.com/)
> 📎 **GitHub:** [github.com/Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> 📎 **Docs:** [docs.graphify.com](https://docs.graphify.com)
> 📎 **PyPI:** [pypi.org/project/graphifyy](https://pypi.org/project/graphifyy/) (gói chính thức là `graphifyy` — hai chữ y)

**Các bài trong series Graphify:**

* 👉 **[Cài đặt và bắt đầu](graphify-cai-dat-va-bat-dau.md)** — yêu cầu, cài CLI, build graph lần đầu
* 👉 **[Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md)** — chat với AI, graph.html, lệnh chuyên sâu, cập nhật
* 👉 **[Tính năng nâng cao](graphify-tinh-nang-nang-cao.md)** — chế độ offline, God Nodes, .graphifyignore, export
* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)** — .graphifyrc, env, privacy
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)** — export, Graphify Cloud, xử lý lỗi

**Lộ trình đọc đề xuất:** Tổng quan → Cài đặt → Sử dụng hàng ngày → Tính năng nâng cao → Cấu hình & quyền riêng tư → Export, Cloud & troubleshooting. Nếu mới bắt đầu, chỉ cần 3 bài đầu là đủ để dùng Graphify trong dự án thực tế.

---

## Graphify giải quyết vấn đề gì?

Agent phải tự khám phá cấu trúc: grep → glob → Read → grep lại → đọc thêm file. Hàng chục tool calls trước khi bắt đầu xử lý thực sự, và mỗi session lại phải lặp lại.

Graphify thay đổi điều đó: xây dựng **một bản đồ có cấu trúc** của codebase một lần, lưu xuống đĩa (`graph.json`), và để agent truy vấn qua CLI hoặc MCP. Kết quả: ít tool calls hơn, ít token hơn, và câu trả lời có **đường dẫn (path)** và **trích dẫn file:line** có thể mở được — thay vì đoán.

So với RAG/vector search truyền thống, Graphify **không dựa vào embedding để retrieval** (có thể lưu embedding như một tín hiệu trên node, nhưng retrieval là graph traversal) và **không có vector store** như nguồn dữ liệu chính: nó xây dựng graph thật và duyệt graph, nên mọi câu trả lời là một đường đi rõ ràng với nguồn trích dẫn.

---

## Tính năng chính

### Knowledge graph từ mọi thứ

Graphify không chỉ parse code — nó biến **code, docs, SQL schema, config, PDF, hình ảnh, audio/video** thành cùng một graph. Mỗi node là một concept, mỗi edge là một quan hệ (`calls`, `imports`, `inherits`, `mixes_in`, …) với tag provenance.

### Confidence tag trên mỗi edge

Mỗi cạnh được gắn tag để bạn biết thông tin đến từ đâu:

* **`EXTRACTED`** — có rõ ràng trong source (đọc trực tiếp)
* **`INFERRED`** — được Graphify suy ra qua resolution

Nhờ đó bạn phân biệt được "đọc trực tiếp" với "suy ra", rất quan trọng cho công việc audit/regulatory.

### God nodes & Communities

* **God nodes** — các concept kết nối nhiều nhất, cho thấy "mọi thứ chảy qua đâu"
* **Communities** — graph được tách thành các subsystem bằng **Leiden community detection**, với label không cần LLM

### Query, path, explain

Ba thao tác cốt lõi trên `graph.json`:

* `graphify query "<câu hỏi>"` — trả về subgraph liên quan cho câu hỏi ngôn ngữ tự nhiên
* `graphify path "A" "B"` — đường đi ngắn nhất giữa hai node, kèm confidence của hop yếu nhất
* `graphify explain "X"` — giải thích một concept (node, community, degree, connections)

### Rationale + doc refs

Comment `# NOTE:` / `# WHY:` và trích dẫn ADR/RFC trở thành first-class node, link tới code — giữ lại "lý do" đằng sau implementation.

### Local-first, không telemetry

* Code parse bằng tree-sitter AST cục bộ — deterministic, không LLM, không rời máy
* Video/audio được transcribe cục bộ bằng faster-whisper
* Không telemetry, không usage tracking, không analytics — "nothing to opt out of, because nothing is sent"
* Apache 2.0 — toàn bộ source công khai trên GitHub

### Incremental & git hook

Graphify **không dùng real-time file watcher** (để tránh tốn tài nguyên ngầm). Thay đổi code chỉ re-parse file thay đổi (hash comparison, không re-embedding, không full re-index). Cập nhật theo 3 trigger: git commit hook (`post-commit`), gọi thủ công (`/graphify .` / `graphify build .`), hoặc AI agent tự phát hiện dữ liệu cũ (stale check) rồi tự cập nhật.

### PR review & Formal verification

* `graphify prs` — dashboard PR: CI state, review status, worktree mapping; deep dive từng PR với graph impact
* Formal verification so sánh behavior changes và inspect evidence (tùy workflow/ngôn ngữ)

### Cross-repo graph

Một graph liên tục qua mọi repo/service, để câu trả lời đi theo owner xuyên service.

---

## Kiến trúc: cách Graphify xây graph

Pipeline indexing gồm **6 pha**:

| Pha | Mô tả |
| --- | ----- |
| **Structure** | Xây cây thư mục, tạo `CONTAINS` edges |
| **Tree-sitter AST Parsing** | Parse từng file thành AST, trích xuất symbol (~40 ngôn ngữ) |
| **Resolution** | Phân giải import, mapping symbol xuyên file |
| **Clustering** | Leiden community detection — phân cụm code thành functional groups |
| **Execution Flow Tracing** | Trace luồng thực thi, phát hiện call chain |
| **Hybrid Search** | BM25 + vector + RRF (Reciprocal Rank Fusion) |

---

## Lưu trữ: tệp tĩnh, không DBMS

Graphify **không dùng DBMS, không có Vector Database, không có daemon/server nền**. Toàn bộ "database" là các tệp tĩnh trong `graphify-out/`. Khi bạn đặt câu hỏi, `graphify query` nạp và duyệt trực tiếp trên tệp JSON trong bộ nhớ (in-memory) bằng thư viện đồ thị Python (networkx), sau đó giải phóng — không kết nối DB.

Cấu trúc thư mục output:

{% code title="graphify-out/" overflow="wrap" lineNumbers="true" %}
```text
graphify-out/
├── graph.json         # "Database" chính: nodes, edges, thuộc tính, communities (Leiden)
├── GRAPH_REPORT.md    # Báo cáo tóm tắt cấu trúc để AI đọc nhanh
├── graph.html         # Giao diện trực quan hóa (mở bằng trình duyệt)
└── .cache/            # chữ ký hash để nhận diện file thay đổi
```
{% endcode %}

* **`graph.json`** — lưu toàn bộ cấu trúc đồ thị (nodes, edges, thuộc tính, phân cụm community Leiden). AI agent hoặc `graphify query` nạp và duyệt in-memory qua networkx.
* **Tệp cache nội bộ** — lưu chữ ký (hash) của từng file mã nguồn/tài liệu đã quét. Lần chạy sau, Graphify biết chính xác file nào đã sửa để chỉ cập nhật phần đó thay vì quét lại toàn bộ.

### Quản lý `graphify-out/` trong Git

* **Cá nhân / dự án nhỏ:** thêm `graphify-out/` vào `.gitignore` để tránh phình dung lượng repo sau mỗi lần cập nhật code.
* **Team:** có thể commit thư mục `graphify-out/` (hoặc chỉ `graph.json`) lên Git để các thành viên khác kéo về là AI Assistant của họ dùng được ngay mà không cần build lại từ đầu.

---

## Benchmark

| Benchmark | Metric | graphify | Field |
| --- | --- | --- | --- |
| LOCOMO (n=300) | recall@10 | **0.497** | mem0 0.048, supermemory 0.149 |
| LOCOMO (n=300) | QA accuracy | 45.3% | supermemory 49.7%, mem0 27.3% |
| LongMemEval-S (n=50) | QA accuracy | **76%** | tied với dense RAG |
| ERPNext cross-tool (n=6) | key-fact coverage | **82.0%** | grep/read baseline 70.8% |
| Graph build | LLM credits | **0** | per-token cho hầu hết systems |

Mọi system chạy trên cùng harness với cùng model/budgets, scored bởi judge blind-validated với second judge (90.6% agreement, Cohen's kappa 0.81). Full tables + reproduction: [BENCHMARKS.md](https://github.com/Graphify-Labs/graphify/blob/v8/BENCHMARKS.md).

Người dùng báo cáo **79× fewer tokens** (MemMachine case) và **80% token spend reduction** (Graphify Cloud).

---

## So sánh: dùng vs không dùng Graphify

Việc sử dụng Graphify thay đổi hoàn toàn cách AI Coding Assistant (Claude Code, Cursor, Gemini CLI, …) đọc và hiểu codebase của bạn — chuyển từ kiểu "mò mẫm bằng từ khóa" sang "đọc bản đồ kiến trúc có sẵn".

| Tiêu chí | Không dùng Graphify (Mặc định của AI Agent) | Có dùng Graphify |
| --- | --- | --- |
| **Cách AI tìm ngữ cảnh** | Dùng grep, find theo từ khóa rồi mở đọc toàn bộ từng file nghi ngờ | Đọc thẳng `GRAPH_REPORT.md` và truy vấn đúng các node/cạnh liên quan trong `graph.json` |
| **Lượng Token tiêu thụ** | Rất cao. AI thường phải đọc 10–20 file (hàng chục nghìn dòng code thừa) mới gom đủ thông tin | Giảm tới ~70–80%. Chỉ nạp đúng đường đi (path) và các hàm/bảng có liên kết trực tiếp |
| **Tốc độ phản hồi** | Chậm hơn do AI phải thực hiện nhiều vòng gọi tool (search → read file → search tiếp) | Nhanh hơn rõ rệt vì bản đồ quan hệ đã được dựng sẵn ở local |
| **Độ chính xác khi truy vết** | Dễ bỏ sót các liên kết gián tiếp (ví dụ: event, middleware, dependency chéo nhiều tầng) nếu tên biến/hàm đặt khác nhau | Chính xác và xác định (deterministic) nhờ phân tích cú pháp AST (Tree-sitter) toàn bộ call graph |
| **Kết nối Tài liệu & Code** | AI xem file `.md`/`.pdf` và file code là hai thế giới tách biệt, tự đoán mối liên hệ | Tự động nối khái niệm trong tài liệu/SQL với đúng hàm thực thi qua các cạnh `INFERRED` |
| **Chi phí / Tài nguyên setup** | Bằng 0. Mở lên là dùng ngay, không sinh thêm file rác trong repo | Tốn một bước chạy khởi tạo (`/graphify .`), sinh thêm thư mục `graphify-out/` (cần cập nhật khi sửa code) |

### Sự khác biệt thể hiện rõ nhất ở 3 tình huống thực tế

**Khi hỏi câu hỏi xuyên suốt (End-to-End Flow):**

* **Không dùng:** bạn hỏi "Luồng thanh toán chạm tới những bảng DB nào?". AI tìm chữ payment, mở nhầm file UI `PaymentButton.tsx`, rồi lại phải tìm tiếp `paymentService`, `webhook`… dễ bị tràn context window ở dự án lớn.
* **Có dùng:** Graphify dò thẳng đường đi từ node `PaymentController` → `PaymentService` → `TransactionRepository` → bảng `transactions` chỉ trong 1 bước.

**Khi Refactor / Đánh giá tác động (Impact Analysis):**

* **Không dùng:** AI chỉ tìm những chỗ gọi trực tiếp tên hàm đó. Nếu hàm đó được gọi gián tiếp qua một lớp wrapper hoặc module khác, AI rất dễ bỏ qua khiến code bị gãy sau khi sửa.
* **Có dùng:** bạn xem được toàn bộ các node phụ thuộc (incoming edges) và nhận biết ngay nếu hàm đó là một **God Node** (nút thắt cổ chai bị cả hệ thống phụ thuộc).

**Khi dự án còn nhỏ (vài chục file):**

* **Không dùng:** AI đọc thẳng toàn bộ file vẫn cực kỳ nhanh và chuẩn xác, gần như không khác biệt.
* **Có dùng:** không mang lại nhiều lợi ích vượt trội, đôi khi còn dư thừa công sức quản lý thư mục `graphify-out/`.

**Tóm lại:** với dự án nhỏ hoặc script đơn lẻ, không cần dùng Graphify. Nhưng với hệ thống lớn, monorepo, nhiều service hoặc khi bạn làm việc với AI agent liên tục cả ngày (dễ chạm giới hạn token/rate-limit), Graphify giúp tiết kiệm đáng kể chi phí API và giảm thiểu tình trạng AI "ảo giác" do thiếu ngữ cảnh kiến trúc.

---

## So sánh với các công cụ tương tự

Graphify cùng hệ sinh thái MCP code intelligence với CodeGraph, GitNexus, codebase-memory-mcp:

{% tabs %}
{% tab title="Graphify" %}
* **Ngôn ngữ gốc:** Python
* **Lưu trữ:** Tệp tĩnh `graphify-out/graph.json` (không DBMS/Vector DB)
* **Số ngôn ngữ parse:** ~40 (tree-sitter)
* **Cài đặt:** `uv tool install graphifyy`
* **Sao GitHub:** ~149k
* **Điểm mạnh:** Local-first, Apache 2.0, docs/PDFs/images/video vào cùng graph, confidence tags, git hook, PR review, formal verification, 20+ assistants
* **License:** Apache 2.0 (open core)
{% endtab %}
{% tab title="CodeGraph" %}
* **Ngôn ngữ gốc:** TypeScript/Node (kernel Rust)
* **Số ngôn ngữ parse:** 20+
* **Cơ sở dữ liệu:** SQLite + FTS5
* **Cài đặt:** `npx @colbymchenry/codegraph`
* **Sao GitHub:** ~61k
* **Điểm mạnh:** Auto-sync native OS events, framework routes 17+, iOS/RN bridging, `codegraph affected`
* **License:** MIT
{% endtab %}
{% tab title="GitNexus" %}
* **Ngôn ngữ gốc:** TypeScript + Node.js
* **Số ngôn ngữ parse:** 14
* **Cơ sở dữ liệu:** LadybugDB (graph + vector)
* **Số MCP tools:** 16+
* **Cài đặt:** `npm install -g gitnexus`
* **Sao GitHub:** ~44.5k
* **Điểm mạnh:** Web UI zero-server (WASM), multi-repo groups, confidence scoring, 4 agent skills
* **License:** PolyForm Noncommercial
{% endtab %}
{% tab title="codebase-memory-mcp" %}
* **Ngôn ngữ gốc:** C (static binary)
* **Số ngôn ngữ parse:** 158
* **Cơ sở dữ liệu:** SQLite
* **Số MCP tools:** 14
* **Cài đặt:** `curl -fsSL ... | bash`
* **Sao GitHub:** ~33k
* **Điểm mạnh:** Nhiều ngôn ngữ nhất, static binary không dependency, hybrid LSP type resolution
* **License:** MIT
{% endtab %}
{% endtabs %}

| Tiêu chí | Graphify | CodeGraph | GitNexus | codebase-memory-mcp |
| --- | --- | --- | --- | --- |
| **Số ngôn ngữ** | ~40 | 20+ | 14 | 158 |
| **Engine** | Python + tree-sitter | Rust kernel + Node | TS + Node | C static binary |
| **Docs/PDFs/Media** | ✅ vào cùng graph | ❌ | ❌ | ❌ |
| **Confidence tags** | ✅ EXTRACTED/INFERRED | ❌ | ✅ | ❌ |
| **Auto-sync** | ✅ git hook | ✅ native OS events | ❌ | ❌ |
| **Web UI** | ✅ graph.html | ❌ | ✅ zero-server WASM | ❌ |
| **PR review** | ✅ | ❌ | ❌ | ❌ |
| **License** | Apache 2.0 | MIT | PolyForm Noncommercial | MIT |

**Chọn Graphify khi:** bạn muốn graph từ code + docs + media trong cùng một graph, cần confidence tags và PR review, thích Apache 2.0 và local-first. Nếu cần nhiều ngôn ngữ nhất → codebase-memory-mcp. Nếu cần auto-sync thời gian thực + framework routes → CodeGraph. Nếu cần Web UI zero-server + multi-repo → GitNexus.

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
> * [Benchmarks](https://github.com/Graphify-Labs/graphify/blob/v8/BENCHMARKS.md)
> * [Architecture](https://github.com/Graphify-Labs/graphify/blob/v8/ARCHITECTURE.md)
>
> **Bài tiếp theo:** [Cài đặt và bắt đầu](graphify-cai-dat-va-bat-dau.md) · [Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md) · [Tính năng nâng cao](graphify-tinh-nang-nang-cao.md) · [Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md) · [Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)