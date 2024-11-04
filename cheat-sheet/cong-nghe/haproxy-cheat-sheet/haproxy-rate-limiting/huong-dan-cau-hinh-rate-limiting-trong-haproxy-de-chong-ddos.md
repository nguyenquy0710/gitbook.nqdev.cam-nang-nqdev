---
description: >-
  Bài viết sẽ hướng dẫn chi tiết từng bước thiết lập rate limiting, giải thích
  lệnh, và giới thiệu cách sử dụng script Lua để bổ sung các headers thông báo
  cho client về trạng thái giới hạn của mình.
---

# Hướng dẫn cấu hình Rate Limiting trong HAProxy để chống DDoS

## Giới thiệu

Trong bối cảnh công ty phải đối mặt với cuộc tấn công DDoS, tôi đã sử dụng HAProxy để áp dụng Rate Limiting, giúp bảo vệ hệ thống trước các yêu cầu quá mức từ một số địa chỉ IP cụ thể. Bài viết này sẽ hướng dẫn chi tiết cách cấu hình Rate Limiting trong HAProxy với cách dùng **Lua script** và **stick-table**.

## Mục tiêu

* Cấu hình giới hạn tốc độ cho từng IP client.
* Tự động áp dụng các giới hạn dựa trên file cấu hình, cho phép linh hoạt trong việc thay đổi giới hạn cho từng IP.
* Đảm bảo chỉ áp dụng giới hạn với các yêu cầu từ các nguồn không được whitelist.

## Cấu Hình HAProxy Rate Limiting

### **1. Cấu hình trong `haproxy.cfg`**

Chúng ta sẽ bắt đầu với file cấu hình `haproxy.cfg`:

{% code title="haproxy.cfg" lineNumbers="true" %}
```
        # --------------------------------------------------- #
        # ### HAProxy Rate Limiting ###
        # https://www.haproxy.com/blog/four-examples-of-haproxy-rate-limiting
        # Cấu hình giới hạn tốc độ yêu cầu (Rate Limiting) cho mỗi địa chỉ IP client

        # `is_host_have_rate_limiting` ACL để kiểm tra khi có bật chế độ Rate Limiting
        # Chỉ kích hoạt rate limiting cho các yêu cầu đến host "hdr(host) -i nqdev.local"
        acl is_host_have_rate_limiting      hdr(host) -i nqdev.local

        # ### Stick-table cho giới hạn theo IP ###
        # Tạo một stick-table với kích thước 1m, hết hạn sau 10 phút, và lưu số lượng yêu cầu HTTP trong 10 giây qua.
        # Mỗi mục trong stick-table sẽ hết hạn (expire) sau 10 giây kể từ lần cuối cùng mục đó được truy cập hoặc cập nhật.
        # type: binary | ip | string
        stick-table type string size 1m expire 10s store http_req_rate(1s)
        # Track IP của client bằng http-request (thay vì tcp-request)
        # Kết hợp base32 + src (Host header + URL path + src IP) để tạo khóa theo dõi duy nhất cho từng IP và yêu cầu.
        # http-request track-sc0 base32+src

        # Lấy thời gian hiện tại và lưu vào biến
        http-request lua.set_ratelimit_timestamp
        # Lưu timestamp vào biến
        # http-request set-var(req.timestamp) date
        # Sử dụng track với khóa kết hợp IP và timestamp
        http-request track-sc0 src,concat(_,req.ip_request_timestamp)
        
        # Đọc giới hạn tốc độ từ file map cho từng IP
        # File map (ipclient-rates.map) chứa giới hạn tốc độ cho từng IP cụ thể. -1: không giới hạn tốc độ.
        http-request set-var(req.ip_rate_limit) src,map_beg(/usr/local/etc/haproxy/map/ipclient-rates.map,2)
        # Kiểm tra nếu giới hạn tốc độ của IP là -1 (tức là không áp dụng giới hạn với IP này)
        acl ignore_ip_limit var(req.ip_rate_limit) -m int eq -1
        # Lấy tốc độ yêu cầu hiện tại của IP từ stick-table và lưu vào biến `req.ip_request_usage`
        # Nếu sử dụng nhiều stick-table hoặc nhiều store khác nhau, các stick-counters được đánh số từ sc0, sc1, sc2,…
        http-request set-var(req.ip_request_usage) sc0_http_req_rate()

        # So sánh tốc độ yêu cầu của IP với giới hạn từ file map.
        # Nếu tốc độ hiện tại vượt quá giới hạn, thì `rate_limit_above_limit` sẽ kích hoạt
        acl rate_limit_above_limit var(req.ip_rate_limit),sub(req.ip_request_usage) lt 0

        # Thêm tốc độ yêu cầu vào header của phản hồi HTTP để client có thể thấy giới hạn của mình
        http-request add-header x-ratelimit-limit %[var(req.ip_rate_limit)]
        http-request add-header x-ratelimit-usage %[var(req.ip_request_usage)]

        # Lưu giá trị `req.ip_rate_limit` vào `txn.rate_limit` trong giai đoạn `http-request`
        # Giúp chuyển giá trị này đến bước xử lý `http-response` sau
        http-request lua.save_ratelimit_info
        # Thêm header `x-ratelimit-*` vào phản hồi trong giai đoạn `http-response` để cung cấp thông tin về giới hạn
        http-response lua.add_ratelimit_headers

        # Sử dụng Lua service cho các yêu cầu với trạng thái 429 (Too Many Requests)
        # Nếu IP vượt quá giới hạn tốc độ và IP không nằm trong danh sách được bỏ qua, thì trả về mã lỗi 429
        # http-request use-service lua.deny_429_ratelimit_headers if rate_limit_above_limit !ignore_ip_limit
        http-request use-service lua.deny_429_ratelimit_headers if rate_limit_above_limit !ignore_ip_limit is_host_have_rate_limiting

        # Quy tắc xử lý giới hạn tốc độ
        # Nếu vượt quá giới hạn theo đường dẫn và không bỏ qua giới hạn theo IP, thì trả về mã lỗi 429
        # http-request deny deny_status 429 if rate_limit_above_limit !ignore_ip_limit
        http-request deny deny_status 429 if rate_limit_above_limit !ignore_ip_limit is_host_have_rate_limiting

        # ### HAProxy Rate Limiting ###
        # --------------------------------------------------- #
        
```
{% endcode %}

