# DocFX - Hướng dẫn cấu hình file docfx.json

## **Giới thiệu**

File cấu hình `docfx.json` là thành phần trung tâm trong DocFX, giúp xác định cách tài liệu được xây dựng và xuất ra. Bài viết này sẽ hướng dẫn chi tiết các cấu hình trong `docfx.json`, giúp bạn tùy chỉnh dự án DocFX phù hợp với nhu cầu của mình.

***

## **1. Cấu trúc cơ bản của file docfx.json**

Dưới đây là một mẫu file `docfx.json` cơ bản:

```json
{
  "metadata": [],
  "build": {}
}
```

* **metadata**: Phần cấu hình để tạo metadata từ mã nguồn .NET (C#, VB.NET).
* **build**: Phần cấu hình để xây dựng nội dung tài liệu.

***

## **2. Cấu hình metadata**

### **Sử dụng metadata để tạo tài liệu API từ mã nguồn .NET.**

Ví dụ:

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": ["**/*.csproj"],
          "exclude": ["bin/**", "obj/**"]
        }
      ],
      "dest": "api",
      "properties": {
        "TargetFramework": "net6.0"
      }
    }
  ]
}
```

### **Giải thích các trường:**

* **files**: Chỉ định các file nguồn (vd: `.csproj` hoặc `.dll`).
* **exclude**: Loại trừ các thư mục/file không cần thiết.
* **dest**: Thư mục đầu ra của metadata.
* **properties**: Cung cấp các thuộc tính bổ sung (như framework mục tiêu).

***

## **3. Cấu hình build**

### **Sử dụng build để xây dựng tài liệu từ Markdown và metadata.**

Ví dụ:

```json
{
  "build": {
    "sitemap": {
      "baseUrl": "",
      "priority": 0.1,
      "changefreq": "monthly"
    },
    "content": [
      {
        "files": ["articles/**/*.md", "toc.yml"]
      },
      {
        "files": ["api/**.yml"]
      }
    ],
    "dest": "_site",
    "globalMetadata": {
      "_enableSearch": true,
      "_appTitle": "Tài liệu dự án của tôi",
      "_pdfTitle": "Tài liệu PDF"
    },
    "overwrite": ["overwrite/**/*.md"],
    "externalReference": ["xref/*.yml"],
    "template": ["default"],
    "postProcessors": ["ExtractSearchIndex"]
  }
}
```

### **Giải thích các trường:**

1. **content**:
   * Chỉ định các file nội dung để xây dựng tài liệu.
   * Hỗ trợ Markdown (`.md`), YAML (`.yml`), và tài liệu API.
2. **dest**:
   * Thư mục xuất tài liệu sau khi build (ví dụ: `_site`).
3. **globalMetadata**:
   * Thêm các thông tin meta toàn cầu, chẳng hạn như tiêu đề trang (`_appTitle`) hoặc bật tìm kiếm (`_enableSearch`).
4. **overwrite**:
   * Cho phép ghi đè nội dung metadata bằng các file Markdown.
5. **externalReference**:
   * Thêm liên kết ngoài đến tài liệu hoặc API khác.
6. **template**:
   * Sử dụng template để tùy chỉnh giao diện tài liệu (ví dụ: `default`).
7. **postProcessors**:
   * Chạy các tác vụ xử lý sau khi build (vd: tạo index tìm kiếm).

***

## **4. Tùy chỉnh nâng cao**

### **4.1. Tạo PDF**

Nếu muốn xuất tài liệu dưới dạng PDF, thêm cấu hình:

```json
{
  "pdf": {
    "content": [
      {
        "files": ["articles/**/*.md"]
      }
    ],
    "dest": "_pdf",
    "globalMetadata": {
      "_pdfTitle": "Tài liệu PDF"
    }
  }
}
```

### **4.2. Đa ngôn ngữ**

DocFX hỗ trợ tạo tài liệu đa ngôn ngữ:

```json
{
  "build": {
    "locales": ["en-us", "vi-vn"],
    "content": [
      {
        "files": ["articles/**/en-us/*.md"],
        "locale": "en-us"
      },
      {
        "files": ["articles/**/vi-vn/*.md"],
        "locale": "vi-vn"
      }
    ],
    "dest": "_site"
  }
}
```

### **4.3. Bật tìm kiếm**

Tìm kiếm có thể được bật bằng cách thêm metadata toàn cầu:

```json
{
  "build": {
    "globalMetadata": {
      "_enableSearch": true
    }
  }
}
```

***

## **5. Tích hợp với GitHub Pages**

Nếu muốn xuất tài liệu lên **GitHub Pages:**

1.  Thêm trường `output`:

    ```json
    {
      "build": {
        "dest": "docs"
      }
    }
    ```


2. Push thư mục `docs` lên nhánh `gh-pages`.

***

## **6. Lợi ích của việc sử dụng docfx.json**

* **Linh hoạt**: Bạn có thể cấu hình cho nhiều loại tài liệu khác nhau.
* **Mở rộng dễ dàng**: Hỗ trợ thêm metadata, ghi đè nội dung, và tích hợp API.
* **Tích hợp sâu với .NET**: Tự động tạo tài liệu API từ mã nguồn.

***

## **7. Tài liệu tham khảo**

```markdown
- [Tài liệu chính thức về cấu hình DocFX](https://dotnet.github.io/docfx/docs/config.html)
- [GitHub DocFX](https://github.com/dotnet/docfx)
```



***

## **Kết luận**

Cấu hình `docfx.json` là bước quan trọng để tận dụng tối đa sức mạnh của DocFX. Với bài viết này, bạn đã nắm được cách thiết lập file cấu hình cơ bản và nâng cao. Hãy thử tùy chỉnh `docfx.json` và áp dụng vào dự án của bạn ngay hôm nay!

Nếu bạn có thắc mắc, hãy để lại bình luận hoặc liên hệ để được hỗ trợ! 😊
