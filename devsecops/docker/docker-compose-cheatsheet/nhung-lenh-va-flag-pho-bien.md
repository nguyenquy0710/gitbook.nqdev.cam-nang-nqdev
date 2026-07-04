---
description: >-
  Docker Compose là một công cụ mạnh mẽ giúp quản lý và triển khai các ứng dụng
  đa container dễ dàng.
---

# Những Lệnh và Flag Phổ Biến

Với Docker Compose, bạn có thể định nghĩa, xây dựng và chạy các ứng dụng phức tạp chỉ bằng một file YAML đơn giản. Trong bài viết này, chúng ta sẽ cùng điểm qua những lệnh, flag phổ biến và một ví dụ thực tế về file `docker-compose.yml` hoàn chỉnh.

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

## 9. **Ví Dụ Hoàn Chỉnh về File Docker Compose**

Dưới đây là một ví dụ hoàn chỉnh về file `docker-compose.yml`, mô tả một ứng dụng web đơn giản sử dụng Nginx, Flask, và PostgreSQL.

{% code title="docker-compose.yml" %}
```yaml
version: '3'
services:
  web:
    build: ./web
    container_name: flask-app
    ports:
      - "5000:5000"
    volumes:
      - ./web:/app
    environment:
      - FLASK_ENV=development
    depends_on:
      - db
    networks:
      - app-network

  nginx:
    image: nginx:latest
    container_name: nginx-server
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - app-network

  db:
    image: postgres:13
    container_name: postgres-db
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres-data:

networks:
  app-network:
    driver: bridge

```
{% endcode %}

### Cấu Trúc Thư Mục

```markdown
project/
│
├── docker-compose.yml
├── web/
│   ├── Dockerfile
│   └── app.py
└── nginx/
    └── nginx.conf
```

### File `Dockerfile` cho Flask

Trong thư mục `web`, bạn cần một file `Dockerfile` để build ứng dụng Flask:

{% code title="Dockerfile" %}
```docker
# Sử dụng image Python
FROM python:3.8-slim

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép toàn bộ file vào container
COPY . /app

# Cài đặt các thư viện cần thiết
RUN pip install --no-cache-dir -r requirements.txt

# Expose cổng 5000
EXPOSE 5000

# Chạy ứng dụng Flask
CMD ["python", "app.py"]

```
{% endcode %}

### File `app.py` cho Flask

Một file Python đơn giản để chạy ứng dụng Flask:

{% code title="app.py" %}
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, Docker!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

```
{% endcode %}

### File `nginx.conf` cho Nginx

File cấu hình Nginx để phục vụ ứng dụng Flask:

{% code title="nginx.conf" %}
```nginx
server {
    listen 80;

    location / {
        proxy_pass http://flask-app:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

```
{% endcode %}



## Kết Luận

Bài viết này đã điểm qua các lệnh và tính năng chính của Docker Compose. Với những thông tin trên, bạn có thể dễ dàng bắt đầu quản lý và triển khai ứng dụng của mình một cách hiệu quả hơn. Hãy giữ bài cheatsheet này gần bạn mỗi khi làm việc với Docker Compose!

Bạn có thể thử ngay những lệnh và cấu hình trên để làm quen và tận dụng tối đa Docker Compose trong dự án của mình.