#### **Giải thích các dòng lệnh:**

* `acl is_host_have_rate_limiting hdr(host) -i nqdev.local`: Kiểm tra nếu request đến từ domain `nqdev.local` thì sẽ áp dụng Rate Limiting.
* `stick-table type string size 1m expire 10s store http_req_rate(1s)`: Thiết lập **stick-table** để lưu lịch sử các request cho từng IP trong vòng 10 giây, với mỗi mục lưu số lượng request trong 1 giây.
* `http-request track-sc0 src,concat(_,req.ip_request_timestamp)`: Theo dõi IP client để lấy thông tin và xác định tốc độ request.
* `http-request set-var(req.ip_rate_limit) src,map_beg(/usr/local/etc/haproxy/map/ipclient-rates.map,2)`: Đọc giới hạn tốc độ từ file `ipclient-rates.map` để lấy mức giới hạn cho từng IP.
* `http-request add-header x-ratelimit-*`: Thêm thông tin giới hạn tốc độ vào header phản hồi HTTP để client biết được giới hạn và mức sử dụng.

### **2. Tạo Lua script để quản lý Header và Response**

File **`save_add_ratelimit_headers.lua`** giúp thêm header về tốc độ giới hạn và cung cấp response chi tiết khi request vượt quá giới hạn.

{% code title="save_add_ratelimit_headers.lua" lineNumbers="true" %}
```lua
-- Lấy thời gian hiện tại và lưu vào biến
core.register_action("set_ratelimit_timestamp", { "http-req" }, function(txn)
    -- local timestamp = os.date("%Y-%m-%d %H:%M:%S") -- (ví dụ: 2024-11-04 15:30:00).
    local timestamp = os.date("%Y%m%d%H%M") -- (ví dụ: 2024-11-04 15:30:00).
    txn:set_var("req.ip_request_timestamp", timestamp)
end)

-- Hàm thêm header vào phản hồi, kể cả khi mã trạng thái là 429
core.register_action("add_ratelimit_headers", { "http-res" }, function(txn)
  -- Lấy các biến rate limit từ txn đã lưu ở bước http-request
  local rate_limit = txn:get_var("txn.rate_limit") or "unknown"  -- Giới hạn tốc độ
  local request_usage = txn:get_var("txn.request_usage") or "unknown"  -- Mức sử dụng
  local request_timestamp = txn:get_var("txn.request_timestamp") or "unknown"
  local remaining = tonumber(rate_limit) - tonumber(request_usage)  -- Tính số yêu cầu còn lại

  -- Thêm các header thông tin về giới hạn
  txn.http:res_add_header("x-ratelimit-limit", rate_limit)
  txn.http:res_add_header("x-ratelimit-usage", request_usage)
  txn.http:res_add_header("x-ratelimit-timestamp", request_timestamp)

  if remaining >= 0 then
    txn.http:res_add_header("x-ratelimit-remaining", tostring(remaining))
  else
    txn.http:res_add_header("x-ratelimit-remaining", tostring(0))
  end
end)

-- Hàm lưu giá trị `req.ip_rate_limit`
core.register_action("save_ratelimit_info", { "http-req" }, function(txn)
  -- Lấy giá trị giới hạn tốc độ và mức sử dụng từ biến yêu cầu
  local rate_limit = txn:get_var("req.ip_rate_limit") or "unknown"
  local request_usage = txn:get_var("req.ip_request_usage") or "unknown"
  local timestamp = txn:get_var("req.ip_request_timestamp") or "unknown"
  
  -- Lưu giá trị giới hạn và mức sử dụng vào biến giao dịch
  txn:set_var("txn.rate_limit", rate_limit)
  txn:set_var("txn.request_usage", request_usage)
  txn:set_var("txn.request_timestamp", timestamp)
end)

-- Thêm header thông tin vào phản hồi khi quá giới hạn
core.register_service("deny_429_ratelimit_headers", "http", function(applet)
  -- Kiểm tra loại nội dung yêu cầu
  local content_type = applet.headers["content-type"][0] or ""  -- Lấy loại nội dung từ header
  
  -- Đảm bảo rằng txn có tồn tại trước khi truy cập vào các biến
  local limit = applet:get_var("req.ip_rate_limit") or "unknown"  -- Giới hạn tốc độ
  local usage = applet:get_var("req.ip_request_usage") or "unknown"  -- Mức sử dụng
  local remaining = tonumber(limit) - tonumber(usage)  -- Tính số yêu cầu còn lại
  
  -- Nội dung phản hồi
  local response
  if content_type == "application/json" then
    -- Nếu content_type là application/json, trả về JSON
    applet:add_header("content-type", "application/json")  -- Thiết lập loại nội dung là application/json
    response = '{"status":"429","message":"Too Many Requests","details":"You have sent too many requests in a short period of time. Please try again later.","rate_limit":'..limit..',"rate_remaining":'..remaining..',"rate_usage":'..usage..'}'
  else
    -- Nếu không, trả về HTML
    applet:add_header("content-type", "text/html")  -- Thiết lập loại nội dung là text/html
    response = [[
      <html>
        <body>
          <h1>429 Too Many Requests</h1>
          <p>You have sent too many requests in a short period of time. Please try again later.</p>
        </body>
      </html>
    ]]
  end
  
  -- Đặt mã trạng thái HTTP là 429 (Too Many Requests)
  applet:set_status(429)
  applet:add_header("content-length", string.len(response))  -- Thiết lập chiều dài nội dung
  
  -- Bắt đầu phản hồi và gửi nội dung
  applet:start_response()
  applet:send(response)
end)
```
{% endcode %}

