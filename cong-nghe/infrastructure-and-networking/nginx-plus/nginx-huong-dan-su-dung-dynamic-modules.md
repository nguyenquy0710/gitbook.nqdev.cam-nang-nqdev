# NGINX: Hướng Dẫn Sử Dụng Dynamic Modules

**Dynamic Modules** cho phép bạn thêm các module vào NGINX mà không cần phải biên dịch lại toàn bộ phần mềm. Tính năng này giúp NGINX linh hoạt hơn, dễ dàng mở rộng với các chức năng bổ sung chỉ khi cần thiết.

<figure><img src="https://docs.nginx.com/nginx/images/nginx-plus-dynamic-module-plug-ins.png" alt="Dynamic Modules" width="375"><figcaption><p>Các mô-đun động cắm vào NGINX Plus để cung cấp chức năng bổ sung.</p></figcaption></figure>



***

## 1. **Dynamic Modules Là Gì?**

Dynamic Modules là các module được tải vào lúc runtime thay vì tích hợp sẵn vào NGINX khi biên dịch. Điều này mang lại các lợi ích:

* **Dễ dàng thêm/bớt module**: Chỉ cần chỉnh sửa cấu hình, không cần biên dịch lại NGINX.
* **Giảm tải**: Tải các module cần thiết để tối ưu hóa tài nguyên.

***

## 2. **Kiểm Tra Dynamic Modules**

Để kiểm tra phiên bản NGINX hiện tại có hỗ trợ dynamic modules hay không, sử dụng lệnh:

```bash
nginx -V
```

Tìm các module có dạng `--with-compat` hoặc các module có hỗ trợ `dynamic`. Ví dụ:

```javascript
--with-compat --add-dynamic-module=/path/to/module
```

***

## 3. **Cách Tải Module Động**

Dynamic Modules thường có phần mở rộng `.so`. Bạn có thể tải module trong cấu hình NGINX bằng cách sử dụng chỉ thị `load_module`.

### **Cấu Hình Mẫu**

Thêm module vào file `nginx.conf` hoặc file cấu hình tùy chỉnh:

```nginx
load_module modules/ngx_http_geoip_module.so;
load_module modules/ngx_stream_geoip_module.so;
```

### **Xác Minh**

Sau khi chỉnh sửa, kiểm tra cấu hình:

```bash
nginx -t
```

### Khởi động lại NGINX:

```bash
sudo systemctl reload nginx
```

***

## 4. **Các Bước Cài Đặt Module Động**

### **4.1. Lấy Module Dynamic**

* **Dùng Module Có Sẵn**:
  * Các bản phân phối NGINX chính thức (hoặc NGINX Plus) thường bao gồm các module động sẵn.
  * Kiểm tra thư mục `/etc/nginx/modules/` hoặc `/usr/share/nginx/modules/` để tìm file `.so`.
* **Biên Dịch Module Riêng**: Nếu module bạn cần không có sẵn, bạn cần biên dịch nó:
*   ```bash
    wget http://nginx.org/download/nginx-<version>.tar.gz
    tar -xzvf nginx-<version>.tar.gz
    cd nginx-<version>

    ./configure --with-compat --add-dynamic-module=/path/to/your/module
    make modules
    ```

    File `.so` sẽ được tạo trong thư mục `objs/`.

### **4.2. Cài Đặt Module**

* Sao chép file `.so` vào thư mục module NGINX:
* ```bash
  sudo cp objs/ngx_http_geoip_module.so /etc/nginx/modules/
  ```

### **4.3. Tải Module Vào NGINX**

Chỉnh sửa file cấu hình `nginx.conf`:

```nginx
load_module modules/ngx_http_geoip_module.so;

http {
    geoip_country /path/to/GeoIP.dat;
}
```

***

## 5. **Danh Sách Một Số Module Dynamic Phổ Biến**

| Module                         | Chức Năng                                       |
| ------------------------------ | ----------------------------------------------- |
| `ngx_http_geoip_module`        | Phân tích địa chỉ IP để xác định vị trí địa lý. |
| `ngx_http_image_filter_module` | Chuyển đổi và tối ưu hình ảnh.                  |
| `ngx_http_headers_more_module` | Thêm, chỉnh sửa, hoặc xóa HTTP headers.         |
| `ngx_http_lua_module`          | Mở rộng NGINX với Lua scripting.                |
| `ngx_http_ssl_module`          | Hỗ trợ HTTPS.                                   |

***

## 6. **Xử Lý Lỗi Khi Tải Module**

* **Lỗi Module Không Tìm Thấy:** Kiểm tra đường dẫn module trong chỉ thị `load_module`.
* **Lỗi Phiên Bản Không Tương Thích:** Dynamic Modules cần được biên dịch với tùy chọn `--with-compat` để đảm bảo tương thích với NGINX hiện tại.
* **Kiểm Tra Log Lỗi:** Log lỗi của NGINX nằm ở `/var/log/nginx/error.log`. Kiểm tra thông báo cụ thể để xử lý.

***

## 7. **Cấu Hình Mẫu Hoàn Chỉnh**

Dưới đây là ví dụ cấu hình hoàn chỉnh với module `ngx_http_geoip_module`:

```nginx
load_module modules/ngx_http_geoip_module.so;

http {
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    geoip_city /usr/share/GeoIP/GeoIPCity.dat;

    server {
        listen 80;

        location / {
            set $geoip_country_code $geoip_country_code;
            set $geoip_city $geoip_city;

            proxy_set_header X-Geo-Country $geoip_country_code;
            proxy_set_header X-Geo-City $geoip_city;

            proxy_pass http://backend;
        }
    }
}
```

***

## 8. **Kết Luận**

Dynamic Modules là cách hiệu quả để mở rộng NGINX mà không phải biên dịch lại toàn bộ hệ thống. Với các bước trên, bạn có thể dễ dàng tải và sử dụng các module động trong NGINX để thêm các tính năng mạnh mẽ và linh hoạt vào cấu hình hiện có.

{% code title="Tài liệu tham khảo:" overflow="wrap" lineNumbers="true" %}
```http
https://docs.nginx.com/nginx/admin-guide/dynamic-modules/dynamic-modules/
```
{% endcode %}

