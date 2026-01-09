---
description: >-
  ViHAT's customized version of NGINX includes additional useful modules for
  usage.
---

# nqdev/nginx

Đây là container NGINX tùy chỉnh với các module mở rộng và tích hợp Redis, được phát triển bởi NQDEV team. Container này cung cấp web server hiệu năng cao với advanced features cho production environments.

### 🚀 Khởi động nhanh



```
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
docker-compose up -d --build --force-recreate --remove-orphans
```

### 🧱 Thành phần & Tính năng



#### Core Components



* **NGINX 1.27.2**: High-performance web server và reverse proxy
* **LuaJIT 2.0**: High-performance Lua scripting engine
* **Alpine Linux**: Base image tối ưu về kích thước
* **Redis Integration**: Session management và caching

#### Custom Modules



* ✅ **headers-more-nginx-module**: Advanced HTTP header manipulation
* ✅ **rate-limit-nginx-module**: Request rate limiting
* ✅ **ngx\_http\_geoip\_module**: Geographic IP location
* ✅ **ngx\_http\_image\_filter\_module**: On-the-fly image processing
* ✅ **ngx\_http\_xslt\_filter\_module**: XML transformation
* ✅ **ngx\_http\_js\_module**: JavaScript scripting support

#### Advanced Features



* ✅ **Automated Configuration Backup** với cron jobs
* ✅ **Real IP Detection** từ multiple proxy layers
* ✅ **SSL/TLS Optimization** với modern ciphers
* ✅ **Caching Strategy** với multiple cache zones
* ✅ **GeoIP Location Services** cho geographic routing
* ✅ **Status Monitoring** endpoint trên port 8080
* ✅ **Custom Error Handling** với detailed logging
* ✅ **Multi-port Support** cho different services

### 📦 Build & Deployment



#### Build với custom modules



```
# Build container với all modules
docker build -t nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1 .

# Kiểm tra modules đã install
docker run --rm nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1 nginx -V
```

#### Docker Compose (Khuyến nghị)



```
# # # # # Nginx Proxy with Redis Integration
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
# # # # #

services:
  nginx-server:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    build:
      context: ./
      dockerfile: ./Dockerfile
    container_name: nginx-server
    restart: always
    user: root
    ports:
      - "32768:80" # HTTP main port
      - "18080:8080" # Status monitoring
      - "32769:81" # Additional service port
      - "32770:82" # Additional service port
      - "32771:83" # Additional service port
    environment:
      TZ: Asia/Ho_Chi_Minh
      NGINX_HTTP_PORT_NUMBER: 80
      NGINX_HTTPS_PORT_NUMBER: 443
      CRONTAB_ENABLE: true
    volumes:
      - ./data-etc/nginx/nginx.conf:/etc/nginx/nginx.conf:rw
      - ./data-etc/nginx/conf.d/:/etc/nginx/conf.d:rw
      - ./data-etc/nginx/njs/:/etc/nginx/njs:rw
      - ./data-etc/nginx/stream.d/:/etc/nginx/stream.d:rw
      - ./data-log/nginx/:/var/log/nginx:rw
      - ./data-share/GeoIP/:/usr/share/GeoIP:rw
      - ./data-share/nginx/:/usr/share/nginx:rw
    depends_on:
      - nginx-redis
    dns:
      - 8.8.8.8
      - 8.8.4.4
      - 1.1.1.1
      - 1.0.0.1
    deploy:
      resources:
        limits:
          cpus: "0.80"
          memory: "3.2G"
        reservations:
          cpus: "0.25"
          memory: "256M"

  nginx-redis:
    image: redis:alpine3.18
    container_name: nginx-redis
    restart: always
    ports:
      - "6379:6379"
    environment:
      - TZ=Asia/Ho_Chi_Minh
    deploy:
      resources:
        limits:
          cpus: "0.80"
          memory: "3.2G"
        reservations:
          cpus: "0.25"
          memory: "256M"
```

#### Standalone Docker



