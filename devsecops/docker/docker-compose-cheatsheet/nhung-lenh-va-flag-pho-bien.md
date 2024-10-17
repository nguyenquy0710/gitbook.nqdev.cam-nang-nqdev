---
description: >-
  Docker Compose là một công cụ mạnh mẽ giúp bạn dễ dàng quản lý và triển khai
  các ứng dụng đa container.
---

# Những Lệnh và Flag Phổ Biến

Với Docker Compose, bạn có thể định nghĩa, xây dựng và chạy các ứng dụng phức tạp chỉ bằng một file YAML đơn giản. Trong bài viết này, chúng ta sẽ điểm qua một số lệnh và flag phổ biến khi làm việc với Docker Compose.

## 1. **Cấu Trúc Docker Compose Cơ Bản**

File `docker-compose.yml` là nơi bạn định nghĩa các service của ứng dụng. Ví dụ dưới đây mô tả một ứng dụng web đơn giản có sử dụng Redis:

```yaml
services:
  web:
    build: .
    context: ./Path
    dockerfile: Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - .:/code
  redis:
    image: redis
```

Trong cấu trúc trên:

* **build**: Định nghĩa việc build image từ Dockerfile.
* **context**: Thư mục chứa Dockerfile.
* **dockerfile**: Tên của Dockerfile nếu không phải là mặc định.
* **ports**: Định nghĩa các cổng được ánh xạ giữa host và container.
* **volumes**: Gắn kết thư mục từ host vào container.

## 2. **Các Lệnh Docker Compose Phổ Biến**

Dưới đây là các lệnh bạn sẽ thường xuyên sử dụng khi làm việc với Docker Compose:

* `docker compose start`: Khởi động các service đã được định nghĩa.
* `docker compose stop`: Dừng các service đang chạy.
* `docker compose pause`: Tạm dừng các container.
* `docker compose unpause`: Tiếp tục các container đã tạm dừng.
* `docker compose ps`: Liệt kê các container và trạng thái của chúng.
* `docker compose up`: Khởi động các service và tạo các container mới nếu cần.
* `docker compose down`: Dừng và xóa tất cả các container, network, volumes.

## 3. **Xây Dựng và Quản Lý Image**

Docker Compose hỗ trợ nhiều cách để xây dựng image. Bạn có thể build trực tiếp từ Dockerfile hoặc sử dụng các image có sẵn từ Docker Hub.

```yaml
web:
  # Build từ Dockerfile mặc định
  build: .
  
  # Build từ Dockerfile tùy chỉnh
  build:
    context: ./dir
    dockerfile: Dockerfile.dev
    
  # Sử dụng image từ Docker Hub
  image: ubuntu
  image: ubuntu:14.04
  image: tutum/influxdb
  image: example-registry:4000/postgresql
  image: a4bc65fd
```

## 4. **Khai Báo Cổng (Ports)**

Bạn có thể ánh xạ các cổng giữa host và container hoặc chỉ expose các cổng trong network nội bộ của các container.

```yaml
ports:
  - "3000"
  - "8000:80" # guest:host
  
# Chỉ expose port tới các service liên kết, không tới host
expose:
  - "3000"
```

## 5. **Lệnh và EntryPoint**

Bạn có thể tùy chỉnh command để chạy các lệnh cụ thể trong container hoặc thay đổi `entrypoint` của container.

```yaml
command: bundle exec thin -p 3000
command: [bundle, exec, thin, -p, 3000]

entrypoint: /app/start.sh
entrypoint: [php, -d, vendor/bin/phpunit]
```

## 6. **Biến Môi Trường (Environment Variables)**

Biến môi trường giúp bạn tùy chỉnh cấu hình khi chạy các container.

```yaml
environment:
  RACK_ENV: development
  - RACK_ENV=development

# Tải biến môi trường từ file .env
env_file: .env
env_file: [.env, .development.env]
```

## 7. **Quản Lý Phụ Thuộc (Dependencies)**

Docker Compose giúp bạn quản lý các phụ thuộc giữa các service. Ví dụ, bạn có thể chắc chắn rằng service `db` được khởi động trước khi service `web` bắt đầu:

```yaml
depends_on:
  - db
  
links:
  - db:database
  - redis
```

## 8. **Tính Năng Nâng Cao**

### **Extends (Kế thừa cấu hình)**

Docker Compose cho phép bạn mở rộng (extends) một service khác để tái sử dụng cấu hình.

```yaml
extends:
  file: common.yml
  service: webapp
```

### **Volumes**

Bạn có thể gắn kết các thư mục hoặc volume từ host vào container.

```yaml
volumes:
  - /var/lib/mysql
  - ./_data:/var/lib/mysql
```

### **Labels**

Labels giúp bạn quản lý các metadata cho service của mình.

```yaml
labels:
  com.example.description: "Accounting web app"
```

### **DNS Servers**

Bạn có thể tùy chỉnh DNS cho từng service:

```yaml
dns: 8.8.8.8
dns:
  - 8.8.8.8
  - 8.8.4.4
```

### **Devices**

Cấu hình để kết nối các thiết bị từ host vào container.

```yaml
devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"
```

### **External Links và Hosts**

Bạn có thể liên kết tới các container ngoài hay thêm các mục vào file `/etc/hosts`.

```yaml
external_links:
  - redis_1
  - project_db_1:mysql

extra_hosts:
  - "somehost:192.168.1.100"
```

## Kết Luận

Bài viết này đã điểm qua các lệnh và tính năng chính của Docker Compose. Với những thông tin trên, bạn có thể dễ dàng bắt đầu quản lý và triển khai ứng dụng của mình một cách hiệu quả hơn. Hãy giữ bài cheatsheet này gần bạn mỗi khi làm việc với Docker Compose!

Bạn có thể thử ngay những lệnh và cấu hình trên để làm quen và tận dụng tối đa Docker Compose trong dự án của mình.
