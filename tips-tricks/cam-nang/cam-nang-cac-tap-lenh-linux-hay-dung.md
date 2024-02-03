---
description: 'Nguồn: techmaster.vn'
---

# Cẩm nang các tập lệnh Linux hay dùng

Linux không khó chỉ tại các bạn nghĩ nó khó. 98% máy chủ đang chạy ở các data center sử dụng một biến thể nào đó của Linux. Nếu bạn thành thạo lệnh Linux thì bạn cũng sử dụng terminal Mac, Unix dễ dàng.

## Tệp và thư mục

1. **ls**: Liệt kê nội dung của một thư mục
2. **cd**: Thay đổi thư mục làm việc hiện tại
3. **mkdir**: Tạo thư mục mới
4. **rmdir**: Xóa thư mục rỗng
5. **touch**: Tạo một tệp trống mới hoặc cập nhật ngày sửa đổi cuối cùng của một tệp hiện có
6. **cp**: Sao chép một tập tin hoặc thư mục
7. **mv**: Di chuyển hoặc đổi tên tệp hoặc thư mục
8. **rm**: Xóa một tập tin hoặc thư mục
9. **cat**: Hiển thị nội dung của một tập tin
10. **less**: Hiển thị nội dung của tệp trên một trang tại một thời điểm
11. **head**: Hiển thị một vài dòng đầu tiên của tệp
12. **tail**: Hiển thị vài dòng cuối cùng của tệp
13. **grep**: Tìm kiếm một mẫu cụ thể trong một tệp hoặc thư mục
14. **find**: Tìm kiếm một tệp hoặc thư mục theo tên hoặc các tiêu chí khác
15. **chmod**: Thay đổi quyền của một tập tin hoặc thư mục
16. **chown**: Thay đổi chủ sở hữu của một tập tin hoặc thư mục
17. **stat**: Hiển thị thông tin về một tập tin hoặc thư mục
18. **zip**: nén file
19. **unzip**: giãn nén file

## Phân quyền và truy cập têp, thư mục

1. **chmod**: Thay đổi quyền của một tập tin hoặc thư mục
2. **chown**: Thay đổi chủ sở hữu của một tập tin hoặc thư mục
3. **chgrp**: Thay đổi quyền sở hữu nhóm của một tệp hoặc thư mục
4. **umask**: Đặt quyền mặc định cho các tệp và thư mục mới được tạo

## Quản lý user, group

1. **useradd**: Tạo người dùng mới trong hệ thống
2. **usermod**: Sửa đổi tài khoản người dùng hiện có
3. **userdel**: Xóa tài khoản người dùng
4. **passwd**: Thay đổi mật khẩu của người dùng
5. **groupadd**: Tạo một nhóm mới
6. **groupmod**: Sửa đổi một nhóm hiện có
7. **groupdel**: Xóa một nhóm.
8. **whoami**: trả về người dùng đang đăng nhập

## Mạng

1. **ping**: Gửi gói kiểm tra đến máy chủ mạng để kiểm tra xem có thể truy cập được không
2. **traceroute**: Hiển thị tuyến đường được thực hiện bởi các gói đến một máy chủ mạng cụ thể
3. **ifconfig**: Hiển thị cấu hình của giao diện mạng và trạng thái của chúng
4. **ip**: Hiển thị và sửa đổi cấu hình của giao diện mạng
5. **route**: Hiển thị và sửa đổi bảng định tuyến
6. **netstat**: Hiển thị kết nối mạng, bảng định tuyến, v.v..
7. **nslookup**: Truy vấn DNS để lấy thông tin về tên miền hoặc địa chỉ IP
8. **dig**: Truy vấn DNS để lấy thông tin về tên miền hoặc địa chỉ IP
9. **nmap**: Quét mạng để khám phá máy chủ và dịch vụ
10. **tcpdump**: Chụp và hiển thị các gói trên mạng

## Quản lý tiền trình

1. **ps**: Liệt kê các tiến trình đang chạy trên hệ thống
2. **top**: Hiển thị chế độ xem động của các tiến trình hàng đầu theo mức sử dụng CPU hoặc bộ nhớ
3. **htop**: Hiển thị chế độ xem động của các tiến trình hàng đầu với giao diện tương tác hơn
4. **kill**: Gửi tín hiệu tới một tiến trình để chấm dứt nó
5. **killall**: Gửi tín hiệu tới tất cả các tiến trình có tên được chỉ định để chấm dứt chúng
6. **pkill**: Gửi tín hiệu tới một tiến trình dựa trên tên của nó hoặc các tiêu chí khác
7. **nice**: Thay đổi mức độ ưu tiên của một tiến trình
8. **renice**: Thay đổi mức độ ưu tiên của một tiến trình đang chạy
9. **bg**: Gửi tiến trình đã dừng xuống nền
10. **fg**: Đưa tiến trình nền lên phía trước
11. **service**: khởi động, dừng, tái khởi động dịch vụ kiểu System V

