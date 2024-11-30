# Hướng Dẫn Cài Đặt Varnish Cache với HAProxy Sử Dụng Docker Compose

Trong bài viết này, mình sẽ hướng dẫn bạn cách sử dụng **Docker Compose** để triển khai **Varnish Cache** kết hợp với **HAProxy**, giúp tối ưu hóa việc cân bằng tải (load balancing) và caching cho các dịch vụ web. Cấu hình này rất hữu ích khi bạn muốn sử dụng Varnish để caching các yêu cầu HTTP và HAProxy để cân bằng tải giữa nhiều backend server.

## 1. **Yêu Cầu Trước Khi Cài Đặt**

Trước khi bắt đầu, bạn cần cài đặt Docker và Docker Compose trên máy của mình:

* **Cài đặt Docker**: Nếu chưa cài đặt Docker, bạn có thể tham khảo hướng dẫn tại Docker Installation.
* **Cài đặt Docker Compose**: Nếu chưa có Docker Compose, bạn có thể cài đặt nó bằng cách làm theo hướng dẫn tại Install Docker Compose.

Sau khi cài xong, bạn có thể kiểm tra phiên bản của Docker và Docker Compose bằng các lệnh sau:

```bash
docker --version
docker-compose --version
```

## 2. **Cấu Hình Docker Compose**

Docker Compose cho phép bạn cấu hình và quản lý nhiều container Docker trong một tệp YAML duy nhất. Trong trường hợp này, chúng ta sẽ cấu hình 3 dịch vụ: **HAProxy**, **Varnish Cache**, và một dịch vụ backend ví dụ (chúng ta sẽ sử dụng **Nginx** làm backend).

### **Bước 1: Tạo Thư Mục Dự Án**

Đầu tiên, tạo một thư mục mới để chứa tất cả các tệp cấu hình và ứng dụng:

```bash
mkdir varnish-haproxy-docker
cd varnish-haproxy-docker
```

### **Bước 2: Tạo Tệp `docker-compose.yml`**

Tạo tệp **docker-compose.yml** trong thư mục dự án của bạn để cấu hình các dịch vụ.

```bash
nano docker-compose.yml
```

Dán nội dung sau vào tệp **docker-compose.yml**:

```yaml
version: '3.8'

services:
  haproxy:
    image: haproxy:alpine
    container_name: haproxy
    ports:
      - "80:80"     # Mở cổng 80 để tiếp nhận các yêu cầu HTTP
      - "443:443"   # Nếu cần sử dụng HTTPS
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg  # Ánh xạ tệp cấu hình HAProxy
    networks:
      - varnish-network
    depends_on:
      - varnish
      - nginx  # HAProxy cần đảm bảo rằng Nginx đã chạy trước khi nó khởi động

  varnish:
    image: varnish:stable
    container_name: varnish
    ports:
      - "6081:6081"  # Cổng giám sát Varnish
    volumes:
      - ./default.vcl:/etc/varnish/default.vcl  # Ánh xạ tệp cấu hình Varnish
    networks:
      - varnish-network
    depends_on:
      - nginx  # Varnish cần đảm bảo rằng Nginx đã chạy trước khi nó khởi động

  nginx:
    image: nginx:alpine
    container_name: nginx
    volumes:
      - ./html:/usr/share/nginx/html  # Ánh xạ tệp HTML hoặc ứng dụng cần phục vụ
    networks:
      - varnish-network
    restart: always

networks:
  varnish-network:
    driver: bridge
```

#### **Giải thích cấu hình:**

* **haproxy**:
  * **image**: Dùng image chính thức của HAProxy từ Docker Hub (`haproxy:alpine`).
  * **ports**: Mở cổng 80 và 443 để tiếp nhận yêu cầu HTTP và HTTPS.
  * **volumes**: Ánh xạ tệp cấu hình HAProxy (`haproxy.cfg`) từ máy chủ vào container.
  * **depends\_on**: Đảm bảo rằng Varnish và Nginx phải khởi động trước HAProxy.
  * **networks**: Sử dụng mạng riêng **varnish-network** để các container có thể giao tiếp với nhau.
* **varnish**:
  * **image**: Dùng image chính thức của Varnish (`varnish:stable`).
  * **ports**: Mở cổng 6081 để giám sát và tương tác với Varnish.
  * **volumes**: Ánh xạ tệp cấu hình `default.vcl` vào container để tùy chỉnh cách Varnish xử lý các yêu cầu HTTP.
  * **depends\_on**: Đảm bảo rằng Nginx phải khởi động trước Varnish.
  * **networks**: Kết nối Varnish vào mạng **varnish-network**.
