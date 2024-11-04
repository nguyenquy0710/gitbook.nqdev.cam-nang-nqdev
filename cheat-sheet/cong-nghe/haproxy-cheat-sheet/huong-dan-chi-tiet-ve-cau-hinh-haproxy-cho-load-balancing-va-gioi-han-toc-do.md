# Hướng dẫn chi tiết về cấu hình HAProxy cho Load Balancing và giới hạn tốc độ

HAProxy là một giải pháp mã nguồn mở mạnh mẽ, chuyên dùng để cân bằng tải và quản lý yêu cầu vào các ứng dụng web. Trong bài viết này, chúng ta sẽ đi sâu vào từng lệnh cấu hình trong một file HAProxy mẫu, giải thích cách cấu hình nâng cao như log, tối ưu hiệu suất, và kiểm soát giới hạn tốc độ theo từng IP.

## **Cấu Hình `global`**

Phần `global` chứa các cài đặt chung cho toàn bộ HAProxy.

```plaintext
global
  stats socket /var/run/api.sock user haproxy group haproxy mode 660 level admin expose-fd listeners
  log stdout format raw local0 info
  log stdout format raw local1 notice
  tune.ssl.default-dh-param 2048
  ulimit-n 100050
  pidfile /var/run/haproxy.pid
  maxconn 50000
  user haproxy
  group haproxy
  daemon
  lua-load /usr/local/etc/haproxy/lua/capture_response_info.lua
  lua-load /usr/local/etc/haproxy/lua/verify_request.lua
  lua-load /usr/local/etc/haproxy/lua/save_add_ratelimit_headers.lua
```

* **`stats socket`**: Thiết lập socket cho việc quản lý và giám sát. Lệnh này tạo một socket API để giao tiếp với HAProxy, cho phép theo dõi các chỉ số và điều chỉnh cấu hình trong quá trình hoạt động.
* **`log`**: Dòng này cấu hình log cấp độ `info` cho mọi yêu cầu và log cấp độ `notice` dành riêng cho lỗi.
* **`tune.ssl.default-dh-param`**: Cài đặt tham số Diffie-Hellman mặc định là 2048-bit, giúp tăng cường bảo mật cho các kết nối SSL.
* **`ulimit-n`**: Đặt số lượng file tối đa có thể mở là `100050`, cải thiện khả năng xử lý tải cao.
* **`lua-load`**: Nạp các script Lua để xử lý thêm các yêu cầu, như ghi nhận thông tin phản hồi (`capture_response_info`), xác minh yêu cầu (`verify_request`), và thêm tiêu đề giới hạn tốc độ (`save_add_ratelimit_headers`).

## **Thiết Lập `resolvers` và `mailers`**

HAProxy hỗ trợ việc chỉ định các dịch vụ DNS để quản lý tên miền, cũng như cấu hình gửi email.

```plaintext
resolvers my_dns
    nameserver google1 8.8.8.8:53
    nameserver google2 8.8.4.4:53
    nameserver cf1 1.1.1.1:53
    nameserver cf2 1.0.0.1:53

mailers smtp_vihatgroup
    timeout mail 20s
    mailer smtp1 mail.vihatgroup.com:587
```

* **`resolvers`**: Đặt danh sách các máy chủ DNS để giải mã tên miền. Để HAProxy có thể truy vấn tên miền nhanh chóng, ta định nghĩa các máy chủ DNS từ Google và Cloudflare.
* **`mailers`**: Cấu hình dịch vụ email, dùng để gửi thông báo về các lỗi nghiêm trọng.

## **Phần `defaults`: Cấu Hình Mặc Định**

Phần `defaults` chứa các thiết lập áp dụng cho các `frontend`, `backend`, và `listen` nếu không có cài đặt riêng.

```plaintext
defaults
    mode http
    log global
    option dontlognull
    option http-server-close
    option forwardfor
    retries 3
    timeout http-request 10s
    timeout queue 1m
    timeout connect 60000ms
    timeout client 120000ms
    timeout server 120000ms
    timeout http-keep-alive 5m
    log-format '{ "type":"haproxy", "timestamp":%Ts, ... }'
    email-alert mailers smtp_vihatgroup
    email-alert from quynh@vihatgroup.com
    email-alert to quynh@vihatgroup.com
```

