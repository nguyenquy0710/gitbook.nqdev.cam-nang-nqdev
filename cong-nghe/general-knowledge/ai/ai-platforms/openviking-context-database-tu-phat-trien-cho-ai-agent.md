---
description: >-
  Giới thiệu OpenViking — Context Database mã nguồn mở của Volcano Engine,
  thống nhất Memory, RAG và Skills cho AI Agent qua giao diện file system
  viking://.
---

# OpenViking: Context Database tự phát triển cho AI Agent

**OpenViking** là cơ sở dữ liệu ngữ cảnh (**Context Database**) mã nguồn mở dành cho AI Agent, được phát triển bởi **Volcano Engine** (ByteDance). Thay vì quản lý bộ nhớ, tri thức RAG và kỹ năng (skills) thành ba hệ thống rời rạc như cách làm truyền thống, OpenViking gói toàn bộ ngữ cảnh của Agent vào một **hệ thống tệp ảo** dưới giao thức `viking://` — giúp Agent đọc ghi ngữ cảnh giống như developer thao tác với thư mục và file.

Dự án đang là một trong những repository tăng trưởng nhanh nhất trong mảng AI Agent infrastructure với hơn **32.000 GitHub stars** sau vài tháng công bố, và đã được đánh giá là **#1 Repository Của Ngày** trên [TiniX Repo Trending](https://repo.tinix.ai/vi/project/volcengine-openviking-5fd8fed3-4830-470e-b5a3-f487fd47fcf9) ở cả hai chủ đề `agent-memory` lẫn `agentic-rag`.

{% hint style="info" %}
Số liệu GitHub tại thời điểm viết bài (tháng 8/2026): **32.4k stars**, **2.5k forks**, hơn **2.000 commits**. License chính của dự án là **AGPLv3**, các thành phần CLI (`crates/ov_cli`) và ví dụ dùng **Apache 2.0**.
{% endhint %}

***

## Vì sao AI Agent cần Context Database?

Nếu bạn đã từng xây dựng chatbot hoặc AI Agent trong thực tế, chắc chắn sẽ gặp ít nhất một trong những "cơn đau đầu" sau:

* **Ngữ cảnh phân mảnh:** Bộ nhớ hội thoại nằm ở một chỗ, knowledge base RAG nằm ở chỗ khác, skills/tools lại ở nơi thứ ba. Mỗi hệ thống một API, một cách đánh index, khiến pipeline trở nên rối rắm và khó bảo trì.
* **Vector store là "hộp đen":** RAG truyền thống cắt tài liệu thành các chunk phẳng rồi nhét vào vector database. Khi kết quả truy xuất sai, bạn gần như không thể biết *tại sao* sai hay chunk nào đã được đưa vào prompt.
* **Token overflow:** Nhồi toàn bộ lịch sử hội thoại + tài liệu vào context window khiến chi phí token tăng vọt, response chậm và dễ vượt giới hạn model.
* **Agent không trưởng thành:** Mỗi session kết thúc thì mọi kinh nghiệm bay màu. Agent chạy 1.000 lần vẫn "ngây thơ" như lần đầu, không nhớ được sở thích người dùng hay bài học từ lỗi cũ.

👉 Bài toán này được giới nghiên cứu gọi là **context engineering** — và OpenViking đề xuất một hướng giải quyết khác biệt: coi ngữ cảnh như một *cơ sở dữ liệu* đúng nghĩa, thay vì một đống embedding rời rạc.

***

## OpenViking là gì?

