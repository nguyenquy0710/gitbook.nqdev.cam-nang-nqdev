---
description: >-
  Trong hệ sinh thái AI hiện nay, việc tự triển khai một hệ thống AI Knowledge
  Base không còn quá phức tạp – đặc biệt khi có những công cụ như MaxKB.
---

# Cài đặt MaxKB bằng Docker

Ở bài viết này,

## 🧠 MaxKB + Docker: Vì sao nên chọn?

Khi kết hợp **MaxKB** với Docker, bạn có:

* ✅ Triển khai nhanh (1 lệnh chạy)
* ✅ Dễ scale, dễ backup
* ✅ Chạy được ở local hoặc server
* ✅ Tách biệt môi trường (không “bẩn máy”)

👉 Đây cũng là cách mà nhiều team triển khai production ban đầu

***

## ⚙️ Chuẩn bị trước khi cài

Trước khi bắt đầu, bạn cần:

### 1. Server / máy local

* Ubuntu / MacOS / Windows (WSL)
* RAM tối thiểu: **4GB (khuyến nghị 8GB)**

***

### 2. Cài Docker & Docker Compose

Kiểm tra:

```
docker -v
docker compose version
```

Nếu chưa có:

```
# Ubuntu
sudo apt update
sudo apt install docker.io docker-compose -y
```

***

## 🚀 Cách cài đặt MaxKB bằng Docker

### 🔽 Bước 1: Clone source

```
git clone https://github.com/1Panel-dev/MaxKB.git
cd MaxKB
```

***

### 🔧 Bước 2: Chuẩn bị file môi trường

Copy file `.env`:

```
cp .env.example .env
```

Mở file và chỉnh:

```
# Port chạy app
MAXKB_PORT=8080

# Database
DB_PASSWORD=yourpassword

# Redis
REDIS_PASSWORD=yourpassword
```

👉 Lưu ý:

* Đặt password mạnh nếu deploy public

***

### 🐳 Bước 3: Chạy Docker Compose

```
docker compose up -d
```

Lệnh này sẽ:

* Tạo container:
  * maxkb app
  * database (PostgreSQL)
  * redis
* Pull image cần thiết
* Khởi động toàn bộ hệ thống

***

### 📊 Bước 4: Kiểm tra container

```
docker ps
```

Bạn sẽ thấy các service đang chạy

***

### 🌐 Bước 5: Truy cập MaxKB

Mở trình duyệt:

```
http://localhost:8080
```

Tài khoản mặc định:

```
User: admin
Pass: MaxKB@123..
```

👉 Nhớ đổi password ngay sau khi login

***

## 🔌 Cấu hình sau khi cài

Sau khi vào dashboard, bạn cần làm 3 bước quan trọng:

***

### 1. Kết nối AI Model

Vào phần **Model Settings**:

* OpenAI (GPT)
* DeepSeek
* Claude
* hoặc local LLM (Ollama)

👉 Đây là “trái tim” của hệ thống

***

### 2. Tạo Knowledge Base

* Upload:
  * PDF
  * DOCX
  * Markdown
* Hoặc crawl website

MaxKB sẽ tự:

* Chunk dữ liệu
* Embedding
* Index vector

***

### 3. Tạo Chatbot

* Chọn knowledge base
* Tùy chỉnh prompt
* Publish chatbot

***

## 🧩 Cấu trúc hệ thống Docker của MaxKB

Khi chạy bằng Docker, bạn đang sử dụng:

| Service      | Vai trò           |
| ------------ | ----------------- |
| maxkb        | Backend + UI      |
| postgres     | Lưu dữ liệu       |
| redis        | Cache             |
| vector store | Tìm kiếm semantic |

👉 Hiểu phần này giúp bạn scale sau này

***

## ⚠️ Một số lỗi thường gặp

### ❌ Port đã bị chiếm

```
Error: port already in use
```

👉 Cách fix:

* Đổi port trong `.env`

***

### ❌ Container crash

```
docker logs maxkb
```

👉 Kiểm tra log để debug

***

### ❌ Không connect được AI

* Sai API key
* Firewall chặn outbound

***

## 🎯 Khi nào nên dùng Docker thay vì 1Panel?

| Trường hợp           | Nên dùng        |
| -------------------- | --------------- |
| Dev/test local       | ✅ Docker        |
| CI/CD                | ✅ Docker        |
| Production đơn giản  | ✅ Docker        |
| Người không rành CLI | ❌ (dùng 1Panel) |

***

## 🏁 Kết luận

Cài đặt MaxKB bằng Docker là cách:

* Nhanh nhất
* Linh hoạt nhất
* Phù hợp dev & DevOps

👉 Với vài lệnh cơ bản, bạn đã có thể:

* Build chatbot AI nội bộ
* Triển khai hệ thống knowledge base
* Làm nền tảng cho AI product

***

💡 Gợi ý từ **Cẩm nang NQDEV**:

* Kết hợp MaxKB + Ollama để chạy local AI
* Dùng Nginx reverse proxy khi deploy production
* Backup database định kỳ
