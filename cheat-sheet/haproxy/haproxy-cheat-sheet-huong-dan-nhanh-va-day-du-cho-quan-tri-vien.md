---
description: >-
  HAProxy (High Availability Proxy) là một công cụ cân bằng tải và proxy mã
  nguồn mở, phổ biến trong việc xây dựng các hệ thống phân tán với độ sẵn sàng
  cao.
---

# HAProxy Cheat Sheet: Hướng dẫn nhanh và đầy đủ cho quản trị viên

Bài viết này tổng hợp các lệnh, cấu hình, và mẹo sử dụng HAProxy hiệu quả nhất.

***

## **1. HAProxy là gì?**

HAProxy là một phần mềm:

* **Cân bằng tải** (Load Balancer): Phân phối lưu lượng mạng đến nhiều server backend.
* **Proxy ngược** (Reverse Proxy): Đóng vai trò trung gian giữa client và server.
* Được sử dụng để cải thiện hiệu năng, bảo mật và độ tin cậy của hệ thống.

***

## **2. Cài đặt HAProxy**

### **Cài đặt trên Ubuntu/Debian**

```bash
sudo apt update
sudo apt install haproxy
```

### **Kiểm tra phiên bản**

```bash
haproxy -v
```

### **Khởi động và dừng HAProxy**

```bash
sudo systemctl start haproxy
sudo systemctl stop haproxy
sudo systemctl restart haproxy
sudo systemctl enable haproxy
```

***

## **3. Cấu trúc tệp cấu hình HAProxy**

File cấu hình mặc định của HAProxy thường nằm ở:

```bash
/etc/haproxy/haproxy.cfg
```

### Cấu trúc file gồm 4 phần chính:

1. **Global**: Các cài đặt toàn cục (log, số lượng kết nối tối đa).
2. **Defaults**: Cấu hình mặc định cho các proxy.
3. **Frontend**: Giao diện tiếp nhận kết nối từ client.
4. **Backend**: Server phía sau xử lý yêu cầu từ frontend.

***

## **4. Các Lệnh HAProxy CLI**

| **Lệnh**                        | **Chức năng**                                  |
| ------------------------------- | ---------------------------------------------- |
| `haproxy -f /path/to/config`    | Chạy HAProxy với tệp cấu hình cụ thể.          |
| `haproxy -c -f /path/to/config` | Kiểm tra tính hợp lệ của file cấu hình.        |
| `haproxy -v`                    | Hiển thị phiên bản của HAProxy.                |
| `haproxy -sf <pid>`             | Reload HAProxy mà không làm gián đoạn dịch vụ. |

***

## **5. Ví dụ Cấu hình HAProxy**

### **Cân bằng tải HTTP cơ bản**

```haproxy
global
    log /dev/log local0
    maxconn 2000

defaults
    log global
    mode http
    timeout connect 5s
    timeout client 50s
    timeout server 50s

frontend http-in
    bind *:80
    default_backend web-backend

backend web-backend
    balance roundrobin
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```

### **Cân bằng tải HTTPS**

```haproxy
frontend https-in
    bind *:443 ssl crt /etc/ssl/certs/haproxy.pem
    default_backend web-backend
```

### **Cân bằng tải theo IP Hash**

```haproxy
backend web-backend
    balance source
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```

***

## **6. Các Kiểu Cân Bằng Tải**

| **Kiểu Cân Bằng** | **Mô Tả**                                                           |
| ----------------- | ------------------------------------------------------------------- |
| `roundrobin`      | Phân phối yêu cầu tuần tự giữa các server.                          |
| `leastconn`       | Chuyển yêu cầu đến server có ít kết nối nhất.                       |
| `source`          | Phân phối dựa trên IP nguồn (giữ kết nối liên tục với cùng server). |
| `random`          | Chọn ngẫu nhiên một server backend.                                 |

***

## **7. Theo Dõi và Giám Sát**

### **Bật giao diện quản trị**

Thêm vào file cấu hình:

```haproxy
frontend stats
    bind *:8080
    stats enable
    stats uri /stats
    stats auth admin:password
```

* Truy cập: `http://<server-ip>:8080/stats`
* Tài khoản: `admin`
* Mật khẩu: `password`

***

## **8. Mẹo Tối Ưu Cấu Hình**

1. **Sử dụng kiểm tra sức khỏe (Health Check)**: Thêm từ khóa `check` vào backend để đảm bảo chỉ server khỏe mạnh nhận lưu lượng:

```
server web1 192.168.1.101:80 check
server web2 192.168.1.102:80 check
```

2. **Tăng giới hạn kết nối**: Trong phần `global`:

```
maxconn 4000
```

3. **Tối ưu timeout**:

* `timeout connect`: Thời gian chờ kết nối đến server backend.
* `timeout client`: Thời gian chờ phản hồi từ client.
* `timeout server`: Thời gian chờ phản hồi từ server.

4. **Sử dụng SSL Termination**: Để giảm tải SSL, cấu hình frontend lắng nghe kết nối HTTPS và chuyển HTTP đến backend.

***

## **9. Các Công Cụ Hỗ Trợ**

*   **HAProxy Logs**: Kiểm tra file log để debug:

    ```
    tail -f /var/log/haproxy.log
    ```
* **Công cụ giám sát**:
  * Prometheus: Tích hợp với HAProxy để theo dõi hiệu suất.
  * Grafana: Tạo dashboard trực quan.

***

## **Kết Luận**

HAProxy là một công cụ mạnh mẽ giúp quản lý lưu lượng mạng, đảm bảo tính sẵn sàng cao và tăng hiệu suất hệ thống. Với cheat sheet này, bạn có thể dễ dàng cấu hình và tối ưu HAProxy cho nhu cầu cụ thể của mình. Đừng quên thực hành và kiểm tra cấu hình trước khi triển khai trong môi trường thực tế! 🚀
