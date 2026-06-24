# Hướng dẫn xây dựng ứng dụng web bằng ASP.NET Core và Blazor trên nền .NET 8 LTS

## Tại sao chọn .NET 8 LTS?

.NET 8 được công bố vào tháng 11 năm 2023 và là phiên bản Long‑Term Support (LTS) mới nhất của nền tảng .NET. Theo chính sách hỗ trợ của Microsoft, các bản phát hành LTS được bảo đảm cập nhật và sửa lỗi miễn phí trong ba năm, trong khi các bản Standard Term Support (STS) chỉ được hỗ trợ 18 tháng. Microsoft cũng duy trì chu kỳ phát hành hàng năm; các phiên bản có số chẵn (như .NET 8) là LTS nên phù hợp cho các dự án cần độ ổn định lâu dài.

Ngoài bảo đảm hỗ trợ lâu dài, .NET 8 còn mang lại nhiều cải tiến về hiệu năng và công cụ. Bản phát hành này giới thiệu trình biên dịch **Dynamic Profile‑Guided Optimisation (PGO)** giúp tối ưu mã dựa trên dữ liệu chạy thực tế, giúp các API JSON tăng tới 18 % hiệu suất và kịch bản phức tạp như Fortunes tăng tới 24 %. Bản phát hành cũng bổ sung chế độ biên dịch Ahead‑of‑Time (AOT), hỗ trợ container gọn nhẹ và các công cụ phát triển mới. Đặc biệt, Blazor trong .NET 8 trở thành framework giao diện người dùng **full stack** – có thể kết hợp cả Blazor Server và Blazor WebAssembly trong cùng một ứng dụng.

## Chuẩn bị môi trường

1. **Cài .NET 8 SDK (LTS)** – tải bộ cài từ trang chủ `.NET` và cài đặt đúng phiên bản cho hệ điều hành của bạn. Kiểm tra bằng lệnh `dotnet --version` để chắc chắn đã cài đặt thành công.
2. **IDE/Editor** – Visual Studio 2022 (v17.8 trở lên) hoặc Visual Studio Code kèm các extension C#. Visual Studio mang lại trải nghiệm hoàn chỉnh, còn VS Code phù hợp nếu bạn cần công cụ nhẹ hoặc muốn làm việc đa nền tảng.

## Tạo dự án Blazor trên .NET 8

### 1. Mô hình dự án mới – **Blazor Web App**

Trong .NET 8, Microsoft thống nhất các mẫu dự án Blazor thành một **Blazor Web App** duy nhất. Mẫu này kết hợp ưu điểm của Blazor Server và Blazor WebAssembly, đồng thời hỗ trợ **server‑side rendering tĩnh**, **rendering tương tác trên server**, **rendering tương tác bằng WebAssembly** và **chế độ Auto**. Các mẫu cũ như _Blazor Server_ và tuỳ chọn _ASP.NET Core Hosted_ trong Blazor WebAssembly đã bị loại bỏ, tuy nhiên các ứng dụng cũ vẫn được hỗ trợ trong .NET 8.

Để tạo dự án:

* **Visual Studio** – chọn **Create a new project → Blazor Web App**. Điền tên dự án và chọn kiểu rendering mặc định (Static, Interactive Server, Interactive WebAssembly hoặc Auto).
*   **CLI** – dùng lệnh:

    ```bash
    bashSao chépChỉnh sửadotnet new blazorwebapp -n MyBlazorApp
    ```

    Tham số `--hosted` không còn cần thiết vì mô hình mới đã hỗ trợ cả client và server.

### 2. Các chế độ rendering trong Blazor Web App

