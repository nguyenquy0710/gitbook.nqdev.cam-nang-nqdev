---
description: >-
  Khi phát triển các ứng dụng hiện đại, việc sử dụng API Gateway để quản lý
  luồng yêu cầu từ phía client đến backend là một giải pháp hiệu quả và phổ
  biến.
---

# Tích Hợp NGINX Làm API Gateway với Các Bước Xử Lý Phổ Biến

[**NGINX**](./) là một công cụ mạnh mẽ để xây dựng API Gateway, hỗ trợ các chức năng từ xác thực, định tuyến động đến chuyển đổi giao thức. Trong bài viết này, chúng ta sẽ cấu hình NGINX thực hiện các bước sau:

* **Parameter Validation**: Kiểm tra tham số yêu cầu.
* **Allow List/Deny List**: Chặn hoặc cho phép các yêu cầu dựa trên IP hoặc tiêu đề.
* **Authentication & Authorization**: Xác thực và phân quyền.
* **Rate Limiting**: Giới hạn tần suất yêu cầu.
* **Dynamic Routing**: Định tuyến động đến các dịch vụ backend.
* **Service Discovery**: Tích hợp phát hiện dịch vụ.
* **Protocol Conversion**: Chuyển đổi giữa các giao thức như HTTP và gRPC.

***

## 1. **Mô Hình Luồng Xử Lý API Gateway**

<figure><img src="https://miro.medium.com/v2/resize:fit:1100/format:webp/0*bD1nHLwJrBzVU604.png" alt=""><figcaption><p>Image from — <a href="https://blog.bytebytego.com/p/ep23-how-to-choose-the-right-database">blog.bytebytego.com</a></p></figcaption></figure>

***

## 2. **Cấu Hình Chi Tiết với NGINX**

### **2.1. Parameter Validation**

Kiểm tra các tham số trong yêu cầu HTTP, ví dụ: xác thực query string hoặc body JSON.

#### **Ví dụ kiểm tra query string:**

```nginx
server {
    listen 8080;

    location /api {
        if ($arg_token = "") {
            return 400 "Missing token parameter";
        }

        proxy_pass http://backend_service;
    }
}
```

### **2.2. Allow List/Deny List**

Cho phép hoặc chặn các yêu cầu dựa trên địa chỉ IP.

#### **Cấu hình Allow List/Deny List:**

```nginx
server {
    listen 8080;

    location /api {
        deny 192.168.1.0/24;  # Chặn IP trong dải 192.168.1.0/24
        allow 10.0.0.0/16;    # Chỉ cho phép IP từ 10.0.0.0/16
        deny all;             # Chặn tất cả các IP khác

        proxy_pass http://backend_service;
    }
}
```

### **2.3. Authentication & Authorization**

Sử dụng mô-đun `ngx_http_auth_request_module` để xác thực qua dịch vụ bên ngoài.

#### **Cấu hình xác thực:**

```nginx
server {
    listen 8080;

    location /api {
        auth_request /auth;
        auth_request_set $auth_status $upstream_status;

        if ($auth_status = 403) {
            return 403 "Forbidden";
        }

        proxy_pass http://backend_service;
    }

    location /auth {
        proxy_pass http://auth_service;
        proxy_set_header Content-Type application/json;
    }
}
```

### **2.4. Rate Limiting**

Giới hạn tần suất yêu cầu từ một client bằng cách sử dụng `ngx_http_limit_req_module`.

#### **Cấu hình giới hạn yêu cầu:**

```nginx
http {
    limit_req_zone $binary_remote_addr zone=api_rate_limit:10m rate=5r/s;

    server {
        listen 8080;

        location /api {
            limit_req zone=api_rate_limit burst=10 nodelay;
            proxy_pass http://backend_service;
        }
    }
}
```

### **2.5. Dynamic Routing**

Định tuyến yêu cầu đến các dịch vụ backend khác nhau dựa trên đường dẫn.

#### **Cấu hình định tuyến động:**

```nginx
server {
    listen 8080;

    location /service1 {
        proxy_pass http://service1_backend;
    }

    location /service2 {
        proxy_pass http://service2_backend;
    }
}
```

### **2.6. Service Discovery**

Sử dụng NGINX Plus hoặc tích hợp với các công cụ như Consul để tự động phát hiện backend.

#### **Cấu hình với NGINX Plus:**

```nginx
upstream backend {
    zone backend_zone 64k;
    server backend1.example.com:80;
    server backend2.example.com:80;
}
```

### **2.7. Protocol Conversion**

Chuyển đổi giao thức giữa HTTP và gRPC.

#### **Cấu hình chuyển đổi từ HTTP sang gRPC:**

```nginx
server {
    listen 8080;

    location /grpc {
        grpc_pass grpc://grpc_service:50051;
    }
}
```

#### **Cấu hình chuyển đổi từ gRPC sang HTTP:**

```nginx
server {
    listen 50051 http2;

    location / {
        proxy_pass http://http_service;
    }
}
```

***

## 3. **Kết Hợp Tất Cả Cấu Hình**

Dưới đây là cấu hình mẫu kết hợp tất cả các bước:

```nginx
http {
    limit_req_zone $binary_remote_addr zone=api_rate_limit:10m rate=5r/s;

    upstream backend_service {
        server backend1.example.com;
        server backend2.example.com;
    }

    server {
        listen 8080;

        # Parameter Validation
        location /api {
            if ($arg_token = "") {
                return 400 "Missing token parameter";
            }

            # Allow/Deny List
            deny 192.168.1.0/24;
            allow 10.0.0.0/16;
            deny all;

            # Authentication
            auth_request /auth;
            auth_request_set $auth_status $upstream_status;
            if ($auth_status = 403) {
                return 403 "Forbidden";
            }

            # Rate Limiting
            limit_req zone=api_rate_limit burst=10 nodelay;

            # Dynamic Routing
            proxy_pass http://backend_service;
        }

        location /auth {
            proxy_pass http://auth_service;
            proxy_set_header Content-Type application/json;
        }
    }
}
```

***

## 4. **Kết Luận**

Bằng cách sử dụng NGINX, bạn có thể dễ dàng xây dựng một **API Gateway** mạnh mẽ với các bước xử lý từ cơ bản đến nâng cao. Cấu hình này không chỉ giúp quản lý lưu lượng yêu cầu mà còn tăng cường bảo mật, tối ưu hiệu năng và cải thiện trải nghiệm người dùng.

{% code title="Tài liệu tham khảo" overflow="wrap" lineNumbers="true" %}
```http
- [EP23: How to choose the right database?](https://blog.bytebytego.com/p/ep23-how-to-choose-the-right-database)
- [What does API gateway do in Microservices Architecture?](https://medium.com/@maheshsaini.sec/what-does-api-gateway-do-in-microservices-architecture-d1e93e27e040)
```
{% endcode %}



Hãy áp dụng các bước trên để xây dựng hệ thống **API Gateway** của bạn với NGINX!

> **Đừng quên theo dõi** [**Cẩm nang NQDEV**](https://blogs.nhquydev.net/) **để cập nhật thêm các bài viết hay về công nghệ!** 🚀
