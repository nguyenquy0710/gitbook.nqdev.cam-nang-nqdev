---
description: >-
  Sử dụng Graphify hàng ngày: chat với AI assistant, mở bản đồ trực quan graph.html,
  các lệnh chuyên sâu query/explain/path, và cơ chế cập nhật đồ thị.
---

# Graphify: sử dụng hàng ngày

Bài này hướng dẫn khai thác Graphify trong công việc hàng ngày. Đọc sau [Cài đặt và bắt đầu](graphify-cai-dat-va-bat-dau.md).

---

## Khai thác đồ thị trong công việc hàng ngày

Sau khi `graphify-out/` được tạo, không cần cấu hình thêm. Hệ thống sẵn sàng khai thác theo 3 cách chính:

### 1. Chat và hỏi đáp tự nhiên với AI Assistant (cách dùng chính)

Từ lúc này, bất cứ khi nào bạn đặt câu hỏi về mã nguồn trong Claude Code, Cursor hay Gemini CLI, AI sẽ tự động đọc `graphify-out/graph.json` và `GRAPH_REPORT.md` trước thay vì lục từng file bằng grep hay đọc toàn bộ thư mục.

Tận dụng để hỏi những câu "xuyên suốt hệ thống" mà bình thường AI rất dễ trả lời thiếu hoặc tốn nhiều token:

* **Dò luồng xử lý (Path tracing):** "Truy vết luồng dữ liệu từ endpoint tạo đơn hàng đi qua những service, middleware và bảng DB nào?"
* **Đánh giá tác động (Impact analysis):** "Nếu tôi sửa cấu trúc dữ liệu trả về của hàm `verifyTenant()`, những module hoặc API nào sẽ bị ảnh hưởng?"
* **Tìm kiếm theo khái niệm / tài liệu:** "Tính năng phân quyền trong file PRD được cài đặt cụ thể ở những class và file nào?"
* **Onboard / hiểu nhanh dự án:** "Dựa vào graph hiện tại, hãy giải thích kiến trúc tổng quan và các module lõi của dự án này."

> 💡 Mẹo: nếu muốn chắc chắn AI dùng đồ thị thay vì quét file thô, thêm cụm "dùng graphify" hoặc "kiểm tra trong graph" vào cuối câu hỏi.

### 2. Mở bản đồ trực quan để tự kiểm tra kiến trúc (`graph.html`)

Mở `graphify-out/graph.html` bằng trình duyệt bất kỳ (Chrome, Edge, Safari) để xem toàn cảnh dự án dưới dạng đồ thị mạng lưới tương tác:

* **Xem các cụm (Clusters):** file/module liên quan mật thiết được gom cùng màu. Nếu một file nằm sai cụm hoặc có quá nhiều dây nối chằng chịt sang cụm khác → dấu hiệu tight coupling (phụ thuộc chéo quá mức) cần refactor.
* **Click vào từng Node:** xem node đó kết nối với những thành phần nào và lý do kết nối (`EXTRACTED` từ code hay `INFERRED` từ tài liệu).

### 3. Dùng các lệnh nhánh của `/graphify` khi cần chuyên sâu

Ngoài lệnh mặc định, gọi trực tiếp các lệnh chuyên biệt trong khung chat hoặc terminal (xem bảng bên dưới).

---

## Truy vấn và tối ưu ngữ cảnh cho AI

Khi đặt câu hỏi cho AI về dự án (ví dụ: "Luồng xử lý thanh toán đi qua những service nào?" hoặc "Tìm các module phụ thuộc vào bảng users"), AI sẽ **tự động ưu tiên đọc `graph.json`** thay vì quét toàn bộ file mã nguồn — giúp tiết kiệm tới **~80% lượng token** tiêu thụ.

---

## Cập nhật đồ thị khi mã nguồn thay đổi

Graphify **không tự động theo dõi tệp theo thời gian thực** (real-time file watcher) để tránh tốn tài nguyên hệ thống chạy ngầm. Việc cập nhật `graphify-out/` diễn ra theo **3 cơ chế kích hoạt**:

1. **Tự động mỗi khi `git commit` (khuyên dùng):** nếu đã chạy `graphify hook install`, Graphify cài một `post-commit` hook vào `.git/hooks/post-commit`. Ngay sau khi `git commit` thành công, hook chỉ quét các tệp vừa thay đổi trong commit đó và cập nhật phần AST tương ứng vào `graph.json` trong vài mili-giây, không làm chậm quá trình commit.

2. **Cập nhật thủ công khi bạn gọi lệnh:** bất cứ khi nào sửa đổi lượng lớn mã nguồn hoặc thêm tài liệu mới và muốn AI nắm bắt ngay trước khi commit:
   * Trong khung chat AI Assistant: gõ lại `/graphify .` (hoặc `/graphify update`).
   * Trên Terminal: chạy `graphify build .` (hoặc `graphify update .`).

