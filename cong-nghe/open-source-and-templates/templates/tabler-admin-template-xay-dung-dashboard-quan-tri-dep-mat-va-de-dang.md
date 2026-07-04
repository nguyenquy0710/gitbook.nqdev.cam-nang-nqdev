---
description: >-
  Tabler là một UI kit dành cho các ứng dụng web, đặc biệt là các dashboard quản
  trị, được xây dựng trên nền tảng Bootstrap 5.
---

# Tabler Admin Template: Xây dựng Dashboard Quản trị đẹp mắt và dễ dàng

Với thiết kế hiện đại, dễ sử dụng và hoàn toàn miễn phí, Tabler là lựa chọn tuyệt vời để tạo ra các giao diện quản trị chuyên nghiệp và đáp ứng tốt trên nhiều thiết bị. Trong bài viết này, chúng ta sẽ tìm hiểu cách bắt đầu với Tabler Admin Template và xây dựng một dashboard cơ bản.

## 1. **Giới Thiệu về Tabler**

**Tabler** là một bộ công cụ UI (giao diện người dùng) miễn phí và mã nguồn mở giúp bạn xây dựng các trang dashboard quản trị hoặc ứng dụng web với giao diện đẹp và dễ tùy chỉnh. Tabler được xây dựng trên nền tảng **Bootstrap 5**, giúp bạn dễ dàng sử dụng và mở rộng các tính năng của Bootstrap, đồng thời cung cấp hàng trăm component và layout mẫu để bạn có thể tùy chỉnh theo nhu cầu.

Một số đặc điểm nổi bật của Tabler:

* **Miễn phí và mã nguồn mở**.
* **Dễ dàng tùy chỉnh** và mở rộng.
* **Responsive**: Giao diện phù hợp với tất cả các thiết bị.
* **Component phong phú**: Card, bảng biểu, biểu đồ, form, icon, v.v.

***

## 2. **Cài Đặt và Khởi Tạo Dự Án với Tabler**

Để bắt đầu sử dụng Tabler, bạn chỉ cần vài bước đơn giản. Dưới đây là hướng dẫn cài đặt:

### **Bước 1: Tải Tabler về Máy**

