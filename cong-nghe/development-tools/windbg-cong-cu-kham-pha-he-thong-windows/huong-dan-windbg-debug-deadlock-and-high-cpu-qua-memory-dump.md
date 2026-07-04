# Hướng dẫn WinDbg: Debug Deadlock & High CPU qua Memory Dump

Không phải sự cố production nào cũng kết thúc bằng một crash rõ ràng. Ngược lại, những vấn đề **khó chịu nhất** thường là:

* Hệ thống **treo** (request không trả về, CPU thấp)
* Hoặc **CPU tăng vọt 100%** nhưng không có lỗi

Trong cả hai trường hợp, memory dump là **ảnh chụp hiện trường** tại thời điểm hệ thống đang “bất thường”. WinDbg giúp bạn đọc bức ảnh đó – nếu bạn biết cách đặt câu hỏi đúng.

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/windbg-page3-001.png" alt="" width="563"><figcaption></figcaption></figure>

***

### 1. Phân biệt Deadlock và High CPU – bước tư duy đầu tiên

Trước khi debug, hãy xác định **bản chất vấn đề**:

| Hiện tượng | CPU  | Trạng thái thread |
| ---------- | ---- | ----------------- |
| Deadlock   | Thấp | Block / Wait      |
| High CPU   | Cao  | Running / Loop    |

📌 **Sai lầm phổ biến**: Dùng cùng một quy trình debug cho cả hai.\
Thực tế, deadlock và high CPU yêu cầu **hai hướng tư duy hoàn toàn khác nhau**.

***

### 2. Nền tảng bắt buộc: Nhìn toàn cảnh thread

Bất kể deadlock hay high CPU, luôn bắt đầu bằng:

```
~
```

Lệnh này liệt kê:

* Tất cả thread
* Trạng thái
* CPU time

📌 **Câu hỏi cốt lõi**

> Thread nào không làm đúng vai trò của nó?

***

## PHẦN I – DEBUG DEADLOCK

### 3. Nhận diện deadlock qua thread state

#### Chuyển sang từng thread và xem stack

```
~Ns
k
```

Bạn cần tìm:

* Thread đang chờ lock
* Thread giữ lock nhưng không tiến triển
* Chuỗi phụ thuộc vòng tròn

📌 **Deadlock không phải “treo”**\
Deadlock là **hệ thống đang làm việc… nhưng không bao giờ xong**.

***

### 4. Phát hiện lock & synchronization object

#### Với critical section / mutex (user-mode)

```
!locks
```

Hoặc:

```
!cs -l
```

Bạn sẽ thấy:

* Lock nào đang bị giữ
* Thread nào sở hữu
* Thread nào đang chờ

📌 **Dấu hiệu rõ ràng**

* Một thread giữ lock rất lâu
* Nhiều thread xếp hàng chờ cùng một lock

***

### 5. Đọc stack để hiểu “vì sao lock không được nhả”

Hãy đặt câu hỏi:

* Thread giữ lock đang làm gì?
* Có I/O, sleep, hoặc gọi sang external system không?
* Có lock lồng nhau không?

📌 **Nguyên tắc kiến trúc**

> Không giữ lock khi gọi code không kiểm soát được thời gian thực thi.

***

## PHẦN II – DEBUG HIGH CPU

### 6. Xác định thread ăn CPU nhiều nhất

#### Xem CPU usage từng thread

```
!runaway
```

Hoặc reset rồi đo lại:

```
!runaway reset
```

(chờ vài giây)

```
!runaway
```

📌 **Thread có User Time hoặc Kernel Time cao nhất** chính là mục tiêu đầu tiên.

***

### 7. Phân tích stack thread high CPU

Chuyển sang thread nghi vấn:

```
~Ns
kv
```

Tìm:

* Vòng lặp
* Hàm được gọi lặp đi lặp lại
* Thiếu điều kiện thoát
* Busy wait

📌 **High CPU không phải do “nặng”**\
Mà thường do **làm việc vô ích, lặp lại không cần thiết**.

***

### 8. Phân biệt User CPU và Kernel CPU

* **User CPU cao**: logic code, vòng lặp, thuật toán
* **Kernel CPU cao**: I/O spin, lock contention, syscall bất thường

Stack trace sẽ cho bạn câu trả lời.

***

### 9. Khi stack “đẹp” nhưng CPU vẫn cao?

Đây là case nguy hiểm nhất.

Nguyên nhân thường là:

* Thread đang spin ở native code
* External library
* JIT / GC / runtime internal loop

📌 **Chiến lược**

* So sánh nhiều dump
* So sánh stack các thread cùng CPU cao
* Tìm pattern lặp lại

***

### 10. Deadlock giả & High CPU giả

Không phải lúc nào biểu hiện cũng phản ánh bản chất.

Ví dụ:

* CPU thấp nhưng thread chờ I/O → không phải deadlock
* CPU cao do load hợp lệ → không phải bug

📌 **Debug tốt là biết khi nào nên… không debug**

***

### Kết luận: Debug concurrency là bài kiểm tra tư duy hệ thống

Deadlock và High CPU không thể giải quyết bằng một stack trace đẹp. Chúng yêu cầu:

* Hiểu vòng đời thread
* Hiểu chiến lược synchronization
* Hiểu chi phí của từng quyết định kiến trúc

WinDbg chỉ là công cụ.\
**Tư duy hệ thống mới là thứ tạo ra khác biệt.**

Đó cũng là định hướng mà **Cẩm nang NQDEV** và **NQDEV Platform** theo đuổi:

> _Khi hệ thống gặp sự cố, người hiểu concurrency sâu là người cuối cùng rời phòng._

👉 Theo dõi thêm các bài phân tích thực chiến tại:\
🔗 [**https://blogs.nhquydev.net/**](https://blogs.nhquydev.net/)