3. **AI Agent tự động phát hiện dữ liệu cũ (Stale check):** khi bạn đặt câu hỏi, hướng dẫn trong skill của Graphify yêu cầu AI kiểm tra nhanh dấu thời gian/hash giữa mã nguồn hiện tại và `graphify-out/graph.json`. Nếu phát hiện chênh lệch lớn hoặc tệp đang hỏi vừa mới được tạo/sửa nhưng chưa có trong đồ thị, AI sẽ tự động kích hoạt cập nhật phần bị thiếu trước khi trả lời.

**Cơ chế cập nhật thông minh (Incremental Update)** — dù kích hoạt theo cách nào, Graphify không build lại từ đầu:

* **Đối với Code (AST):** đối chiếu mã băm (hash) của từng file; file không đổi sẽ bỏ qua, chỉ phân tích cú pháp lại file có thay đổi.
* **Đối với Tài liệu / PDF / Ảnh (Semantic Pass):** chỉ chạy lại bước phân tích ngữ nghĩa tốn kém (nếu có dùng LLM) trên những file tài liệu thực sự bị chỉnh sửa nội dung.

---

## Các lệnh chuyên sâu

| Lệnh | Mục đích sử dụng |
| --- | --- |
| `/graphify query "<câu hỏi>"` (hoặc `graphify query`) | Ép công cụ truy vấn trực tiếp trên đồ thị và trả về danh sách các node/cạnh liên quan nhất kèm trích dẫn file |
| `/graphify explain <tên_hàm_hoặc_file>` (hoặc `graphify explain`) | Giải thích chi tiết vai trò của một thành phần cụ thể, ai gọi nó và nó đang phụ thuộc vào những gì |
| `/graphify path <node_A> <node_B>` (hoặc `graphify path`) | Tìm đường đi ngắn nhất giữa hai thành phần bất kỳ (ví dụ: từ một UI component tới một bảng dưới database) |

---

## Các lệnh thường dùng

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```text
/graphify .                        # build graph cho thư mục hiện tại
/graphify ./docs --update          # re-extract chỉ file thay đổi
/graphify . --cluster-only         # rerun clustering không re-extract
/graphify . --cluster-only --resolution 1.5      # communities chi tiết hơn
/graphify . --cluster-only --exclude-hubs 99     # loại bỏ super-hub khỏi god-node ranking
/graphify . --no-viz               # bỏ HTML, chỉ report + JSON
/graphify . --wiki                 # build markdown wiki từ graph

graphify build . --no-llm               # chỉ phân tích AST, offline, không tốn API
graphify mcp                            # chạy MCP server cho client hỗ trợ MCP

graphify export callflow-html      # Mermaid architecture/call-flow HTML (auto-regen mỗi commit nếu hook cài)

graphify query "what connects auth to the database?"
graphify path "UserService" "DatabasePool"
graphify explain "RateLimiter"

graphify add https://arxiv.org/abs/1706.03762   # fetch paper và thêm vào graph
graphify add <youtube-url>                       # transcribe và thêm video

graphify hook install              # auto-rebuild on commit + branch checkout
graphify merge-graphs a.json b.json              # combine hai graph

graphify prs                       # PR dashboard: CI state, review status, worktree mapping
graphify prs 42                    # deep dive PR #42 với graph impact
graphify prs --triage              # AI xếp hàng review (dùng backend đã cấu hình)
graphify prs --conflicts           # PRs chia sẻ communities: merge-order risk
```
{% endcode %}

---

## CLI skills hay MCP instructions?

| Setup | Guidance | Query access |
| --- | --- | --- |
| Local CLI + installed assistant skill | Platform instructions do `graphify install` viết | Chạy `graphify query/path/explain` trên local graph (`graphify-out/`) |
| Connected Graphify MCP server | Instructions của connection + tools server list | Gọi MCP tools trên graph do connection serve |

Cả hai đều encourage scoped graph queries trước broad source searches. Chọn instructions khớp với tools assistant thực sự access được.

---

## Bước tiếp theo

* 👉 **[Tính năng nâng cao](graphify-tinh-nang-nang-cao.md)** — chế độ offline, God Nodes, .graphifyignore, export
* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)** — .graphifyrc, env, privacy
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)** — export, Graphify Cloud, xử lý lỗi
* 👉 **[Cài đặt và bắt đầu](graphify-cai-dat-va-bat-dau.md)** — quay lại cài đặt
* 👉 **[Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md)** — quay lại tổng quan

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
> * [CLI reference](https://docs.graphify.com/reference/overview)