#### **Giải thích Lua script**:

* **`set_ratelimit_timestamp`**: Lấy thời gian hiện tại và lưu vào biến
* **`add_ratelimit_headers`**: Hàm thêm header vào phản hồi, kể cả khi mã trạng thái là 429
* **`save_ratelimit_info`**: Lưu giá trị giới hạn và mức sử dụng của mỗi request để kiểm tra sau này.
* **`deny_429_ratelimit_headers`**: Khi IP vượt quá giới hạn, trả về mã HTTP 429 với nội dung phản hồi JSON chi tiết về giới hạn và mức sử dụng.

### **3. Cấu hình file `ipclient-rates.map`**

Đây là file chứa các giới hạn tốc độ yêu cầu cho từng IP cụ thể:

{% code title="ipclient-rates.map" %}
```plaintext
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# filename: ipclient-rates.map
# ---------------------------------------------------------
# Các giới hạn tốc độ yêu cầu theo địa chỉ IP
# Định dạng: <địa chỉ IP> <giới hạn yêu cầu>
# Giới hạn yêu cầu được tính bằng số lượng yêu cầu mỗi giây (req/sec)
# Nếu giới hạn là -1, điều đó có nghĩa là không giới hạn yêu cầu từ địa chỉ IP đó.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Ví dụ:
# 203.0.113.1 1000  # IP client 1 - cho phép 1000 yêu cầu mỗi giây
# 203.0.113.2 50    # IP client 2 - cho phép 50 yêu cầu mỗi giây
# 0.0.0.0/0 10 # các IP khác là 10 yêu cầu/giây
# ---------------------------------------------------------

# Whitelist
# Danh sách Địa chỉ IP không có giới hạn yêu cầu
127.0.0.1 -1
171.224.0.0/11 -1
# ---------------------------------------------------------

# Danh sách Địa chỉ IP Công ty
203.0.113.1 5
203.0.113.2 5
# ---------------------------------------------------------

# Danh sách Địa chỉ IP giới hạn yêu cầu
172.18.0.1 5
# ---------------------------------------------------------

```
{% endcode %}

#### **Giải thích file `ipclient-rates.map`**:

* **`127.0.0.1 -1`**: Địa chỉ `127.0.0.1` không bị giới hạn (giá trị -1).
* **`203.0.113.1 5`**: Địa chỉ `203.0.113.1` có giới hạn 5 yêu cầu mỗi giây.

## Kết Luận

Bằng cách kết hợp các tính năng như **stick-table**, **ACL**, và **Lua script**, HAProxy có thể kiểm soát lưu lượng và áp dụng giới hạn yêu cầu hiệu quả để ngăn chặn DDoS. Với bài hướng dẫn này, hy vọng bạn sẽ nắm được các bước cấu hình Rate Limiting và hiểu rõ các khái niệm, cấu hình và cách thức hoạt động của HAProxy khi chống lại các cuộc tấn công mạng.
