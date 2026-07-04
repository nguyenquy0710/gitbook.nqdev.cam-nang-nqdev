---
description: >-
  OpenSpec là framework Spec-Driven Development (SDD) dành cho AI Coding
  Assistant. Giúp chuẩn hóa quy trình, giảm Vibe Coding, lưu spec trong Git.
---

# OpenSpec – Chấm dứt "Vibe Coding", đưa AI Coding vào quy trình chuyên nghiệp

## OpenSpec – Chấm dứt "Vibe Coding", đưa AI Coding vào quy trình chuyên nghiệp

Trong khoảng 2 năm trở lại đây, AI Coding phát triển với tốc độ chóng mặt. Chỉ cần vài prompt, Claude Code, Cursor, GitHub Copilot, Codex hay Windsurf đều có thể tạo ra hàng nghìn dòng code.

Nhưng cũng từ đó xuất hiện một khái niệm khá nổi tiếng: **Vibe Coding** — lập trình bằng cảm hứng, yêu cầu nằm rải rác trong lịch sử chat, AI hiểu một kiểu, lập trình viên hiểu một kiểu, và sau vài chục prompt thì không ai còn nhớ ban đầu mình định xây cái gì.

Đó là lý do OpenSpec ra đời.

### **OpenSpec là gì?**

OpenSpec là một framework **Spec-Driven Development (SDD)** dành cho các AI Coding Assistant. Ý tưởng rất đơn giản: thống nhất yêu cầu (Specification) trước, AI viết code sau.

Thay vì bắt AI code ngay, OpenSpec yêu cầu bạn tạo **Proposal, Specification, Design và Tasks** trước khi bắt đầu implement. Điều này giúp AI có một "nguồn sự thật" (Source of Truth) rõ ràng thay vì chỉ dựa vào lịch sử hội thoại.

### **Vì sao OpenSpec đang được cộng đồng AI Developer quan tâm?**

#### **✅ 1. Giảm hiện tượng AI "quên ngữ cảnh"**

Đây là vấn đề mà gần như ai dùng AI Coding cũng gặp. Ví dụ:

* **Prompt 1:** Thêm Dark Mode
* **Prompt 15:** À quên, phải hỗ trợ Tablet nữa
* **Prompt 37:** Đừng sửa Authentication nhé
* **Prompt 82:** Sao AI lại xóa Login?

OpenSpec biến toàn bộ yêu cầu này thành tài liệu Markdown trong project, giúp AI luôn đọc đúng yêu cầu hiện tại thay vì phụ thuộc vào lịch sử chat.

#### **✅ 2. Làm việc giống Software Engineering thực thụ**

Workflow mặc định:

```
Proposal → Specification → Design → Tasks → Implementation → Archive
```

Điều này khiến AI Coding trở nên gần với quy trình phát triển phần mềm chuyên nghiệp hơn thay vì "prompt rồi cầu may".

#### **✅ 3. Hỗ trợ hơn 20 AI Coding Assistant**

OpenSpec không phụ thuộc vào một IDE hay một mô hình AI duy nhất. Có thể dùng với:

* **Claude Code**
* **Cursor**
* **GitHub Copilot**
* **OpenAI Codex CLI**
* **Windsurf**
* **Cline**
* **RooCode**
* **Amazon Q**
* và nhiều công cụ khác.

Đây là điểm mình đánh giá rất cao vì không bị khóa vào hệ sinh thái của một nhà cung cấp.

#### **✅ 4. Toàn bộ Specification nằm trong Git**

Mọi thứ đều là Markdown: `proposal.md`, `design.md`, `tasks.md`, `spec.md`. Nghĩa là:

* Review được
* Pull Request được
* Diff được
* Rollback được
* Audit được

Đây là điều mà prompt trong ChatGPT hay Claude không thể làm tốt.

#### **✅ 5. Phù hợp cả dự án mới lẫn dự án cũ**

