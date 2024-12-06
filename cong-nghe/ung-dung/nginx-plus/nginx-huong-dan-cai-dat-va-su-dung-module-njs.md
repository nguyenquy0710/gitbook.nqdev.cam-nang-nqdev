# NGINX: Hướng dẫn Cài đặt và Sử dụng Module njs

Module **njs** là một công cụ mạnh mẽ giúp bạn mở rộng khả năng của NGINX bằng cách viết kịch bản tùy chỉnh sử dụng JavaScript. Dưới đây là hướng dẫn chi tiết từng bước để cài đặt, viết mã, và triển khai module njs.

***

#### 1. **Cài đặt Module njs**

**1.1. Cài đặt njs trên các hệ điều hành phổ biến**

Tùy vào hệ điều hành, bạn có thể cài đặt module `ngx_http_js_module` và `ngx_stream_js_module` như sau:

* **Ubuntu/Debian**:
* ```bash
  sudo apt-get install nginx-module-njs
  ```
* **CentOS/Red Hat**:
* ```bash
  sudo yum install nginx-plus-module-njs
  ```
* **Alpine Linux**:
* ```bash
  apk add nginx-plus-module-njs
  ```

**1.2. Kích hoạt module trong tệp cấu hình `nginx.conf`**

Sau khi cài đặt, bạn cần khai báo và tải module njs trong cấu hình NGINX:

```nginx
load_module modules/ngx_http_js_module.so;
load_module modules/ngx_stream_js_module.so;
```

Kiểm tra cấu hình và khởi động lại NGINX:

```bash
nginx -t && nginx -s reload
```

***

#### 2. **Viết Mã JavaScript với njs**

**2.1. Tạo một tệp JavaScript**

Tạo tệp `app.js` chứa logic xử lý:

```javascript
function hello(r) {
    r.return(200, "Hello, welcome to NGINX with njs!\n");
}

export default { hello };
```

**2.2. Cấu hình NGINX để sử dụng mã njs**

Thêm cấu hình vào tệp `nginx.conf`:

```nginx
load_module modules/ngx_http_js_module.so;

events {}

http {
    js_import app.js;

    server {
        listen 8080;

        location / {
            js_content app.hello;
        }
    }
}
```

Cấu hình này:

* Tải module njs.
* Nhập tệp `app.js` (được đặt trong cùng thư mục với cấu hình NGINX).
* Gọi hàm `hello` khi có yêu cầu đến đường dẫn gốc `/`.

Khởi động lại NGINX:

```bash
nginx -t && nginx -s reload
```

***

#### 3. **Kiểm tra Kết quả**

Mở trình duyệt hoặc sử dụng lệnh `curl` để kiểm tra:

```bash
curl http://localhost:8080
```

Kết quả sẽ hiển thị:

```vbnet
Hello, welcome to NGINX with njs!
```

***

#### 4. **Tính Năng Mở Rộng với njs**

**4.1. Thao tác tiêu đề yêu cầu và phản hồi**

Thêm logic trong tệp `app.js`:

```javascript
function handleHeaders(r) {
    r.headersOut['Custom-Header'] = 'njs is awesome!';
    r.return(200, "Headers modified successfully!");
}

export default { handleHeaders };
```

Cập nhật cấu hình NGINX:

```nginx
server {
    listen 8080;

    location /headers {
        js_content app.handleHeaders;
    }
}
```

Truy cập `http://localhost:8080/headers` để xem tiêu đề phản hồi được sửa đổi.

**4.2. Xử lý yêu cầu phức tạp**

Ví dụ: Kiểm tra token xác thực:

```javascript
function authCheck(r) {
    const token = r.headersIn['Authorization'];
    if (token === 'Bearer mysecrettoken') {
        r.return(200, "Authorized\n");
    } else {
        r.return(403, "Forbidden\n");
    }
}

export default { authCheck };
```

Cập nhật cấu hình:

```nginx
server {
    listen 8080;

    location /auth {
        js_content app.authCheck;
    }
}
```

Kiểm tra với lệnh `curl`:

```bash
curl -H "Authorization: Bearer mysecrettoken" http://localhost:8080/auth
```

***

#### 5. **Lợi ích và Ứng dụng của njs**

* **Tùy chỉnh linh hoạt**: Xử lý logic phía máy chủ mà không cần thay đổi ứng dụng backend.
* **Hiệu năng cao**: njs được tích hợp trực tiếp vào NGINX, đảm bảo tốc độ và hiệu suất.
* **Tương thích tốt**: Dễ dàng mở rộng và tích hợp với các ứng dụng hiện có.

***

#### 6. **Kết Luận**

Module njs là công cụ mạnh mẽ giúp NGINX trở nên linh hoạt hơn trong xử lý HTTP và Stream. Từ việc xử lý yêu cầu đơn giản đến tạo logic phức tạp, njs mở ra nhiều cơ hội mới cho các nhà phát triển.

Hãy bắt đầu triển khai njs để tận dụng hết tiềm năng của NGINX! 🎉

{% code title="Tài liệu tham khảo:" overflow="wrap" lineNumbers="true" %}
```http
njs Scripting Language - https://docs.nginx.com/nginx/admin-guide/dynamic-modules/nginscript/
Tài liệu về mô-đun JavaScript của NGINX - https://nginx.org/en/docs/njs/
Hướng dẫn cài đặt njs - https://nginx.org/en/docs/njs/install.html
Tham khảo cú pháp và API của njs - https://nginx.org/en/docs/njs/reference.html
```
{% endcode %}

