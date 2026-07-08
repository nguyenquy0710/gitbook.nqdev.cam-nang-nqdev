---
description: >-
  Hướng dẫn chi tiết tự host Penpot — nền tảng thiết kế UI/UX mã nguồn mở thay thế Figma — bằng Docker Compose. Bao gồm cài đặt, cấu hình SMTP/OIDC, backup, upgrade và reverse proxy.
---

# Self-host Penpot với Docker: Hướng dẫn từ A đến Z

Penpot là nền tảng thiết kế UI/UX mã nguồn mở, miễn phí, hoàn toàn có thể tự host trên hạ tầng của bạn. Không bị phụ thuộc vendor, không lo dữ liệu thiết kế rò rỉ ra ngoài. Bài viết này hướng dẫn bạn triển khai Penpot bằng Docker Compose — phương pháp đơn giản và phổ biến nhất.

## 1. Tổng quan về Penpot <a href="#id-1" id="id-1"></a>

Penpot là công cụ thiết kế giao diện và prototyping dành cho team sản phẩm. Điểm mạnh:

* **Mã nguồn mở (AGPLv3):** Không giới hạn tính năng, không lock-in.
* **Web-based:** Chạy trên trình duyệt, không cần cài đặt client.
* **Hỗ trợ SVG & CSS:** Thiết kế xuất code sạch, thân thiện với developer.
* **Real-time collaboration:** Nhiều người cùng chỉnh sửa một file thiết kế.

So với Figma hay Sketch, Penpot cho phép bạn kiểm soát hoàn toàn dữ liệu và hạ tầng — lý tưởng cho doanh nghiệp cần compliance hoặc làm việc với thông tin nhạy cảm.

## 2. Yêu cầu hệ thống <a href="#id-2" id="id-2"></a>

* **OS:** Linux (Ubuntu/Debian khuyên dùng), macOS, Windows (Docker Desktop)
* **CPU/RAM:** Tối thiểu 1–2 CPU, 4 GB RAM
* **Dung lượng:** 10 GB+ (PostgreSQL + assets)
* **Network:** Cổng 80/443 nếu muốn truy cập từ Internet
* **Docker & Docker Compose:** Bản mới nhất

## 3. Cài đặt Penpot với Docker Compose <a href="#id-3" id="id-3"></a>

### 3.1 Tải file docker-compose

```bash
mkdir -p ~/penpot && cd ~/penpot
wget https://raw.githubusercontent.com/penpot/penpot/main/docker/images/docker-compose.yaml
```

File `docker-compose.yaml` này khởi tạo đầy đủ:
* **Frontend** — giao diện web
* **Backend** — API server
* **Exporter** — render ảnh xuất
* **PostgreSQL** — cơ sở dữ liệu
* **Valkey** — cache & WebSocket notifications

### 3.2 Khởi động

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
docker compose -p penpot -f docker-compose.yaml up -d
```
{% endcode %}

Sau vài phút, Penpot sẽ chạy tại `http://localhost:9001`.

### 3.3 Pin phiên bản

Với môi trường production, luôn chỉ định version cụ thể:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
PENPOT_VERSION=2.4.3 docker compose -p penpot -f docker-compose.yaml up -d
```
{% endcode %}

Kiểm tra các phiên bản mới nhất tại [Docker Hub](https://hub.docker.com/u/penpotapp) hoặc [Release notes](https://penpot.app/release-notes).

## 4. Cấu hình cơ bản <a href="#id-4" id="id-4"></a>

Các biến môi trường được khai báo trong `docker-compose.yaml`:

### Public URI

{% code title="docker-compose.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
PENPOT_PUBLIC_URI: https://penpot.congty.com
```
{% endcode %}

### SMTP (gửi email xác thực)

