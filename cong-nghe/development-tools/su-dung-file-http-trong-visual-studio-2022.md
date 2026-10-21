---
description: >-
  Hướng dẫn sử dụng file .http và .rest tích hợp sẵn trong Visual Studio 2022 (v17.8+)
  để gửi yêu cầu HTTP, kiểm thử REST API với biến môi trường không cần Postman.
---

# Sử dụng file .http trong Visual Studio 2022

Từ phiên bản **Visual Studio 2022 v17.8**, Microsoft đã tích hợp sẵn trình soạn thảo và thực thi file `.http` (hoặc `.rest`). Đây là công cụ cực kỳ mạnh mẽ giúp lập trình viên kiểm thử API ngay trong IDE mà không cần cài đặt thêm các công cụ bên ngoài như Postman hay Insomnia.

{% hint style="warning" %}
**Yêu cầu:** Visual Studio 2022 v17.8 trở lên với workload **ASP.NET and web development** đã cài đặt.
{% endhint %}

## Tính năng nổi bật

* **Built-in:** Hỗ trợ sẵn, không cần extension.
* **Tích hợp sâu:** Cho phép lấy thông tin từ biến môi trường của dự án (Launch Profiles).
* **Git-friendly:** File văn bản thuần túy, dễ dàng lưu trữ và chia sẻ cùng mã nguồn.
* **Hỗ trợ biến (Variables):** Định nghĩa biến để tái sử dụng cho nhiều môi trường.

## Cách sử dụng cơ bản

### 1. Tạo file
Bạn có thể tạo file mới bằng cách:
1. Chuột phải vào Project -> **Add** -> **New Item**.
2. Tìm kiếm `http` hoặc chọn **Code** -> **HTTP File**.
3. Đặt tên file có đuôi `.http` hoặc `.rest`.

### 2. Viết yêu cầu HTTP
Cấu trúc cơ bản gồm phương thức (Method), URL và các Header.

{% code title="example.http" overflow="wrap" lineNumbers="true" %}
```http
@baseUrl = https://localhost:7001

### Lấy danh sách sản phẩm
GET {{baseUrl}}/api/products
Accept: application/json

### Thêm sản phẩm mới
POST {{baseUrl}}/api/products
Content-Type: application/json

{
  "name": "IPhone 15",
  "price": 999
}
```
{% endcode %}

### 3. Thực thi và xem kết quả
* **Gửi yêu cầu:** Nhấn vào biểu tượng **nút Play** (hoặc chữ **Send Request**) xuất hiện ngay phía trên dòng định nghĩa phương thức HTTP.
* **Xem kết quả:** Kết quả sẽ hiển thị ở một cửa sổ bên phải (HTTP Response) bao gồm: Status Code, Response Headers, và Body (hỗ trợ format JSON/XML).

## Kỹ thuật nâng cao

### Sử dụng biến môi trường (Environment Variables)
Visual Studio 2022 hỗ trợ file `http-client.env.json` để quản lý biến theo từng môi trường (Development, Staging, Production).

{% code title="http-client.env.json" overflow="wrap" %}
```json
{
  "dev": {
    "host": "localhost:7001",
    "token": "dev-token"
  },
  "prod": {
    "host": "api.nqdev.com",
    "token": "prod-token"
  }
}
```
{% endcode %}

Sau đó trong file `.http`, bạn có thể chọn môi trường ở thanh công cụ phía trên và sử dụng:
```http
GET https://{{host}}/api/user
Authorization: Bearer {{token}}
```

### Phân tách các yêu cầu
Sử dụng dấu `###` để phân tách giữa các Request trong cùng một file. Visual Studio sẽ coi mỗi phần là một yêu cầu độc lập để bạn có thể nhấn "Send" riêng lẻ.

### Biến môi trường chung ($shared)

`$shared` là tên environment đặc biệt, giá trị trong `$shared` sẽ được dùng làm mặc định cho tất cả các environment khác nếu environment đó không định nghĩa lại biến.

{% code title="http-client.env.json" overflow="wrap" %}
```json
{
  "$shared": {
    "HostAddress": "https://localhost:7293"
  },
  "dev1": {
    "username": "dev1user"
  },
  "dev2": {
    "username": "dev2user"
  },
  "staging": {
    "username": "staginguser",
    "HostAddress": "https://staging.contoso.com"
  }
}
```
{% endcode %}

Trong ví dụ trên:
* `dev1` và `dev2` không định nghĩa `HostAddress` → lấy giá trị từ `$shared` (`https://localhost:7293`).
* `staging` định nghĩa `HostAddress` riêng → ghi đè giá trị từ `$shared`.

### Request Variables (Biến từ response)

Bạn có thể truyền giá trị từ response của request này sang request khác trong cùng file `.http` bằng cách đặt comment `# @name` ngay trước request cần đặt tên:

{% code title="example.http" overflow="wrap" lineNumbers="true" %}
```http
# @name login
POST https://localhost:44320/api/login
Content-Type: application/json

{
  "username": "admin",
  "password": "123456"
}

###

GET https://localhost:44320/api/userinfo
Authorization: Bearer {{login.response.body.$.token}}

###
```
{% endcode %}