* **`mode http`**: Thiết lập chế độ HTTP cho HAProxy, tức là hoạt động ở tầng ứng dụng (layer 7).
* **`log-format`**: Tùy chỉnh định dạng log để xuất dưới dạng JSON, dễ dàng cho việc phân tích sau này.
* **`email-alert`**: Khi có cảnh báo xảy ra, hệ thống sẽ gửi email đến địa chỉ được chỉ định.

## **Cache Cấu Hình**

Cấu hình cache để giảm tải và cải thiện tốc độ phản hồi.

```plaintext
cache cache
    total-max-size 200
    max-object-size 10485760
    max-age 3600
    process-vary on
```

* **`total-max-size`**: Bộ nhớ cache tối đa là 200MB.
* **`max-object-size`**: Kích thước tối đa của một đối tượng là 10MB.
* **`max-age`**: Đối tượng sẽ tồn tại trong bộ nhớ cache tối đa là 1 giờ.

## **Cấu Hình Giới Hạn Tốc Độ (Rate Limiting)**

Phần này kiểm soát tốc độ yêu cầu từ các IP, nhằm hạn chế DDoS.

```plaintext
stick-table type string size 1m expire 10s store http_req_rate(1s)
http-request track-sc0 src
http-request set-var(req.ip_rate_limit) src,map_beg(/usr/local/etc/haproxy/map/ipclient-rates.map,2)
acl rate_limit_above_limit var(req.ip_rate_limit),sub(req.ip_request_usage) lt 0
```

* **`stick-table`**: Tạo một bảng lưu tốc độ yêu cầu của các IP, sử dụng để so sánh giới hạn tốc độ.
* **`http-request track-sc0`**: Theo dõi yêu cầu từ IP.
* **`set-var`**: Đặt biến `ip_rate_limit` từ file `ipclient-rates.map` để xác định mức độ giới hạn tốc độ cho từng IP.

## **Frontend và Backend**

Phần `frontend` và `backend` thực hiện việc định tuyến và phân phối yêu cầu đến các dịch vụ.

```plaintext
frontend http_in
    bind *:80
    bind *:443 ssl crt /etc/haproxy/ssl/ alpn h2,http/1.1 no-sslv3 no-tlsv10 no-tlsv11
    http-request capture req.body len 80000
    http-request add-header X-Real-IP %[src]
    http-request set-header X-SSL %[ssl_fc]

backend backend_maintaince_server
    balance roundrobin
    option httpchk OPTIONS / HTTP/1.0
    compression algo gzip
    compression type text/css text/html text/javascript application/javascript text/plain text/xml application/json
```

* **`frontend`**: Phần frontend xử lý yêu cầu vào và chuyển tiếp đến backend.
  * **`bind *:80`** và **`bind *:443 ssl crt`**: Thiết lập HAProxy lắng nghe trên cổng HTTP và HTTPS.
  * **`http-request capture`**: Ghi lại dữ liệu yêu cầu từ body để kiểm tra sau.
  * **`http-request add-header`**: Thêm các header cần thiết cho bảo mật và xác thực.
* **`backend`**: Phần backend chỉ định server đích và các thuật toán phân phối tải.
  * **`balance roundrobin`**: Thuật toán cân bằng tải theo thứ tự tuần tự.
  * **`compression`**: Nén các nội dung được chỉ định để giảm dung lượng truyền tải.

## Giải thích chi tiết từng thành phần

### [Cấu hình `listen stats`](haproxy-stats.md)

Phần cấu hình `listen stats` trong HAProxy cho phép bạn thiết lập một trang thống kê trên cổng 7001, nơi bạn có thể giám sát tình trạng của các frontend, backend, cũng như các server thành viên. Trang thống kê cung cấp thông tin chi tiết về lưu lượng, hiệu suất và trạng thái của từng thành phần trong HAProxy, rất hữu ích cho việc theo dõi và phân tích.

```plaintext
listen stats
    mode http
    bind *:7001
    stats enable
    # stats refresh 30s
    stats hide-version
    stats realm HAproxy-Statistics
    stats uri /
    stats auth admin:password
    # stats admin if { src 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 127.0.0.0/8 }
    stats show-node
    stats show-legends
    stats show-modules
    option forwardfor
    option httpclose
    # acl whitelist src -f /etc/haproxy/whitelist.lst
    # http-request deny if !whitelist
```

#### Giải thích từng dòng cấu hình

