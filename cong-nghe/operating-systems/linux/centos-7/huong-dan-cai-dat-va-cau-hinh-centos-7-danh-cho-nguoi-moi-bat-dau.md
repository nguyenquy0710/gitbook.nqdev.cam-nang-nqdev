# Hướng dẫn cài đặt và cấu hình Centos 7 dành cho người mới bắt đầu

## **Giới thiệu**

VPS (Virtual Private Server) là một giải pháp lưu trữ được nhiều cá nhân và doanh nghiệp sử dụng để triển khai các ứng dụng, website, hoặc hệ thống. Đặc biệt, CentOS 7 là một trong những hệ điều hành phổ biến nhờ tính ổn định và bảo mật. Bài viết này sẽ hướng dẫn bạn từng bước cài đặt và cấu hình VPS CentOS 7 một cách an toàn và hiệu quả.

***

## 1. **Chuẩn Bị Trước Khi Bắt Đầu**

Trước khi tiến hành cài đặt và cấu hình, bạn cần chuẩn bị:

* **Thông tin đăng nhập VPS**: IP, tài khoản root, mật khẩu hoặc SSH key.
* **Phần mềm quản lý kết nối SSH**: Có thể sử dụng [PuTTY](https://putty.org/) (Windows) hoặc Terminal (Linux/Mac).
* **Kiến thức cơ bản về lệnh Linux**: Để thao tác dễ dàng hơn trong môi trường dòng lệnh.

***

## 2. **Kết Nối VPS**

1. Mở PuTTY (hoặc Terminal).
2. Nhập địa chỉ IP VPS và chọn **Port 22** (cổng mặc định của SSH).
3. Đăng nhập bằng tài khoản `root` và nhập mật khẩu đã được cung cấp.

📌 **Lưu ý**: Đổi mật khẩu mặc định sau khi đăng nhập lần đầu để tăng cường bảo mật.

```bash
passwd
```

***

## 3. **Cập Nhật Hệ Thống**

Việc cập nhật đảm bảo bạn có các bản vá lỗi và bảo mật mới nhất. Chạy các lệnh sau:

```bash
yum update -y
yum upgrade -y
```

***

## 4. **Cấu Hình Tường Lửa (Firewall)**

Tường lửa giúp bảo vệ VPS khỏi các truy cập trái phép. Cài đặt và cấu hình cơ bản với Firewalld:

1.  Kích hoạt Firewalld:

    ```bash
    systemctl start firewalld
    systemctl enable firewalld
    ```
2.  Mở các cổng cần thiết (ví dụ: HTTP, HTTPS, SSH):

    ```bash
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --reload
    ```

***

## 5. **Cài Đặt Các Gói Cần Thiết**

Một số gói cơ bản cần thiết cho quản trị hệ thống:

```bash
yum install wget curl nano vim -y
```

***

## 6. **Tạo Người Dùng Mới và Phân Quyền**

Không nên sử dụng tài khoản root để quản trị hàng ngày. Hãy tạo một tài khoản người dùng mới:

```bash
adduser myuser
passwd myuser
usermod -aG wheel myuser
```

📌 **Chuyển đổi quyền**: Dùng lệnh `sudo` khi cần quyền root.

***

## 7. **Cài Đặt Dịch Vụ Web (Apache/Nginx)**

### **Với Apache:**

1.  Cài đặt:

    ```bash
    yum install httpd -y
    ```
2.  Khởi động dịch vụ:

    ```bash
    systemctl start httpd
    systemctl enable httpd
    ```
3. Kiểm tra hoạt động: Truy cập `http://<IP-VPS>`.

### **Với Nginx:**

1.  Cài đặt:

    ```bash
    yum install nginx -y
    ```
2.  Khởi động dịch vụ:

    ```bash
    systemctl start nginx
    systemctl enable nginx
    ```

***

## 8. **Tăng Cường Bảo Mật VPS**

### **Tắt đăng nhập bằng root qua SSH**:

#### Tìm và sửa dòng:

```bash
nano /etc/ssh/sshd_config
```

#### Sửa file cấu hình SSH:

```bash
PermitRootLogin no
```

#### Sau đó, khởi động lại SSH:

```bash
systemctl restart sshd
```

### **Cài đặt Fail2Ban** để ngăn chặn brute-force:

```bash
yum install epel-release -y
yum install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban
```

***

## 9. **Sao Lưu và Quản Lý VPS**

Hãy thường xuyên sao lưu dữ liệu bằng cách sử dụng các công cụ như `rsync` hoặc các giải pháp cloud backup.

***

## Kết Luận

Bài viết trên đã hướng dẫn bạn cài đặt và cấu hình VPS CentOS 7 từ cơ bản đến nâng cao. Việc bảo mật và duy trì hệ thống là yếu tố then chốt để VPS của bạn hoạt động ổn định. Nếu bạn gặp khó khăn, hãy để lại bình luận trên blog [Cẩm nang NQDEV](../../../), chúng tôi sẽ hỗ trợ bạn kịp thời!

Chúc bạn thành công! 🚀