## Quản lý gói phần mềm

* **apt** (Debian/Ubuntu): Cài đặt, xóa và cập nhật các gói trên hệ thống sử dụng Công cụ đóng gói nâng cao (APT)
* **yum** (Red Hat/Fedora/CentOS): Cài đặt, xóa và cập nhật các gói trên hệ thống sử dụng Trình cập nhật Yellowdog, Đã sửa đổi (YUM)
* **dnf** (Fedora 22 trở lên): Cài đặt, xóa và cập nhật các gói trên hệ thống sử dụng Dandified YUM (DNF)
* **zypper** (SUSE/openSUSE): Cài đặt, gỡ bỏ và cập nhật các gói trên hệ thống sử dụng trình quản lý gói ZYpp
* **pacman** (Arch Linux): Cài đặt, gỡ bỏ và cập nhật các gói trên hệ thống Arch Linux

Các trình quản lý gói này cho phép bạn cài đặt, gỡ bỏ và cập nhật các gói phần mềm trên hệ thống của mình. Ví dụ:

* `apt-get install` để cài đặt gói
* `apt-get remove` để xóa gói
* `apt-get update` để cập nhật cơ sở dữ liệu gói và nâng cấp các gói đã cài đặt.

Các bản phân phối Linux khác nhau sử dụng các trình quản lý gói khác nhau, vì vậy bạn sẽ cần sử dụng lệnh thích hợp cho hệ thống của mình

## Truy vấn thông tin máy tính

1. `uptime`: Hiển thị thời gian hệ thống đã chạy và tải trung bình hiện tại
2. `free`: Hiển thị dung lượng bộ nhớ trống và đã sử dụng trong hệ thống
3. `df`: Hiển thị dung lượng trống trên mỗi hệ thống tệp được gắn kết
4. `du`: Hiển thị không gian được sử dụng bởi một thư mục và các thư mục con của nó
5. `top`: Hiển thị chế độ xem động của các tiến trình hàng đầu theo mức sử dụng CPU hoặc bộ nhớ
6. `htop`: Hiển thị chế độ xem động của các tiến trình hàng đầu với giao diện tương tác hơn
7. `lsof`: Hiển thị danh sách các tệp đang mở và tiến trình mở chúng
8. `ps`: Hiển thị danh sách các tiến trình đang chạy
9. `netstat`: Hiển thị kết nối mạng, bảng định tuyến, v.v.
10. `vmstat`: Hiển thị thống kê bộ nhớ ảo

## Làm việc với thiết bị

1. `lsblk`: Liệt kê các thiết bị lưu trữ (ví dụ: ổ cứng, ổ USB)
2. `lspci`: Liệt kê các thiết bị PCI (ví dụ: card mạng, card đồ họa)
3. `lsusb`: Liệt kê các thiết bị USB
4. `lshw`: Liệt kê các thiết bị phần cứng và thuộc tính của chúng
5. `lsscsi`: Liệt kê các thiết bị SCSI (ví dụ: ổ cứng, ổ băng từ)
6. `dmesg`: Hiển thị nhật ký thông báo nhân của hệ điều hành OS kennel

## Làm việc với ổ lưu trữ

1. `df`: Hiển thị dung lượng trống trên mỗi hệ thống tệp được gắn kết
2. `du`: Hiển thị không gian được sử dụng bởi một thư mục và các thư mục con của nó
3. `lsblk`: Liệt kê các ổ lưu trữ (ví dụ: ổ cứng, ổ USB)
4. `fdisk`: Phân vùng và định dạng ổ cứng
5. `mkfs`: Tạo hệ thống file trên ổ cứng
6. `mount`: Gắn ổ lưu trữ thành một thư mục
7. `umount`: Gỡ bỏ ổ lưu trữ
8. `parted`: Thay đổi kích thước, tạo và xóa phân vùng ổ cứng
9. `gparted`: Thay đổi kích thước, tạo và xóa phân vùng bằng giao diện đồ họa
10. `fsck`: Kiểm tra và sửa chữa một hệ thống tập tin

## Kết nối tới máy chủ khác

1. `ssh`: tạo kết nối Secure Shell Protocol để điều khiển hệ điều hành Linux, Unix từ xa
2. `wget`: tải file trên internet
3. `curl`: tạo yêu cầu HTTP
