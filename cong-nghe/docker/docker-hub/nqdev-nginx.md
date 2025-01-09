---
description: >-
  ViHAT's customized version of NGINX includes additional useful modules for
  usage.
---

# nqdev/nginx

## NGINX Enhanced Docker Image

![](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/nginx/logo.png)

### Tổng quan

Docker image này được xây dựng dựa trên `nginx:1.27.2-alpine` và được mở rộng với các module tuỳ chỉnh, đồng thời tích hợp thêm các tính năng mới nhằm tối ưu việc cấu hình và sử dụng.

#### **Điểm mới trong Dockerfile**:

* **Hỗ trợ LuaJIT và Lua scripting**: Cho phép chạy các đoạn mã Lua trong NGINX với hiệu suất cao.
* **Bổ sung các module mới**:
  * `ngx_http_headers_more_filter_module`: Kiểm soát và tuỳ chỉnh HTTP headers.
  * `ngx_http_geoip_module`: Thêm khả năng truy vấn địa chỉ IP và định vị địa lý.
  * `ngx_http_rate_limit_module`: Quản lý giới hạn tốc độ truy cập.
  * **Backup tự động và Cron Jobs**: Hỗ trợ sao lưu định kỳ file cấu hình NGINX.
* **Thêm tập lệnh build động**: Cho phép biên dịch và thêm module tuỳ chỉnh.

#### **Danh sách các module có thể sử dụng trong phiên bản image này**:

* ngx\_http\_geoip\_module-debug.so
* ngx\_http\_geoip\_module.so
* ngx\_http\_headers\_more\_filter\_module.so
* ngx\_http\_image\_filter\_module-debug.so
* ngx\_http\_image\_filter\_module.so
* ngx\_http\_js\_module-debug.so
* ngx\_http\_js\_module.so
* ngx\_http\_rate\_limit\_module.so
* ngx\_http\_xslt\_filter\_module-debug.so
* ngx\_http\_xslt\_filter\_module.so
* ngx\_mail\_module.so
* ngx\_stream\_geoip\_module-debug.so
* ngx\_stream\_geoip\_module.so
* ngx\_stream\_js\_module-debug.so
* ngx\_stream\_js\_module.so

Các mô-đun này được đặt trong thư mục `/usr/lib/nginx/modules/`.

### **Tính năng chính**

1. **Base Image**: Dựa trên Alpine Linux - gọn nhẹ và nhanh chóng.
2. **LuaJIT**:
   * Tích hợp LuaJIT để chạy mã Lua trong NGINX.
   * Dùng để xử lý các request và response linh hoạt hơn.
3. **Headers More**:
   * Cấu hình và loại bỏ HTTP headers dễ dàng.
4. **Backup cấu hình tự động**:
   * Cron Jobs thực thi backup hàng tuần các file cấu hình NGINX.
   * Backup lưu tại `/var/backups/nginx_config`.

***

### **Hướng dẫn sử dụng**

#### 1. **Kéo Image**

```bash
docker push nqdev/nginx:<tag>
```

#### 2. **Chạy Container**

```bash
docker run -d -p 80:80 -p 443:443 --name my-nginx nqdev/nginx:<tag>
```

#### 3. **Tích hợp Lua Scripts**

Để sử dụng Lua scripting:

* Mount file Lua vào container và tham chiếu trong `nginx.conf`:

```nginx
location /api {
    content_by_lua_file /path/to/your/script.lua;
}
```

#### 4. **Tuỳ chỉnh HTTP Headers**

Sử dụng **Headers More** để thêm hoặc xoá headers:

```nginx
server {
    listen 80;
    location / {
        more_set_headers "X-Custom-Header: MyValue";
        more_clear_headers "Server";
    }
}
```

#### 5. **Backup file cấu hình NGINX**

* Backup được tự động chạy hàng tuần bằng cron.
* Để thực hiện backup thủ công:

```bash
docker exec <container-id> /usr/local/bin/100-backup-nginx.sh
```

* Backup sẽ được lưu tại `/var/backups/nginx_config`.

***

### **Cổng mở**

* `80`: HTTP
* `443`: HTTPS
* `8080`: NGINX status page

***

### **Build Image tuỳ chỉnh**

Dockerfile hỗ trợ build động và thêm các module khác:

1. Tạo Dockerfile của bạn:

```dockerfile
FROM nqdev/nginx
COPY nginx.conf /etc/nginx/nginx.conf
```

2. Build Image:

```bash
docker build -t my-nginx-image .
```

***

### **Tham khảo**

* **LuaJIT**: [LuaJIT](https://github.com/LuaJIT/LuaJIT)
* **Headers More**: [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module)
* **Rate Limit**: [rate-limit-nginx-module](https://github.com/weserv/rate-limit-nginx-module)

***

### **Liên hệ hỗ trợ**

* [Docker Community Slack](https://dockr.ly/comm-slack)
* [Stack Overflow](https://stackoverflow.com/questions/tagged/nginx)

***

### **Cách chạy nhanh**

#### Ví dụ: Chạy NGINX với nội dung tĩnh

```bash
docker run --name static-nginx -v /local/content:/usr/share/nginx/html:ro -p 8080:80 my-nginx-image
```

Sau đó truy cập `http://localhost:8080` để xem kết quả.
