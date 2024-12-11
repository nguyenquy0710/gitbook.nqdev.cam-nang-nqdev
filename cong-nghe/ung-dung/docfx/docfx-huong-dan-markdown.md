---
description: >-
  Markdown là một ngôn ngữ đánh dấu đơn giản, được sử dụng rộng rãi để tạo tài
  liệu văn bản dễ đọc và dễ viết.
---

# DocFX - Hướng dẫn Markdown

## **Giới thiệu**

Trong [**DocFX**](./), Markdown là thành phần cốt lõi, giúp bạn viết nội dung tài liệu nhanh chóng với các tính năng mở rộng mạnh mẽ. Bài viết này sẽ hướng dẫn bạn cách sử dụng Markdown trong DocFX, bao gồm các cú pháp cơ bản, các mở rộng hỗ trợ và cách tùy chỉnh.

***

## **1. Markdown cơ bản**

**Các cú pháp Markdown phổ biến:**

1.  **Tiêu đề**:

    ```markdown
    # Tiêu đề 1
    ## Tiêu đề 2
    ### Tiêu đề 3
    ```



    Kết quả:

    ```markdown
    Tiêu đề 1
    Tiêu đề 2
    Tiêu đề 3
    ```


2.  **In đậm và in nghiêng**:

    ```markdown
    **In đậm**
    *In nghiêng*
    ```

    Kết quả: **In đậm** và _In nghiêng_.
3. **Danh sách**:
   *   Danh sách không thứ tự:

       ```markdown
       - Mục 1
       - Mục 2
       ```


   *   Danh sách có thứ tự:

       ```markdown
       1. Mục 1
       2. Mục 2
       ```


4.  **Liên kết và hình ảnh**:

    ```markdown
    [Liên kết](https://example.com)
    ![Hình ảnh](https://example.com/image.png)
    ```


5.  **Khối mã**:

    ````markdown
    ```language
    Code block
    ````



***

## **2. Mở rộng Markdown trong DocFX**

DocFX hỗ trợ các mở rộng Markdown để cung cấp thêm nhiều tính năng.

### **2.1. Tab Group**

Sử dụng tab để hiển thị nội dung theo các tùy chọn khác nhau:

```markdown
# [Tab 1 Title](#tab/tab1)
Nội dung Tab 1

# [Tab 2 Title](#tab/tab2)
Nội dung Tab 2

# [Tab End](#tab/end)
```

### **2.2. Note (Chú thích)**

Hiển thị các ghi chú dạng cảnh báo, thông báo hoặc mẹo:

```markdown
> [!NOTE]
> Đây là ghi chú thông thường.

> [!WARNING]
> Đây là cảnh báo.

> [!TIP]
> Đây là một mẹo hay.
```

### **2.3. Liên kết chéo**

Dẫn liên kết giữa các trang hoặc tài liệu:

```markdown
[Liên kết đến trang khác](xref:uid_of_the_target)
```

### **2.4. Chèn hình ảnh và video**

Hỗ trợ nhúng hình ảnh:

```markdown
![Mô tả hình ảnh](image_url)
```

Và video:

```markdown
::: video
source: video_url
:::
```

### **2.5. Bảng (Table)**

Tạo bảng với Markdown:

```markdown
| Cột 1 | Cột 2 | Cột 3 |
|-------|-------|-------|
| Dữ liệu 1 | Dữ liệu 2 | Dữ liệu 3 |
```

***

## **3. Tùy chỉnh Markdown trong DocFX**

### **3.1. Sử dụng YAML Metadata**

YAML Metadata cho phép bạn thêm thông tin meta vào đầu file Markdown:

```markdown
---
uid: unique_identifier
title: Tiêu đề trang
description: Mô tả ngắn gọn
---
```

### **3.2. Cấu hình Markdown trong `docfx.json`**

Bạn có thể cấu hình Markdown trong DocFX bằng cách thêm phần `markdownEngine` vào file `docfx.json`:

```json
{
  "build": {
    "markdownEngineName": "dfm",
    "markdownEngineProperties": {
      "enableContentPlaceholder": true,
      "enableFileLinkPlaceholder": true
    }
  }
}
```

***

## **4. Kết hợp Markdown với tài liệu API**

**Markdown** trong DocFX không chỉ dùng cho nội dung tùy chỉnh mà còn có thể được tích hợp với tài liệu API để thêm giải thích hoặc ví dụ. Điều này giúp cải thiện chất lượng tài liệu và trải nghiệm người dùng.

Ví dụ, bạn có thể thêm các phần mở rộng Markdown vào tài liệu API:

```markdown
### [!NOTE]
Đây là tài liệu API được mở rộng với Markdown.
```

***

## **5. Tài nguyên hỗ trợ**

Để hiểu rõ hơn về Markdown trong DocFX, bạn có thể tham khảo thêm:

```markdown
- [Tài liệu Markdown chính thức của DocFX](https://dotnet.github.io/docfx/docs/markdown.html)
- [Hướng dẫn Markdown cơ bản](https://www.markdownguide.org/)
```



***

## **Kết luận**

Markdown là công cụ đơn giản nhưng mạnh mẽ trong DocFX, giúp bạn tạo tài liệu chất lượng cao một cách nhanh chóng. Với các mở rộng và tùy chỉnh của DocFX, bạn có thể tận dụng Markdown để tăng tính chuyên nghiệp và dễ đọc của tài liệu.

Hãy thử sử dụng Markdown trong **DocFX** ngay hôm nay và chia sẻ trải nghiệm của bạn! 😊

***

Nếu bạn có câu hỏi hoặc cần hỗ trợ thêm, hãy để lại bình luận dưới bài viết nhé!