* **Context Database:** Hệ thống lưu trữ chuyên biệt cho ngữ cảnh của AI Agent — bao gồm **memory** (ký ức), **resources** (tài nguyên: tài liệu, repo, web page) và **skills** (kỹ năng) — thống nhất trong một nền tảng duy nhất.
* **Giao diện `viking://`:** Mọi mục ngữ cảnh đều có một URI dạng filesystem. Agent định vị và thao tác ngữ cảnh bằng các thao tác quen thuộc như `ls`, `tree`, `find` thay vì query vào một vector store vô hình.
* **Tiered loading (tải theo tầng):** Mỗi nội dung khi ghi vào được xử lý sẵn thành 3 tầng tóm lược, và chỉ tải sâu đúng mức mà tác vụ yêu cầu — cắt giảm token consumption đáng kể.
* **Self-evolving:** Sau mỗi session, OpenViking tự động trích xuất sở thích người dùng và kinh nghiệm của Agent vào bộ nhớ dài hạn — Agent càng dùng càng "khôn".
* **Nền tảng kỹ thuật:** Ngôn ngữ chính là **Python**, kèm nhân hiệu năng cao viết bằng **Rust** (`crates/`). Phát hành qua **PyPI**, **npm** và **cargo**, deploy bằng Docker/Helm đều được hỗ trợ.

### Thông tin dự án

| Tiêu chí | Chi tiết |
| ------------------- | ------------------------------------------------------- |
| Phát triển bởi | Volcano Engine (ByteDance) |
| Ra mắt mã nguồn | Tháng 1/2026 |
| GitHub Stars ⭐ | ~32.4k (tháng 8/2026) |
| License | AGPLv3 (main) · Apache 2.0 (CLI, examples) |
| Ngôn ngữ | Python (chính), Rust (nhân hiệu năng) |
| Yêu cầu | Python 3.10+ |
| Nghiên cứu nền tảng | Paper **VikingMem** — chấp nhận tại **VLDB 2026** |

***

## Kiến trúc hệ thống

Toàn bộ ngăn xếp của OpenViking có thể hình dung như sau:

{% code title="Kiến trúc tổng quan của OpenViking" overflow="wrap" %}
```text
┌─────────────────────────────────────────────┐
│        AI Agent / Chatbot Interface         │
├─────────────────────────────────────────────┤
│        OpenViking Context Database          │
├───────────────┬───────────────┬─────────────┤
│ L0: Abstract  │ L1: Overview  │ L2: Details │
│ (kiểm tra     │ (lập kế       │ (đọc đủ khi │
│  liên quan)   │  hoạch)       │  cần thiết) │
├───────────────┴───────────────┴─────────────┤
│        File System Organization             │
│        ├── resources/                       │
│        ├── user/{id}/memories/              │
│        └── user/{id}/skills/                │
├─────────────────────────────────────────────┤
│      Recursive Directory Retrieval          │
├─────────────────────────────────────────────┤
│           LLM (Claude, GPT, ...)            │
└─────────────────────────────────────────────┘
```
{% endcode %}

Ba tầng ngữ cảnh được tổ chức như một cây thư mục thực thụ:

{% code title="Không gian tên viking://" overflow="wrap" %}
```text
viking://
├── resources/              # Tài nguyên: docs dự án, repos, web pages...
│   └── my_project/
│       ├── docs/
│       │   ├── api/
│       │   └── tutorials/
│       └── src/
└── user/
    └── {user_id}/
        ├── memories/       # Bộ nhớ dài hạn của người dùng
        │   └── preferences/
        │       ├── writing_style
        │       └── coding_habits
        ├── resources/      # Tài nguyên riêng tư của user
        ├── skills/         # Kỹ năng mà Agent học được
        │   ├── search_code
        │   └── analyze_data
        └── peers/          # Agent/người dùng khác tương tác
```
{% endcode %}

👉 Điểm tinh tế nhất: **mỗi thư mục cũng mang tầng tóm lược riêng** (`​.abstract`, `.overview`), nên hệ thống có thể đánh giá mức độ liên quan của cả nhánh trước khi đọc bất kỳ file đầy đủ nào.

***

## Sáu tính năng nổi bật

### 1. Quản lý ngữ cảnh theo paradigm file system

