---
description: 'Nguồn: viblo.asia'
---

# Cách dùng Docker để phát triển ứng dụng Wordpress

Trong bài này, mình sẽ hướng dẫn cách dựng môi trường phát triển cho ứng dụng Wordpress một cách nhanh chóng bằng Docker thông qua một boilerplate có sẵn đó là [sun-asterisk-research/docker-php-development](https://github.com/sun-asterisk-research/docker-php-development).

Lần trước mình cũng đã làm một bài giới thiệu chung [Dựng môi trường phát triển nhanh chóng với docker-php-development](broken-reference), hôm nay chúng ta sẽ focus vào việc dựng môi trường cho Wordpress nhé.

### Bạn sẽ học được gì? <a href="#ban-se-hoc-duoc-gi-0" id="ban-se-hoc-duoc-gi-0"></a>

Qua bài viết này, bạn có thể nhanh chóng áp dựng boilerplate để dựng môi trường cho wordpress hay bất kỳ ứng dụng PHP nào. Bài này sẽ:

* Cách cấu hình lại Nginx
* Cách thay đổi config của PHP
* Hiểu thêm các bước để config boilerplate cho dự án PHP/Wordpress của bạn

### Cấu trúc thư mục <a href="#cau-truc-thu-muc-1" id="cau-truc-thu-muc-1"></a>

Tương tự với bài trước, cấu trúc thư mục sẽ là:

```none
|__ wordpress  => Source code wordpress
|__ docker-php-development
```

### Chuẩn bị source code <a href="#chuan-bi-source-code-2" id="chuan-bi-source-code-2"></a>

1. Download source wordpress và giải nén thành thư mục wordpress
2. Clone repo [sun-asterisk-research/docker-php-development](https://github.com/sun-asterisk-research/docker-php-development) về thư mục `docker-php-development`

### Bật các service / biến môi trường <a href="#bat-cac-service--bien-moi-truong-3" id="bat-cac-service--bien-moi-truong-3"></a>

#### 1. Tạo file `services` để chọn các file `compose/*.yml` nào được chạy, chạy lệnh <a href="#id-1-tao-file-services-de-chon-cac-file-composeyml-nao-duoc-chay-chay-lenh-4" id="id-1-tao-file-services-de-chon-cac-file-composeyml-nao-duoc-chay-chay-lenh-4"></a>

```bash
cp services.example services
```

Đối với wordpress, mình chỉ cần chạy 2 file docker-compose là `compose/php.yml` để chạy PHP, `compose/mariadb.yml` để chạy MariaDB là database. Khi đó mình điền tên 2 file này vào trong file `services` vừa tạo ra. (Nhớ để thừa một dòng trống ở cuối file `services` nhé).

```bash
php
mariadb

```

#### 2. Tạo file `.env` <a href="#id-2-tao-file-env-5" id="id-2-tao-file-env-5"></a>

```bash
cp .env.example .env
```

```bash
#-------------------------------------------------------------------------------
# Code paths
#-------------------------------------------------------------------------------

PATH_PHP=../php
PATH_WEB=../web

#-------------------------------------------------------------------------------
# Data paths
#-------------------------------------------------------------------------------

PATH_DATA=./data
PATH_LOGS=./logs

#-------------------------------------------------------------------------------
# Traefik domain and ports
# DOMAIN, PORT defines public domain for your PHP application
# DOMAIN_WEB defines public domain for your Node.js application
# DOMAIN_SECONDARY is the domain used for other services e.g traefik, mailhog, phpmyadmin .etc
#-------------------------------------------------------------------------------

DOMAIN=example.localhost
DOMAIN_WEB=web.example.localhost
PORT=8000

DOMAIN_SECONDARY=backend.localhost

#-------------------------------------------------------------------------------
# Databases
# DB_DATABASE, DB_USERNAME and DB_PASSWORD are mandatory
# You can leave the others empty for default values
#-------------------------------------------------------------------------------

DB_DATABASE=my_database
DB_USERNAME=my_user
DB_PASSWORD=secret

#-------------------------------------------------------------------------------
# Other things
#-------------------------------------------------------------------------------

ELASTICSEARCH_VERSION=7.3.2

PGADMIN_DEFAULT_EMAIL=admin@domain.com
PGADMIN_DEFAULT_PASSWORD=secret

MEMORY_LIMIT_PHP_FPM=1G
MEMORY_LIMIT_BEANSTALKD=200m
MEMORY_LIMIT_ELASTICSEARCH=512m
MEMORY_LIMIT_MAILHOG=200m
MEMORY_LIMIT_MYSQL=1G
MEMORY_LIMIT_POSTGRES=1G
MEMORY_LIMIT_REDIS=200m

NGINX_DOCUMENT_ROOT=/php/public
NGINX_CONFIG_TEMPLATE=./config/nginx/default.conf

# LARAVEL_ECHO_SERVER_REDIS_KEY_PREFIX=

COMPOSE_PROJECT_NAME=php-dev
HOSTS_FILE=/etc/hosts

```

#### 3. Thay đổi các biến cho phù hợp <a href="#id-3-thay-doi-cac-bien-cho-phu-hop-6" id="id-3-thay-doi-cac-bien-cho-phu-hop-6"></a>

Các biến chính cần sửa lại đó là:

```bash
# Đường dẫn tới thư mục code PHP
PATH_PHP=../wordpress

# Đổi domain của ứng dụng PHP khi chạy dưới local
DOMAIN=my-app.lc

# Mình muốn sau khi chạy, web sẽ chạy ở cổng 80 luôn
PORT=80

# Đổi domain của các backend dashboard, dùng cho: traefik, mailhog, phpmyadmin...
# Tương ứng, khi truy cập sẽ là: traefik.backend.lc, mailhog.backend.lc, phpmyadmin.backend.lc...
DOMAIN_SECONDARY=backend.lc

# Đổi lại tên database trước khi chạy lệnh, nếu service db đã được chạy trước đó mà bạn mới đổi thì sẽ cần xóa bỏ data của service db cũ rồi mới chạy lại để nó nhận thông tin account mới.
# EX: rm -rf ./data/mariadb
DB_DATABASE=viblo
DB_USERNAME=viblo
DB_PASSWORD=secret

# Đổi Prefix cho tên các container được chạy.
# VD: viblo_php_1, viblo_mariadb_1....
COMPOSE_PROJECT_NAME=viblo

# Các biến MEMORY_LIMIT_*, nếu máy bạn ít RAM thì có thể giới hạn memory được phép sử dụng thấp xuống, VD:
# MYSQL được cấp tối đa là 512 MB memory.
MEMORY_LIMIT_MYSQL=512m

# Vì trong container chạy php, source code được mount vào thưc mục /php
# Trỏ nginx về đúng thư mục PHP, mặc định nó được cấu hình sẵn với Laravel nên có /public, với wordpress thì không có thư mục public nữa:
# NGINX_DOCUMENT_ROOT=/php/public
NGINX_DOCUMENT_ROOT=/php

# Đây là file cấu hình mặc định của nginx, mình thấy nó không phù hợp với Wordpress nên sẽ cần edit lại, mình sẽ tạo file cấu hình mới tại:
NGINX_CONFIG_TEMPLATE=./config/nginx/wordpress.conf
```

#### 4. Customize Nginx + PHP cho wordpress <a href="#id-4-customize-nginx--php-cho-wordpress-7" id="id-4-customize-nginx--php-cho-wordpress-7"></a>

1. Sửa lại config Nginx một xíu, do mình khai báo biến `NGINX_CONFIG_TEMPLATE=./config/nginx/wordpress.conf` rồi nên không phải sửa thêm gì nữa:

```bash
server {
  listen 80;

  root  ${DOCUMENT_ROOT};
  index index.html index.htm index.php;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location = /favicon.ico { access_log off; log_not_found off; }
  location = /robots.txt  { access_log off; log_not_found off; }

  location ~ \.php$ {
    fastcgi_pass    php:9000;
    fastcgi_param   SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    include         fastcgi_params;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires max;
    log_not_found off;
  }
}

```

2. Do wordpress thường có thể bạn sẽ cần import các file backup với dung lượng cao, mặc định thì là 2MB uploads nên mình sẽ sửa thêm file config PHP.ini. Có một file mẫu ở `./config/php/zzz-docker-php.ini`, mình sẽ làm theo hướng dẫn ở bên trong file để cho phép upload được file dung lượng lớn hơn.

```bash
; How to use this file?
; You just mount this file onto "/usr/local/etc/php/conf.d/zzz-docker-php.ini"
; in "php" service via "docker-compose.override.yml" file.

; Example: docker-compose.override.yml
; version: "2.2"
; services:
;   php:
;     volumes:
;     - ./config/php/zzz-docker-php.ini:/usr/local/etc/php/conf.d/zzz-docker-php.ini:ro

post_max_size = 300M
upload_max_filesize = 300M

max_execution_time = 300
max_input_time = 300

```

Trong đó, mình tăng kích thước tối đã là 300MB, tăng thời gian xử lý lên 300 giây.

3. Tạo file `docker-compose.override.yml` để override lại cấu hình có sẵn trong các file `compose/*.yml`. File này vẫn là file docker-compose như bình thường, chỉ có điều là bạn cần ghi đề config nào thì khai báo mục đó chứ không cần khai báo lại đủ. Nếu bạn muốn chạy thêm service mới thì cũng có thể ghi vào đây, file này nó được ignore bởi Git.

```yaml
version: '2.2'

services:
    mariadb:
        image: mariadb:10 # Mình đổi lại image của service mariadb tại đây, chứ ko sửa trực tiếp file compose/mariadb.yml, chạy git status nó không báo mình sửa đổi file :D
    php:
        user: 1000:1000 # đổi lại user chạy php-fpm là 1000:1000 -> đây là uid/gid của user mình đang đăng nhập.
        volumes:
            - ./config/php/zzz-php-uploads.ini:/usr/local/etc/php/conf.d/zzz-docker-php.ini:ro
```

Chú ý, mình cần đổi user chạy php-fpm là 1000:1000, chính là uid/gid của user mình đang đăng nhập. Vì như bạn biết trong wordpress sẽ cần cài thêm plugin, mình để uid giống với tài khoản thực ngoài máy thật để không dính các vấn đề về permission khi đọc ghi file, xóa file. Các bạn dùng windows chắc là sẽ không lo, nhưng với linux thì các bạn biết, nó sẽ có phân quyền đọc/ghi/thực thi theo user và group.

4. Tới đây, chúng ta chỉ cần chạy lệnh sau để run các container lên:

```bash
./project up
```

5. Nhớ thêm các domain ảo của bạn vào trong file /etc/hosts nhé!

```bash
0.0.0.0 my-app.lc backend.lc traefik.backend.lc
```

<img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"><img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích, hãy mời tôi một tách cà phê nha!_ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