Truy cập trang web chính thức của Tabler [Tabler Admin Template](https://tabler.io/admin-template) và tải bộ template về máy. Bạn cũng có thể clone trực tiếp từ GitHub nếu muốn đóng góp hoặc chỉnh sửa mã nguồn.

* [Tải Tabler từ GitHub](https://github.com/tabler/tabler)

### **Bước 2: Cấu Hình Dự Án**

Sau khi tải về, bạn sẽ thấy thư mục chứa các tệp HTML, CSS, JavaScript và các thư viện liên quan. Để khởi tạo dự án, bạn chỉ cần mở các tệp HTML trong trình duyệt hoặc tích hợp vào dự án của bạn.

**Cấu trúc thư mục của Tabler**:

* **assets/**: Các tệp CSS, JS và hình ảnh cần thiết.
* **index.html**: Tệp HTML chính, nơi bạn có thể chỉnh sửa và thêm nội dung.
* **docs/**: Hướng dẫn chi tiết và tài liệu tham khảo.

### **Bước 3: Tùy Chỉnh Giao Diện**

Sau khi khởi tạo dự án, bạn có thể bắt đầu tùy chỉnh giao diện bằng cách thay đổi các thành phần trong tệp HTML và CSS. Tabler cung cấp các layout mẫu, vì vậy bạn chỉ cần chèn các component vào là đã có thể có một dashboard hoàn chỉnh.

***

## 3. **Khám Phá Các Component của Tabler**

Tabler cung cấp nhiều component hữu ích giúp bạn tạo ra các trang quản trị đẹp mắt và đầy đủ tính năng.

{% tabs %}
{% tab title="Card" %}
Card là một trong những component phổ biến trong Tabler để hiển thị thông tin theo dạng module. Mỗi card có thể chứa nội dung như văn bản, hình ảnh, biểu đồ, bảng dữ liệu, v.v.

**Ví dụ:**

```html
<div class="card">
  <div class="card-header">
    <h5 class="card-title">Card Title</h5>
  </div>
  <div class="card-body">
    <p class="card-text">Some quick example text to build on the card title and make up the bulk of the card's content.</p>
  </div>
</div>
```
{% endtab %}

{% tab title="Table" %}
Tabler hỗ trợ tạo bảng dữ liệu với thiết kế đẹp mắt, dễ đọc và dễ tùy chỉnh.

**Ví dụ:**

```html
<table class="table table-hover">
  <thead>
    <tr>
      <th>#</th>
      <th>Name</th>
      <th>Role</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>John Doe</td>
      <td>Admin</td>
      <td><span class="badge bg-success">Active</span></td>
    </tr>
    <tr>
      <td>2</td>
      <td>Jane Smith</td>
      <td>User</td>
      <td><span class="badge bg-danger">Inactive</span></td>
    </tr>
  </tbody>
</table>
```
{% endtab %}

{% tab title="Charts" %}
**Charts**

Tabler tích hợp với thư viện **Chart.js** để tạo biểu đồ trực quan, giúp bạn dễ dàng theo dõi các chỉ số hoặc thống kê quan trọng.

**Ví dụ:**

```html
<canvas id="chart" class="chartjs" width="400" height="200"></canvas>
<script>
  var ctx = document.getElementById('chart').getContext('2d');
  var chart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['January', 'February', 'March', 'April', 'May'],
      datasets: [{
        label: 'Demo Dataset',
        data: [10, 20, 30, 40, 50],
        borderColor: '#4bc0c0',
        fill: false
      }]
    }
  });
</script>
```
{% endtab %}

{% tab title="Forms và Inputs" %}
Tabler cung cấp các form component để thu thập thông tin từ người dùng. Các form này được thiết kế đơn giản nhưng vẫn rất đẹp mắt và dễ sử dụng.

**Ví dụ:**

```html
<form>
  <div class="mb-3">
    <label for="email" class="form-label">Email address</label>
    <input type="email" class="form-control" id="email" required>
  </div>
  <div class="mb-3">
    <label for="password" class="form-label">Password</label>
    <input type="password" class="form-control" id="password" required>
  </div>
  <button type="submit" class="btn btn-primary">Submit</button>
</form>
```
{% endtab %}
{% endtabs %}



***

## 4. **Tùy Chỉnh Tabler theo Nhu Cầu của Bạn**

Tabler rất dễ dàng tùy chỉnh. Bạn có thể thay đổi màu sắc, font chữ, kích thước và nhiều yếu tố khác trong các tệp **CSS** của Tabler hoặc sử dụng các **utility classes** có sẵn của Bootstrap. Bạn cũng có thể thay đổi cấu trúc layout hoặc thêm các tính năng đặc biệt như xác thực người dùng, quản lý quyền truy cập, v.v.

## 5. **Kết Luận**

Tabler là một công cụ mạnh mẽ để tạo ra các ứng dụng dashboard hoặc trang quản trị web với thiết kế hiện đại và tính năng phong phú. Với sự hỗ trợ của Bootstrap 5, bạn có thể dễ dàng tùy chỉnh và mở rộng dự án theo nhu cầu. Hãy bắt đầu với Tabler ngay hôm nay để tạo ra những giao diện đẹp mắt và hiệu quả cho các dự án của bạn!

* **Link tham khảo và tài liệu chính thức**: [Tabler Docs](https://tabler.io/docs/getting-started)
* **Github Repository**: [Tabler trên GitHub](https://github.com/tabler/tabler)

Nếu bạn có bất kỳ câu hỏi nào về việc sử dụng Tabler, đừng ngần ngại để lại câu hỏi dưới bài viết này nhé!

***

Hy vọng bài viết này sẽ giúp bạn bắt đầu với Tabler và phát triển các ứng dụng web của mình một cách dễ dàng hơn. Chúc bạn thành công!
