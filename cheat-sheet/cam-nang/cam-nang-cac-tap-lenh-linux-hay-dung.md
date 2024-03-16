---
description: 'Nguồn: techmaster.vn'
---

# Cẩm nang các tập lệnh Linux hay dùng

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