* **Thay thế lưu trữ vector phân mảnh:** Memory, tài nguyên và skills được tổ chức như cấu trúc folder thay vì các collection embedding vô hình.
* **Thao tác tất định (deterministic):** Agent tìm ngữ cảnh bằng `ls`/`tree`/`find` trên URI `viking://` — kết quả có thể đoán trước được, khác hẳn việc "đánh cược" vào similarity search.
* **Dễ visualize và debug:** Developer có thể mở cây ngữ cảnh ra xem trực tiếp, y như quản lý file trên máy — không cần tool đặc biệt nào.

### 2. Tải ngữ cảnh theo tầng (3-Layer Loading)

Mỗi nội dung khi ghi vào được xử lý thành ba tầng, và chỉ được tải đến đúng độ sâu cần thiết:

* **L0 — Abstract:** Tóm tắt một câu (~100 tokens) dùng để kiểm tra nhanh mức liên quan.
* **L1 — Overview:** Thông tin cốt lõi và kịch bản sử dụng (~2k tokens) phục vụ giai đoạn lập kế hoạch.
* **L2 — Details:** Dữ liệu gốc đầy đủ, chỉ đọc khi tác vụ thực sự cần.

{% code title="Mỗi thư mục đều mang tầng tóm lược riêng" overflow="wrap" %}
```text
viking://resources/my_project/
├── .abstract               # L0: ~100 tokens — kiểm tra liên quan nhanh
├── .overview               # L1: ~2k tokens — cấu trúc và điểm chính
└── docs/
    ├── .abstract
    ├── .overview
    └── api/
        ├── auth.md         # L2: nội dung đầy đủ, tải on-demand
        └── endpoints.md
```
{% endcode %}

✅ Kết quả: tránh token overflow, giảm chi phí gọi LLM và giữ context window "sạch" cho những gì thực sự quan trọng.

### 3. Truy xuất đệ quy thư mục (Recursive Directory Retrieval)

* **Kết hợp vị trí + ngữ nghĩa:** Vector search chỉ đóng vai trò *định vị thư mục có điểm số cao nhất*, sau đó hệ thống đi sâu xuống layer-by-layer.
* **Kết quả có ngữ cảnh đi kèm:** Chunk được trả về cùng với toàn bộ "xung quanh" của nó trong cây thư mục — hết cảnh chunk lạc loài, mất mối liên hệ.
* **Đa cấp độ:** Truy vấn đi từ tổng quát đến chi tiết, mô phỏng cách con người duyệt tài liệu thật.

### 4. Quỹ đạo truy xuất minh bạch (Retrieval Visualization)

* **Trực quan hóa quá trình retrieval:** Mỗi truy vấn đều lưu lại trajectory duyệt thư mục — bạn thấy được chính xác đường dẫn nào sinh ra kết quả.
* **Debug dễ dàng:** Khi kết quả sai, thay vì đoán, bạn lần theo quỹ đạo để tìm chỗ hỏng (sai vị trí thư mục? tóm tắt L0 kém?).
* **Tối ưu hiệu suất có căn cứ:** Dựa vào quỹ đạo để cải thiện cấu trúc cây, đổi tên thư mục, bổ sung tóm tắt — thay vì chỉnh mù tùy chỉnh tham số embedding.

### 5. Quản lý phiên tự động (Auto Session Management)

* **Nén nội dung tự động:** Hội thoại dài được nén gọn mà vẫn giữ thông tin quan trọng.
* **Tham chiếu tài nguyên thông tin:** Nội dung lớn không nhét thẳng vào prompt mà được tham chiếu qua URI `viking://`.
* **Rút trích bộ nhớ dài hạn:** Khi session commit, hệ thống bất đồng bộ trích xuất sở thích người dùng và kinh nghiệm Agent vào `memories/`.

### 6. Tự phát triển theo sử dụng (Self-Evolving)