* **`listen stats`**: Khởi tạo một `listen` section tên là `stats`. Phần này sẽ chạy trên một cổng độc lập để phục vụ trang thống kê HAProxy.
* **`mode http`**: Thiết lập chế độ `HTTP` cho phần `listen` này, cho phép trang thống kê có thể truy cập qua HTTP.
* **`bind *:7001`**: Lệnh này yêu cầu HAProxy lắng nghe trên tất cả các địa chỉ IP (`*`) tại cổng `7001`. Điều này có nghĩa là bất kỳ ai biết IP của máy chủ và cổng 7001 đều có thể truy cập vào trang thống kê (nếu không bị giới hạn quyền truy cập).
* **`stats enable`**: Kích hoạt trang thống kê.
* **`stats refresh 30s`**: (Được tắt bỏ) Nếu bật, lệnh này sẽ tự động làm mới trang thống kê sau mỗi 30 giây.
* **`stats hide-version`**: Ẩn phiên bản của HAProxy trên trang thống kê để tăng cường bảo mật, giúp tránh lộ phiên bản đang sử dụng.
* **`stats realm HAproxy-Statistics`**: Thiết lập tên của cửa sổ đăng nhập (realm) khi người dùng cố gắng truy cập vào trang thống kê. Dòng chữ "HAproxy-Statistics" sẽ hiển thị trong cửa sổ đăng nhập để thông báo cho người dùng biết họ đang truy cập vào trang gì.
* **`stats uri /`**: Chỉ định đường dẫn của trang thống kê là `/`, có nghĩa là trang sẽ có thể truy cập trực tiếp khi bạn vào địa chỉ IP và cổng của HAProxy (vd: `http://<IP>:7001/`).
* **`stats auth admin:password`**: Thiết lập xác thực với tài khoản `admin` và mật khẩu `UaA84JvFZzNW`. Khi truy cập vào trang thống kê, bạn sẽ được yêu cầu nhập tài khoản này để bảo vệ quyền truy cập.
* **`stats admin if { src 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 127.0.0.0/8 }`**: (Được tắt bỏ) Lệnh này cho phép quyền "admin" (để thay đổi trạng thái backend hoặc server) nếu IP truy cập thuộc các dải địa chỉ nội bộ đã được chỉ định. Điều này giúp bảo vệ trang thống kê, chỉ cho phép các IP nội bộ có quyền kiểm soát cao nhất.
* **`stats show-node`**: Hiển thị tên node trên trang thống kê, giúp xác định cụ thể máy chủ HAProxy nếu bạn đang dùng nhiều node.
* **`stats show-legends`**: Hiển thị chú thích (legend) trong các bảng thống kê, giúp người dùng dễ dàng hiểu rõ hơn về ý nghĩa của các thông số trên trang.
* **`stats show-modules`**: Hiển thị các module HAProxy đang sử dụng, giúp người quản trị dễ dàng kiểm tra các module đang hoạt động và hỗ trợ.
* **`option forwardfor`**: Chuyển tiếp thông tin địa chỉ IP của client trong trường hợp sử dụng proxy ngược. Lệnh này thêm header `X-Forwarded-For` để server backend biết địa chỉ IP thực của client.
* **`option httpclose`**: Đóng kết nối HTTP sau mỗi yêu cầu, giúp giảm lượng tài nguyên hệ thống tiêu tốn và tránh các vấn đề liên quan đến kết nối dài.
* **`acl whitelist src -f /etc/haproxy/whitelist.lst`** và **`http-request deny if !whitelist`**: (Được tắt bỏ) Cấu hình này sẽ từ chối mọi truy cập vào trang thống kê nếu địa chỉ IP không có trong danh sách cho phép (`whitelist.lst`). Bạn có thể kích hoạt lệnh này để tăng cường bảo mật cho trang thống kê, đặc biệt hữu ích khi có nguy cơ truy cập trái phép từ bên ngoài.

***



### Cấu hình `frontend http_in`

Phần `frontend http_in` bạn chia sẻ thực hiện chức năng tiếp nhận yêu cầu HTTP/HTTPS từ client và chuyển tiếp đến các backend thích hợp. Cấu hình bao gồm nhiều tính năng như hỗ trợ HTTP/1.x và HTTP/2, HSTS, chuyển hướng HTTP sang HTTPS, giới hạn tốc độ (Rate Limiting), nén HTTP, bộ nhớ đệm và tùy chỉnh header. Dưới đây là giải thích chi tiết từng dòng trong cấu hình.

```plaintext
frontend http_in
```

Tạo phần cấu hình `frontend` tên là `http_in`. Phần này chịu trách nhiệm tiếp nhận các yêu cầu HTTP từ client trước khi chuyển tiếp đến backend.