| Chế độ                                              | Mô tả & đặc điểm chính                                                                                                                                                                  |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Static server‑side rendering (Static SSR)**       | Tạo HTML tĩnh trên server, phù hợp cho SEO và tốc độ tải lần đầu. Không có tương tác phía client cho tới khi bật chế độ tương tác.                                                      |
| **Interactive Server (interactive SSR)**            | Thành phần được render trên server và duy trì kết nối thời gian thực bằng SignalR. Mọi sự kiện trên giao diện được gửi qua kết nối này và phản hồi lập tức.                             |
| **Interactive WebAssembly (Client‑side rendering)** | Toàn bộ .NET runtime và gói ứng dụng được tải xuống trình duyệt. Ứng dụng chạy trên client nên giảm tải cho server và hỗ trợ làm việc ngoại tuyến, nhưng thời gian tải ban đầu dài hơn. |
| **Interactive Auto**                                | Lần đầu dùng rendering server, sau đó tải gói WebAssembly và chuyển sang chạy client trong các lần truy cập tiếp theo. Giúp khởi động nhanh và tận dụng ưu điểm cả hai mô hình.         |

Chọn chế độ thích hợp phụ thuộc vào nhu cầu: SSR tĩnh cho nội dung SEO cao, Interactive Server cho ứng dụng phụ thuộc server và cập nhật thời gian thực, Interactive WebAssembly cho khả năng chạy offline hoặc tải trọng server thấp, và Auto khi muốn trải nghiệm cân bằng.

### 3. Dự án WebAssembly hoặc Blazor Server cũ

Nếu vẫn muốn tạo dự án riêng biệt như các phiên bản trước, có thể sử dụng lệnh:

*   **WebAssembly (client)**:

    ```bash
    bashSao chépChỉnh sửadotnet new blazorwasm -n MyBlazorClientApp
    ```
*   **Server**:

    ```bash
    bashSao chépChỉnh sửadotnet new blazorserver -n MyBlazorServerApp
    ```

Tuy nhiên, Microsoft khuyến khích chuyển sang mẫu Blazor Web App để tận dụng khả năng hợp nhất và nâng cấp dễ dàng.

## Cấu trúc dự án và xây dựng giao diện

Trong một dự án Blazor:

* **`App.razor`** định nghĩa router và layout chung: sử dụng `<Router AppAssembly="@typeof(Program).Assembly">` để ánh xạ các route tới component.
* **Thư mục `Pages`** chứa các trang `.razor` định tuyến với `@page "/route"`.
* **Thư mục `Shared`** chứa các component dùng chung như header, footer.
* **`wwwroot`** lưu trữ tệp tĩnh (CSS, ảnh, JS).

### Viết Razor Component

Component được viết trong các file `.razor` chứa markup HTML và mã C#. Ví dụ trang đếm số đơn giản:

```razor
razorSao chépChỉnh sửa@page "/counter"
<h3>Counter</h3>
<p>Current count: @currentCount</p>
<button @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;
    private void IncrementCount()
    {
        currentCount++;
    }
}
```

Thuộc tính `@page "/counter"` xác định route, trong khi `@onclick="IncrementCount"` liên kết sự kiện click với hàm C# `IncrementCount`. Razor cho phép trộn lẫn C# và HTML một cách linh hoạt, đồng thời hỗ trợ binding dữ liệu hai chiều, validation, và component hóa.

### Điều hướng và cải tiến trong .NET 8

Blazor sử dụng thành phần `Router` để điều hướng. .NET 8 bổ sung cơ chế **enhanced navigation and form handling**: khi người dùng chuyển trang hoặc gửi form, Blazor có thể chặn yêu cầu, thực hiện yêu cầu qua `fetch` và cập nhật DOM mà không tải lại toàn bộ trang. Tính năng này giúp trải nghiệm mượt mà hơn, đồng thời hỗ trợ `NavigationManager.Refresh()` để làm mới trang hiện tại.

## Kết nối cơ sở dữ liệu với Entity Framework Core

### Cấu hình DbContext

Entity Framework Core (EF Core) cung cấp đối tượng `DbContext` làm cầu nối giữa ứng dụng và cơ sở dữ liệu. Trong ASP.NET Core, đăng ký `DbContext` thông qua phương thức `AddDbContext` sẽ tạo một instance cho mỗi yêu cầu. Ví dụ cấu hình trong `Program.cs`:

```csharp
csharpSao chépChỉnh sửavar connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
```

