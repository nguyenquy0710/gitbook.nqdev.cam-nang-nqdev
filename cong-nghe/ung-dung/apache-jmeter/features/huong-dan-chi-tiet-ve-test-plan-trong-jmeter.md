---
description: >-
  Kế hoạch kiểm thử (Test Plan) là nơi thiết lập các cài đặt tổng thể cho một
  bài kiểm thử.
---

# Hướng dẫn chi tiết về Test Plan trong JMeter

## 1. Test Plan là gì?

Trong [JMeter](../), **Test Plan** là thành phần cốt lõi, chứa tất cả các phần tử kiểm thử, từ các nhóm người dùng (**Thread Group**) đến các yếu tố như **Samplers**, **Listeners**, **Timers**, và **Assertions**. Nó xác định cách JMeter thực hiện kiểm thử hiệu năng và quản lý dữ liệu trong suốt quá trình kiểm thử.

Mỗi Test Plan có thể chứa nhiều Thread Group và các thành phần phụ trợ, giúp mô phỏng kịch bản kiểm thử thực tế một cách linh hoạt.

***

## 2. Các thành phần chính của Test Plan

### 2.1. Name (Tên Test Plan)

* **Mô tả**: Đặt tên cho Test Plan để dễ nhận diện.
* **Cách sử dụng**: Bạn nên đặt tên mô tả rõ ràng, ví dụ: `Performance Test - API Login`.

### 2.2. User Defined Variables (Biến do người dùng định nghĩa)

* **Mô tả**: Cho phép khai báo các biến có thể sử dụng trong toàn bộ Test Plan.
* **Cách sử dụng**:
  * Ví dụ: Khai báo biến `base_url = https://api.example.com` và sử dụng trong các Samplers bằng cú pháp `${base_url}/login`.

### 2.3. Run Thread Groups Consecutively (Chạy Thread Groups tuần tự)

* **Mô tả**: Khi bật tùy chọn này, JMeter sẽ chạy từng [Thread Group](huong-dan-chi-tiet-ve-thread-group-trong-jmeter.md) theo thứ tự thay vì chạy song song.
* **Cách sử dụng**: Hữu ích khi bạn có nhiều nhóm kiểm thử với các mục đích khác nhau.

### 2.4. Functional Test Mode

* **Mô tả**: Nếu bật chế độ này, JMeter sẽ tập trung vào kiểm thử chức năng thay vì kiểm thử tải.
* **Cách sử dụng**: Thường sử dụng cho các bài kiểm thử đơn lẻ, không đánh giá hiệu năng hệ thống.

### 2.5. Add Directory or Jar to Classpath

* **Mô tả**: Cho phép thêm thư viện bên ngoài vào Test Plan.
* **Cách sử dụng**: Hữu ích khi cần sử dụng các plugin hoặc thư viện Java tùy chỉnh.

### 2.6. TearDown Thread Group

* **Mô tả**: Một loại Thread Group đặc biệt, được thực thi sau khi toàn bộ kiểm thử hoàn tất.
* **Cách sử dụng**: Thích hợp để dọn dẹp dữ liệu hoặc thực hiện các tác vụ hậu kiểm thử.

***

## 3. Cách tạo Test Plan trong JMeter

### 3.1. Bước 1: Tạo một Test Plan mới

* Mở JMeter.
* Chọn **File > New** để tạo một Test Plan trống.

### 3.2. Bước 2: Thêm Thread Group

* Click chuột phải vào **Test Plan > Add > Thread Group**.
* Cấu hình số lượng user, ramp-up time và loop count.

### 3.3. Bước 3: Thêm Samplers

* Click chuột phải vào **Thread Group > Add > Sampler**.
* Chọn loại Sampler như **HTTP Request**, **JDBC Request**, v.v.

### 3.4. Bước 4: Thêm Listeners

* Click chuột phải vào **Test Plan > Add > Listener**.
* Chọn **View Results Tree** hoặc **Aggregate Report** để quan sát kết quả kiểm thử.

### 3.5. Bước 5: Lưu Test Plan và chạy kiểm thử

* Chọn **File > Save** để lưu Test Plan.
* Nhấn **Start** (hoặc Ctrl + R) để chạy kiểm thử.

***

## 4. Kết luận

Test Plan là nền tảng cho mọi kịch bản kiểm thử trong [JMeter](../). Việc hiểu rõ cách cấu hình Test Plan giúp bạn xây dựng kịch bản kiểm thử hiệu quả và linh hoạt hơn. Hãy tối ưu hóa Test Plan của bạn bằng cách sử dụng hợp lý các biến, [Thread Groups](huong-dan-chi-tiet-ve-thread-group-trong-jmeter.md) và các thành phần hỗ trợ.

💡 **Bạn đã từng gặp khó khăn khi thiết lập Test Plan trong JMeter chưa? Chia sẻ kinh nghiệm của bạn trong phần bình luận nhé!** 🚀
