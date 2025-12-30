# Hướng dẫn WinDbg: Các cú pháp cốt lõi khi phân tích Memory Dump

Khi đã có trong tay một file **memory dump**, câu hỏi quan trọng không còn là _“dùng lệnh nào?”_ mà là:

> **“Mình đang tìm kiếm sự thật nào bên trong trạng thái hệ thống?”**

WinDbg không dẫn bạn đi theo quy trình cố định. Nó cung cấp **bộ công cụ thô**, còn việc ghép nối dữ kiện thành bức tranh toàn cảnh phụ thuộc hoàn toàn vào tư duy của người phân tích.

Phần này của **Cẩm nang NQDEV** sẽ giúp bạn xây dựng **khung tư duy phân tích dump**, thông qua các cú pháp WinDbg quan trọng nhất.

***

### 1. Thiết lập nền tảng: Symbol – nếu sai, mọi thứ đều sai

Trước khi phân tích bất kỳ dump nào, **symbol** là điều kiện tiên quyết. Không có symbol đúng, stack trace chỉ là những địa chỉ vô nghĩa.

#### Cấu hình symbol path chuẩn

```
.symfix
.reload
```

* `.symfix` trỏ symbol về Microsoft Symbol Server
* `.reload` nạp lại toàn bộ module và symbol

📌 **Tư duy quan trọng**\
Nếu stack trace “trông lạ”, module name mơ hồ, hoặc không resolve được function → **dừng lại kiểm tra symbol trước**, đừng phân tích tiếp.

***

### 2. Nhìn tổng thể crash: `!analyze -v`

Đây là lệnh đầu tiên nên chạy với mọi file dump.

```
!analyze -v
```

WinDbg sẽ cung cấp:

* Loại crash (Access Violation, Stack Overflow, BugCheck…)
* Module nghi vấn
* Faulting thread
* Call stack sơ bộ
* Các hint ban đầu

📌 **Đừng coi `!analyze -v` là kết luận**\
Đây chỉ là **bản tóm tắt**, không phải phán quyết cuối cùng. Rất nhiều case production, kết luận thực sự nằm sâu hơn stack trace mặc định.

***

### 3. Làm chủ Thread – nơi sự cố thực sự xảy ra

#### Liệt kê thread

```
~
```

#### Chuyển sang thread cụ thể (ví dụ thread 3)

```
~3s
```

#### Xem stack trace của thread hiện tại

```
k
```

Hoặc chi tiết hơn:

```
kv
```

📌 **Tư duy phân tích**

* Thread crash chưa chắc là thread “gây ra vấn đề”
* Hãy tìm:
  * Thread giữ lock
  * Thread chạy quá lâu
  * Thread bị block bất thường

***

### 4. Đọc stack trace đúng cách

Stack trace không phải để “nhìn cho có”. Hãy tập trung vào:

* Hàm **đầu tiên thuộc code của bạn**
* Ranh giới giữa:
  * System DLL (ntdll, kernel32…)
  * Third-party library
  * Application code

Các biến thể thường dùng:

```
k      ; stack ngắn gọn
kb     ; stack + tham số
kv     ; stack chi tiết + symbol
```

📌 **Nguyên tắc vàng**

> Dòng “đáng nghi” nhất thường không phải là dòng trên cùng.

***

### 5. Kiểm tra module & DLL liên quan

#### Liệt kê module đã load

```
lm
```

#### Xem chi tiết một module cụ thể

```
lmvm ten_module
```

Ví dụ:

```
lmvm myapp
```

Bạn sẽ thấy:

* Version
* Timestamp
* Path
* Symbol status

📌 **Dấu hiệu nguy hiểm**

* DLL version không đồng nhất
* Module build quá cũ
* Third-party DLL không có symbol

***

### 6. Phân tích exception chi tiết

Nếu crash liên quan đến exception (rất phổ biến):

```
.exr -1
```

Kết hợp với:

```
.ecxr
```

Để chuyển context sang thời điểm exception xảy ra, sau đó xem lại stack:

```
kv
```

📌 **Đây là bước nhiều người bỏ qua**, nhưng lại cực kỳ quan trọng để thấy đúng trạng thái CPU & register khi crash.

***

### 7. Kiểm tra bộ nhớ & con trỏ nghi vấn

#### Kiểm tra vùng nhớ tại địa chỉ cụ thể

```
dd 0xADDRESS
```

Hoặc hiển thị theo kiểu con trỏ:

```
dq 0xADDRESS
```

#### Kiểm tra object (nếu có type info)

```
dt TypeName 0xADDRESS
```

📌 **Tư duy hệ thống**

* Access Violation ≠ bug ngay tại dòng code đó
* Rất thường là hậu quả của memory corruption xảy ra **trước đó rất lâu**

***

### 8. Khi nào nên dừng lại và đặt giả thuyết?

Một phiên debug dump hiệu quả **không phải chạy thật nhiều lệnh**, mà là:

* Mỗi lệnh trả lời **một câu hỏi cụ thể**
* Sau mỗi cụm lệnh, bạn phải có **giả thuyết mới**
* Nếu không có giả thuyết → bạn đang “soi dump mù”

Đây chính là khác biệt giữa:

* _Biết dùng WinDbg_
* _Biết phân tích hệ thống bằng WinDbg_

***

### Kết luận: WinDbg không dạy cú pháp – WinDbg rèn tư duy

Các cú pháp trong bài này chỉ là **bộ xương sống**. Giá trị thực sự mà WinDbg mang lại nằm ở:

* Tư duy suy luận dựa trên trạng thái hệ thống
* Khả năng đọc memory như đọc log sống
* Năng lực debug khi không còn công cụ nào khác

Trong các bài tiếp theo của **Cẩm nang NQDEV**, chúng ta sẽ tiếp tục đi sâu vào:

* Debug deadlock & high CPU
* Phân tích memory leak qua dump
* Case study production thực tế

👉 Theo dõi thêm tại **Cẩm nang NQDEV**:\
🔗 [https://blogs.nhquydev.net/](https://blogs.nhquydev.net/)

**NQDEV Platform** tin rằng:

> _Người hiểu hệ thống sâu là người không bị động trước sự cố._

{% code title="Tài liệu tham khảo" %}
```
http://www.windbg.org/
https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/
https://gist.github.com/reinaldocoelho/8ed0778c5ba7eb1f99fe0193e43542b2
```
{% endcode %}