OpenSpec không chỉ dành cho dự án mới (greenfield). Bạn hoàn toàn có thể đưa nó vào dự án đang phát triển để quản lý thay đổi theo từng tính năng, với các proposal và spec được lưu riêng rồi hợp nhất sau khi hoàn thành.

### **Nhược điểm**

Không có công cụ nào hoàn hảo.

* **❌ Thêm một bước trước khi viết code:** Nếu bạn chỉ sửa vài dòng CSS thì OpenSpec hơi "quá quy trình".
* **❌ Cần thay đổi thói quen:** Nhiều lập trình viên đã quen "Prompt → AI Code → Copy". OpenSpec yêu cầu "Spec → Review → AI Code". Ban đầu sẽ thấy chậm hơn.
* **❌ Chưa phù hợp với prototype cực nhanh:** Nếu mục tiêu là hackathon hoặc MVP trong vài giờ thì việc viết spec có thể là dư thừa.

### **Cài đặt**

Yêu cầu Node.js.

{% code title="terminal" overflow="wrap" %}
```bash
npm install -g @fission-ai/openspec
```
{% endcode %}

Khởi tạo trong project:

{% code title="terminal" overflow="wrap" %}
```bash
openspec init
```
{% endcode %}

Sau đó chọn AI Coding Assistant bạn đang dùng. OpenSpec sẽ tự cấu hình command và hướng dẫn tương ứng cho công cụ đó.

### **Workflow cơ bản**

Một số lệnh phổ biến:

| Lệnh            | Chức năng                                |
| --------------- | ---------------------------------------- |
| `/opsx:propose` | Tạo proposal và các tài liệu cần thiết   |
| `/opsx:apply`   | Yêu cầu AI triển khai theo specification |
| `/opsx:sync`    | Đồng bộ thay đổi vào đặc tả chính        |
| `/opsx:archive` | Đóng thay đổi sau khi hoàn tất           |

### **So sánh nhanh**

| Công cụ             | Điểm mạnh                                                       | Hạn chế                                                     |
| ------------------- | --------------------------------------------------------------- | ----------------------------------------------------------- |
| **OpenSpec**        | Spec-driven, tool-agnostic, hỗ trợ nhiều AI, lưu spec trong Git | Cần thay đổi quy trình làm việc                             |
| **GitHub Spec Kit** | Quy trình chuẩn hóa mạnh cho dự án mới                          | Thiên về greenfield, ít linh hoạt với dự án đang phát triển |
| **Claude Code**     | Viết code rất tốt                                               | Requirement chủ yếu nằm trong chat                          |
| **Cursor Rules**    | Thiết lập rule đơn giản                                         | Không quản lý proposal và spec đầy đủ                       |
| **Cline**           | Tự động hóa cao                                                 | Thiếu framework quản lý yêu cầu                             |
| **Copilot**         | Tích hợp VS Code rất tốt                                        | Không có workflow Spec-Driven mặc định                      |

### **Khi nào nên dùng OpenSpec?**

✅ Team nhiều người cùng phát triển\
✅ Dự án kéo dài nhiều tháng\
✅ Muốn AI sinh code nhất quán\
✅ Muốn review requirement trước khi code\
✅ Muốn giảm "hallucination" khi AI lập trình

**Không nên dùng nếu:**

❌ Chỉ sửa vài dòng code\
❌ Làm prototype siêu nhanh\
❌ Script ngắn vài chục dòng

### **Kết luận**

Theo mình, OpenSpec không phải là công cụ để AI viết code nhanh hơn, mà là công cụ giúp AI viết **đúng hơn**. Nó đưa "Specification" trở lại vị trí trung tâm của quy trình phát triển phần mềm, giảm phụ thuộc vào lịch sử chat và giúp cả con người lẫn AI thống nhất về mục tiêu trước khi bắt đầu triển khai.

Nếu bạn đang sử dụng Cursor, Claude Code, GitHub Copilot hay Codex CLI mỗi ngày, OpenSpec là một dự án mã nguồn mở rất đáng để thử.

**Tài liệu tham khảo:**

* [OpenSpec GitHub Repository](https://github.com/Fission-AI/OpenSpec)