* **Học hỏi từ ngữ cảnh:** Agent tích lũy kinh nghiệm qua từng session — lỗi từng gặp, quy ước dự án, phong cách người dùng.
* **Cơ chế feedback vòng lặp:** Kinh nghiệm được cập nhật tự động, tạo vòng lặp cải tiến liên tục.
* **Đã được kiểm chứng:** Trên benchmark tau2-bench, bộ nhớ kinh nghiệm giúp nâng tỷ lệ hoàn thành nhiệm vụ lên **+6.87 điểm %** (retail) và **+11.87 điểm %** (airline) so với cùng LLM chạy không có memory.

***

## So sánh với RAG truyền thống và Vector DB

### Bảng so sánh nhanh

| Tiêu chí | RAG truyền thống | Vector DB thuần | OpenViking |
| --------------------- | ------------------------ | ------------------------ | ---------------------------------- |
| Tổ chức ngữ cảnh | Chunk phẳng | Embedding phẳng | Cây thư mục `viking://` có cấu trúc |
| Bộ nhớ dài hạn | Không có | Không có | Có (auto-extract từ session) |
| Skills của Agent | Ngoài phạm vi | Ngoài phạm vi | Lưu và quản lý ngay trong DB |
| Token consumption | Cao (nhồi nhiều chunk) | Cao | Thấp (tải L0/L1 trước, L2 on-demand) |
| Khả năng debug | Gần như bằng không | Thấp | Cao (quỹ đạo truy xuất hiển thị) |
| Kết quả trả về | Chunk rời rạc | Vector + metadata | Nội dung kèm ngữ cảnh thư mục |

### Phân tích chi tiết

{% tabs %}
{% tab title="RAG truyền thống" %}
Pipeline điển hình: chunking → embedding → similarity search → nhồi top-K vào prompt.

* **Điểm yếu lớn nhất là mất ngữ cảnh cấu trúc:** một đoạn văn bản về "API authentication" khi đứng độc lập không biết nó thuộc tài liệu nào, phiên bản nào, liên quan module nào.
* **Không có khái niệm "ghi nhớ":** mỗi truy vấn bắt đầu từ số không, history hội thoại phải quản lý thủ công bên ngoài.
* **Khó vận hành:** chỉnh chất lượng retrieval đồng nghĩa với chỉnh lại toàn bộ chunking/embedding strategy — rất tốn công thử sai.
{% endtab %}
{% tab title="Vector DB thuần" %}
Pinecone, Milvus, Qdrant... giải quyết tốt bài toán tìm kiếm tương tự ở quy mô lớn, nhưng:

* **Chỉ là storage, không phải context management:** không có tầng tóm lược, không có session lifecycle, không có memory extraction.
* **Retrieval quality phụ thuộc hoàn toàn vào embedding model** và cách chunking phía upstream.
* **Black-box với end-to-end agent:** không trả lời được câu hỏi "tại sao Agent lại nghĩ người dùng thích câu trả lời kiểu này?".
{% endtab %}
{% tab title="OpenViking" %}
Đặt ngữ cảnh làm *first-class citizen* thay vì phụ phẩm của embedding:

* **Thống nhất 3 loại ngữ cảnh** (memory + knowledge + skills) trong một giao diện duy nhất — giảm số hệ thống phải vận hành.
* **Chi phí token được kiểm soát chủ động** nhờ kiến trúc 3 tầng thay vì bị động nhồi top-K chunks.
* **Quan sát được:** mọi quyết định truy xuất đều để lại dấu vết để audit.
* **Đánh đổi:** bạn cần vận hành thêm một service (server + embedding/VLM provider) và chấp nhận license AGPLv3 nếu self-host.
{% endtab %}
{% endtabs %}

***

## Benchmark thực tế

Phiên bản **0.3.22** đã được đánh giá trên hai benchmark uy tín: **LoCoMo** (bộ nhớ người dùng trong hội thoại dài) và **tau2-bench** (nhiệm vụ multi-turn agent).

### Độ chính xác bộ nhớ người dùng (LoCoMo)

