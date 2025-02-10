# Cách dùng Docker để phát triển ứng dụng Wordpress

## **Giới thiệu**

Việc thiết lập môi trường phát triển WordPress thường yêu cầu cài đặt nhiều công cụ như PHP, MySQL, và Nginx. Tuy nhiên, với **Docker**, bạn có thể nhanh chóng xây dựng một môi trường phát triển đồng nhất, dễ bảo trì và triển khai.

Trong bài viết này, [**Cẩm nang NQDEV**](https://app.gitbook.com/o/ZnO3U2gDjowIXUi3yNwm/s/riO9WU3lEu4DXKD3d9zp/) sẽ hướng dẫn bạn cách sử dụng Docker để tạo môi trường WordPress hoàn chỉnh, đồng thời tìm hiểu cách:\
✅ Cấu hình lại Nginx.\
✅ Thay đổi config PHP.\
✅ Thiết lập **boilerplate** cho các dự án PHP/WordPress.

***

## **1. Cài Đặt Docker và Docker Compose**

Trước khi bắt đầu, bạn cần cài đặt **Docker** và **Docker Compose** trên máy của mình.

### **Cài Docker trên Linux (Ubuntu/Debian)**

```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

### **Cài Docker Compose**

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Kiểm tra phiên bản:

```bash
docker --version
docker-compose --version
```

***

## **2. Tạo Cấu Trúc Dự Án WordPress Với Docker**

Chúng ta sẽ thiết lập môi trường **WordPress + Nginx + MySQL** bằng Docker Compose.

### **Bước 1: Tạo thư mục dự án**

```bash
mkdir wordpress-docker
cd wordpress-docker
```

### **Bước 2: Tạo `docker-compose.yml`**

Tạo file `docker-compose.yml` để định nghĩa các container:

{% code title="docker-compose.yml" %}
```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: always
    depends_on:
      - mysql
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: user
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - ./wordpress:/var/www/html

  mysql:
    image: mysql:5.7
    container_name: wordpress_db
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: user
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - ./db_data:/var/lib/mysql

  nginx:
    image: nginx:latest
    container_name: wordpress_nginx
    restart: always
    ports:
      - "8080:80"
    volumes:
      - ./wordpress:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - wordpress
```
{% endcode %}

***

## **3. Cấu Hình Nginx Cho WordPress**

### Tạo thư mục cấu hình **nginx**:

```bash
mkdir nginx
```

### Tạo file `nginx/default.conf` để cấu hình Nginx:

{% code title="default.conf" %}
```nginx
server {
    listen 80;
    server_name localhost;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
{% endcode %}

***

## **4. Cấu Hình PHP (PHP.ini)**

Để thay đổi config PHP, bạn có thể tạo một file `php.ini` và mount nó vào container.

### Tạo thư mục cấu hình PHP:

```bash
mkdir php
```

### Tạo file `php/php.ini`:

{% code title="php.ini" %}
```ini
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 512M
max_execution_time = 300
```
{% endcode %}

Sau đó, sửa `docker-compose.yml` để mount file này vào container:

```yaml
volumes:
  - ./php/php.ini:/usr/local/etc/php/conf.d/custom.ini
```

***

## **5. Chạy Docker Compose Và Truy Cập WordPress**

Sau khi đã thiết lập xong, chạy lệnh sau để khởi động các container:

```bash
docker-compose up -d
```

Kiểm tra container đang chạy:

```bash
docker ps
```

Truy cập **http://localhost:8080** để cài đặt WordPress.

***

## **6. Một Số Lệnh Hữu Ích Khi Làm Việc Với Docker**

*   **Dừng toàn bộ container**:

    ```bash
    docker-compose down
    ```
*   **Xem logs của container**:

    ```bash
    docker-compose logs -f
    ```
*   **Truy cập vào container WordPress**:

    ```bash
    docker exec -it wordpress_app bash
    ```
*   **Khởi động lại container**:

    ```bash
    docker-compose restart
    ```

***

## **7. Kết Luận**

Sử dụng **Docker** giúp bạn thiết lập môi trường phát triển **WordPress** nhanh chóng và dễ dàng hơn. Bạn không cần cài đặt từng thành phần riêng lẻ mà có thể sử dụng **boilerplate** để triển khai ngay lập tức.

✅ **Cấu hình lại Nginx** để phục vụ WordPress.\
✅ **Thay đổi config PHP** để tối ưu hiệu suất.\
✅ **Xây dựng boilerplate** cho dự án PHP/WordPress của bạn.

Hy vọng bài viết từ **Cẩm nang NQDEV** sẽ giúp bạn triển khai WordPress bằng Docker một cách chuyên nghiệp! 🚀

***

Nếu bạn có bất kỳ câu hỏi nào, hãy để lại bình luận nhé! 🚀

<img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"><img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích, hãy mời tôi một tách cà phê nha!_ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
