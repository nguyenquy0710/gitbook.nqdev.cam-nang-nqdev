---
description: >-
  DocFX là công cụ mạnh mẽ để tạo tài liệu tĩnh (static documentation) và tài
  liệu API tự động.
---

# Những khái niệm cơ bản trong DocFX

Hiểu rõ các khái niệm cơ bản của DocFX sẽ giúp bạn sử dụng nó một cách hiệu quả hơn trong các dự án của mình. Bài viết này sẽ giải thích các thành phần quan trọng của DocFX và cách chúng phối hợp với nhau.

## Tóm tắt

DocFX là công cụ mạnh mẽ giúp bạn tạo tài liệu cho các dự án .NET với nhiều tính năng vượt trội:

* Hỗ trợ Markdown để viết tài liệu tĩnh.
* Tự động tạo tài liệu API từ code.
* Dễ dàng tùy chỉnh giao diện và tích hợp vào CI/CD.

***

## **1. Tài liệu tĩnh (Static Content)**

DocFX cho phép bạn sử dụng các file Markdown (`*.md`) để tạo nội dung tài liệu. Đây là các file bạn viết thủ công và chứa nội dung như hướng dẫn sử dụng, ghi chú kỹ thuật hoặc bất kỳ tài liệu nào bạn muốn hiển thị trên website.

### **Cách sử dụng:**

* Đặt các file Markdown trong thư mục nội dung, ví dụ: `articles/` hoặc `docs/`.
* DocFX sẽ chuyển đổi chúng thành các trang HTML tĩnh trong quá trình build.

### **Lợi ích:**

* Markdown dễ viết, dễ đọc, và hỗ trợ nhiều cú pháp linh hoạt.
* Có thể nhúng hình ảnh, mã code, và liên kết nội bộ.

***

## **2. Tài liệu API (API Documentation)**

Tính năng nổi bật của DocFX là khả năng tự động tạo tài liệu API từ code hoặc file XML comments. Điều này đặc biệt hữu ích khi làm việc với các dự án .NET.

### **Quy trình tạo tài liệu API:**

1. **Tạo metadata**: DocFX đọc file `*.csproj` hoặc `*.dll` trong dự án của bạn để tạo metadata cho API.
2. **Sinh tài liệu**: Từ metadata, DocFX tạo ra các trang mô tả từng class, method, property, và event trong API.

### **Lợi ích:**

* Tự động hóa tài liệu API, giúp tiết kiệm thời gian.
* Tài liệu luôn đồng bộ với mã nguồn.
* Dễ dàng tích hợp vào quy trình CI/CD.

***

## **3. File cấu hình (docfx.json)**

File `docfx.json` là trung tâm quản lý cấu hình của DocFX. Nó định nghĩa các thông tin như:

* Vị trí lưu file Markdown và tài liệu API.
* Cài đặt cho quá trình build và phục vụ.
* Các tùy chỉnh giao diện và template.

### **Ví dụ file docfx.json:**

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
        ],
        "dest": "_site"
    }
}
```
{% endcode %}

### **Các phần quan trọng:**

* `metadata`: Chỉ định nơi DocFX sẽ tìm kiếm các file mã nguồn để tạo tài liệu API.
* `build`: Định nghĩa nơi lưu nội dung và thư mục đầu ra.

***

## **4. Giao diện (Templates)**

DocFX hỗ trợ các template để tùy chỉnh giao diện của trang tài liệu. Bạn có thể:

* Sử dụng template mặc định.
* Tạo template tùy chỉnh theo nhu cầu.
* Sử dụng các extension để mở rộng chức năng.

### **Tùy chỉnh template:**

* Templates được lưu trong thư mục `templates/`.
* Có thể sửa đổi CSS, HTML để thay đổi giao diện hoặc thêm các tính năng mới.

***

## **5. Quy trình build**

Quá trình build của DocFX bao gồm 3 bước chính:

1. **Tạo metadata**:
   * Đọc file cấu hình `docfx.json` để tạo thông tin về tài liệu API.
2. **Chuyển đổi nội dung**:
   * Biến các file Markdown thành HTML.
   * Kết hợp metadata để tạo tài liệu API.
3. **Xuất kết quả**:
   * Tạo các file HTML tĩnh trong thư mục đầu ra (thường là `_site`).

### **Cách thực hiện:**

* Sử dụng lệnh `docfx build` để thực hiện quá trình này.
* Kết quả có thể được phục vụ thông qua một server hoặc đẩy lên các dịch vụ như GitHub Pages.

***

## **6. Phục vụ tài liệu (Serve Documentation)**

Sau khi build, bạn có thể kiểm tra tài liệu của mình bằng cách chạy server nội bộ:

```bash
docfx serve _site
```

* Server chạy ở `http://localhost:8080` (có thể tùy chỉnh cổng).
* Thích hợp cho việc kiểm tra trước khi triển khai chính thức.

***

## **7. Tích hợp CI/CD**

DocFX dễ dàng tích hợp vào các pipeline CI/CD để tự động build và triển khai tài liệu. Ví dụ:

* **GitHub Actions**: Thiết lập workflow để build và đẩy tài liệu lên GitHub Pages.
* **Azure DevOps**: Tích hợp vào pipeline để triển khai tự động.

***

Với sự hỗ trợ đa nền tảng và khả năng mở rộng, DocFX là lựa chọn lý tưởng cho các dự án cần tài liệu chuyên nghiệp. Hãy bắt đầu với DocFX ngay hôm nay và biến tài liệu của bạn trở nên dễ dàng hơn bao giờ hết!

Nếu có thắc mắc, hãy để lại bình luận để trao đổi thêm nhé! 😊
