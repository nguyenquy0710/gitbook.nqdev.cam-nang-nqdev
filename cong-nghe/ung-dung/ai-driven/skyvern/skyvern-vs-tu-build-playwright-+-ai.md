# Skyvern vs Tự build Playwright + AI

### Phân tích chi phí dài hạn: Cái giá thật sự của Browser Automation

Khi bàn về automation, câu hỏi phổ biến nhất thường là:

> “Dùng Skyvern có tốn tiền hơn tự build không?”

Đây là **câu hỏi sai**.\
Câu hỏi đúng phải là:

> **Sau 1–2 năm, giải pháp nào tiêu tốn ít nguồn lực hơn cho cùng một giá trị tạo ra?**

Để trả lời, cần nhìn automation như một **hệ thống sống**, không phải một script chạy một lần.

***

### 1. Khung phân tích: Tổng chi phí sở hữu (TCO)

Chi phí automation dài hạn không chỉ gồm:

* Tiền tool
* Tiền hạ tầng

Mà còn gồm:

* Thời gian kỹ sư
* Chi phí bảo trì
* Chi phí cơ hội
* Rủi ro vận hành

Chúng ta sẽ so sánh Skyvern và tự build theo 5 trục chính:

1. Chi phí phát triển ban đầu
2. Chi phí bảo trì & sửa lỗi
3. Chi phí mở rộng & scale
4. Chi phí nhân sự & phụ thuộc cá nhân
5. Chi phí rủi ro & gián đoạn vận hành

***

### 2. Chi phí phát triển ban đầu

#### 2.1 Tự build Playwright + AI

Ban đầu, tự build thường **trông có vẻ rẻ**:

* Playwright: miễn phí
* LLM: trả theo usage
* Code: “dev nhà làm”

Nhưng thực tế, để đạt mức ổn định tương đương Skyvern, bạn phải xây:

* Planner logic
* State machine
* Retry & fallback
* Prompt strategy
* Logging & trace
* Workflow orchestration

👉 Thời gian thực tế: **2–4 tháng cho phiên bản usable**, nếu team có kinh nghiệm.

#### 2.2 Skyvern

* Có sẵn kiến trúc
* Có workflow engine
* Có planner & feedback loop
* Có UI quản lý

👉 Thời gian triển khai: **vài ngày đến vài tuần**.

**Kết luận giai đoạn đầu**\
Tự build rẻ tiền mặt, nhưng đắt thời gian.\
Skyvern tốn tiền sớm, nhưng mua được **thời gian và độ hoàn thiện**.

***

### 3. Chi phí bảo trì: “kẻ giết automation thầm lặng”

#### 3.1 Với tự build

Sau 3–6 tháng, chi phí bắt đầu tăng:

* UI đổi → sửa prompt
* Flow thêm bước → sửa logic
* Case lạ → thêm rule
* Lỗi ngẫu nhiên → debug khó

Quan trọng hơn:

> **Automation không hỏng ngay, mà hỏng lắt nhắt liên tục.**

Mỗi lần như vậy:

* Dev phải can thiệp
* Context cũ không còn đúng
* Code ngày càng rối

#### 3.2 Với Skyvern

Skyvern được thiết kế để:

* UI thay đổi nhẹ → AI thích nghi
* Flow phát sinh → planner xử lý
* Retry & fallback có sẵn

Dev chỉ can thiệp khi:

* Business goal thay đổi
* Website thay đổi hoàn toàn

**Kết luận bảo trì**\
Tự build: chi phí tăng theo thời gian\
Skyvern: chi phí phẳng hơn, dự đoán được

***

### 4. Chi phí mở rộng & scale

#### 4.1 Tự build

Mỗi workflow mới thường kéo theo:

* Code mới
* Prompt mới
* Case mới

Scale từ:

* 3 workflow → 30 workflow\
  chi phí **không tuyến tính**, mà tăng theo cấp số nhân.

Ngoài ra:

* Không có UI cho non-dev
* Mọi thứ dồn lên dev

#### 4.2 Skyvern

Skyvern được thiết kế như nền tảng:

* Workflow reusable
* Non-dev có thể vận hành
* Dễ tích hợp n8n, service khác

Scale workflow:

* Chủ yếu tăng chi phí compute
* Không tăng tương ứng chi phí dev

**Kết luận scale**\
Tự build: scale = thêm gánh nặng\
Skyvern: scale = thêm giá trị

***

### 5. Chi phí nhân sự & rủi ro phụ thuộc cá nhân

Đây là phần **hiếm khi được tính**, nhưng cực kỳ nguy hiểm.

#### 5.1 Tự build

* Automation logic nằm trong đầu 1–2 dev
* Prompt + rule khó đọc, khó chuyển giao
* Dev nghỉ → automation “đóng băng”

Rủi ro không nằm ở code, mà ở **knowledge concentration**.

#### 5.2 Skyvern

* Workflow rõ ràng
* Logic ở nền tảng
* Dev mới tiếp quản nhanh

Skyvern giảm:

* Bus factor
* Rủi ro vận hành

***

### 6. Chi phí rủi ro & gián đoạn vận hành

Hãy tự hỏi:

* Nếu automation ngừng chạy 1 tuần thì sao?
* Ai phát hiện?
* Ai sửa?
* Sửa trong bao lâu?

Tự build thường:

* Không có alert tốt
* Không có replay rõ ràng
* Debug mất nhiều ngày

Skyvern:

* Có trace
* Có workflow state
* Có retry & resume

👉 **Chi phí downtime thường lớn hơn chi phí tool.**

***

### 7. Bảng tổng hợp chi phí dài hạn

| Khía cạnh       | Tự build | Skyvern    |
| --------------- | -------- | ---------- |
| Chi phí ban đầu | Thấp     | Trung bình |
| Chi phí bảo trì | Cao      | Thấp hơn   |
| Scale workflow  | Khó      | Dễ         |
| Phụ thuộc dev   | Cao      | Thấp       |
| Dự đoán chi phí | Khó      | Dễ         |
| TCO 1–2 năm     | Cao      | Thấp hơn   |

***

### 8. Kết luận: Đắt nhất là “rẻ lúc đầu”

Tự build Playwright + AI **không sai**. Nhưng nó phù hợp khi:

* Use case rất hẹp
* Automation không phải core
* Team chấp nhận bảo trì dài hạn

Skyvern phù hợp khi:

* Automation là năng lực chiến lược
* Workflow ngày càng nhiều
* Muốn giảm gánh nặng kỹ thuật

> **Chi phí lớn nhất của automation không phải là tool, mà là sự phức tạp tích tụ theo thời gian.**

Skyvern không mua sự tiện lợi, mà mua:

* Sự bền vững
* Khả năng dự đoán
* Không gian để đội ngũ tập trung vào giá trị cao hơn
