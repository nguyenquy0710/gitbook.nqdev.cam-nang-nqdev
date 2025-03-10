---
description: Ubuntu Server CLI cheat sheet 2024 v6.pdf
---

# Ubuntu CLI cheat sheet

{% embed url="https://assets.ubuntu.com/v1/3bd0daaf-Ubuntu%20Server%20CLI%20cheat%20sheet%202024%20v6.pdf" %}
Ubuntu Server CLI cheat sheet 2024 v6.pdf
{% endembed %}



[Nội dung then chốt từ tài liệu PDF trái phép với yêu cầu chia sẻ thông tin dưới dạng đánh dấu độc quyền. Xin vui lòng xem tài liệu trực tiếp bằng cách bấm vào liên kết trên.](https://assets.ubuntu.com/v1/3bd0daaf-Ubuntu%20Server%20CLI%20cheat%20sheet%202024%20v6.pdf)

Dưới đây là tóm tắt một số lệnh quan trọng trong môi trường Ubuntu Server:

#### Cập nhật và Quản lý Gói

* **Cập nhật danh sách gói**: Chạy `sudo apt update` để làm mới thông tin gói.
* **Nâng cấp hệ thống**: Sử dụng `sudo apt upgrade` để cài đặt các phiên bản mới nhất của các gói hiện có.
* **Xóa các gói không còn cần thiết**: `sudo apt autoremove` giúp loại bỏ các gói không cần thiết.

#### Quản lý Tệp và Thư Mục

* **Liệt kê thư mục**: `ls` sẽ hiển thị nội dung trong thư mục hiện tại hoặc một thư mục được chỉ định.
* **Chuyển đổi thư mục**: Sử dụng `cd <thư_mục>` để di chuyển đến thư mục mong muốn.
* **Tạo thư mục**: `mkdir <tên_thư_mục>` sẽ tạo một thư mục mới.
* **Xóa tệp hoặc thư mục**: `rm <tên_tệp>` hoặc `rm -r <tên_thư_mục>` để xóa.

#### Quản lý Người Dùng

* **Tạo người dùng mới**: `adduser <tên_người_dùng>` để thêm một người dùng mới với thông tin chi tiết.
* **Thay đổi thông tin người dùng**: `usermod -l <tên_mới> <tên_cũ>` để thay đổi tên người dùng.
* **Xóa người dùng**: `deluser <tên_người_dùng>` để loại bỏ một người dùng.

#### Kiểm tra Hệ Thống

* **Hiển thị các tiến trình đang chạy**: `top` hiển thị các tiến trình theo thời gian thực.
* **Kiểm tra dung lượng đĩa**: `df -h` để kiểm tra dung lượng đĩa còn trống theo định dạng dễ đọc.
* **Kiểm tra bộ nhớ**: `free -h` cho thông tin về việc sử dụng bộ nhớ.

Ngoài ra, tài liệu cũng cung cấp ví dụ chi tiết và các mẹo thực hành tốt cho việc quản lý máy chủ bằng dòng lệnh. Để biết thêm chi tiết và các trường hợp sử dụng cụ thể, vui lòng truy cập tài liệu PDF qua liên kết trên.
