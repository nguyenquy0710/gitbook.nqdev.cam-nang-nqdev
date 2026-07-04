---
description: >-
  Ocelot là một thư viện phổ biến trong hệ sinh thái .NET cho phép bạn xây dựng
  và cấu hình API Gateway cho các dịch vụ vi mô.
---

# Ocelot

### Tính năng chính của Ocelot:

* **Routing**: Dễ dàng cấu hình để chuyển tiếp các yêu cầu đến các dịch vụ vi mô khác.
* **API Aggregation**: Cho phép hợp nhất kết quả từ nhiều dịch vụ thành một phản hồi duy nhất.
* **Load Balancing**: Hỗ trợ cân bằng tải giữa các dịch vụ.
* **Security**: Hỗ trợ xác thực và phân quyền thông qua các công cụ như JWT token.
* **Rate Limiting**: Kiểm soát số lượng yêu cầu đến các API.
* **Caching**: Cung cấp khả năng cache phản hồi API để tối ưu hóa hiệu suất.

### Cài đặt và cấu hình Ocelot trong .NET Core:

1. **Cài đặt NuGet package Ocelot**: Bạn cần cài đặt Ocelot thông qua NuGet Package Manager trong dự án API Gateway của mình:

* ```bash
  dotnet add package Ocelot
  ```
*   **Cấu hình Ocelot**: Bạn cần cấu hình Ocelot trong file `ocelot.json` để chỉ định cách routing và các cài đặt khác.

    Ví dụ cấu hình `ocelot.json`:
* ```json
  {
    "ReRoutes": [
      {
        "DownstreamPathTemplate": "/api/values",
        "UpstreamPathTemplate": "/values",
        "UpstreamHttpMethod": [ "Get" ]
      }
    ],
    "GlobalConfiguration": {
      "BaseUrl": "http://localhost:5000"
    }
  }
  ```
* **Cấu hình Startup**: Trong lớp `Startup.cs`, bạn cần thêm Ocelot vào pipeline của ứng dụng như sau:

1. ```csharp
   public class Startup
   {
       public void ConfigureServices(IServiceCollection services)
       {
           services.AddOcelot();
       }

       public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
       {
           if (env.IsDevelopment())
           {
               app.UseDeveloperExceptionPage();
           }

           app.UseOcelot().Wait();
       }
   }
   ```

### Các giải pháp khác trong .NET Core:

Ngoài Ocelot, còn có một số giải pháp khác mà bạn có thể sử dụng để xây dựng API Gateway trong .NET Core, ví dụ:

* **YARP (Yet Another Reverse Proxy)**: Là một thư viện proxy ngược mạnh mẽ do Microsoft phát triển, hỗ trợ nhiều tính năng và dễ dàng tích hợp vào .NET Core.
* **Azure API Management**: Nếu bạn đang triển khai ứng dụng lên Azure, bạn có thể sử dụng dịch vụ quản lý API của Azure để xây dựng và quản lý API Gateway.

Tóm lại, **Ocelot** là lựa chọn phổ biến trong .NET Core để làm API Gateway, tương tự như **Spring Cloud Gateway** trong Java.