```
docker run -d \
  --name nginx-server \
  -p 32768:80 \
  -p 18080:8080 \
  -e TZ=Asia/Ho_Chi_Minh \
  -e CRONTAB_ENABLE=true \
  -v ./nginx.conf:/etc/nginx/nginx.conf:rw \
  -v ./logs:/var/log/nginx:rw \
  nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
```

### 🗂️ Cấu trúc Container



#### Thư mục chính



```
/etc/nginx/                           # NGINX configuration
├── nginx.conf                        # Main configuration
├── conf.d/                           # Server configurations
│   └── nginx_status.conf             # Status endpoint
├── include/                          # Shared configurations
│   ├── log.conf                      # Logging setup
│   ├── resolvers.conf                # DNS resolvers
│   ├── ip_ranges.conf                # IP range definitions
│   ├── ssl-ciphers.conf              # SSL configuration
│   └── proxy.conf                    # Proxy settings
├── njs/                              # JavaScript files
└── stream.d/                         # Stream configurations

/usr/lib/nginx/modules/               # Custom modules
├── ngx_http_headers_more_filter_module.so
├── ngx_http_rate_limit_module.so
├── ngx_http_geoip_module.so
├── ngx_http_image_filter_module.so
├── ngx_http_xslt_filter_module.so
└── ngx_http_js_module.so

/usr/share/GeoIP/                     # GeoIP databases
├── GeoIP.dat                         # Country database
└── GeoLiteCity.dat                   # City database

/var/backups/nginx_config/            # Automated backups
└── nginx_config_YYYYMMDD.tar.gz

/var/tmp/nginx/cache/                 # Cache directories
├── body/                             # Request body cache
├── public/                           # Public cache zone
└── private/                          # Private cache zone
```

### ⚙️ Configuration Features



#### Custom Modules Loading



```
# Load custom modules
load_module /usr/lib/nginx/modules/ngx_http_headers_more_filter_module.so;
load_module /usr/lib/nginx/modules/ngx_http_image_filter_module.so;
load_module /usr/lib/nginx/modules/ngx_http_xslt_filter_module.so;
load_module /usr/lib/nginx/modules/ngx_http_geoip_module.so;
load_module /usr/lib/nginx/modules/ngx_stream_geoip_module.so;
load_module /usr/lib/nginx/modules/ngx_http_js_module.so;
```

#### Real IP Detection



```
# Real IP từ multiple proxy layers
set_real_ip_from 10.0.0.0/8;
set_real_ip_from 172.16.0.0/12;
set_real_ip_from 192.168.0.0/16;
real_ip_header X-Real-IP;
real_ip_recursive on;
```

#### Proxy Cache Configuration



```
# Multiple cache zones
proxy_cache_path /var/tmp/nginx/cache/public  levels=1:2 keys_zone=public-cache:30m max_size=192m;
proxy_cache_path /var/tmp/nginx/cache/private levels=1:2 keys_zone=private-cache:5m max_size=1024m;
```

#### GeoIP Integration



```
# Geographic location services
geoip_country /usr/share/GeoIP/GeoIP.dat;
geoip_city    /usr/share/GeoIP/GeoLiteCity.dat;
geoip_proxy_recursive on;
```

#### Security Headers



```
# Remove sensitive headers
more_clear_headers "X-Powered-By";
more_clear_headers "Server";

# SSL optimization
ssl_prefer_server_ciphers on;
```

### 🔧 Advanced Usage Examples



#### Rate Limiting với Custom Module



```
http {
    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=1r/s;

    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
        }
    }
}
```

#### Image Processing với Image Filter



```
location ~ ^/resize/(\d+)x(\d+)/(.+) {
    set $width $1;
    set $height $2;
    set $image_path $3;

    image_filter resize $width $height;
    image_filter_jpeg_quality 95;

    try_files /$image_path =404;
}
```

#### Header Manipulation



```
server {
    # Custom security headers
    more_set_headers "X-Frame-Options: DENY";
    more_set_headers "X-Content-Type-Options: nosniff";
    more_set_headers "X-XSS-Protection: 1; mode=block";

    # Custom application headers
    more_set_headers "X-Backend-Server: $upstream_addr";
    more_set_headers "X-Response-Time: $upstream_response_time";
}
```