Syntax trích xuất giá trị:

```
{{<request name>.(response|request).(body|headers).(*|JSONPath|XPath|<header name>)}}.
```

Ví dụ:
* `{{login.response.body.*}}` — lấy toàn bộ body.
* `{{login.response.body.$.token}}` — lấy trường `token` từ JSON (JSONPath).
* `{{login.response.headers.Location}}` — lấy header `Location`.

{% hint style="info" %}
**Tip:** Bạn cần trigger request có `@name` trước (nhấn Send) để có response, sau đó mới dùng được biến từ response của nó.
{% endhint %}

## Thực hành

### Bước 1: Tải source code mẫu

Bạn có thể tải source code mẫu tại [đây](https://github.com/nqdev-samples/vs2022-http-files-demo), hoặc bạn có thể thực hành ngay trên source code của chính bạn.

### Bước 2: Tạo thư mục Http Files

Tạo thư mục `Http Files` trong project để quản lý các file `.http`.

```
Solution
 └── Project
      ├── Controllers
      │    └── SampleController.cs
      ├── Http Files
      │    ├── sample.http
      │    └── http-client.env.json
      └── Program.cs
```

### Bước 3: Tạo file `sample.http`

Trong project có một Controller là `SampleController`, nên chúng ta sẽ tạo file `sample.http` để quản lý các request trong Controller đó.

### Bước 4: Tạo file biến môi trường

Tạo file `http-client.env.json`, đặt trong thư mục `Http Files`:

{% code title="Http Files/http-client.env.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "dev": {
    "HostAddress": "https://localhost:7229/api"
  },
  "test": {
    "HostAddress": "https://testapp.com"
  }
}
```
{% endcode %}

### Bước 5: Viết test API

Trong file `sample.http`, viết request test API lưu dữ liệu:

{% code title="Http Files/sample.http" overflow="wrap" lineNumbers="true" %}
```http
@controllerName=sample

POST {{HostAddress}}/{{controllerName}}
Content-Type: application/json

{
    "GroupName": "Gia đình",
    "Description": "Bao gồm từ vựng chủ đề gia đình",
    "GroupTypeEnum": 1
}

###
```
{% endcode %}

Trong đó:
* `@controllerName` — biến được khai báo riêng trong file `.http`.
* `{{HostAddress}}` — biến môi trường khai báo trong file `http-client.env.json`.

### Bước 6: Chạy và kiểm tra kết quả

1. **Chạy project** (F5 hoặc Ctrl+F5).
2. Chọn **Send Request** ở trên mỗi API cần test.
3. Sau khi gửi, màn hình sẽ hiển thị kết quả request lỗi hay thành công.

{% hint style="info" %}
**Tip:** Để xem toàn bộ thông tin Request được gửi đi, bạn chọn Tab **Request** trong cửa sổ kết quả.
{% endhint %}

## Endpoints Explorer

**Endpoints Explorer** là tool window hiển thị tất cả các endpoint mà Web API định nghĩa, cho phép bạn tạo request `.http` tự động.

**Cách sử dụng:**
1. Mở **View** > **Other Windows** > **Endpoints Explorer**.
2. Chuột phải vào endpoint cần test > **Generate Request**.
3. Visual Studio tự động tạo file `.http` (hoặc thêm vào file có sẵn) với request tương ứng.

{% hint style="info" %}
**Tip:** Từ Visual Studio 17.11 Preview, Endpoints Explorer còn discovery endpoint tại runtime (chỉ statically trước đó).
{% endhint %}

## Các tính năng chưa hỗ trợ

Visual Studio 2022 `.http` editor chưa hỗ trợ một số tính năng có trong VS Code REST Client extension:

* Request spans nhiều dòng
* Chỉ định file path làm request body
* Multipart/form-data với mixed format
* GraphQL requests
* cURL request / Copy/paste as cURL
* Request history
* Lưu response body ra file
* Certificate-based authentication
* Prompt variables

## Lưu ý quan trọng

{% hint style="info" %}
**Tip:** Bạn có thể kéo thả tệp kết quả Response ra cửa sổ riêng hoặc lưu lại để so sánh sau này.
{% endhint %}

{% hint style="warning" %}
**Bảo mật:** Tránh commit file `http-client.env.json` nếu nó chứa thông tin nhạy cảm như API Key hoặc mật khẩu. Hãy đưa nó vào `.gitignore` và sử dụng tệp `http-client.env.json.user` cho các giá trị bí mật cá nhân.
{% endhint %}

## Tài liệu tham khảo
* [Microsoft Learn: Use .http files in VS 2022](https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0#prerequisites)
* [LinkedIn: Using .http files in Visual Studio 2022](https://www.linkedin.com/pulse/using-http-files-visual-studio-2022-wilan-bigay/)
* [Viblo: HTTP file gọi REST API ngay trong Visual Studio](https://viblo.asia/p/05-http-file-goi-rest-api-ngay-trong-visual-studio-ban-da-thu-chua-vlZL9abdLQK)

***
<img src="https://me.momo.vn/nhquydev" alt="Momo" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