| Agent | Bộ nhớ gốc | Với OpenViking |
| ------------- | ---------- | -------------- |
| OpenClaw | 24.20% | **82.08%** |
| Hermes | 33.38% | **82.86%** |
| Claude Code | 57.21% | **80.32%** |

* **Token input:** giảm **34.3–91.0%** so với chạy native.
* **Query latency:** giảm **58.45–66.10%**.
* **tau2-bench (kinh nghiệm Agent):** tỷ lệ thành công nhiệm vụ tăng **+6.87pp** (retail) và **+11.87pp** (airline).

{% hint style="success" %}
Con số đáng chú ý nhất: cả ba Agent khi gắn OpenViking đều **hội tụ về dải 80–83%** độ chính xác — nghĩa là phần lớn khoảng cách giữa các Agent đến từ chất lượng lớp bộ nhớ, chứ không phải LLM bên dưới. Đây cũng là luận điểm trung tâm của paper VikingMem (VLDB 2026) đằng sau dự án.
{% endhint %}

***

## Bắt đầu nhanh với OpenViking

### Cài đặt và khởi chạy server

Yêu cầu **Python 3.10 trở lên**. Ba bước chuẩn:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
pip install openviking --upgrade

# Wizard tương tác: chọn provider, model, ghi ov.conf
openviking-server init

# Kiểm tra config, Python, kết nối provider, dung lượng disk
openviking-server doctor

# Chạy server (background: nohup openviking-server > openviking.log 2>&1 &)
openviking-server
```
{% endcode %}

{% hint style="info" %}
Bước `init` hỗ trợ nhiều provider: **Volcengine, OpenAI, Codex OAuth, Kimi, GLM** và **Ollama local** — với Ollama, wizard còn tự dò hardware và gợi ý model phù hợp. Config được ghi vào `~/.openviking/ov.conf`.
{% endhint %}

### Thao tác ngữ cảnh bằng CLI `ov`

Sau khi server chạy, dùng client `ov` (đã kèm khi cài đặt):

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Xem trạng thái server
ov status

# Nạp một tài nguyên (repo GitHub) vào Context Database
ov add-resource https://github.com/volcengine/OpenViking   # thêm --wait để chờ xử lý xong
ov ls viking://resources/
ov tree viking://resources/volcengine -L 2

# Chờ semantic processing hoàn tất nếu không dùng --wait
ov find "what is openviking"
ov grep "openviking" --uri viking://resources/volcengine/OpenViking/docs/en
```
{% endcode %}

👉 Nếu muốn trải nghiệm trước khi cài đặt, mở ngay **OpenViking Studio** — playground live trên browser với context playground, semantic search và multi-agent hub, không cần cài gì cả.

***

## Tích hợp với AI Agent có sẵn

OpenViking cung cấp sẵn các integration để inject khả năng recall vào Agent phổ biến và tự commit session memory:

* **CLI Coding Agents:** Claude Code, Codex, Cursor, TRAE, OpenCode, pi, Hermes, OpenClaw.
* **Giao thức chuẩn:** MCP clients — dùng được cho bất kỳ Agent framework nào hỗ trợ MCP.
* **Framework Python:** LangChain / LangGraph qua package tích hợp riêng.
* **Plugin hệ:** Agent Plugins 1.0 cho hệ sinh thái plugin đa Agent.

{% content-ref url="../../../development-tools/ai-cli-tools/claude-code/claude-md-bo-nho-du-an-va-auto-memory.md" %}
[claude-md-bo-nho-du-an-va-auto-memory](../../../development-tools/ai-cli-tools/claude-code/claude-md-bo-nho-du-an-va-auto-memory.md)
{% endcontent-ref %}

Nếu bạn đã quen với cơ chế **CLAUDE.md / Auto Memory** của Claude Code, OpenViking có thể xem là bước nâng cấp tiếp theo: thay vì một file markdown tĩnh cho toàn dự án, bạn có một Context Database có cấu trúc, phân tầng và tự học theo thời gian.

### Use case phù hợp thực tế

