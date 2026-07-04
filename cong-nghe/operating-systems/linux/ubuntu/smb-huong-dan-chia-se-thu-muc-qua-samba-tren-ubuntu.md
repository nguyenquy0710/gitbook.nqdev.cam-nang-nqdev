---
description: >-
  SMB (Server Message Block) – còn được biết đến với tên gọi CIFS (Common
  Internet File System) – là giao thức chia sẻ file và máy in phổ biến nhất
  trong môi trường Windows.
---

# Hướng dẫn chia sẻ thư mục qua SMB (Samba) trên Ubuntu

Nhờ có **Samba**, Ubuntu có thể trở thành một máy chủ chia sẻ file hoạt động liền mạch với Windows, macOS và cả các bản phân phối Linux khác.

Trong bài viết này, tôi sẽ hướng dẫn bạn từng bước thiết lập một thư mục chia sẻ qua SMB trên Ubuntu, kèm theo các tùy chọn xác thực và phân quyền cơ bản.

***

### 1. Điều kiện tiên quyết

* Một máy tính cài **Ubuntu 20.04/22.04/24.04** (các phiên bản khác cũng tương tự).
* Quyền `sudo` hoặc tài khoản root.
* Máy chủ và máy khách nằm trong cùng mạng nội bộ.
* Địa chỉ IP tĩnh được khuyến khích để tránh thay đổi sau mỗi lần khởi động lại.

***

### 2. Cập nhật hệ thống và cài đặt Samba

Trước tiên, hãy cập nhật danh sách gói và nâng cấp hệ thống:

bash

```bash
sudo apt update && sudo apt upgrade -y
```

Sau đó cài đặt Samba:

bash

```bash
sudo apt install samba -y
```

Sau khi cài đặt, bạn có thể kiểm tra phiên bản Samba:

bash

```bash
smbd --version
```

Kết quả tương tự: `Version 4.15.13-Ubuntu`.

***

### 3. Tạo thư mục muốn chia sẻ

Giả sử bạn muốn chia sẻ thư mục `share` nằm trong thư mục người dùng `nqdev`.\
Tạo thư mục và cấp quyền phù hợp:

bash

```bash
mkdir -p /home/nqdev/share
sudo chmod -R 0755 /home/nqdev/share
sudo chown -R nqdev:nqdev /home/nqdev/share
```

* `chmod 0755`: chủ sở hữu có toàn quyền (đọc, ghi, thực thi), nhóm và người khác chỉ đọc và thực thi.
* `chown nqdev:nqdev`: gán chủ sở hữu và nhóm là `nqdev`.

Nếu bạn muốn cho phép người dùng khác ghi vào thư mục, hãy đặt quyền `0777` (không an toàn) hoặc tạo nhóm riêng và gán quyền.

***

### 4. Sao lưu file cấu hình gốc

Trước khi sửa file cấu hình, hãy sao lưu để dễ khôi phục:

bash

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```

***

### 5. Cấu hình Samba

Mở file cấu hình bằng trình soạn thảo (nano hoặc vim):

bash

```bash
sudo nano /etc/samba/smb.conf
```

#### 5.1. Cấu hình phần `[global]` (tuỳ chọn)

Bạn có thể để mặc định hoặc thêm các tuỳ chỉnh sau vào cuối phần `[global]`:

ini

```ini
[global]
   workgroup = WORKGROUP
   server string = %h server (Samba, Ubuntu)
   netbios name = ubuntu-server
   map to guest = bad user
   dns proxy = no
```

* `map to guest = bad user`: nếu người dùng không tồn tại, tự động chuyển thành guest (hữu ích khi bật guest access).

#### 5.2. Định nghĩa share

Cuối file, thêm một định nghĩa share. Ví dụ:

ini

```ini
[MyShare]
   comment = Thư mục chia sẻ của NQDEV
   path = /home/nqdev/share
   browseable = yes
   read only = no
   guest ok = no
   valid users = nqdev
   create mask = 0755
   directory mask = 0755
```

**Giải thích các tuỳ chọn**:

* `[MyShare]` – tên share sẽ hiển thị trên mạng.
* `comment` – mô tả (xuất hiện khi duyệt mạng).
* `path` – đường dẫn thư mục thực tế.
* `browseable` – hiển thị trong danh sách share khi duyệt mạng.
* `read only = no` – cho phép ghi.
* `guest ok = no` – yêu cầu xác thực (đặt `yes` nếu muốn cho phép khách không cần mật khẩu).
* `valid users` – chỉ cho phép người dùng `nqdev` truy cập.
* `create mask` / `directory mask` – quyền tạo file/thư mục mới (theo chuẩn Linux).

Nếu bạn muốn **cho phép truy cập guest (không cần mật khẩu)** và không yêu cầu tài khoản, đặt:

ini

```ini
   guest ok = yes
   read only = no
   force user = nqdev          # tuỳ chọn: áp dụng quyền của người dùng nqdev cho guest