* **nginx**:
  * **image**: Dùng image chính thức của Nginx (`nginx:alpine`).
  * **volumes**: Ánh xạ thư mục `html` vào Nginx để phục vụ các tệp HTML hoặc ứng dụng.
  * **networks**: Kết nối Nginx vào mạng **varnish-network**.

### **Bước 3: Tạo Tệp Cấu Hình HAProxy (`haproxy.cfg`)**

HAProxy sẽ hoạt động như một reverse proxy và cân bằng tải giữa các backend server (trong trường hợp này là Nginx). Tạo một tệp **haproxy.cfg** để cấu hình HAProxy:

```bash
nano haproxy.cfg
```

Dán nội dung cấu hình sau vào tệp `haproxy.cfg`:

```cfg
global
    log /dev/log local0
    maxconn 200

defaults
    log     global
    option  httplog
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms

frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    server nginx1 nginx:80 check
```

#### **Giải thích cấu hình**:

* **frontend http\_front**: Định nghĩa frontend cho HAProxy, lắng nghe các yêu cầu HTTP trên cổng 80 và chuyển tiếp chúng đến backend **http\_back**.
* **backend http\_back**: Định nghĩa backend với cân bằng tải sử dụng thuật toán **roundrobin** giữa các server Nginx. Trong trường hợp này, chúng ta chỉ có một backend server là **nginx** (container Nginx).

### **Bước 4: Tạo Tệp Cấu Hình Varnish (`default.vcl`)**

Tệp **default.vcl** là nơi bạn cấu hình Varnish để xác định backend mà Varnish sẽ caching dữ liệu. Backend ở đây sẽ là **HAProxy** (tức là container **haproxy**).

Tạo tệp **default.vcl** trong thư mục dự án:

```bash
nano default.vcl
```

Dán nội dung sau vào tệp `default.vcl`:

```vcl
vcl 4.0;

backend default {
    .host = "haproxy";  # Tên container HAProxy trong mạng Docker
    .port = "80";       # Cổng mà HAProxy lắng nghe
}

sub vcl_recv {
    # Các chỉ thị xử lý yêu cầu trước khi gửi tới backend
    if (req.method == "PURGE") {
        return (synth(200, "OK"));
    }
}
```

* **backend default**: Chỉ định backend là **HAProxy** (container với tên `haproxy`) và sử dụng cổng 80.
* **vcl\_recv**: Xử lý các yêu cầu HTTP, ví dụ như xóa cache khi nhận được yêu cầu `PURGE`.

### **Bước 5: Tạo Thư Mục HTML (Dành Cho Nginx)**

Để Nginx có thể phục vụ nội dung, bạn cần tạo thư mục **html** chứa các tệp HTML hoặc ứng dụng mà bạn muốn phục vụ.

Tạo thư mục **html** và thêm một tệp HTML đơn giản:

```bash
mkdir html
nano html/index.html
```

Dán nội dung HTML sau vào tệp `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Varnish + HAProxy</title>
</head>
<body>
  <h1>Hello from Nginx served via Varnish and HAProxy!</h1>
</body>
</html>
```

## 3. **Khởi Động Dự Án Với Docker Compose**

Bây giờ bạn có thể sử dụng Docker Compose để xây dựng và chạy các container:

```bash
docker-compose up -d
```

* **-d**: Chạy các container trong chế độ nền (detached mode).

## 4. **Kiểm Tra Hoạt Động**

Sau khi các container đã được khởi động, bạn có thể truy cập vào ứng dụng qua trình duyệt:

* Mở trình duyệt và nhập `http://localhost`. Bạn sẽ thấy trang web với thông điệp "Hello from Nginx served via Varnish and HAProxy!" được phục vụ qua Nginx, cache bởi Varnish và được cân bằng tải qua HAProxy.

## 5. **Dừng và Xóa Dự Án**

Khi không còn cần sử dụng các container nữa, bạn có thể dừng và xóa chúng bằng lệnh:

```bash
docker-compose down
```

## Kết Luận

Với việc sử dụng **Docker Compose**, bạn có thể dễ dàng triển khai một hệ thống caching mạnh mẽ với **Varnish** và **HAProxy**. Docker Compose giúp bạn quản lý các container và các dịch vụ một cách đơn giản và thuận tiện, đồng thời dễ dàng mở rộng và cấu hình lại môi trường khi cần thiết.
