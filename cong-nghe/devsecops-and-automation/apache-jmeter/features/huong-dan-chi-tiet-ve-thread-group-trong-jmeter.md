---
description: >-
  "Một Nhóm Luồng (Thread Group) xác định một nhóm người dùng sẽ thực thi một
  trường hợp kiểm thử cụ thể đối với máy chủ của bạn.
---

# Hướng dẫn chi tiết về Thread Group trong JMeter

## 1. Giới thiệu về Thread Group

Trong [JMeter](../), **Thread Group** là thành phần quan trọng nhất, đóng vai trò như một "container" chứa các request và kiểm soát cách chúng được thực thi. Mỗi Thread Group đại diện cho một tập hợp các người dùng ảo (virtual users) thực hiện các request theo kịch bản kiểm thử hiệu năng.

Thread Group cung cấp nhiều thông số cấu hình giúp điều chỉnh số lượng người dùng, thời gian chạy, và cách tải được phân phối trong quá trình kiểm thử.

<div align="center"><figure><img src="https://cdn-s3-001.quyit.id.vn/gitbook/blogs/cong-nghe/threadgroup-1739415439.png" alt="Performance Test | Thread Group"><figcaption><p>Performance Test</p></figcaption></figure></div>



***

## 2. Các thông số cấu hình quan trọng của Thread Group

### 2.1. Number of Threads (Users)

* **Mô tả**: Xác định số lượng user ảo chạy đồng thời.
* **Cách sử dụng**: Nếu bạn muốn mô phỏng 100 người dùng cùng lúc truy cập hệ thống, đặt giá trị này là `100`.

### 2.2. Ramp-up Period (in seconds)

* **Mô tả**: Khoảng thời gian để JMeter khởi chạy tất cả các thread.
* **Cách sử dụng**: Nếu bạn đặt `Ramp-up Period = 10` với `Number of Threads = 100`, JMeter sẽ khởi động 100 user trong vòng 10 giây (tức là mỗi giây sẽ có 10 user được khởi chạy).
* **Lưu ý**: Giá trị này quá nhỏ có thể gây tải đột ngột lên hệ thống, trong khi giá trị quá lớn có thể làm chậm quá trình kiểm thử.

### 2.3. Loop Count

* **Mô tả**: Xác định số lần mỗi thread thực hiện toàn bộ test script.
* **Cách sử dụng**:
  * Nếu đặt `Loop Count = 1`, mỗi thread chỉ chạy một lần.
  * Nếu đặt `Loop Count = 10`, mỗi thread sẽ chạy kịch bản kiểm thử 10 lần.
  * Nếu chọn **Forever**, các thread sẽ chạy liên tục cho đến khi bạn dừng kiểm thử.

### 2.4. Duration (seconds)

* **Mô tả**: Xác định tổng thời gian chạy kiểm thử.
* **Cách sử dụng**: Nếu bạn muốn kiểm thử trong 5 phút, đặt giá trị là `300` giây.
* **Lưu ý**: Khi thiết lập `Duration`, JMeter sẽ dừng kiểm thử ngay cả khi `Loop Count` chưa hoàn thành.

### 2.5. Delay Thread creation until needed

* **Mô tả**: Nếu được bật, JMeter sẽ tạo thread khi cần thay vì tạo tất cả ngay từ đầu.
* **Cách sử dụng**: Giúp tối ưu hiệu suất khi mô phỏng số lượng lớn user.

### 2.6. Scheduler (Bộ lập lịch)

Khi bật **Scheduler**, bạn có thể cấu hình thêm hai thông số:

* **Start Time**: Thời điểm bắt đầu chạy kiểm thử.
* **End Time**: Thời điểm dừng kiểm thử.
* **Lưu ý**: Nếu bạn đặt **Duration**, JMeter sẽ bỏ qua `End Time`.

***

## 3. Ví dụ cấu hình Thread Group tối ưu

Giả sử bạn muốn kiểm thử 200 user truy cập vào hệ thống, với yêu cầu:

* Khởi chạy dần trong vòng 20 giây.
* Mỗi user thực hiện kiểm thử 5 lần.
* Kiểm thử chạy trong vòng 10 phút.

Cấu hình Thread Group:

* **Number of Threads (Users):** `200`
* **Ramp-up Period (seconds):** `20`
* **Loop Count:** `5`
* **Duration:** `600` giây (10 phút)
* **Scheduler:** Bật và đặt `Start Time` & `End Time` phù hợp.

***

## 4. Kết luận

Thread Group là thành phần cốt lõi trong JMeter, giúp kiểm soát số lượng user, cách tải được tạo ra, và thời gian kiểm thử. Việc cấu hình hợp lý sẽ giúp bạn có được kết quả kiểm thử chính xác và phản ánh đúng hiệu suất hệ thống.

Bạn có thể kết hợp Thread Group với các thành phần khác như **Timers**, **Listeners**, và **Assertions** để mô phỏng tải thực tế một cách hiệu quả.

💡 **Bạn đã sử dụng Thread Group trong JMeter như thế nào? Hãy chia sẻ kinh nghiệm của bạn trong phần bình luận nhé!** 🚀
