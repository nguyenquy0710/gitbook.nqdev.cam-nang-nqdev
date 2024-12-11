# DocFX - Hướng dẫn sử dụng và tùy chỉnh Template

## **Giới thiệu**

Template trong DocFX là công cụ mạnh mẽ giúp bạn tùy chỉnh giao diện và cách hiển thị tài liệu của mình. DocFX hỗ trợ nhiều template mặc định và cho phép người dùng tùy chỉnh template theo nhu cầu. Trong bài viết này, chúng ta sẽ tìm hiểu cách sử dụng, tùy chỉnh và áp dụng template trong DocFX.

***

## **1. Template trong DocFX là gì?**

Template là một tập hợp các tệp HTML, CSS, JavaScript, và các tài nguyên khác, xác định cách trình bày nội dung tài liệu. DocFX cung cấp template mặc định và hỗ trợ xuất hoặc tạo template tùy chỉnh.

### **Các template phổ biến:**

* **Default**: Template mặc định, dễ sử dụng và phù hợp với hầu hết các dự án.
* **Custom**: Template tùy chỉnh do người dùng tự tạo hoặc sửa đổi.

***

## **2. Cách sử dụng template**

### **2.1. Áp dụng template mặc định**

Trong file `docfx.json`, bạn có thể chỉ định template cần sử dụng bằng cách thêm cấu hình:

```json
{
  "build": {
    "template": ["default"]
  }
}
```

### **2.2. Áp dụng nhiều template**

DocFX hỗ trợ áp dụng nhiều template theo thứ tự ưu tiên:

```json
{
  "build": {
    "template": ["custom-template", "default"]
  }
}
```

* Nếu không tìm thấy tệp trong `custom-template`, DocFX sẽ tự động sử dụng tệp từ template `default`.

***

## **3. Tùy chỉnh template**

DocFX cho phép bạn tùy chỉnh template để phù hợp với thương hiệu hoặc yêu cầu dự án.

### **3.1. Xuất template mặc định**

Để tùy chỉnh, bạn cần xuất template mặc định và chỉnh sửa:

```batch
docfx template export default
```

* Template sẽ được xuất vào thư mục `templates/default`.

### **3.2. Chỉnh sửa template**

Trong thư mục template, bạn có thể chỉnh sửa:

* **HTML**: Thay đổi cấu trúc giao diện.
* **CSS**: Tùy chỉnh màu sắc, font chữ, và phong cách.
* **JavaScript**: Thêm tính năng hoặc tương tác mới.

### **3.3. Áp dụng template tùy chỉnh**

Sau khi chỉnh sửa, áp dụng template bằng cách cấu hình:

```css
templates/
|-- default/
    |-- styles/        # Chứa file CSS
    |-- scripts/       # Chứa file JavaScript
    |-- partials/      # Các thành phần HTML tái sử dụng
    |-- layout.html    # Layout chính của trang
    |-- toc.html       # Giao diện Table of Contents
    |-- ...            # Các tệp khác
```

#### **Mô tả các thành phần chính:**

* **layout.html**: Tệp HTML chính quyết định bố cục chung.
* **partials/**: Chứa các phần giao diện có thể tái sử dụng, như header, footer.
* **styles/**: Tùy chỉnh giao diện bằng CSS.
* **scripts/**: Tích hợp các tính năng tương tác bằng JavaScript.

***

## **5. Tính năng nâng cao của template**

### **5.1. Hỗ trợ Data Binding**

DocFX hỗ trợ **Liquid template**, cho phép bạn sử dụng các biến và vòng lặp trong tệp HTML:

```liquid
{{ page.title }}  <!-- Hiển thị tiêu đề trang -->
{% raw %}
{% for item in model.items %}
    <a href="{{ item.href }}">{{ item.name }}</a>
{% endfor %}
{% endraw %}
```

### **5.2. Tích hợp Metadata**

Bạn có thể sử dụng metadata để tùy chỉnh nội dung hiển thị:

```liquid
{% raw %}
{% if model.metadata.language == "en" %}
    <p>This is an English page</p>
{% else %}
    <p>This is a localized page</p>
{% endif %}
{% endraw %}
```

### **5.3. Chạy Post Processor**

Bạn có thể thêm **Post Processor** để xử lý template sau khi build:

```json
{
  "build": {
    "postProcessors": ["CustomPostProcessor"]
  }
}
```

* Post Processor là script tùy chỉnh để sửa đổi output cuối cùng.

***

## **6. Mẹo tối ưu hóa khi tùy chỉnh template**

1. **Giữ nguyên backup template gốc**: Trước khi chỉnh sửa, luôn sao lưu template mặc định để tránh lỗi không mong muốn.
2. **Sử dụng CSS thay vì sửa HTML**: Hạn chế chỉnh sửa HTML trực tiếp, sử dụng CSS để giữ tính nhất quán.
3. **Kiểm tra tương thích**: Sau khi chỉnh sửa, kiểm tra trên nhiều trình duyệt để đảm bảo giao diện hoạt động tốt.

***

## **7. Kết hợp template với đa ngôn ngữ**

Nếu dự án hỗ trợ đa ngôn ngữ, bạn có thể tạo các file riêng cho mỗi ngôn ngữ trong template:

* Tạo các file như `layout.vi.html` hoặc `layout.en.html`.
* Sử dụng cấu hình ngôn ngữ trong `docfx.json`:

```json
{
  "build": {
    "locales": ["en-us", "vi-vn"]
  }
}
```

***

## **8. Tài nguyên tham khảo**

```markdown
- [Tài liệu chính thức về template DocFX](https://dotnet.github.io/docfx/docs/template.html)
- [Hướng dẫn tùy chỉnh giao diện]()
```



***

## **Kết luận**

Template trong DocFX là công cụ mạnh mẽ giúp bạn tạo ra tài liệu chuyên nghiệp và phù hợp với thương hiệu. Với bài viết này, bạn đã nắm được cách sử dụng và tùy chỉnh template để tạo ra các giao diện tài liệu độc đáo.

Nếu bạn có thắc mắc hoặc cần hỗ trợ thêm, hãy để lại bình luận bên dưới. Hãy thử ngay và chia sẻ kết quả của bạn nhé! 😊