#### **Thiết Lập Kết Nối HTTP và HTTPS**

```plaintext
bind *:80 name http_in_80
bind *:443 name http_in_443 ssl crt /etc/haproxy/ssl/ alpn h2,http/1.1 no-sslv3 no-tlsv10 no-tlsv11
```

* **`bind *:80`**: Cấu hình HAProxy lắng nghe cổng 80 (HTTP). Đây là cổng tiêu chuẩn cho các kết nối HTTP không bảo mật.
* **`name http_in_80`**: Đặt tên cho dòng kết nối là `http_in_80`, giúp dễ dàng theo dõi hoặc cấu hình trong `stats`.
* **`bind *:443`**: Lắng nghe cổng 443 (HTTPS) với chứng chỉ SSL, cho phép giao tiếp HTTPS.
* **`ssl crt /etc/haproxy/ssl/`**: Chỉ định thư mục chứa các chứng chỉ SSL được sử dụng cho kết nối bảo mật.
* **`alpn h2,http/1.1`**: Kích hoạt HTTP/2 (h2) và HTTP/1.1, cho phép client chọn giao thức.
* **`no-sslv3 no-tlsv10 no-tlsv11`**: Vô hiệu các phiên bản cũ hơn của SSL và TLS để cải thiện bảo mật.

#### **Các Tuỳ Chọn và Header HTTP**

```plaintext
option socket-stats
http-after-response set-header Strict-Transport-Security "max-age=31536000"
option http-ignore-probes
compression algo deflate gzip
compression type text/ application/javascript application/xhtml+xml image/x-icon
http-request cache-use cache
http-response cache-store cache
maxconn 50000
option forwardfor
option forwardfor except 127.0.0.1
option forwardfor header X-Real-IP
http-request capture req.body len 80000
```

* **`option socket-stats`**: Cung cấp các thống kê theo từng dòng `bind` trên `stats`.
* **`http-after-response set-header Strict-Transport-Security`**: Thiết lập HSTS cho một năm để yêu cầu trình duyệt chỉ truy cập trang web qua HTTPS.
* **`option http-ignore-probes`**: Bỏ qua các yêu cầu kiểm tra (probes) để giảm tải.
* **`compression algo deflate gzip`**: Kích hoạt nén HTTP với các thuật toán `deflate` và `gzip`.
* **`compression type text/ application/javascript application/xhtml+xml image/x-icon`**: Chỉ nén các loại nội dung này.
* **`http-request cache-use cache`**: Sử dụng bộ nhớ đệm nếu nội dung có thể được lưu trong bộ nhớ cache.
* **`http-response cache-store cache`**: Lưu nội dung vào bộ nhớ cache nếu có thể.
* **`maxconn 50000`**: Giới hạn số lượng kết nối đồng thời là 50,000 để tối ưu tài nguyên.
* **`option forwardfor`**: Thêm header `X-Forwarded-For` để backend nhận diện IP gốc của client.
* **`option forwardfor except 127.0.0.1`**: Không thêm header này nếu IP là `127.0.0.1`.
* **`option forwardfor header X-Real-IP`**: Thay thế header `X-Real-IP` cho IP của client.
* **`http-request capture req.body len 80000`**: Lưu 100 ký tự đầu của nội dung yêu cầu để kiểm tra và phân tích sau.

#### **Chuyển Tiếp Các Header Cụ Thể Đến Backend**

```plaintext
http-request set-header referer %[req.hdr(Referer)]
http-request add-header X-Real-IP %[src]
http-request add-header X-Forwarded-For %[src]
http-request set-header X-HaEsms-Forwarded-For %[src]
http-request add-header X-Forwarded-Port %[dst_port]
http-request set-header X-Forwarded-Host %[req.hdr(Host)]
http-request set-header X-Forwarded-Proto %[ssl_fc,iif(https,http)]
http-request set-header X-Haproxy-Current-Date %T
http-request set-header X-SSL %[ssl_fc]
http-request set-header X-SSL-Session_ID %[ssl_fc_session_id,hex]
http-request set-header X-SSL-Client-Verify %[ssl_c_verify]
http-request set-header X-SSL-Client-DN %{+Q}[ssl_c_s_dn]
http-request set-header X-SSL-Client-CN %{+Q}[ssl_c_s_dn(cn)]
http-request set-header X-SSL-Issuer %{+Q}[ssl_c_i_dn]
http-request set-header X-SSL-Client-NotBefore %{+Q}[ssl_c_notbefore]
http-request set-header X-SSL-Client-NotAfter %{+Q}[ssl_c_notafter]
```