{% code title="docker-compose.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
PENPOT_FLAGS:
  - enable-smtp
PENPOT_SMTP_HOST: smtp.congty.com
PENPOT_SMTP_PORT: 587
PENPOT_SMTP_USERNAME: penpot@congty.com
PENPOT_SMTP_PASSWORD: secret
PENPOT_SMTP_TLS: "true"
```
{% endcode %}

### Xác thực OIDC (SSO)

{% code title="docker-compose.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
PENPOT_FLAGS:
  - enable-login-with-oidc
PENPOT_OIDC_CLIENT_ID: <client-id>
PENPOT_OIDC_CLIENT_SECRET: <secret>
PENPOT_OIDC_BASE_URI: https://oidc-provider.com
```
{% endcode %}

### Giới hạn đăng ký theo domain

{% code title="docker-compose.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
PENPOT_FLAGS:
  - enable-email-whitelist
PENPOT_REGISTRATION_DOMAIN_WHITELIST: congty.com,doitac.com
```
{% endcode %}

Sau khi thay đổi config, restart stack:

```bash
docker compose -p penpot -f docker-compose.yaml down
docker compose -p penpot -f docker-compose.yaml up -d
```

## 5. Reverse Proxy & HTTPS <a href="#id-5" id="id-5"></a>

Penpot yêu cầu HTTPS để các browser API (clipboard, WebSocket) hoạt động đầy đủ.

### NGINX

{% code title="nginx.conf" overflow="wrap" lineNumbers="true" %}
```nginx
server {
    listen 80;
    server_name penpot.congty.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name penpot.congty.com;

    client_max_body_size 367001600;

    ssl_certificate     /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    location /ws/notifications {
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://localhost:9001/ws/notifications;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_pass http://localhost:9001/;
    }
}
```
{% endcode %}

SSL miễn phí Let's Encrypt với Certbot:

```bash
sudo certbot --nginx -d penpot.congty.com
```

## 6. Quản lý người dùng <a href="#id-6" id="id-6"></a>

Penpot cung cấp CLI `manage.py` trong container backend:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Tạo user (khi đã tắt registration)
docker exec -ti penpot-penpot-backend-1 python3 manage.py create-profile

# Tạo user bỏ qua tutorial
docker exec -ti penpot-penpot-backend-1 python3 manage.py create-profile \
  --skip-tutorial --skip-walkthrough
```
{% endcode %}

Kiểm tra tên container backend chính xác:

```bash
docker compose -p penpot ps
```

## 7. Backup & Restore <a href="#id-7" id="id-7"></a>

Penpot lưu dữ liệu vào hai Docker volume: `penpot_postgres` (DB) và `penpot_assets` (file upload).

### Backup database

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
docker compose exec penpot-postgres \
  pg_dump -U penpot -d penpot > penpot-$(date +%F).sql
```
{% endcode %}

### Backup assets

```bash
docker run --rm -v penpot_assets:/data -v $(pwd):/backup \
  alpine tar czf /backup/assets-$(date +%F).tar.gz -C /data .
```

### Restore

```bash
# Stop stack
docker compose -p penpot down

# Restore DB
docker compose exec -T penpot-postgres psql -U penpot penpot < penpot-2026-01-01.sql

# Restore assets
docker run --rm -v penpot_assets:/data -v $(pwd):/backup \
  alpine tar xzf /backup/assets-2026-01-01.tar.gz -C /data

# Start lại
docker compose -p penpot up -d
```

## 8. Nâng cấp phiên bản <a href="#id-8" id="id-8"></a>

1. Kiểm tra [release notes](https://penpot.app/release-notes) — lưu ý breaking changes
2. Nâng cấp từng phiên bản nhỏ (tránh nhảy nhiều version)
3. Backup DB trước khi upgrade

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
docker compose -f docker-compose.yaml pull
docker compose -p penpot -f docker-compose.yaml up -d
```
{% endcode %}

## 9. Các phương án triển khai khác <a href="#id-9" id="id-9"></a>

| Phương án | Phù hợp |
|---|---|
| **Elestio** | Click-and-deploy, không cần kỹ thuật |
| **Kubernetes (Helm chart)** | Team đã có K8s cluster |
| **Rancher / OpenShift** | Doanh nghiệp dùng K8s enterprise |
| **TrueNAS** | Tích hợp với hệ thống storage ZFS |

Xem thêm tại [help.penpot.app](https://help.penpot.app/technical-guide/getting-started/).

## 10. Lưu ý quan trọng <a name="#id-10" id="id-10"></a>

* **Bảo mật:** Luôn chạy HTTPS. Không dùng flag `disable-secure-session-cookies` ngoài môi trường dev.
* **Backup định kỳ:** Thiết lập cron job backup DB và assets hàng ngày.
* **Monitor:** Theo dõi dung lượng ổ đĩa (assets và log).
* **Version lag:** Docker images được publish sau bản SaaS vài ngày — kiểm tra [community post](https://community.penpot.app/t/why-do-self-hosted-versions-lag-behind-new-releases/9897) để biết schedule.

## Tài liệu tham khảo

* [Penpot Self-Host](https://penpot.app/self-host)
* [Penpot Help Center — Getting Started](https://help.penpot.app/technical-guide/getting-started/)
* [How to deploy Penpot with Docker (official blog)](https://penpot.app/blog/deploy-penpot-with-docker/)
* [Self-hosting Penpot II — Community](https://community.penpot.app/t/self-hosting-penpot-ii/2337)
* [Penpot Configuration](https://help.penpot.app/technical-guide/configuration/)