#### Geographic Routing



```
map $geoip_country_code $allowed_country {
    default no;
    VN yes;
    US yes;
    JP yes;
}

server {
    if ($allowed_country = no) {
        return 403;
    }
}
```

### 📊 Monitoring & Status



#### Status Endpoint



* **URL**: [http://localhost:18080/nginx\_status](http://localhost:18080/nginx_status)
* **Features**: Active connections, requests per second, server metrics
* **Access**: Restricted to localhost và local networks

#### Status Response Example



```
Active connections: 15
server accepts handled requests
 1234 1234 5678
Reading: 2 Writing: 5 Waiting: 8
```

#### Backup Monitoring



```
# Check backup logs
docker exec nginx-server tail -f /var/log/nginx/nginx_backup.log

# Manual backup
docker exec nginx-server /usr/local/bin/100-backup-nginx.sh
```

### 🔍 Management Scripts



#### Configuration Validation



```
# Verify NGINX configuration
./01-verify-config.sh

# Reload configuration
./02-reload-config.sh

# Startup with build
./00-startup.sh
```

#### Health Checks



```
# Test configuration syntax
docker exec nginx-server nginx -t

# Check loaded modules
docker exec nginx-server nginx -V

# View active processes
docker exec nginx-server ps aux | grep nginx
```

### 📋 Environment Variables



| Biến                       | Mặc định           | Mô tả                    |
| -------------------------- | ------------------ | ------------------------ |
| `TZ`                       | `Asia/Ho_Chi_Minh` | Container timezone       |
| `NGINX_HTTP_PORT_NUMBER`   | `80`               | HTTP port number         |
| `NGINX_HTTPS_PORT_NUMBER`  | `443`              | HTTPS port number        |
| `NGINX_STATUS_PORT_NUMBER` | `8080`             | Status monitoring port   |
| `CRONTAB_ENABLE`           | `false`            | Enable automated backups |

### 🔒 Security Features



#### SSL/TLS Configuration



```
# Modern SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
```

#### Access Control



```
# IP-based access control
allow 192.168.1.0/24;
allow 10.0.0.0/8;
deny all;

# Geographic restrictions
if ($geoip_country_code !~ ^(VN|US|JP)$) {
    return 403;
}
```

#### Request Filtering



```
# Block suspicious requests
if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$ ) {
    return 405;
}

# Rate limiting per IP
limit_req zone=general burst=10 nodelay;
```

### 🚀 Production Deployment



#### High Availability Setup



```
# Load balancer configuration
upstream backend_servers {
least_conn;
server web1:80 weight=3;
server web2:80 weight=2;
server web3:80 weight=1 backup;
}

server {
location / {
proxy_pass http://backend_servers;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
}
}
```

#### Performance Optimization



```
# Worker optimization
worker_processes auto;
worker_connections 1024;

# Buffer optimization
client_body_buffer_size 128k;
client_max_body_size 2000m;
large_client_header_buffers 4 16k;

# Timeout optimization
keepalive_timeout 90s;
proxy_connect_timeout 90s;
proxy_read_timeout 90s;
```

#### Caching Strategy



```
# Static asset caching
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Dynamic content caching
location /api/ {
    proxy_cache private-cache;
    proxy_cache_valid 200 302 10m;
    proxy_cache_valid 404 1m;
}
```

### 📜 License



Distributed under the MIT License. See `LICENSE` for more information.

### 👨‍💻 Maintainer



**NQDEV Team**

* 📧 Email: [quynh@nhquydev.net](mailto:quynh@nhquydev.net)
* 🌐 Website: [nhquydev.net](https://nhquydev.net/)
* 📦 Container Registry: [GitHub Packages](https://github.com/nqdev-group/containers/pkgs/container/nginx)
* 📖 NGINX Documentation: [NGINX Documentation](https://nginx.org/en/docs/)
