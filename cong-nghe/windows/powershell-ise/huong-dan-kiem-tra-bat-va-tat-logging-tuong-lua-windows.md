---
description: >-
  Trong quá trình vận hành hệ thống hoặc debug kết nối (SSH, HTTP, database…),
  việc bị chặn bởi Windows Firewall là tình huống rất phổ biến nhưng lại khó
  phát hiện nếu không có log.
---

# Hướng dẫn kiểm tra, bật và tắt logging tường lửa Windows

Bài viết này trong **Cẩm nang NQDEV** sẽ giúp bạn:

* Hiểu cách kiểm tra trạng thái logging của firewall
* Bật log để theo dõi gói tin bị chặn / cho phép
* Đọc log để phân tích nguyên nhân
* Tắt log khi không còn cần thiết

👉 Tham khảo thêm tại: [**Cẩm nang NQDEV**](https://blogs.nhquydev.net/) để cập nhật các hướng dẫn thực tế khác trên **NQDEV Platform**.

***

### 1. Khi nào bạn nên bật logging Firewall?

Bạn nên bật log khi gặp các tình huống như:

* Không kết nối được đến server (timeout, connection refused)
* Service chạy bình thường nhưng không truy cập được từ bên ngoài
* Nghi ngờ firewall đang chặn port hoặc IP

👉 Logging sẽ giúp bạn trả lời câu hỏi quan trọng:

> **Gói tin có bị firewall drop hay không?**

***

### 2. Kiểm tra trạng thái logging hiện tại

Mở **PowerShell (Run as Administrator)** và chạy:

```
Get-NetFirewallProfile | Select Name, Enabled, LogFileName, LogAllowed, LogBlocked
```

#### Ý nghĩa:

* `LogFileName`: đường dẫn file log
* `LogAllowed`: có log gói tin được phép không
* `LogBlocked`: có log gói tin bị chặn không

👉 Nếu `False` → logging đang tắt

***

### 3. Bật logging tường lửa Windows

#### Lệnh bật log đầy đủ (khuyến nghị khi debug):

```
Set-NetFirewallProfile -Profile Private,Public `
-LogFileName "C:\Windows\System32\LogFiles\Firewall\pfirewall.log" `
-LogAllowed True `
-LogBlocked True
```

#### Giải thích:

* `Private, Public`: áp dụng cho mạng nội bộ & mạng công cộng
* `LogAllowed True`: ghi log các kết nối được phép
* `LogBlocked True`: ghi log các kết nối bị chặn

👉 Trong thực tế:

* Chỉ cần bật `LogBlocked` là đủ để debug nhanh
* `LogAllowed` nên bật khi cần phân tích sâu

***

### 4. Vị trí file log Firewall

File log mặc định:

```
C:\Windows\System32\LogFiles\Firewall\pfirewall.log
```

#### Cách mở nhanh:

* Dùng Notepad
* Hoặc PowerShell:

```
notepad C:\Windows\System32\LogFiles\Firewall\pfirewall.log
```

***

### 5. Cách đọc log Firewall (rất quan trọng)

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/windows/powershell-ise/ps-wf-001.jpg" alt=""><figcaption></figcaption></figure>

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/windows/powershell-ise/ps-wf-002.jpg" alt=""><figcaption></figcaption></figure>

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/windows/powershell-ise/ps-wf-004.jpg" alt=""><figcaption></figcaption></figure>

Một dòng log mẫu:

```
2026-03-22 10:15:30 DROP TCP 192.168.1.10 192.168.1.20 12345 80 ...
```

#### Ý nghĩa nhanh:

* `DROP` → bị chặn ❌
* `ALLOW` → được phép ✅
* `TCP/UDP` → giao thức
* `IP nguồn → IP đích`
* `Port nguồn → Port đích`

👉 Ví dụ:

* Nếu thấy `DROP TCP ... port 3306` → MySQL bị chặn
* Nếu thấy `DROP TCP ... port 22` → SSH bị chặn

***

### 6. Test lại kết nối sau khi bật log

Sau khi bật logging:

1. Thử lại kết nối (curl, telnet, browser…)
2. Mở file log
3. Tìm theo:
   * IP
   * Port
   * Thời gian

👉 Đây là cách debug nhanh nhất khi deploy trên **NQDEV Platform** hoặc server Windows.

***

### 7. Tắt logging khi không cần thiết

Logging liên tục có thể:

* Làm file log rất lớn
* Ảnh hưởng hiệu năng (nhẹ nhưng đáng lưu ý)

#### Tắt log:

```
Set-NetFirewallProfile -Profile Private,Public `
-LogAllowed False `
-LogBlocked False
```

***

### 8. Best Practices (kinh nghiệm thực tế)

* Chỉ bật log khi debug → tắt sau khi xong
* Luôn kiểm tra `DROP` trước khi nghi ngờ ứng dụng
* Kết hợp với:
  * `netstat -an`
  * `Test-NetConnection`
* Nếu không có log → vấn đề có thể không nằm ở firewall

***

### Kết luận

Logging của Windows Firewall là một công cụ cực kỳ mạnh nhưng thường bị bỏ qua. Khi biết cách sử dụng đúng, bạn có thể:

* Xác định chính xác nguyên nhân lỗi kết nối
* Tránh mất thời gian debug sai hướng
* Hiểu rõ hơn cách hệ thống mạng hoạt động

Trong hệ sinh thái vận hành hiện đại, đặc biệt khi làm việc với cloud, container hay CI/CD trên **NQDEV Platform**, việc nắm vững kỹ năng này sẽ giúp bạn xử lý sự cố nhanh và chính xác hơn rất nhiều.