Các lệnh này lần lượt thiết lập các header bổ sung cho yêu cầu HTTP, cung cấp thông tin như:

* **Địa chỉ IP thực** của client (`X-Real-IP`, `X-Forwarded-For`),
* **Chế độ bảo mật** (`X-SSL`, `X-SSL-Session_ID`),
* **Thông tin chứng chỉ** như tên CN của client và thời gian hết hạn.

#### **Điều Kiện ACL và Các Tính Năng Nâng Cao**

```plaintext
acl whitelist src -f /etc/haproxy/whitelist.lst
acl whitelist_webadmin src -f /etc/haproxy/whitelist-webadmin.lst
```

* **`acl whitelist src -f /etc/haproxy/whitelist.lst`**: Chỉ định danh sách các IP được phép truy cập từ file `whitelist.lst`.
* **`acl whitelist_webadmin src -f /etc/haproxy/whitelist-webadmin.lst`**: Tương tự, nhưng dành cho web admin.

#### **Cấu Hình Giới Hạn Tốc Độ (Rate Limiting)**

```plaintext
acl is_host_have_rate_limiting hdr(host) -i nqdev.local
stick-table type string size 1m expire 10s store http_req_rate(1s)
http-request lua.set_ratelimit_timestamp
http-request set-var(req.ip_rate_limit) src,map_beg(/usr/local/etc/haproxy/map/ipclient-rates.map,2)
acl ignore_ip_limit var(req.ip_rate_limit) -m int eq -1
http-request set-var(req.ip_request_usage) sc0_http_req_rate()
acl rate_limit_above_limit var(req.ip_rate_limit),sub(req.ip_request_usage) lt 0
```

* **`acl is_host_have_rate_limiting hdr(host) -i nqdev.local`**: Kiểm tra yêu cầu đến từ host `nqdev.local` để áp dụng giới hạn tốc độ.
* **`stick-table`**: Tạo bảng lưu trữ tốc độ yêu cầu của từng IP với thời gian hết hạn là 10 giây.
* **`lua.set_ratelimit_timestamp`**: Sử dụng Lua script để lưu dấu thời gian cho từng yêu cầu.
* **`map_beg(/usr/local/etc/haproxy/map/ipclient-rates.map,2)`**: Đọc giới hạn tốc độ từ file map.
* **`ignore_ip_limit`**: Bỏ qua giới hạn nếu tốc độ là `-1`.

#### Sử Dụng Backend

```plaintext
use_backend backend_maintaince_server if host_nqdev_local
use_backend backend_maintaince_server if host_vip_rest
use_backend backend_whitelist_ip_server if host_nqdev_local
use_backend backend_whitelist_ip_server if host_vip_rest
```

* **`use_backend backend_maintaince_server if host_nqdev_local`**: Chuyển tiếp các yêu cầu đến backend `backend_maintaince_server` nếu hostname của yêu cầu là `nqdev.local`.
* **`use_backend backend_maintaince_server if host_vip_rest`**: Tương tự, nhưng cho hostname `vip-rest.esms.vn`.
* **`use_backend backend_whitelist_ip_server if host_nqdev_local`**: Nếu yêu cầu đến từ `nqdev.local`, sẽ chuyển tiếp đến backend `backend_whitelist_ip_server`, có thể là để xử lý các yêu cầu từ các IP nằm trong danh sách trắng.
* **`use_backend backend_whitelist_ip_server if host_vip_rest`**: Tương tự như trên nhưng dành cho hostname `vip-rest.esms.vn`.

#### **Quy Tắc Redirect HTTPS**

```plaintext
redirect scheme https if host_vip_rest !{ ssl_fc }
```

* **`redirect scheme https if host_vip_rest !{ ssl_fc }`**: Nếu yêu cầu đến từ `vip-rest.esms.vn` và không phải là kết nối SSL (`!{ ssl_fc }`), chuyển hướng yêu cầu này sang HTTPS.

***



## Kết Luận

Cấu hình HAProxy này giúp tối ưu hóa hiệu suất, kiểm soát tốc độ yêu cầu và bảo vệ hệ thống khỏi các cuộc tấn công. Với việc sử dụng các lệnh Lua và các cấu hình nâng cao, HAProxy cung cấp một giải pháp mạnh mẽ, linh hoạt để cân bằng tải và quản lý truy cập.