```

Lưu file và thoát (Ctrl + O, Enter, Ctrl + X với nano).

***

### 6. Thêm người dùng Samba

Samba sử dụng cơ sở dữ liệu riêng để quản lý mật khẩu.\
Tạo người dùng Samba với mật khẩu (người dùng này phải tồn tại trong hệ thống Ubuntu):

bash

```bash
sudo smbpasswd -a nqdev
```

Hệ thống sẽ yêu cầu nhập mật khẩu (có thể khác với mật khẩu đăng nhập Ubuntu).\
Để kích hoạt tài khoản:

bash

```bash
sudo smbpasswd -e nqdev
```

***

### 7. Khởi động lại dịch vụ Samba và cấu hình tường lửa

Khởi động lại các dịch vụ `smbd` (server SMB) và `nmbd` (hỗ trợ NetBIOS):

bash

```bash
sudo systemctl restart smbd nmbd
```

Kích hoạt tự động khởi động cùng hệ thống:

bash

```bash
sudo systemctl enable smbd nmbd
```

Nếu bạn đang sử dụng tường lửa **ufw**, hãy mở các cổng cho Samba:

bash

```bash
sudo ufw allow samba
```

hoặc cụ thể hơn:

bash

```bash
sudo ufw allow 445/tcp
sudo ufw allow 139/tcp
sudo ufw allow 137/udp
sudo ufw allow 138/udp
```

***

### 8. Kiểm tra trạng thái dịch vụ

Xem `smbd` đã chạy chưa:

bash

```bash
sudo systemctl status smbd
```

Kiểm tra cấu hình Samba có lỗi cú pháp không:

bash

```bash
testparm
```

Lệnh này sẽ hiển thị cấu hình hợp lệ và cảnh báo nếu có lỗi.

***

### 9. Truy cập thư mục chia sẻ

#### 9.1. Từ máy tính Windows

*   Mở **File Explorer**, nhập đường dẫn:

    text

    ```bash
    \\địa_chỉ_ip_ubuntu\MyShare
    ```

    Ví dụ: `\\192.168.1.100\MyShare`
* Nhập tên người dùng và mật khẩu Samba (đã tạo ở bước 6).
* Nếu không thấy share, hãy thử dùng IP thay vì tên máy.

#### 9.2. Từ macOS

* Mở **Finder** → menu **Go** → **Connect to Server...** (⌘K)
* Nhập: `smb://địa_chỉ_ip_ubuntu/MyShare`
* Nhập thông tin đăng nhập.

#### 9.3. Từ Linux

Dùng lệnh `smbclient`:

bash

```bash
smbclient //192.168.1.100/MyShare -U nqdev
```

Hoặc mount thư mục vào hệ thống:

bash

```bash
sudo mount -t cifs //192.168.1.100/MyShare /mnt/share -o username=nqdev,password=your_password
```

***

### 10. Xử lý sự cố thường gặp

#### 10.1. Lỗi “Permission denied” khi ghi file

* Kiểm tra quyền Linux của thư mục: `ls -ld /home/nqdev/share`
* Kiểm tra `create mask` và `directory mask` trong `smb.conf`.
* Nếu dùng guest, hãy thêm `force user = nqdev` để đảm bảo quyền ghi.

#### 10.2. Không thể kết nối từ Windows

* Tắt tường lửa tạm thời để kiểm tra: `sudo ufw disable` (sau đó bật lại).
* Đảm bảo máy khách và máy chủ cùng subnet.
* Kiểm tra log Samba: `sudo tail -f /var/log/samba/log.smbd`

#### 10.3. Vẫn hỏi mật khẩu dù đã đặt guest ok = yes

Thêm dòng `map to guest = bad user` vào phần `[global]` trong `smb.conf` và khởi động lại Samba.

#### 10.4. Lỗi “You do not have permission to access” trên Windows 10/11

* Mở **Control Panel** → **Programs and Features** → **Turn Windows features on or off** → bật **SMB 1.0/CIFS Client** (không khuyến khích vì bảo mật) hoặc đảm bảo máy chủ Samba hỗ trợ SMB2/3 (Samba mặc định hỗ trợ).
* Đôi khi Windows yêu cầu đăng nhập với định dạng `tên_máy\tên_người_dùng`.

***

### 11. Kết luận

Bạn đã hoàn tất việc thiết lập một máy chủ chia sẻ file SMB trên Ubuntu. Với cấu hình trên, bạn có thể dễ dàng chia sẻ dữ liệu giữa các hệ điều hành khác nhau trong mạng nội bộ.

Samba còn rất nhiều tuỳ chỉnh nâng cao như chia sẻ theo nhóm, tích hợp với Active Directory, giới hạn băng thông, v.v. Tuỳ vào nhu cầu, bạn có thể mở rộng cấu hình để đáp ứng các yêu cầu phức tạp hơn.

Hy vọng bài viết này hữu ích với bạn. Nếu có bất kỳ thắc mắc, hãy để lại bình luận bên dưới.

***

**Cẩm nang NQDEV** – Kiến thức IT thực chiến, dễ hiểu và áp dụng ngay.