Đoạn mã trên đọc chuỗi kết nối từ cấu hình và đăng ký `ApplicationDbContext` như dịch vụ có phạm vi (scoped); ngữ cảnh này sử dụng provider SQL Server. Lớp `ApplicationDbContext` cần có constructor nhận `DbContextOptions<ApplicationDbContext>` và kế thừa `DbContext`.

> **Lưu ý:** Blazor WebAssembly chạy trong sandbox của trình duyệt và không thể kết nối trực tiếp tới cơ sở dữ liệu; bạn cần gọi API hoặc sử dụng phần server của mô hình Blazor Web App để truy cập dữ liệu. Microsoft khuyến cáo chỉ sử dụng EF Core trong Blazor Server hoặc trong phần `Server` của dự án được host.

### Tạo migration và cập nhật DB

Sau khi cấu hình `DbContext` và các entity, chạy các lệnh sau để tạo migration và cập nhật cơ sở dữ liệu:

```bash
bashSao chépChỉnh sửadotnet ef migrations add InitialCreate
dotnet ef database update
```

Kết quả sẽ tạo bảng tương ứng trong cơ sở dữ liệu và cập nhật schema mỗi khi có thay đổi.

## Triển khai ứng dụng

### Deploy lên Azure App Service

1. Đăng nhập Azure và tạo một **App Service** phù hợp (.NET 8).
2. Trong Visual Studio, chọn **Publish → Azure → App Service**.
3. Cấu hình tên, vùng và kết nối. Visual Studio sẽ xây dựng, xuất bản và cấu hình CI/CD nếu cần.

### Triển khai bằng Docker

Tạo file `Dockerfile` sử dụng image .NET 8 và publish ứng dụng ở chế độ Release:

```dockerfile
dockerfileSao chépChỉnh sửaFROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyBlazorApp.dll"]
```

Dùng lệnh:

```bash
bashSao chépChỉnh sửadocker build -t myblazorapp .
docker run -d -p 80:80 myblazorapp
```

để xây image và chạy container. .NET 8 hỗ trợ xuất bản image không cần Dockerfile và thêm người dùng không root để tăng bảo mật.

## Tính năng nâng cao và thực hành tốt

* **Xác thực & phân quyền** – ASP.NET Core 8 cung cấp UI Identity dựa trên Blazor và cookie authentication sẵn sàng dùng. Bạn có thể tích hợp Identity hoặc xác thực bên ngoài (Google, Facebook).
* **SignalR** – Sử dụng để xây dựng các tính năng thời gian thực như chat, thông báo. Blazor Server sử dụng SignalR để duy trì kết nối, giúp việc tích hợp dễ dàng.
* **JavaScript Interop** – Khi cần sử dụng thư viện JavaScript, Blazor cho phép gọi JS từ C# và ngược lại.
* **Antiforgery** – .NET 8 bổ sung thẻ `AntiforgeryToken` và thuộc tính `[RequireAntiforgeryToken]` để bảo vệ form khỏi tấn công CSRF.
* **Hiệu năng** – Sử dụng Static SSR cho các trang ít tương tác để tận dụng khả năng cache, chuyển sang Interactive khi cần. Tận dụng `InteractiveAuto` để tối ưu trải nghiệm người dùng.

## Kết luận

Blazor và ASP.NET Core trong .NET 8 LTS mang lại bước tiến lớn: **giao diện full stack thống nhất**, lựa chọn linh hoạt giữa server và WebAssembly, kèm theo hiệu năng và bảo mật được cải thiện mạnh mẽ. Việc Microsoft đưa ra chính sách hỗ trợ ba năm cho LTS giúp các nhà phát triển như bạn yên tâm xây dựng những sản phẩm dài hạn. Trong khi đó, những cải tiến về rendering, form handling, EF Core và công cụ triển khai mở ra nhiều cơ hội sáng tạo.

Hãy bắt đầu với dự án đầu tiên của bạn bằng .NET 8, tận dụng Blazor Web App để khai thác sức mạnh full stack, và chia sẻ trải nghiệm của bạn cùng cộng đồng. Tin chắc rằng nền tảng này sẽ giúp các ứng dụng web của bạn không chỉ **ổn định và bền vững** mà còn **đột phá và khác biệt** trong tương lai.
