---
description: >-
  Parallel Routes là một tính năng mạnh mẽ trong Next.js App Router, cho phép
  bạn định nghĩa và hiển thị nhiều route song song trong một ứng dụng.
---

# Parallel Routes trong Next.js

Tính năng này đặc biệt hữu ích khi bạn cần hiển thị nhiều nội dung hoặc giao diện trong cùng một cấp độ của giao diện người dùng, chẳng hạn như sidebar và nội dung chính.

{% code title="Tài liệu tham khảo:" overflow="wrap" lineNumbers="true" %}
```http
- https://nextjs.org/docs/app/building-your-application/routing/parallel-routes
```
{% endcode %}

<figure><img src="https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fparallel-routes.png&#x26;w=3840&#x26;q=75" alt=""><figcaption><p>parallel-routes</p></figcaption></figure>



***

## **Khái niệm chính**

Khi sử dụng **Parallel Routes**, bạn có thể định nghĩa các route song song bằng cách sử dụng cấu trúc thư mục và cách định danh trong Next.js. Điều này giúp bạn linh hoạt hơn trong việc tổ chức giao diện và quản lý trạng thái của các phần khác nhau trong ứng dụng.

Ví dụ: Một ứng dụng blog có thể sử dụng **Parallel Routes** để hiển thị:

* Một sidebar chứa danh sách bài viết.
* Một phần chính hiển thị nội dung bài viết chi tiết.

***

## **Cách hoạt động của Parallel Routes**

**Parallel Routes** dựa trên việc cấu hình các route song song thông qua việc sử dụng các tệp đặc biệt trong App Router của Next.js:

### **Thư mục định danh**

* Bạn sử dụng các thư mục có định danh để định nghĩa các route song song.
* Các thư mục này được đặt trong cấu trúc thư mục của **App Router** và được định nghĩa trong file layout hoặc page.

Ví dụ:

```bash
app/
  layout.js
  @sidebar/
    layout.js
    page.js
  @main/
    page.js
```

Trong cấu trúc trên:

* `@sidebar` đại diện cho khu vực sidebar.
* `@main` đại diện cho khu vực nội dung chính.

***

## **Triển khai Parallel Routes**

### **1. Cấu trúc thư mục**

Tạo các thư mục đại diện cho các khu vực giao diện mà bạn muốn render song song. Trong mỗi thư mục, bạn có thể sử dụng các file `layout.js`, `page.js`, hoặc `loading.js` để quản lý route.

### **2. Sử dụng layout để quản lý Parallel Routes**

Trong file `layout.js`, bạn có thể định nghĩa cách các route song song được hiển thị.

Ví dụ:

```jsx
// app/layout.js
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <div style={{ display: 'flex' }}>
          {children}
        </div>
      </body>
    </html>
  );
}
```

### **3. Kết hợp các khu vực song song**

Kết hợp các route song song bằng cách sử dụng `children` và props.

Ví dụ:

```jsx
// app/@sidebar/layout.js
export default function SidebarLayout({ children }) {
  return <aside>{children}</aside>;
}

// app/@sidebar/page.js
export default function Sidebar() {
  return <div>Danh sách bài viết</div>;
}

// app/@main/page.js
export default function MainContent() {
  return <div>Nội dung bài viết</div>;
}
```

Kết quả là giao diện sẽ hiển thị cả hai phần **Sidebar** và **Main Content** song song.

***

## **Lợi ích của Parallel Routes**

1. **Tăng tính linh hoạt**: Giúp bạn tổ chức và quản lý giao diện theo cách dễ dàng và rõ ràng hơn.
2. **Tối ưu hiệu năng**: Cho phép tải các phần của giao diện độc lập, giảm thời gian tải và cải thiện trải nghiệm người dùng.
3. **Hỗ trợ cấu trúc phức tạp**: Parallel Routes đặc biệt hữu ích khi bạn làm việc với giao diện có nhiều khu vực động, như ứng dụng quản lý, bảng điều khiển, hay blog.

***

## **Khi nào nên sử dụng Parallel Routes?**

* Khi giao diện của bạn cần hiển thị nhiều khu vực độc lập.
* Khi bạn cần quản lý trạng thái và logic của từng phần riêng biệt.
* Khi muốn tăng tốc độ tải trang bằng cách chia nhỏ giao diện thành các thành phần có thể tải riêng lẻ.

***

## **Kết luận**

**Parallel Routes** là một tính năng mạnh mẽ trong Next.js App Router, giúp bạn dễ dàng xây dựng các giao diện phức tạp, hiện đại và tối ưu hiệu năng. Với cách triển khai linh hoạt và khả năng mở rộng, Parallel Routes là một công cụ không thể thiếu cho các nhà phát triển Next.js.

Hãy tận dụng **Parallel Routes** để xây dựng ứng dụng web chuyên nghiệp, nhanh chóng và hiệu quả hơn!
