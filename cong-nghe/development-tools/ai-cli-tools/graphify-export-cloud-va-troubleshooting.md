---
description: >-
  Export đồ thị Graphify sang MCP/Cypher/GraphML, Graphify Cloud và các lỗi thường
  gặp khi cài đặt, extraction.
---

# Graphify: export, Cloud và troubleshooting

Bài này tập hợp các nội dung về xuất dữ liệu ra hệ sinh thái ngoài, lớp hosted Graphify Cloud và xử lý lỗi thường gặp. Đọc sau [Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md).

---

## 1. Xuất dữ liệu sang hệ sinh thái ngoài (MCP / Cypher / GraphML)

Dù mặc định lưu dưới dạng `graph.json`, Graphify hỗ trợ xuất cấu trúc đồ thị sang định dạng chuẩn khi dự án phình to thành hệ thống đa repo:

* **MCP Server Mode:** chạy dưới dạng Model Context Protocol server (`graphify mcp`) để các client hỗ trợ MCP gọi trực tiếp các công cụ truy vấn đồ thị (`query_graph`, `get_neighbors`, `find_path`) thay vì phải tự đọc file JSON.
* **Export Cypher / GraphML:** hỗ trợ xuất ra định dạng tương thích với **Neo4j** hoặc **Gephi** để phân tích chuyên sâu trên hệ thống có hàng trăm nghìn node.

---

## 2. Graphify Cloud (hosted)

[**Graphify Cloud**](https://app.graphify.com/signup) là lớp always-on xây trên graphify: giữ một graph live qua toàn bộ SDLC:

* **80% fewer tokens** — always-on memory, agent không còn re-read/re-explain codebase mỗi session
* **Monorepo và cross-repo** — một graph kết nối qua mọi service/repo
* **Formal verification** — check architectural/dependency invariants trên live graph
* **Code review** với bird's-eye view của SDLC
* **SDLC connectors** — Sentry, Jira, … để incidents/tickets/code trong cùng graph
* **Always-on** — update liên tục background qua code, docs, meetings

**Start free, no card required:** [app.graphify.com/signup](https://app.graphify.com/signup)

---

## 3. Troubleshooting

Các vấn đề cài đặt/extraction thường gặp và cách fix: [Troubleshooting](https://docs.graphify.com/troubleshooting). Một số lưu ý:

* `command not found` sau `pip install`: xem Installation docs và Troubleshooting
* PowerShell quoting, strict mode, `uvx` usage: xem [Installation](https://docs.graphify.com/installation)
* `GRAPHIFY_VIZ_NODE_LIMIT` / `.graphifyrc` `viz_node_limit=N` áp dụng cho `cluster-only`, `update`, `watch`, hooks — không áp dụng `export html`
* Leiden fallback: không có `leiden` extra thì clustering silently dùng networkx Louvain; chuyển sau reshuffle mọi community → plan full relabel

---

## Kết luận

Graphify là lựa chọn mạnh trong hệ sinh thái MCP code intelligence nhờ triết lý **local-first + Apache 2.0 + graph từ code lẫn docs/media**, với confidence tags, git hook, PR review và formal verification. Với ~149k sao GitHub, 11M PyPI downloads và 15.2M repositories indexed, đây là một trong những công cụ code intelligence phổ biến nhất cho AI coding agent hiện nay.

Nếu bạn đã dùng CodeGraph/GitNexus/codebase-memory-mcp, Graphify bổ sung giá trị ở chỗ **đưa docs/PDFs/media vào cùng graph** và **confidence tags** cho từng edge — rất hữu ích cho codebase có nhiều tài liệu kỹ thuật và audit trail.

---

## Bước tiếp theo

* 👉 **[Cấu hình, biến môi trường và quyền riêng tư](graphify-cau-hinh-va-quyen-rieng-tu.md)** — quay lại cấu hình
* 👉 **[Tính năng nâng cao](graphify-tinh-nang-nang-cao.md)** — quay lại tính năng nâng cao
* 👉 **[Sử dụng hàng ngày](graphify-su-dung-hang-ngay.md)** — quay lại sử dụng
* 👉 **[Tổng quan và kiến trúc](graphify-tong-quan-va-kien-truc.md)** — quay lại tổng quan

> 🔗 **Tài liệu tham khảo:**
> * [Website: Graphify](https://graphify.com/)
> * [GitHub: Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify)
> * [Docs](https://docs.graphify.com)
> * [Benchmarks](https://github.com/Graphify-Labs/graphify/blob/v8/BENCHMARKS.md)
> * [Architecture](https://github.com/Graphify-Labs/graphify/blob/v8/ARCHITECTURE.md)
