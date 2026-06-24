---
description: >-
  Đây là hai bộ giao diện quản trị (Admin Dashboard) miễn phí và mã nguồn mở,
  được phát triển trên nền tảng Bootstrap và cung cấp các chức năng mạnh mẽ,
  giao diện thân thiện.
---

# Hướng dẫn sử dụng Voler và Mazer Dashboard từ Zuramai

## Giới Thiệu

**Voler** và **Mazer Dashboard** đều là những mẫu giao diện quản trị trên Bootstrap, giúp đơn giản hóa quy trình phát triển giao diện quản lý của các ứng dụng. Voler mang đến giao diện tối giản, thanh lịch, còn Mazer Dashboard có thiết kế hiện đại, dễ tùy chỉnh và phù hợp cho các dự án đa dạng, từ ứng dụng doanh nghiệp đến các trang web thương mại điện tử.

**Các lợi ích của việc sử dụng các template này bao gồm:**

* Tiết kiệm thời gian thiết kế giao diện.
* Mã nguồn mở, dễ dàng tùy chỉnh và mở rộng.
* Tối ưu hóa cho các dự án trên Bootstrap với khả năng responsive tốt.

## Mục Tiêu

* Hướng dẫn cài đặt Voler và Mazer Dashboard.
* Cấu hình các tính năng cơ bản để nhanh chóng tích hợp vào dự án.
* Cung cấp các giải thích chi tiết về cấu hình, giúp các kỹ thuật viên hiểu cách thức hoạt động của từng phần tử trong giao diện quản trị.

## Cấu Hình

### **1. Cài Đặt Voler**

#### **Bước 1:** Tải về từ GitHub Bạn có thể tải mã nguồn Voler từ [zuramai/voler](https://github.com/zuramai/voler). Đây là mã nguồn mở, nên bạn chỉ cần tải về và giải nén vào thư mục dự án của mình.

#### **Bước 2:** Khởi chạy Dự án Voler Trong thư mục chứa mã nguồn Voler, mở file `index.html` để xem giao diện demo và điều chỉnh theo nhu cầu của bạn. Bạn có thể chỉnh sửa trực tiếp các file CSS và JavaScript trong thư mục `assets` để thay đổi màu sắc, font chữ, và các yếu tố giao diện khác.

#### **Bước 3:** Cấu hình các phần chính

* **Sidebar và Navbar:** Bạn có thể tùy chỉnh các menu trong file HTML và cấu hình các liên kết điều hướng.
* **Widget và Component:** Voler cung cấp các thành phần sẵn có như biểu đồ, bảng dữ liệu, và các widget thông báo. Bạn chỉ cần thêm mã HTML vào vị trí mong muốn để sử dụng chúng.

### **2. Cài Đặt Mazer Dashboard**

#### **Bước 1:** Tải về từ GitHub Mazer Dashboard có thể được tải từ [zuramai/mazer](https://github.com/zuramai/mazer). Với cấu trúc đơn giản và tài liệu hướng dẫn cụ thể, bạn có thể dễ dàng tích hợp nó vào các dự án hiện tại.

#### **Bước 2:** Chạy bản Demo Mở file `index.html` trong thư mục `demo` để xem bản demo của Mazer Dashboard. Thư mục `assets` chứa tất cả các file cần thiết như CSS, JS, fonts và icons để giao diện hoạt động.

#### **Bước 3:** Tích hợp các thành phần chính

* **Component Mazer:** Mazer cung cấp các component như các form, bảng, thẻ thông báo, và biểu đồ. Bạn có thể tùy chỉnh và tích hợp vào các trang quản trị của mình một cách dễ dàng.
* **Cấu hình biểu đồ:** Mazer có tích hợp sẵn thư viện biểu đồ (chart), bạn có thể tìm thấy cấu hình mẫu trong file `demo/index.html`. Điều này giúp bạn dễ dàng hiển thị dữ liệu động từ server.

## **Cấu hình chi tiết một số lệnh cơ bản**

* **Thay đổi màu nền (Background):** Trong file CSS của cả Voler và Mazer, bạn có thể tìm thấy các lớp `.bg-primary`, `.bg-secondary`, `.bg-light`,... để thay đổi màu nền của các thành phần theo ý thích.
* **Cấu hình Menu Sidebar:** Cả hai giao diện đều cung cấp sidebar cố định để điều hướng. Trong phần HTML, bạn có thể thêm hoặc loại bỏ các mục menu bằng cách thay đổi các thẻ `<li>` bên trong phần `<ul class="sidebar-menu">`.
* **Thêm biểu đồ:** Để hiển thị biểu đồ, bạn có thể sử dụng thư viện Chart.js có sẵn trong Mazer bằng cách chỉnh sửa đoạn mã:

```html
<canvas id="myChart"></canvas>
<script>
    var ctx = document.getElementById('myChart').getContext('2d');
    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Jan', 'Feb', 'Mar'],
            datasets: [{
                label: 'Sales',
                data: [12, 19, 3],
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
            }]
        },
        options: { responsive: true }
    });
</script>
```

Biểu đồ này có thể được thay đổi loại (type), dữ liệu (data), và tùy chỉnh màu sắc.

## Kết Luận

Cả Voler và Mazer đều là những giải pháp tuyệt vời cho các ứng dụng quản trị. Với cấu trúc rõ ràng, dễ tích hợp, hai giao diện này giúp các kỹ thuật viên tiết kiệm thời gian và tập trung vào việc phát triển các tính năng của hệ thống. Thêm vào đó, các tính năng quản trị mạnh mẽ, khả năng tùy chỉnh cao giúp bạn có thể biến hai giao diện này thành nền tảng chính cho các dự án của mình.

Bài viết này đã hướng dẫn bạn qua các bước cài đặt, cấu hình và tích hợp các thành phần quan trọng. Nếu bạn muốn tạo ra một ứng dụng quản trị chuyên nghiệp, hiệu quả, hãy thử nghiệm và tùy chỉnh Voler và Mazer theo nhu cầu của dự án của mình.
