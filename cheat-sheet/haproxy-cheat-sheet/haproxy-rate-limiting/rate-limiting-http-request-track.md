# Rate Limiting: http-request track

Trong HAProxy, lệnh `http-request track-sc0` (cùng các biến thể `track-sc1`, `track-sc2`,...) cho phép bạn theo dõi thông tin từ các yêu cầu HTTP và lưu chúng vào `stick table`. Việc này hữu ích khi bạn cần giám sát số lần truy cập từ một địa chỉ IP, theo dõi các yêu cầu theo từng URL cụ thể, hoặc phát hiện hành vi bất thường.

### Các Field Thường Được Theo Dõi với `http-request track`

HAProxy cung cấp nhiều lựa chọn cho khóa (key) mà bạn có thể sử dụng với `http-request track`:

| Field                  | Mô tả                                                             |
| ---------------------- | ----------------------------------------------------------------- |
| **src**                | Địa chỉ IP của client                                             |
| **src,map**            | Địa chỉ IP của client với file mapping                            |
| **req.hdr(\<header>)** | Giá trị của một header cụ thể trong yêu cầu (ví dụ: `User-Agent`) |
| **req.uri**            | Đường dẫn URI của yêu cầu                                         |
| **req.path**           | Đường dẫn của yêu cầu (không bao gồm query string)                |
| **req.query**          | Phần query string trong URL                                       |
| **req.method**         | Phương thức HTTP của yêu cầu (GET, POST,...)                      |
| **req.body**           | Nội dung của yêu cầu POST                                         |

Các field này giúp bạn kiểm soát chính xác thông tin mà bạn muốn track, nhưng đôi khi bạn cần thêm timestamp để nhận diện các yêu cầu đến trong khoảng thời gian nhất định.

### Cách Track Dữ Liệu Cùng Timestamp

Để track một yêu cầu HTTP kèm timestamp, bạn cần:

1. Lưu timestamp vào một biến.
2. Kết hợp timestamp này với các trường khác để tạo một khóa (key) độc nhất cho mỗi yêu cầu.

### Hướng Dẫn Cấu Hình

Dưới đây là cấu hình ví dụ trong HAProxy sử dụng `http-request track-sc0` kết hợp timestamp với địa chỉ IP của client:

```haproxy
frontend http_in
    bind *:80

    # Lưu timestamp vào một biến
    http-request set-var(req.timestamp) date(%ts)

    # Track các yêu cầu theo địa chỉ IP kết hợp với timestamp
    http-request track-sc0 src,req.timestamp
```

### Giải Thích Cấu Hình

* **`http-request set-var(req.timestamp) date(%ts)`**: Lưu timestamp hiện tại vào biến `req.timestamp` để sử dụng cho các thao tác sau.
* **`http-request track-sc0 src,req.timestamp`**: Tạo khóa track độc nhất dựa trên địa chỉ IP của client (`src`) và timestamp (`req.timestamp`). Điều này giúp bạn dễ dàng theo dõi từng yêu cầu với chi tiết về thời gian và nguồn yêu cầu.

### Ví Dụ Thực Tế

Giả sử bạn muốn giới hạn số lượng yêu cầu từ một địa chỉ IP cụ thể trong một khoảng thời gian, ví dụ giới hạn mỗi IP chỉ được gửi tối đa 100 yêu cầu trong vòng 1 phút. Bạn có thể cấu hình HAProxy như sau:

```haproxy
# Định nghĩa stick table để lưu thông tin theo dõi
stick-table type ip size 1m expire 1m store http_req_rate(1m)

frontend http_in
    bind *:80

    # Lưu timestamp vào biến
    http-request set-var(req.timestamp) date(%ts)

    # Track các yêu cầu theo địa chỉ IP và timestamp
    http-request track-sc0 src,req.timestamp

    # Kiểm tra tốc độ yêu cầu và giới hạn số lượng yêu cầu
    acl rate_limit_exceeded sc_http_req_rate(0) gt 100
    http-request deny if rate_limit_exceeded
```

#### Giải Thích Cấu Hình Trên

* **stick-table**: Định nghĩa bảng theo dõi (stick table) với `http_req_rate(1m)` để lưu số lượng yêu cầu từ mỗi IP trong 1 phút.
* **track-sc0 src,req.timestamp**: Theo dõi các yêu cầu của client kèm timestamp để tạo một khóa track duy nhất.
* **acl rate\_limit\_exceeded**: Kiểm tra nếu số lượng yêu cầu từ một IP vượt quá 100 trong khoảng thời gian 1 phút (`sc_http_req_rate(0) gt 100`).
* **http-request deny if rate\_limit\_exceeded**: Từ chối yêu cầu nếu vượt quá giới hạn.

### Kết Luận

Lệnh `http-request track` trong HAProxy giúp bạn theo dõi chi tiết từng yêu cầu, và bằng cách kết hợp với timestamp, bạn có thể tạo các giới hạn chi tiết cho từng client theo thời gian. Điều này là công cụ hữu ích để kiểm soát lưu lượng và bảo vệ hệ thống khỏi các hành vi quá tải.

