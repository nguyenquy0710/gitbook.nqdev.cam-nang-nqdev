# Triển khai acme.sh bằng Docker: Chuẩn hoá SSL như một Service độc lập

Sau hai bài trước, **Cẩm nang NQDEV** đã lần lượt làm rõ hai tầng quan trọng:

1. **Tư duy dài hạn khi triển khai SSL Let’s Encrypt cho production**\
   👉 [ssl-mien-phi-lets-encrypt-trien-khai-chuan-production-voi-tu-duy-dai-han.md](ssl-mien-phi-lets-encrypt-trien-khai-chuan-production-voi-tu-duy-dai-han.md "mention")
2. **Chuẩn hoá quy trình tạo SSL bằng script acme.sh**\
   👉 [chuan-hoa-quy-trinh-tao-ssl-lets-encrypt-bang-script-cho-production.md](chuan-hoa-quy-trinh-tao-ssl-lets-encrypt-bang-script-cho-production.md "mention")

Bài viết này đi thêm **một nấc kiến trúc quan trọng**:

> **Đóng gói toàn bộ hệ thống SSL thành một Docker service độc lập.**

Đây là bước chuyển từ _“script chạy được”_ → _“hạ tầng SSL có thể vận hành, mở rộng và tích hợp lâu dài”_.

***

### 1. Vì sao cần Docker hoá acme.sh?

Ở giai đoạn đầu, chạy acme.sh trực tiếp trên host là đủ.\
Nhưng khi hệ thống lớn dần, bạn sẽ gặp các vấn đề:

* Nhiều server, nhiều môi trường
* SSL dùng chung cho HAProxy, Nginx, API Gateway
* Muốn tái sử dụng cùng một logic cho mọi nơi
* Muốn CI/CD hoá việc cấp SSL

👉 **Docker giải quyết đúng bài toán này**:\
Biến SSL thành **một service hạ tầng**, không phụ thuộc host.

***

### 2. Kiến trúc tổng thể: SSL-as-a-Service

Tư duy thiết kế trong bài này bám sát triết lý **NQDEV Platform**:

```
┌──────────────┐
│ Domain YAML  │  ← registry domain
└──────┬───────┘
       │
┌──────▼─────────┐
│ SSL Manager    │  ← Docker container
│ (acme.sh)      │
└──────┬─────────┘
       │
┌──────▼──────────────┐
│ Shared SSL Volume   │  ← /nqdev/ssl
└──────┬──────────────┘
       │
┌──────▼────────────┐
│ HAProxy / Nginx   │
└───────────────────┘
```

👉 Container SSL **không phục vụ traffic**, chỉ:

* Cấp
* Gia hạn
* Chuẩn hoá
* Publish SSL

***

### 3. Dockerfile: tối giản nhưng production-ready

{% code title="Dockerfile" %}
```dockerfile
FROM debian:12-slim

ENV ACME_HOME=/opt/acme
ENV SSL_ROOT=/nqdev/ssl

RUN apt-get update && apt-get install -y \
    curl ca-certificates openssl jq git cron \
 && rm -rf /var/lib/apt/lists/*

RUN curl https://get.acme.sh | sh

COPY bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

VOLUME ["/nqdev/ssl", "/opt/acme"]

ENTRYPOINT ["ssl-manager.sh"]
```
{% endcode %}

#### Vì sao thiết kế như vậy?

* **debian:12-slim** → ổn định, nhẹ, dễ audit
* acme.sh cài đúng chuẩn upstream
* Không hard-code domain hay DNS key
* SSL và acme state nằm trong **volume** → container stateless

👉 Đây là **chuẩn container hoá hạ tầng**, không phải app demo.

***

### 4. Entrypoint: biến SSL thành pipeline

{% code title="ssl-manager.sh" %}
```bash
#!/bin/bash
set -e

REGISTRY=/registry/domains
for f in $REGISTRY/*.yaml; do
  ssl-issue.sh "$f"
done

ssl-publish.sh
ssl-reload.sh
```
{% endcode %}

#### Tư duy phía sau entrypoint

* **Registry domain** = nguồn dữ liệu, không phải code
* Mỗi file YAML đại diện cho một đơn vị SSL
* Chạy theo pipeline:
  1. Issue
  2. Publish
  3. Reload

👉 Container khởi động là **SSL được đồng bộ hoá ngay**.

***

### 5. Issue script: acme.sh đúng bản chất

```bash
acme.sh --issue \
  --dns dns_cf \
  -d example.internal \
  -d *.example.internal
```

Điểm quan trọng:

* Dùng **DNS-01**
* Có wildcard
* Không cần port 80
* Phù hợp mạng private / internal

👉 Đây chính là phần nối tiếp trực tiếp từ **hai bài trước**, nhưng được đóng gói để tái sử dụng ở mọi môi trường.

***

### 6. Lợi ích chiến lược khi dùng Docker cho SSL

So sánh nhanh:

| Cách làm               | Đặc điểm              |
| ---------------------- | --------------------- |
| Chạy acme.sh trên host | Phù hợp giai đoạn đầu |
| Script thủ công        | Khó scale             |
| **Docker SSL service** | Chuẩn platform        |

Docker hoá giúp bạn:

* Chuẩn hoá SSL trên toàn hệ thống
* Tách SSL khỏi web server
* Dễ tích hợp CI/CD
* Dễ đưa vào HAProxy, Ingress, Gateway

***

### 7. Liên kết tư duy với hai bài trước

* **Bài 1** đặt nền móng tư duy:\
  SSL là hạ tầng, không phải config phụ.
* **Bài 2** hiện thực hoá tư duy bằng script:\
  Tự động, an toàn, không downtime.
* **Bài 3 (bài này)** nâng cấp kiến trúc:\
  Đóng gói SSL thành **một service độc lập, cloud-native**.

👉 Đây là một lộ trình hoàn chỉnh, không rời rạc.

***

### 8. Mở rộng trong tương lai

Từ mô hình này, bạn có thể:

* Gắn registry domain với GitOps
* Push SSL vào Kubernetes Secret
* Tạo central SSL service cho toàn công ty
* Thêm alert khi renew fail
* Multi-CA (Let’s Encrypt / ZeroSSL)

***

### Kết luận

Docker hoá acme.sh không phải để “cho đẹp”,\
mà để **đưa SSL về đúng vị trí của nó: hạ tầng nền tảng**.

Khi SSL được chuẩn hoá:

* Dev không phải lo HTTPS
* Ops không lo hết hạn
* Platform vận hành bền vững nhiều năm

Đó chính là tinh thần xuyên suốt của **Cẩm nang NQDEV** và **NQDEV Platform**:\
**xây hệ thống không chỉ chạy hôm nay, mà còn sống khoẻ trong tương lai**.
