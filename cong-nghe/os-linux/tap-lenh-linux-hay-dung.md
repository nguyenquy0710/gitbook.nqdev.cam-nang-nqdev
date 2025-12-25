---
description: 'Tập lệnh Linux hay dùng: Nền tảng bắt buộc cho lập trình viên hiện đại'
---

# Tập lệnh Linux hay dùng

Trong thế giới phát triển phần mềm ngày nay, Linux không còn là lựa chọn phụ mà đã trở thành **hệ điều hành cốt lõi** của server, cloud, container và hệ thống CI/CD. Việc nắm vững các tập lệnh Linux thông dụng giúp lập trình viên **chủ động kiểm soát hệ thống**, xử lý sự cố nhanh và tối ưu hiệu suất một cách bài bản.

Bài viết này trong **Cẩm nang NQDEV** sẽ hệ thống lại các nhóm lệnh Linux quan trọng nhất, không chỉ dừng ở “biết lệnh”, mà hướng tới **hiểu đúng – dùng đúng – dùng hiệu quả** trong thực tế.

***

### 1. Quản lý gói cài đặt – Nền móng của hệ thống Linux

Trên các bản phân phối dựa trên Debian/Ubuntu, `apt-get` là công cụ quản lý gói quen thuộc:

* `apt-get install <package>`\
  → Cài đặt gói phần mềm
* `apt-get remove <package>`\
  → Gỡ bỏ gói đã cài
* `apt-get update`\
  → Cập nhật cơ sở dữ liệu gói (rất quan trọng trước khi cài mới)

> 💡 Lưu ý chiến lược:\
> Mỗi bản phân phối Linux có **trình quản lý gói riêng** (`yum`, `dnf`, `pacman`, `zypper`…). Lập trình viên chuyên nghiệp cần **hiểu tư duy chung**, không chỉ học thuộc một câu lệnh.

***

### 2. Truy vấn thông tin hệ thống – Đọc “sức khỏe” máy chủ

Đây là nhóm lệnh giúp bạn **hiểu hệ thống đang sống hay đang… hấp hối**.

* `uptime` – Thời gian chạy và tải trung bình (load average)
* `free` – Tình trạng bộ nhớ RAM
* `df` – Dung lượng trống của các filesystem
* `du` – Dung lượng thực tế thư mục đang chiếm
* `top` – Danh sách tiến trình tiêu thụ CPU/RAM
* `htop` – Phiên bản nâng cao, trực quan và tương tác hơn
* `ps` – Liệt kê tiến trình đang chạy
* `lsof` – File nào đang bị process nào “giữ”
* `netstat` – Kết nối mạng, port, routing
* `vmstat` – Thống kê bộ nhớ ảo, swap, I/O

> 🎯 Góc nhìn NQDEV Platform:\
> Khi debug hiệu năng, **đừng nhìn một lệnh đơn lẻ**. Hãy kết hợp `top + free + vmstat` để có cái nhìn toàn cảnh.

***

### 3. Làm việc với thiết bị phần cứng

Nhóm lệnh này cực kỳ quan trọng khi làm việc với server vật lý, VM hoặc troubleshooting phần cứng:

* `lsblk` – Danh sách thiết bị lưu trữ
* `lspci` – Thiết bị PCI (card mạng, GPU…)
* `lsusb` – Thiết bị USB
* `lshw` – Thông tin chi tiết phần cứng
* `lsscsi` – Thiết bị SCSI
* `dmesg` – Nhật ký kernel (vũ khí tối thượng khi lỗi driver)

> 🔍 Tư duy dài hạn:\
> `dmesg` không chỉ là log – nó là **dòng thời gian sự cố của kernel**.

***

### 4. Quản lý ổ lưu trữ và hệ thống tập tin

Đây là khu vực “nguy hiểm nhưng bắt buộc phải biết”:

* `df`, `du`, `lsblk` – Quan sát dung lượng
* `fdisk`, `parted` – Phân vùng ổ đĩa
* `mkfs` – Tạo filesystem
* `mount`, `umount` – Gắn / gỡ ổ lưu trữ
* `fsck` – Kiểm tra và sửa lỗi filesystem
* `gparted` – Công cụ đồ họa (GUI)

> ⚠️ Khuyến nghị:\
> **Luôn backup trước khi dùng `fdisk`, `mkfs`, `parted`**. Một lệnh sai có thể xóa toàn bộ dữ liệu.

***

### 5. Kết nối và làm việc với máy chủ từ xa

Không có Linux hiện đại nếu thiếu kết nối mạng:

* `ssh` – Điều khiển máy chủ từ xa an toàn
* `wget` – Tải file nhanh, gọn
* `curl` – Gửi HTTP request, kiểm thử API

> 🚀 Với DevOps:\
> `ssh + curl` là cặp đôi quyền lực để kiểm tra dịch vụ production mà không cần trình duyệt.

***

### Kết luận: Biết lệnh là một chuyện – làm chủ Linux là chuyện khác

Danh sách lệnh trên không nhằm để học thuộc, mà để xây dựng **tư duy làm việc với hệ điều hành Linux một cách chủ động**. Khi bạn hiểu vì sao dùng lệnh đó, trong ngữ cảnh nào, bạn đã vượt qua mức “người dùng Linux” để tiến gần hơn tới **kỹ sư hệ thống thực thụ**.

👉 Nếu bạn muốn tiếp tục đào sâu Linux theo hướng **lập trình – DevOps – hệ thống**, hãy theo dõi thêm các bài viết tại\
🔗 **Cẩm nang NQDEV**: [https://blogs.nhquydev.net/](https://blogs.nhquydev.net/)

**NQDEV Platform** không chỉ chia sẻ kiến thức, mà hướng bạn đến **cách tư duy dài hạn và bền vững trong nghề công nghệ**.

***

{% code title="Tài liệu tham khảo" lineNumbers="true" %}
```
techmaster.vn
```
{% endcode %}
