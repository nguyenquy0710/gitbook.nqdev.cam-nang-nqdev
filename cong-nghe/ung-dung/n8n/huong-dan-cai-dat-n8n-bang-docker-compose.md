---
description: >-
  Hướng dẫn cài đặt n8n (một công cụ workflow automation mạnh mẽ) bằng Docker
  Compose, hỗ trợ cấu hình cơ bản, sử dụng Redis + PostgreSQL, và tự động backup
  dữ liệu.
---

# Hướng dẫn cài đặt n8n bằng docker compose

## 📌 Giới thiệu n8n là gì?

`n8n` là nền tảng **workflow automation mã nguồn mở**, cho phép bạn kết nối và tự động hóa hàng trăm ứng dụng như: Gmail, Google Sheets, Telegram, Slack, MySQL, PostgreSQL, HTTP API, v.v.

* 🔗 Giao diện trực quan dạng “kéo – thả”
* 🔁 Chạy automation theo lịch, webhook, API
* 📡 Tích hợp cực mạnh với hệ thống nội bộ (self-hosted)

***

## 🛠️ Môi trường triển khai

Chúng ta sẽ triển khai n8n với cấu hình gồm:

| Thành phần       | Mô tả                                        |
| ---------------- | -------------------------------------------- |
| `n8n`            | Giao diện và xử lý workflow                  |
| `n8n-worker`     | Chạy các workflow song song (queue mode)     |
| `PostgreSQL`     | Lưu trữ dữ liệu                              |
| `Redis`          | Hàng đợi (queue) để xử lý workflow song song |
| `Backup Service` | Tự động backup PostgreSQL mỗi ngày           |

***

## 📦 1. Tạo thư mục dự án

```bash
mkdir n8n-docker && cd n8n-docker
mkdir db_data redis_data n8n_data pgbackups backup
touch docker-compose.yml
```

## 🧱 2. Viết file `docker-compose.yml`

Dán nội dung dưới đây vào `docker-compose.yml`:

👉 **Bấm để xem chi tiết nội dung docker-compose.yml** (hoặc bạn có thể copy từ phần đầu cuộc trò chuyện ở trên — đã đầy đủ)

**Lưu ý quan trọng:**

* Thay đổi biến môi trường (`.env`) theo nhu cầu (username, password…)
* Trỏ đúng domain (vd: `n8n.esms.center`) nếu bạn dùng HTTPS/public

***

## 🔐 3. Tạo file `.env` (thông tin môi trường)

```bash
touch .env
```

Nội dung ví dụ:

```env
POSTGRES_USER=n8n
POSTGRES_PASSWORD=securepassword123
POSTGRES_DB=n8n_data
REDIS_PASSWORD=redispass
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=n8nadmin123
```

***

## 🚀 4. Khởi động hệ thống

```bash
docker-compose up -d --build
```

Bạn có thể truy cập n8n tại:

```
http://localhost:5678
```

***

## 🔁 5. Cấu hình backup PostgreSQL tự động

#### ✨ Script backup: `backup/backup.sh`

```bash
#!/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/backups/n8n_backup_$DATE.sql"

echo "🔄 Starting PostgreSQL backup at $DATE"

PGPASSWORD=$POSTGRES_PASSWORD pg_dump \
  -h n8n_db \
  -U $POSTGRES_USER \
  -F c \
  -b \
  -v \
  -f "$BACKUP_FILE" \
  $POSTGRES_DB

if [ $? -eq 0 ]; then
  echo "✅ Backup saved to $BACKUP_FILE"
else
  echo "❌ Backup failed!"
  exit 1
fi

# 🧹 Xóa backup cũ hơn 7 ngày
find /backups -type f -name "*.sql" -mtime +7 -exec rm {} \;

echo "✅ Cleanup complete."
```

> ✅ Script này sẽ:
>
> * Tự động backup mỗi ngày
> * Xóa các file cũ hơn 7 ngày để tiết kiệm dung lượng

***

## 🧱 Cấu hình service backup trong `docker-compose.yml`

Thêm đoạn sau vào cuối:

```yaml
postgres_backup:
    image: postgres:15-alpine
    container_name: postgres_backup
    depends_on:
      - n8n_db
    volumes:
      - ./pgbackups:/backups
      - ./backup:/scripts
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    entrypoint: [ "/bin/sh", "-c", "chmod +x /scripts/backup.sh && while true; do /scripts/backup.sh; sleep 86400; done" ]
    restart: always
```

***

## ✅ Kết luận

Vậy là bạn đã hoàn tất cài đặt hệ thống `n8n` cực kỳ chuyên nghiệp, mạnh mẽ và ổn định:

* 🌐 Có thể truy cập từ domain riêng
* 🔐 Bảo mật với Basic Auth
* 🚀 Queue mode mạnh mẽ bằng Redis
* 🧠 Lưu trữ dữ liệu an toàn với PostgreSQL
* 💾 Tự động backup hàng ngày, giữ tối đa 7 ngày

***

## 📚 Tham khảo

* [Tài liệu chính thức n8n](https://docs.n8n.io/)
* [Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)

***

> 📢 **Bạn muốn bài tiếp theo hướng dẫn gì?**
>
> * Gửi notification khi workflow fail?
> * Kết nối với Google Sheets / Gmail?
> * Tích hợp Telegram Bot?

👉 Để lại bình luận hoặc inbox team [**Cẩm nang NQDEV**](https://fb.com/cam.nang.nqdev) để được hỗ trợ nhé!
