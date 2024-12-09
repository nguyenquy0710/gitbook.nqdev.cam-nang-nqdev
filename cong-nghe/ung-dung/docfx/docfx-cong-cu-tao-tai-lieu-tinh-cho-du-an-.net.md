---
description: >-
  DocFX là một công cụ mạnh mẽ được thiết kế để xây dựng tài liệu tĩnh (static
  documentation site) cho các dự án .NET.
---

# DocFX - Công cụ tạo tài liệu tĩnh cho dự án .NET

Đây là một giải pháp lý tưởng không chỉ để tạo tài liệu API tự động mà còn để xây dựng các tài liệu kỹ thuật hoặc hướng dẫn sử dụng cho dự án của bạn.

***

## **1. Tính năng nổi bật của DocFX**

* **Tài liệu API .NET tự động**:\
  DocFX có khả năng tự động tạo tài liệu API từ mã nguồn (source code) hoặc từ file XML comments (được tạo bởi trình biên dịch .NET).
* **Trang web tài liệu tĩnh**:\
  Bạn có thể sử dụng DocFX để chuyển đổi các file Markdown (_.md_) thành một trang web tài liệu tĩnh với giao diện hiện đại, dễ đọc.
* **Đa nền tảng**:\
  DocFX hỗ trợ cả Windows, macOS và Linux, giúp bạn linh hoạt sử dụng trong mọi môi trường phát triển.
* **Tích hợp tốt với .NET**:\
  DocFX tích hợp liền mạch với MSBuild và .NET CLI, giúp tối ưu hóa quy trình làm việc.
* **Khả năng mở rộng cao**:\
  DocFX hỗ trợ tùy chỉnh giao diện bằng các template và cung cấp khả năng mở rộng qua các extension.

***

## **2. Cách sử dụng nhanh DocFX**

### **Bước 1: Cài đặt**

Bạn có thể cài đặt DocFX theo các cách sau:

* Tải file thực thi từ [GitHub](https://github.com/dotnet/docfx).
* Sử dụng các công cụ như Chocolatey, Homebrew, hoặc Docker để cài đặt.

### **Bước 2: Cấu hình**

* Tạo một file cấu hình `docfx.json` để định nghĩa các thông tin cần thiết cho dự án tài liệu.
*   Ví dụ:

    {% code title="docfx.json" %}
    ```json
    {
        "metadata": [
            {
                "src": [
                    {
                        "files": [ "**/*.csproj" ],
                        "cwd": "src"
                    }
                ]
            }
        ],
        "build": {
            "content": [
                {
                    "files": [ "**/*.md" ]
                }
            ]
        }
    }
    ```
    {% endcode %}

### **Bước 3: Tạo tài liệu**

* Sử dụng lệnh `docfx build` để xây dựng tài liệu từ cấu hình.

### **Bước 4: Xem tài liệu**

* Chạy lệnh `docfx serve` để khởi chạy một server tạm thời, xem tài liệu qua trình duyệt tại `http://localhost:8080`.

***

## **3. Tích hợp với Git thông qua file script**

Để tự động hóa quá trình build tài liệu và đẩy lên Git repository, bạn có thể sử dụng file script `.bat` như sau:

{% code title="docfx-build.bat" overflow="wrap" %}
```shell
:: Lấy thời gian hiện tại từ hệ thống và định dạng lại thành YYYY-MM-DD
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set CURRENT_DAY=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%

:: Bước 1: Thực hiện build với DocFX
docfx build .\docfx-quyit\docfx.json --output .\docs --metadata _appTitle="QuyIT Platform" --exportRawModel true --exportViewModel true

:: Bước 2: Kiểm tra nhánh hiện tại trong Git
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set branch=%%b

:: Bước 3: Kiểm tra nếu nhánh là "main" hoặc "develop"
if "%branch%"=="main" goto gitPush
if "%branch%"=="develop" goto gitPush

:: Nếu không phải nhánh "main" hoặc "develop", bỏ qua lệnh git push và thông báo
echo "Current branch (%branch%) is not main or develop. Skipping git push."
goto gitEnd

:: Bước 4: Thực hiện lệnh Git push
:gitPush
call git add .
call git commit -m "%CURRENT_DAY%: deploy docfx"
call git push

:: Bước 5: Kết thúc script
:gitEnd
pause
```
{% endcode %}

### **Giải thích script:**

* **Bước 1**: Lệnh `docfx build` tạo tài liệu từ file cấu hình `docfx.json`.
* **Bước 2**: Kiểm tra nhánh hiện tại trong Git bằng lệnh `git rev-parse`.
* **Bước 3**: Chỉ thực hiện Git push khi nhánh là `main` hoặc `develop`.
* **Bước 4**: Thực hiện các lệnh Git để đẩy thay đổi lên remote repository.
* **Bước 5**: Tạm dừng script để kiểm tra kết quả.

***

## **4. Tài nguyên hữu ích**

* [**Kho mã nguồn trên GitHub**](https://github.com/dotnet/docfx):\
  Xem mã nguồn và báo cáo các vấn đề liên quan.
* [**Hướng dẫn nhanh**](https://dotnet.github.io/docfx/):\
  Bắt đầu sử dụng DocFX với các bước đơn giản.
* [**Tài liệu API**](https://dotnet.github.io/docfx/api/Docfx.html):\
  Tham khảo chi tiết về các API mà DocFX cung cấp.
* [**Hướng dẫn mở rộng và template**](https://dotnet.github.io/docfx/extensions/templates.html):\
  Cách tùy chỉnh và mở rộng giao diện tài liệu của bạn.

***

**DocFX** và script tự động hóa trên giúp bạn tiết kiệm thời gian, nâng cao hiệu quả trong việc quản lý tài liệu dự án. Nếu bạn đang phát triển các dự án .NET, đừng bỏ qua công cụ tuyệt vời này!

***

Hy vọng bài viết này sẽ giúp bạn áp dụng **DocFX** một cách hiệu quả. Nếu có câu hỏi, hãy để lại bình luận để trao đổi thêm! 😊