* **Coding Agent có trí nhớ dài hạn:** nhớ convention dự án, thói quen code, kiến trúc hệ thống qua hàng chục session — đặc biệt giá trị với codebase lớn, maintain lâu năm.
* **Assistant chăm sóc khách hàng:** ghi nhớ lịch sử tương tác và sở thích từng khách hàng (qua `memories/preferences/`), cá nhân hóa phản hồi mà không phải nhồi lại toàn bộ lịch sử.
* **Knowledge base nội bộ doanh nghiệp:** `add-resource` toàn bộ docs, wiki, repos rồi truy vấn bằng tiếng tự nhiên; quỹ đạo truy xuất giúp audit "Agent đã dựa vào tài liệu nào để trả lời".
* **Multi-agent systems:** các Agent chia sẻ ngữ cảnh qua không gian `peers/`, cộng tác trên chung một nguồn tri thức thay vì mỗi con một bộ nhớ riêng.

***

## Ưu nhược điểm và lưu ý khi áp dụng

* **Ưu điểm:** Kiến trúc mới mẻ nhưng có nền tảng nghiên cứu nghiêm túc (VLDB 2026); benchmark chứng minh bằng số liệu cụ thể; mã nguồn mở đầy đủ tính năng, **không khóa tính năng**, không cần account hay activation key; hệ sinh thái integration phủ rộng các Agent phổ biến.
* **Nhược điểm:** Dự án còn rất trẻ (công bố đầu 2026) — API và schema có thể thay đổi nhanh; cần vận hành thêm server + provider embedding/VLM khi self-host; chất lượng retrieval phụ thuộc vào cách tổ chức cây thư mục và chất lượng model tóm tắt.
* **Phù hợp nhất:** Team đang xây dựng Agent production cần bộ nhớ dài hạn thật sự, đã "đủ đau" với RAG truyền thống và muốn một giải pháp có thể debug, audit được.

{% hint style="warning" %}
License **AGPLv3** là điều kiện copyleft mạnh: nếu bạn sửa đổi mã nguồn OpenViking và cung cấp dịch vụ qua mạng, bạn buộc phải mở nguồn các thay đổi đó. Nếu mô hình kinh doanh không phù hợp, hãy cân nhắc bản **Managed SaaS** trên Volcano Engine hoặc **Self-Managed** (BYOC/offline, kích hoạt bằng license key) — hoặc chỉ dùng CLI/examples vốn là Apache 2.0.
{% endhint %}

***

## Kết luận

OpenViking không đơn thuần là một "vector DB thay thế" — nó đề xuất một **paradigm mới cho context engineering**: quản trị ngữ cảnh của AI Agent như một hệ thống tệp có cấu trúc, tải theo tầng để tiết kiệm token, minh bạch để debug, và tự tiến hóa theo quá trình sử dụng. Với sức hút 32k+ stars và bộ benchmark thuyết phục, đây là dự án rất đáng theo dõi và thử nghiệm nếu bạn đang xây dựng Agent ở tầm production — dù vẫn cần cân nhắc kỹ về AGPLv3 và độ ổn định của một dự án non trẻ.

**Tài liệu tham khảo:**

* [OpenViking Website](https://openviking.ai/)
* [Agent Hub Studio](https://openviking.ai/studio/agent-hub)
* [OpenViking Studio — Live Demo](https://openviking.ai/studio)
* [GitHub — volcengine/OpenViking](https://github.com/volcengine/OpenViking)
* [Documentation](https://docs.openviking.ai/)
* [Blog — Benchmark Results](https://blog.openviking.ai/post/openviking-benchmark-results/)
* [Paper: VikingMem (arXiv:2605.29640, VLDB 2026)](https://arxiv.org/abs/2605.29640)
* [Đánh giá trên TiniX Repo Trending](https://repo.tinix.ai/vi/project/volcengine-openviking-5fd8fed3-4830-470e-b5a3-f487fd47fcf9)
