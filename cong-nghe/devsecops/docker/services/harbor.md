---
description: >-
  Sứ mệnh của chúng tôi là trở thành kho lưu trữ gốc đám mây đáng tin cậy cho
  Kubernetes
---

# Harbor

Dưới đây là hướng dẫn cài đặt Harbor bằng Docker Compose, đã được chỉnh sửa để loại bỏ những từ ngữ không cần thiết:

***

### Hướng dẫn cài đặt Harbor bằng Docker Compose

Harbor là một registry mã nguồn mở giúp quản lý và bảo mật các artifact như Docker images. Dưới đây là các bước để cài đặt Harbor bằng Docker Compose:

#### 1. Tải xuống các tệp cài đặt Harbor

Truy cập trang [releases](https://github.com/goharbor/harbor/releases) của Harbor trên GitHub và tải xuống tệp nén cài đặt. Giải nén tệp này trên máy chủ của bạn.

#### 2. Tạo tệp cấu hình `harbor.yml`

Trong thư mục đã giải nén, bạn sẽ thấy tệp mẫu `harbor.yml.tmpl`. Sao chép tệp này và đổi tên thành `harbor.yml`. Chỉnh sửa tệp `harbor.yml` với các thông số phù hợp với môi trường của bạn.

#### 3. Tạo tệp `docker-compose.yml`

Dưới đây là một ví dụ về tệp `docker-compose.yml` để cài đặt Harbor:

```yaml
version: '3.5'

services:
  log:
    image: goharbor/harbor-log:v2.3.0
    container_name: harbor-log
    restart: always
    volumes:
      - /var/log/harbor/:/var/log/docker/:z
    networks:
      - harbor

  registry:
    image: goharbor/registry-photon:v2.3.0
    container_name: registry
    restart: always
    volumes:
      - /data/registry:/storage:z
    networks:
      - harbor

  registryctl:
    image: goharbor/harbor-registryctl:v2.3.0
    container_name: registryctl
    restart: always
    volumes:
      - /data/registry:/storage:z
    networks:
      - harbor

  postgresql:
    image: goharbor/harbor-db:v2.3.0
    container_name: harbor-db
    restart: always
    volumes:
      - /data/database:/var/lib/postgresql/data:z
    networks:
      - harbor

  redis:
    image: goharbor/redis-photon:v2.3.0
    container_name: redis
    restart: always
    networks:
      - harbor

  core:
    image: goharbor/harbor-core:v2.3.0
    container_name: harbor-core
    restart: always
    depends_on:
      - postgresql
      - redis
      - registry
    networks:
      - harbor

  portal:
    image: goharbor/harbor-portal:v2.3.0
    container_name: harbor-portal
    restart: always
    networks:
      - harbor

  jobservice:
    image: goharbor/harbor-jobservice:v2.3.0
    container_name: harbor-jobservice
    restart: always
    networks:
      - harbor

  trivy-adapter:
    image: goharbor/trivy-adapter-photon:v2.3.0
    container_name: trivy-adapter
    restart: always
    networks:
      - harbor

  proxy:
    image: goharbor/nginx-photon:v2.3.0
    container_name: nginx
    restart: always
    networks:
      - harbor
    ports:
      - 80:80
      - 443:443
      - 4443:4443
    depends_on:
      - core
      - portal
      - registry
      - trivy-adapter

networks:
  harbor:
    external: false
```

#### 4. Khởi chạy Harbor

Trong thư mục chứa tệp `docker-compose.yml`, chạy lệnh sau để khởi động Harbor:

```bash
docker-compose up -d
```

#### 5. Cấu hình và sử dụng Harbor

Đăng nhập vào giao diện web của Harbor tại địa chỉ của máy chủ của bạn bằng thông tin đăng nhập quản trị đã cấu hình trong tệp `harbor.yml`. Từ giao diện web, bạn có thể cấu hình các dự án, người dùng, và thiết lập bảo mật cho registry của mình.

***

Đảm bảo rằng bạn thay thế các phiên bản và cấu hình khác tùy thuộc vào phiên bản Harbor mà bạn đang sử dụng.
