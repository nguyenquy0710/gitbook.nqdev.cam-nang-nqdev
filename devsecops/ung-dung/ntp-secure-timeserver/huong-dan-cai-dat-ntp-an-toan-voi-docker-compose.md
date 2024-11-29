---
description: >-
  Network Time Protocol (NTP) đảm bảo đồng bộ hóa thời gian trên các hệ thống
  mạng.
---

# Hướng dẫn cài đặt NTP an toàn với Docker Compose

Bằng cách sử dụng **Docker** và **Network Time Security (NTS)**, ta có thể triển khai một máy chủ NTP an toàn, bảo vệ dữ liệu khỏi các tấn công mạng.

## 1. **Chuẩn Bị Môi Trường**

* **Cài đặt Docker và Docker Compose**:
  * Cài Docker: Hướng dẫn Docker.
  * Cài Docker Compose: Hướng dẫn Docker Compose.
* Đảm bảo các cổng UDP mở trên hệ thống (cổng mặc định là `123`).

***

## 2. **Tạo Tệp `docker-compose.yml`**

Tạo một tệp `docker-compose.yml` tại thư mục dự án:

```yaml
version: '3.8'

services:
  ntp:
    image: cturra/ntp
    container_name: ntp-server
    ports:
      - "123:123/udp"
    restart: unless-stopped
    environment:
      - NTP_SERVERS=pool.ntp.org
```

### **Giải thích**:

* `image: cturra/ntp`: Sử dụng image NTP từ Docker Hub.
* `ports`: Mở cổng UDP 123 cho NTP.
* `environment`:
  * `NTP_SERVERS`: Chỉ định máy chủ NTP (ví dụ: `pool.ntp.org`).

## 3. **Cấu Hình Network Time Security (NTS)**

NTS sử dụng chứng chỉ TLS để bảo mật. Để thêm hỗ trợ NTS:

### **Tạo chứng chỉ**:

Dùng Let’s Encrypt hoặc OpenSSL để tạo chứng chỉ:

```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

### **Gắn chứng chỉ vào container**:

Cập nhật `docker-compose.yml` để sử dụng chứng chỉ:

```
volumes:
  - ./cert.pem:/etc/ntp/cert.pem
  - ./key.pem:/etc/ntp/key.pem
environment:
  - NTS_CERT=/etc/ntp/cert.pem
  - NTS_KEY=/etc/ntp/key.pem
```

***

## 4. **Khởi Chạy Dịch Vụ**

Chạy lệnh sau để khởi chạy dịch vụ:

```bash
docker-compose up -d
```

***

## 5. **Kiểm Tra Hoạt Động**

### **Kiểm tra container**:

```
docker ps
```

### **Kiểm tra đồng bộ thời gian**:

* Cài công cụ `chrony` hoặc `ntpdate`:
  * ```
    sudo apt install chrony
    ```
* Chạy lệnh kiểm tra:
  * ```
    chronyc sources
    ```

***

## 6. **Quản Lý và Giám Sát**

### **Xem log container**:

* ```bash
  docker logs ntp-server
  ```

### **Khởi động lại khi có lỗi**:

* ```bash
  docker-compose restart
  ```

***

## 7. **Kết Luận**

Với Docker Compose, bạn đã triển khai thành công một máy chủ NTP an toàn. Điều này đảm bảo hệ thống đồng bộ thời gian chính xác và bảo vệ trước các mối đe dọa mạng.

***

{% code title="Tài liệu tham khảo:" lineNumbers="true" %}
```http
https://mpolinowski.github.io/docs/DevOps/Linux/2022-09-15--ntp-over-nts-timeserver/2022-09-21/
```
{% endcode %}

