# Bắt đầu với HAProxy Lua API: Hướng dẫn cơ bản

## Giới thiệu về Lập trình Lua trong HAProxy

HAProxy và HAProxy Enterprise tích hợp sẵn bộ thông dịch Lua, cho phép bạn mở rộng khả năng của bộ cân bằng tải với các script Lua tùy chỉnh. Đây là một hướng dẫn nhanh về cách bắt đầu.

## Cấu hình cơ bản

Đầu tiên, trong phần `global` của tệp cấu hình, bạn cần xác định các tệp Lua sẽ được tải. HAProxy sẽ đọc các tệp này trước khi xử lý bất kỳ dòng `chroot` nào trong cấu hình, điều này giúp bạn có thể đặt các tệp Lua ngoài thư mục `chroot` nếu cần.

Do HAProxy có kiến trúc không chặn (non-blocking), các script Lua cần được viết sao cho không gây cản trở cho luồng chính của tiến trình load balancer trong quá trình thực thi. Tốt nhất là đọc file và thực hiện các lệnh có khả năng gây cản trở trong hàm `core.register_init` và lưu dữ liệu trong biến toàn cục để có thể truy cập trong thời gian chạy từ các khối `core.register_service`.

Bên trong script Lua, bạn sẽ thêm các khối bắt đầu bằng `core.register_service` để xác định các hàm mà load balancer sẽ thực thi khi một trong các chỉ thị cấu hình sau được kích hoạt:

* `tcp-request content use-service lua.<tên đã đăng ký>`
* `tcp-response content use-service lua.<tên đã đăng ký>`
* `http-request use-service lua.<tên đã đăng ký>`
* `http-response use-service lua.<tên đã đăng ký>`

#### Ví dụ Hello World

Để làm quen, chúng ta sẽ tạo một ví dụ đơn giản cho câu “hello world” hiển thị URL mà người dùng đã yêu cầu.

Tạo một tệp có tên `/tmp/hello_world.lua` với nội dung sau:

```lua
core.register_service("hello_world_tcp", "tcp", function(applet)
  applet:send("hello world\n")
end)

core.register_service("hello_world_http", "http", function(applet)
  local response = "Đường dẫn bạn đã yêu cầu là: '" .. applet.path .. "'\n"
  applet:set_status(200)
  applet:add_header("content-length", string.len(response))
  applet:add_header("content-type", "text/plain")
  applet:start_response()
  applet:send(response)
end)
```

Script này xác định hai dịch vụ:

1. **hello\_world\_tcp**: trả lời một cách đơn giản cho bất kỳ kết nối TCP nào với nội dung “hello world.”
2. **hello\_world\_http**: trả lời một request HTTP kèm theo tiêu đề và trạng thái.

Thêm các dòng sau vào cấu hình của load balancer:

```haproxy
global
  lua-load /tmp/hello_world.lua

frontend http_test
  bind 127.0.0.1:81
  mode http
  tcp-request inspect-delay 1s
  http-request use-service lua.hello_world_http

frontend tcp_test
  bind 127.0.0.1:82
  mode tcp
  tcp-request inspect-delay 1s
  tcp-request content use-service lua.hello_world_tcp
```

Khởi động lại load balancer. Khi truy cập 127.0.0.1:81, bạn sẽ thấy URL được yêu cầu hiển thị.

## Các Tác Vụ Lua Thông Thường

### **Xác Thực Request Bằng Dịch Vụ Bên Ngoài**

Dưới đây là ví dụ xác thực một số request trước khi xử lý.

Tạo một script Lua mới có tên `verify_request.lua` với nội dung sau:

```lua
core.register_action("verify_request", { "http-req" }, function(txn)
  local s = core.tcp()
  s:connect("127.0.0.1:8080")
  s:send("GET /verify.php?url=" .. txn.sf:path() .. " HTTP/1.1\r\nHost: verify.example.com\r\n\r\n")
  local msg = s:receive("*l")
  
  if msg == nil then return end

  msg = tonumber(string.sub(msg, 9, 12))
  
  if msg == 404 then
     txn.set_var(txn, "txn.request_verified", true)
  else
     txn.set_var(txn, "txn.request_verified", false)
  end
end)
```

Trong tệp cấu hình, thêm dòng `lua-load` trong phần `global` để tải script này:

```haproxy
global
  lua-load /tmp/verify_request.lua
```

Và thêm cấu hình sau vào `frontend` để kiểm tra request:

```haproxy
frontend example
  http-request lua.verify_request
  http-request deny if !{ var(txn.request_verified) -m bool }
```

Script Lua trên đặt một biến tên `txn.request_verified` mà load balancer có thể đọc để xác định cách xử lý request. Tùy thuộc vào giá trị của biến này, bạn có thể từ chối request, thêm header, giảm tốc độ yêu cầu, hoặc ghi log.

Với HAProxy Lua API, bạn có thể mở rộng chức năng của load balancer, giúp hệ thống linh hoạt và tùy chỉnh hơn, phù hợp với yêu cầu cụ thể của dự án.
