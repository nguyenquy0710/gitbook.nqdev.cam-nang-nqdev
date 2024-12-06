---
description: >-
  Load Balancer là một trong những tính năng mạnh mẽ của NGINX, cho phép phân
  phối yêu cầu từ người dùng đến nhiều backend server khác nhau.
---

# NGINX: Hướng Dẫn Chi Tiết Cấu Hình Load Balancer

Điều này giúp cải thiện hiệu suất, tăng tính sẵn sàng và khả năng mở rộng của hệ thống.

***

## 1. **Các Khái Niệm Quan Trọng**

* **Backend Server**: Máy chủ xử lý yêu cầu thực tế từ client.
* **Upstream**: Nhóm backend server được định nghĩa trong NGINX.
* **Load Balancing Algorithm**: Thuật toán phân phối yêu cầu đến backend.

***

## 2. **Cấu Hình Load Balancer**

### **Định Nghĩa Upstream**

Tệp cấu hình NGINX thường nằm trong `/etc/nginx/nginx.conf` hoặc `/etc/nginx/conf.d/*.conf`. Đầu tiên, định nghĩa nhóm backend server:

```nginx
http {
    upstream backend_servers {
        server backend1.example.com;
        server backend2.example.com;
        server backend3.example.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend_servers;
        }
    }
}
```

* **`upstream`**: Định nghĩa nhóm server.
* **`proxy_pass`**: Chuyển yêu cầu từ client đến nhóm server được định nghĩa.

***

## 3. **Thuật Toán Load Balancing**

### **Round Robin (Mặc định)**

Phân phối yêu cầu theo thứ tự vòng tròn:

```nginx
upstream backend_servers {
    server backend1.example.com;
    server backend2.example.com;
}
```

### **Least Connected**

Phân phối yêu cầu đến server có ít kết nối nhất:

```nginx
upstream backend_servers {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
}
```

### **IP Hash**

Gửi tất cả yêu cầu từ một client IP đến cùng một server:

```nginx
upstream backend_servers {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
}
```

### **Weight**

Phân phối yêu cầu dựa trên trọng số:

```nginx
upstream backend_servers {
    server backend1.example.com weight=3;
    server backend2.example.com weight=1;
}
```

***

## 4. **Kiểm Tra Sức Khỏe Backend**

Để đảm bảo hệ thống hoạt động ổn định, bạn có thể kiểm tra sức khỏe backend bằng cách định nghĩa:

```nginx
upstream backend_servers {
    server backend1.example.com max_fails=3 fail_timeout=30s;
    server backend2.example.com max_fails=3 fail_timeout=30s;
}
```

* **`max_fails`**: Số lần thử thất bại trước khi server bị đánh dấu không khả dụng.
* **`fail_timeout`**: Khoảng thời gian server bị đánh dấu không khả dụng.

***

## 5. **Tăng Hiệu Suất Load Balancer**

### **Sử Dụng Keepalive**

Sử dụng kết nối TCP giữ nguyên để giảm chi phí kết nối:

```nginx
upstream backend_servers {
    server backend1.example.com;
    server backend2.example.com;
    keepalive 32;
}
```

### **Cache Header**

Giảm tải bằng cách cache kết quả:

```nginx
proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;

server {
    location / {
        proxy_cache my_cache;
        proxy_pass http://backend_servers;
    }
}
```

***

## 6. **Cấu Hình HTTPS Backend**

Nếu backend server sử dụng HTTPS, cấu hình như sau:

```nginx
upstream backend_servers {
    server backend1.example.com:443;
    server backend2.example.com:443;
}

server {
    listen 80;

    location / {
        proxy_pass https://backend_servers;
        proxy_ssl_server_name on;
    }
}
```

***

## 7. **Kiểm Tra Cấu Hình**

### **Kiểm Tra Lỗi Cấu Hình**

Kiểm tra cấu hình NGINX trước khi khởi động lại:

```bash
nginx -t
```

### **Khởi Động Lại NGINX**

Tải lại NGINX sau khi chỉnh sửa:

```bash
sudo systemctl reload nginx
```

### **Kiểm Tra Kết Quả**

Sử dụng trình duyệt hoặc công cụ dòng lệnh như `curl`:

```bash
curl http://yourdomain.com
```

***

## 8. **Ví Dụ Cấu Hình Hoàn Chỉnh**

### **Cấu Hình Cân Bằng Tải Với Least Connected**

```nginx
http {
    upstream backend_servers {
        least_conn;
        server backend1.example.com max_fails=3 fail_timeout=30s;
        server backend2.example.com max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

***

## 9. **Kết Luận**

Cấu hình Load Balancer trong NGINX là một công cụ quan trọng để cải thiện hiệu suất và độ tin cậy của hệ thống. Với các thuật toán linh hoạt, kiểm tra sức khỏe backend, và khả năng mở rộng, bạn có thể thiết kế hệ thống mạnh mẽ và tối ưu.
