# Playwright: Tự Động Hóa Trình Duyệt Hiệu Quả

## Giới thiệu về Playwright

Playwright là một thư viện tự động hóa trình duyệt mạnh mẽ, hỗ trợ nhiều trình duyệt như Chromium, Firefox và WebKit. Được phát triển bởi Microsoft, Playwright giúp kiểm thử end-to-end (E2E) một cách hiệu quả, ổn định và dễ dàng tích hợp vào các quy trình CI/CD.

## Vì sao nên chọn Playwright?

### Ưu điểm:

* **Hỗ trợ đa trình duyệt**: Chạy thử nghiệm trên Chromium, Firefox và WebKit với một API duy nhất.
* **Tự động hóa mạnh mẽ**: Hỗ trợ các thao tác như nhập liệu, click chuột, chụp màn hình và kiểm tra trạng thái trang.
* **Độ tin cậy cao**: Playwright xử lý tốt các tình huống tải chậm, tương tác bất đồng bộ.
* **Tích hợp CI/CD dễ dàng**: Hỗ trợ chạy trên Docker, GitHub Actions, Azure DevOps và nhiều nền tảng khác.
* **Hỗ trợ nhiều ngôn ngữ**: Ngoài .NET, Playwright còn hỗ trợ JavaScript, Python, Java.

### Nhược điểm:

* **Cấu hình ban đầu phức tạp**: Cần thiết lập môi trường trước khi sử dụng.
* **Tài nguyên tiêu thụ cao**: Chạy trình duyệt thực tế có thể tốn tài nguyên hơn so với các giải pháp kiểm thử đơn giản khác.

## Cài đặt Playwright cho .NET

### Yêu cầu hệ thống:

* .NET 6.0 trở lên
* Hệ điều hành Windows, Linux hoặc macOS

### Cài đặt:

Sử dụng lệnh sau để cài đặt Playwright trong dự án .NET:

```bash
 dotnet add package Microsoft.Playwright
```

Sau đó, tải xuống các trình duyệt cần thiết:

```bash
 dotnet playwright install
```

## Viết một bài kiểm thử cơ bản với Playwright

Dưới đây là một ví dụ kiểm thử trang Google với Playwright trong .NET:

```csharp
using Microsoft.Playwright;
using System;
using System.Threading.Tasks;

class Program
{
    public static async Task Main()
    {
        using var playwright = await Playwright.CreateAsync();
        await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions { Headless = false });
        var context = await browser.NewContextAsync();
        var page = await context.NewPageAsync();

        await page.GotoAsync("https://www.google.com");
        await page.FillAsync("input[name='q']", "Playwright for .NET");
        await page.PressAsync("input[name='q']", "Enter");
        await page.ScreenshotAsync(new PageScreenshotOptions { Path = "screenshot.png" });

        Console.WriteLine("Kiểm thử hoàn tất!");
    }
}
```

## Tích hợp Playwright vào CI/CD

Playwright hỗ trợ tích hợp vào các pipeline CI/CD như GitHub Actions, Azure DevOps và Jenkins. Ví dụ, tích hợp với GitHub Actions:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '6.0'
      - name: Install dependencies
        run: dotnet restore
      - name: Install Playwright
        run: dotnet playwright install
      - name: Run tests
        run: dotnet test
```

## Kết luận

Playwright là một công cụ tự động hóa trình duyệt mạnh mẽ và linh hoạt, phù hợp cho cả kiểm thử chức năng và UI. Với khả năng hỗ trợ đa trình duyệt, tích hợp CI/CD dễ dàng và API thân thiện, Playwright là một lựa chọn hàng đầu cho kiểm thử end-to-end.
