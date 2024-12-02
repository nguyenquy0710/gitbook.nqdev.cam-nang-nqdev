# NGINX: Hướng dẫn sử dụng Lua trên Alpine

NGINX với module Lua là một giải pháp mạnh mẽ để mở rộng khả năng của NGINX bằng cách sử dụng ngôn ngữ lập trình Lua. Lua thường được dùng để xử lý logic tùy chỉnh, tương tác với backend, hoặc thực hiện các tác vụ xử lý phức tạp ngay trong NGINX.

{% code title="Tài liệu tham khảo" lineNumbers="true" %}
```markdown
# NGINX Documentation
- [Lua](https://docs.nginx.com/nginx/admin-guide/dynamic-modules/lua/)

# Docker Hub:
- [nqdev/nginx](https://hub.docker.com/r/nqdev/nginx)
```
{% endcode %}

***

## **1. Cài Đặt NGINX và Lua Trên Alpine Linux**

### **Bước 1: Cài Đặt Alpine**

Đảm bảo bạn đã cài đặt Alpine Linux. Nếu đang sử dụng Docker, bạn có thể bắt đầu với hình ảnh Alpine:

```bash
docker pull alpine
```

### **Bước 2: Cài Đặt Các Gói Cần Thiết**

Cài đặt NGINX, Lua và các công cụ cần thiết:

```bash
apk add nginx lua5.3 lua5.3-dev luarocks gcc make musl-dev
```

### **Bước 3: Cài Đặt Module Lua-nginx**

Sử dụng `luarocks` để cài đặt module Lua-nginx:

```bash
luarocks install lua-nginx-module
```

### **Bước 4: Biên Dịch NGINX Với Lua-nginx**

Nếu bạn muốn sử dụng Lua-nginx như một module động, bạn cần biên dịch NGINX:

```bash
wget http://nginx.org/download/nginx-<version>.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/refs/heads/master.zip
tar -xzvf nginx-<version>.tar.gz
unzip master.zip
cd nginx-<version>
./configure --add-module=../lua-nginx-module-master
make && make install
```

***

## **2. Cấu Hình NGINX Sử Dụng Lua**

### **Thêm Lua Vào `nginx.conf`**

Trong file `nginx.conf`, bạn có thể gọi các tập lệnh Lua bằng cách sử dụng các chỉ thị như `content_by_lua` hoặc `access_by_lua`.

**Ví Dụ: Hello World Với Lua**

Thêm đoạn cấu hình sau vào `nginx.conf`:

```nginx
server {
    listen 80;

    location /hello {
        content_by_lua_block {
            ngx.say("Hello, Lua in NGINX!")
        }
    }
}
```

### **Khởi Chạy Lại NGINX**

Kiểm tra và khởi chạy lại NGINX:

```bash
nginx -t
nginx -s reload
```

Mở trình duyệt và truy cập `http://localhost/hello` để thấy kết quả.

***

## **3. Các Ứng Dụng Lua Trong NGINX**

### **Xử Lý Request**

Sử dụng Lua để phân tích dữ liệu request và thực hiện các tác vụ tùy chỉnh:

```nginx
location /inspect {
    content_by_lua_block {
        local headers = ngx.req.get_headers()
        for k, v in pairs(headers) do
            ngx.say(k, ": ", v)
        end
    }
}
```

### **Gửi Request Tới Backend**

Lua có thể sử dụng thư viện `resty.http` để gửi request HTTP:

```nginx
location /proxy {
    content_by_lua_block {
        local http = require("resty.http")
        local httpc = http.new()
        local res, err = httpc:request_uri("http://example.com", {
            method = "GET"
        })
        if not res then
            ngx.say("Failed to request: ", err)
            return
        end
        ngx.say(res.body)
    }
}
```

### **Xử Lý Dữ Liệu JSON**

Sử dụng thư viện `cjson` để xử lý JSON:

```nginx
location /json {
    content_by_lua_block {
        local cjson = require("cjson")
        local data = {
            message = "Hello, Lua with JSON!",
            status = "success"
        }
        ngx.say(cjson.encode(data))
    }
}
```

***

## **4. Tối Ưu Lua Trong NGINX**

* **Sử Dụng LuaJIT**: LuaJIT là trình biên dịch Just-In-Time cho Lua, giúp cải thiện hiệu năng đáng kể. Cài đặt LuaJIT trên Alpine:
* <pre class="language-bash"><code class="lang-bash"><strong>apk add luajit luajit-dev
  </strong></code></pre>
* **Tối Ưu Bộ Nhớ**: Hạn chế sử dụng biến cục bộ lớn và xóa biến không cần thiết để giảm tải bộ nhớ.
* **Thư Viện OpenResty**: Tận dụng các thư viện OpenResty như `resty.core`, `resty.redis` để xử lý nhanh và hiệu quả.

***

## **5. Kiểm Tra Kết Quả**

Sau khi cấu hình, sử dụng `curl` để kiểm tra các endpoint Lua:

```bash
curl http://localhost/hello
curl http://localhost/inspect
curl http://localhost/proxy
curl http://localhost/json
```

***

## Kết Luận

Sử dụng Lua trong NGINX trên Alpine Linux là một cách tiếp cận linh hoạt để mở rộng và tùy chỉnh chức năng của NGINX. Với Lua, bạn có thể tích hợp các logic phức tạp mà không cần phụ thuộc hoàn toàn vào backend, giúp giảm tải và cải thiện hiệu suất.
