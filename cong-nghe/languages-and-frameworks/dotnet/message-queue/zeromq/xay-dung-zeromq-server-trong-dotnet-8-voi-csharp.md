# Xây dựng ZeroMQ Server trong dotNET 8 với CSharp

[ZeroMQ](./) (ØMQ) là một thư viện mã nguồn mở mạnh mẽ để xử lý giao tiếp tin nhắn bất đồng bộ trong các hệ thống phân tán. Tuy nhiên, ZeroMQ không cung cấp một server mặc định, thay vào đó, bạn có thể sử dụng thư viện **NetMQ** để triển khai một **ZeroMQ server** trong môi trường **.NET 8** với C#.

## 1. Cài đặt NetMQ trong dự án .NET 8

Trước tiên, bạn cần cài đặt thư viện **NetMQ**, một thư viện thay thế ZeroMQ dành cho .NET:

```bash
dotnet add package NetMQ
```

## 2. Tạo file cấu hình **config.json**

File này giúp chúng ta xác định **cổng lắng nghe** và **các cặp client A - client B** cần định tuyến độc lập.

```json
{
  "port": 5555,
  "routes": [
    {
      "clientA": "ClientA1",
      "clientB": "ClientB1"
    },
    {
      "clientA": "ClientA2",
      "clientB": "ClientB2"
    }
  ]
}
```

## 3. Code ZeroMQ Server

Server sử dụng **RouterSocket** để nhận thông điệp từ Client A và chuyển tiếp đến Client B theo cấu hình.

```csharp
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using NetMQ;
using NetMQ.Sockets;

class ZeroMQServer
{
    static void Main(string[] args)
    {
        string configPath = "config.json";
        if (!File.Exists(configPath))
        {
            Console.WriteLine("File cấu hình không tồn tại!");
            return;
        }

        var config = JsonSerializer.Deserialize<ServerConfig>(File.ReadAllText(configPath));
        int port = config.Port;
        var routes = config.Routes;

        Console.WriteLine($"Server chạy trên cổng: {port}");

        using (var routerSocket = new RouterSocket($"@tcp://*:{port}"))
        {
            Console.WriteLine("ZeroMQ Server đang chạy...");

            while (true)
            {
                var clientIdentity = routerSocket.ReceiveFrameString();
                var emptyFrame = routerSocket.ReceiveFrameString();
                var message = routerSocket.ReceiveFrameString();

                Console.WriteLine($"Nhận từ {clientIdentity}: {message}");

                var targetRoute = routes.Find(route => route.ClientA == clientIdentity);
                if (targetRoute != null)
                {
                    routerSocket.SendMoreFrame(targetRoute.ClientB).SendMoreFrame("").SendFrame(message);
                    Console.WriteLine($"Chuyển tiếp đến {targetRoute.ClientB}: {message}");
                }
                else
                {
                    Console.WriteLine($"Không tìm thấy định tuyến cho {clientIdentity}!");
                }
            }
        }
    }
}

public class ServerConfig
{
    public int Port { get; set; }
    public List<Route> Routes { get; set; }
}

public class Route
{
    public string ClientA { get; set; }
    public string ClientB { get; set; }
}
```

## 4. Code Client

### Client A (Gửi thông điệp):

```csharp
using System;
using NetMQ;
using NetMQ.Sockets;

class ZeroMQClientA
{
    static void Main(string[] args)
    {
        using (var dealerSocket = new DealerSocket(">tcp://localhost:5555"))
        {
            dealerSocket.Options.Identity = System.Text.Encoding.UTF8.GetBytes("ClientA1");
            Console.WriteLine("Client A1 đã kết nối với server...");
            
            string message = "Hello from ClientA1";
            dealerSocket.SendFrame(message);
            Console.WriteLine($"Đã gửi: {message}");
        }
    }
}
```

### Client B (Nhận thông điệp):

```csharp
using System;
using NetMQ;
using NetMQ.Sockets;

class ZeroMQClientB
{
    static void Main(string[] args)
    {
        using (var dealerSocket = new DealerSocket(">tcp://localhost:5555"))
        {
            dealerSocket.Options.Identity = System.Text.Encoding.UTF8.GetBytes("ClientB1");
            Console.WriteLine("Client B1 đã kết nối với server...");
            
            var message = dealerSocket.ReceiveFrameString();
            Console.WriteLine($"Client B1 nhận được: {message}");
        }
    }
}
```

## 5. Chạy ứng dụng

* Chạy **Server** trước.
* Chạy **Client A1** để gửi thông điệp.
* Chạy **Client B1** để nhận thông điệp.
* Thử thêm nhiều cặp Client A2 - B2 theo cấu hình JSON.

## 6. Kết quả mong đợi

*   Server hiển thị log:

    ```bash
    Nhận từ ClientA1: Hello from ClientA1
    Chuyển tiếp đến ClientB1: Hello from ClientA1
    ```
*   Client B1 hiển thị:

    ```bash
    Client B1 nhận được: Hello from ClientA1
    ```

## 7. Tổng kết

Bài viết này đã hướng dẫn bạn cách xây dựng một [**ZeroMQ server trong .NET 8**](xay-dung-zeromq-server-trong-dotnet-8-voi-csharp.md) với C#, sử dụng **Router-Dealer** để định tuyến thông điệp giữa các cặp Client A - Client B độc lập. Bạn có thể mở rộng thêm bằng cách:

* Hỗ trợ nhiều cổng khác nhau trong cấu hình.
* Thêm các lớp bảo mật như xác thực client.
* Ghi log và lưu trữ trạng thái tin nhắn vào database.

Hy vọng bài viết giúp bạn triển khai ZeroMQ hiệu quả trong ứng dụng của mình! 🚀
