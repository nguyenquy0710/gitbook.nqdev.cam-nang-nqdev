# DocFX - Hướng dẫn cài đặt, cấu hình sử dụng

## **Giới thiệu**

**DocFX** là công cụ mạnh mẽ để tạo tài liệu API và tài liệu website tĩnh từ Markdown. Để tăng hiệu quả, việc sử dụng script batch giúp tự động hóa quá trình build và quản lý tài liệu trở nên dễ dàng hơn. Trong bài viết này, bạn sẽ học cách cài đặt, cấu hình, khởi tạo DocFX và sử dụng script batch để build nhanh chóng.

***

## **1. Cài đặt DocFX**

### **Bước 1: Tải về và cài đặt**

1. Truy cập [GitHub DocFX](https://github.com/dotnet/docfx).
2. Tải phiên bản mới nhất từ [release](https://github.com/dotnet/docfx/releases).
3. Giải nén file `.zip` và thêm thư mục chứa DocFX vào biến môi trường `PATH`.

### **Bước 2: Kiểm tra cài đặt**

Mở terminal/cmd và chạy lệnh:

```bash
docfx --version
```

Nếu hiển thị phiên bản, DocFX đã được cài đặt thành công.

***

## **2. Khởi tạo dự án DocFX**

### **Tạo cấu trúc dự án DocFX**

1.  Trong thư mục dự án, chạy lệnh:

    ```bash
    docfx init
    ```


2. Lệnh này tạo ra file `docfx.json` và các thư mục cần thiết:
   * `api/`
   * `articles/`
   * `toc.yml`

### **Tùy chỉnh file `docfx.json`**

Cập nhật file `docfx.json` để chỉ định nguồn tài liệu và output:

{% embed url="https://gist.github.com/nguyenquy0710/d2cc3c428cde37c09be5e1ea3c58d8b4" %}
[**docfx.json**](https://gist.github.com/nguyenquy0710/d2cc3c428cde37c09be5e1ea3c58d8b4#file-docfx-json)
{% endembed %}



***

## **3. Sử dụng file batch tự động hóa**

### **Nội dung file batch `docfx-build.bat`**

File batch tự động hóa quá trình build DocFX, serve tài liệu, và tích hợp Git. Dưới đây là nội dung chính:

1. **Biến cấu hình**:
   * `PROJECT_DIR`: Thư mục hiện tại.
   * `CONFIG_PATH`: Đường dẫn file `docfx.json`.
   * `OUTPUT_DIR`: Thư mục chứa tài liệu sau khi build.
2. **Lệnh chính**:
   * `--build`: Build tài liệu.
   * `--serve`: Khởi chạy tài liệu trên trình duyệt.
   * `--git`: Commit và push tài liệu lên Git.

### **Nội dung tệp mẫu:**

{% embed url="https://gist.github.com/nguyenquy0710/7b4598ea2e22cea6f8c4d4005df7e1ee" %}
[**docfx-build.bat**](https://gist.github.com/nguyenquy0710/7b4598ea2e22cea6f8c4d4005df7e1ee#file-docfx-build-bat)
{% endembed %}

### Ví dụ sử dụng:

<pre class="language-batch" data-title="cmd.exe" data-overflow="wrap"><code class="lang-batch">:: use --help
PS D:\vihat\quynh\template\template_dotnet8> <a data-footnote-ref href="#user-content-fn-1">.\docfx-build.bat --help</a>
Chuyen den nhan thu 1: --help
-----------------------------------------------------------
File script: docfx-build.bat
Ngay tao: 11/12/2024
Tac gia: [Nguyen Quy](quynh@vihatgroup.com)
-----------------------------------------------------------
Huong dan su dung script batch:
1. Build tai lieu DocFX:
   docfx-build.bat --build
2. Build tai lieu va commit push (Git nhanh main/ develop):
   docfx-build.bat --build --git
3. Build va serve tai lieu (mo trinh duyet):
   docfx-build.bat --build --serve
4. Serve tai lieu (mo trinh duyet):
   docfx-build.bat --serve
5. Hien thi huong dan su dung:
   docfx-build.bat --help
-----------------------------------------------------------


</code></pre>



***

## **4. Cách sử dụng script**

1.  **Build tài liệu**: Chạy lệnh:

    ```bash
    docfx-build.bat --build
    ```

    Tài liệu sẽ được xuất ra thư mục `artifacts/docfx`.
2.  **Serve tài liệu trên trình duyệt**: Chạy lệnh:

    ```bash
    docfx-build.bat --serve
    ```


3.  **Hỗ trợ Git**: Nếu file batch có tích hợp Git, bạn có thể sử dụng:

    ```bash
    docfx-build.bat --build --git
    ```


4.  **Xem hướng dẫn**:

    ```bash
    docfx-build.bat --help
    ```



***

## **5. Lợi ích khi sử dụng script**

* **Tự động hóa**: Giảm thao tác thủ công.
* **Tích hợp Git**: Đảm bảo tài liệu luôn được cập nhật trên repository.
* **Dễ dàng mở rộng**: Thêm các chức năng khác như kiểm tra lỗi, nén tài liệu, v.v.

***

## **Kết luận**

Sử dụng DocFX cùng script batch là cách tuyệt vời để quản lý tài liệu cho các dự án .NET. Hy vọng bài viết đã cung cấp cho bạn kiến thức cần thiết để triển khai DocFX hiệu quả trong dự án của mình.

**Hãy thử ngay và chia sẻ trải nghiệm của bạn!**

***

Nếu bạn có thắc mắc hoặc cần thêm hỗ trợ, đừng ngần ngại để lại bình luận. 😊 ​



[^1]: 
