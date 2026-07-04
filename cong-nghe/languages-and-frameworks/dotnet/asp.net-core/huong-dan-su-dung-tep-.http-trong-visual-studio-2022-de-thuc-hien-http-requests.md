---
description: >-
  Refer: Use `.http` files in Visual Studio 2022 -
  https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0
---

# Hướng dẫn sử dụng tệp .http trong Visual Studio 2022 để thực hiện HTTP Requests

Tệp `.http` trong Visual Studio là một công cụ mạnh mẽ hỗ trợ các kỹ thuật viên test và debug các yêu cầu HTTP một cách nhanh chóng. Công cụ này rất hữu ích khi bạn cần thử nghiệm các API mà không cần đến các công cụ bên ngoài như Postman.

{% hint style="info" %}
* [Use .http files in Visual Studio 2022](https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0)
* [REST Client for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
* [Web API development in Visual Studio 2022](https://devblogs.microsoft.com/visualstudio/web-api-development-in-visual-studio-2022/)

***

[Tải file PDF từ Microsoft](https://learn.microsoft.com/pdf?url=https://learn.microsoft.com/en-us/aspnet/core/toc.json?view=aspnetcore-8.0).
{% endhint %}

### **1. Tạo Tệp `.http` trong Dự Án của Bạn**

Bước đầu tiên là tạo một tệp `.http` trong dự án. Thực hiện các bước sau:

1. Trong Visual Studio 2022, nhấp chuột phải vào thư mục bạn muốn lưu trữ tệp.
2. Chọn **Add > New Item**.
3. Tìm và chọn **Text File** rồi đổi tên tệp này với phần mở rộng `.http` (ví dụ: `TestAPI.http`).

### **2. Cấu Trúc Cơ Bản của Tệp `.http`**

Trong tệp `.http`, bạn có thể viết các yêu cầu HTTP theo cách rất linh hoạt. Một yêu cầu cơ bản bao gồm:

```http
### Thực hiện yêu cầu GET
GET https://api.example.com/items
```

Tệp `.http` hỗ trợ tất cả các loại HTTP request phổ biến như `GET`, `POST`, `PUT`, `DELETE`, v.v. Bạn có thể thực hiện nhiều yêu cầu trong cùng một tệp bằng cách phân cách chúng bằng dòng `###`.

### **3. Cách Gửi Yêu Cầu HTTP Từ Tệp `.http`**

Để gửi yêu cầu, bạn chỉ cần:

1. Đặt con trỏ chuột tại dòng yêu cầu.
2. Nhấp chuột phải và chọn **Send Request**.

Visual Studio sẽ thực hiện yêu cầu và hiển thị kết quả ngay trong giao diện IDE của bạn. Kết quả trả về có thể bao gồm status code, headers và body của phản hồi.

### **4. Ví Dụ về Các Loại Yêu Cầu HTTP**

Dưới đây là ví dụ về các loại yêu cầu khác nhau có thể sử dụng trong tệp `.http`:

#### **Yêu cầu GET**

```http
### Yêu cầu GET
GET https://api.example.com/items
```

#### **Yêu cầu POST**

```http
### Yêu cầu POST
POST https://api.example.com/items
Content-Type: application/json

{
  "name": "Item name",
  "description": "Item description"
}
```

#### **Yêu cầu với Headers**

```http
### Yêu cầu với Headers
GET https://api.example.com/secure-items
Authorization: Bearer your-access-token
```

#### **Yêu cầu với Query Parameters**

```http
### Yêu cầu với Query Parameters
GET https://api.example.com/items?filter=value&sort=asc
```

### **5. Sử Dụng Biến trong Tệp `.http`**

Tệp `.http` hỗ trợ biến giúp bạn tái sử dụng thông tin một cách dễ dàng. Định nghĩa biến ở phần đầu và sử dụng nó trong các yêu cầu. Ví dụ:

```http
@baseUrl = https://api.example.com

### Yêu cầu với biến
GET {{baseUrl}}/items
```

Bạn chỉ cần thay đổi giá trị biến `@baseUrl` khi cần thiết mà không phải cập nhật từng yêu cầu trong tệp.

### **6. Lợi Ích Khi Sử Dụng Tệp `.http`**

Sử dụng tệp `.http` trong Visual Studio mang lại một số lợi ích:

* **Tiết kiệm thời gian**: Dễ dàng thực hiện các yêu cầu HTTP mà không cần rời khỏi Visual Studio.
* **Tích hợp trực tiếp**: Không cần phần mềm ngoài như Postman, đặc biệt hữu ích khi đang làm việc với các dự án lớn.
* **Có thể tùy chỉnh**: Sử dụng các biến và headers để cấu hình các yêu cầu linh hoạt.
* **Hỗ trợ cho teamwork**: Các tệp `.http` có thể chia sẻ qua Git, giúp đồng đội dễ dàng kiểm tra và debug API.

### Ví dụ

{% code title="demo-vscode.rest" overflow="wrap" %}
```http
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# REST Client for Visual Studio Code
# https://marketplace.visualstudio.com/items?itemName=humao.rest-client
# ----------
# Provide system dynamic variables
# - {{$guid}}
# - {{$randomInt min max}}
# - {{$timestamp [offset option]}}
# - {{$datetime rfc1123|iso8601 [offset option]}}
# - {{$localDatetime rfc1123|iso8601 [offset option]}}
# - {{$processEnv [%]envVarName}}
# - {{$dotenv [%]variableName}}
# - {{$aadToken [new] [public|cn|de|us|ppe] [<domain|tenantId>] [aud:<domain|tenantId>]}}
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@HostAddress = https://httpbin.org
@contentType = application/json
@createdAt = {{$datetime iso8601}}
@modifiedBy = {{$processEnv USERNAME}}

### 

GET  {{HostAddress}}/headers HTTP/1.1
Accept: application/json
Accept-Language: en-GB,en-US;q=0.8,en;q=0.6,zh-CN;q=0.4
Content-Type: application/json
Authorization: token xxx

{
    "name": "sample",
    "time": "Wed, 21 Oct 2015 18:27:50 GMT"
}
```
{% endcode %}



### **Kết Luận**

Tệp `.http` trong Visual Studio 2022 là công cụ tiện lợi giúp bạn kiểm thử các yêu cầu HTTP một cách dễ dàng và hiệu quả. Hy vọng hướng dẫn này sẽ giúp các kỹ thuật viên nhanh chóng làm quen và tận dụng tối đa tính năng này trong công việc hàng ngày.
