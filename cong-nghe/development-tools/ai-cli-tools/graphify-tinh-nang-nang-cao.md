---
description: >-
  Các tính năng nâng cao của Graphify: chế độ offline, God Nodes, liên kết PRD với
  code, và danh sách ngôn ngữ hỗ trợ.
---

# Graphify: tính năng nâng cao

Bài này tập hợp các tính năng nâng cao và thủ thuật thực chiến. Đọc sau [Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md).

Cấu hình (`.graphifyignore`, `.graphifyrc`, biến môi trường, quyền riêng tư), export, Cloud và troubleshooting được tách sang các bài riêng để dễ tra cứu:
* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)**
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)**

---

## 1. Chế độ chỉ chạy cục bộ 100% (`--no-llm` / Code-only)

Mặc dù Graphify hỗ trợ phân tích đa phương tiện (PDF, hình ảnh, video, tài liệu), bước Semantic Pass cần gọi LLM để trích xuất ngữ nghĩa. Nếu bạn chỉ muốn quét mã nguồn và lược đồ SQL mà **không tốn API nào**, hãy chạy:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
graphify build . --no-llm
```
{% endcode %}

Ở chế độ này, Tree-sitter bóc tách toàn bộ class, hàm, biến, import và mối quan hệ gọi hàm (call graph) **hoàn toàn ngoại tuyến (offline)** với tốc độ rất nhanh. Mixed repo: thêm `--code-only` để chỉ index code và skip docs/PDFs/images cần LLM.

---

## 2. Phân tích cấu trúc "God Nodes" & "Surprising Connections"

Khi mở `graphify-out/GRAPH_REPORT.md`, Graphify tự động tính toán các chỉ số lý thuyết đồ thị (thuật toán phân cụm Leiden và độ trung tâm) để chỉ ra những điểm mù kiến trúc mà con người thường bỏ sót:

* **God Nodes (Nút thắt cổ chai):** liệt kê file, class hoặc bảng DB bị quá nhiều module khác phụ thuộc vào — dấu hiệu cảnh báo rủi ro cao khi refactor hoặc dễ gây xung đột khi làm việc nhóm.
* **Surprising Connections (Liên kết bất ngờ):** phát hiện mối liên hệ ngầm giữa hai cụm module tưởng chừng độc lập (ví dụ: một UI component vô tình import trực tiếp utility của tầng database).
* **Suggested Questions:** tự động gợi ý câu hỏi kiến trúc trọng tâm để dùng làm prompt kiểm tra hệ thống.

---

## 3. Loại trừ thư mục rác bằng `.graphifyignore`

Tương tự `.gitignore`, tạo `.graphifyignore` ở thư mục gốc để ngăn Graphify quét thư mục sinh mã tự động, dữ liệu giả (mock), tệp migration cũ hoặc thư mục build làm loãng đồ thị. Chi tiết và ví dụ xem [Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md).

---

## 4. Liên kết chéo giữa Tài liệu thiết kế (PRD/Spec) và Mã nguồn

Điểm mạnh nhất của Graphify so với công cụ chỉ đọc code (ctags, LSP) là khả năng **nối liền tài liệu nghiệp vụ với code thực thi**: nếu bạn đặt các tệp đặc tả (`.md`, `.pdf`), sơ đồ kiến trúc (`.png`/`.jpg`) hoặc file `.sql` chung trong repo (ví dụ thư mục `docs/`), Graphify tạo các cạnh `INFERRED` nối trực tiếp từ khái niệm trong tài liệu sang đúng hàm/service đang cài đặt tính năng đó.

Khi hỏi AI "Tính năng phân quyền multi-tenant trong tài liệu spec đang được implement ở những file nào?", AI đi theo cạnh nối này để trả lời chính xác mà không cần đoán mò.

---

## 5. Hỗ trợ file: ~40 ngôn ngữ

Graphify parse ~40 programming language locally bằng tree-sitter AST, và map docs/PDFs/images/audio-video qua optional semantic pass. Danh sách đầy đủ: [Supported inputs](https://docs.graphify.com/concepts/supported-inputs).

---

## Bước tiếp theo

* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)** — `.graphifyignore`, `.graphifyrc`, env, privacy
* 👉 **[Export, Cloud và troubleshooting](graphify-export-cloud-va-troubleshooting.md)** — export, Graphify Cloud, xử lý lỗi
* 👉 **[Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md)** — quay lại sử dụng
* 👉 **[Cài đặt và bắt đầu](graphify-cai-dat-va-bat-dau.md)** — quay lại cài đặt
* 👉 **[Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md)** — quay lại tổng quan

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
