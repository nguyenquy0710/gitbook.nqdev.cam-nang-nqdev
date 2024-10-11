---
description: >-
  CQRS (Command Query Responsibility Segregation) là một mẫu kiến trúc giúp tách
  biệt cách đọc và ghi dữ liệu bằng cách sử dụng hai mô hình riêng biệt cho các
  hoạt động này.
---

# CQRS and MediatR trong .NET Core

**CQRS** (Command Query Responsibility Segregation) là một mẫu kiến trúc giúp tách biệt cách đọc và ghi dữ liệu bằng cách sử dụng hai mô hình riêng biệt cho các hoạt động này. Điều này mang lại nhiều lợi ích trong những tình huống phức tạp, khi hệ thống phát triển và yêu cầu quản lý dữ liệu trở nên khó khăn hơn.

<figure><img src="https://www.c-sharpcorner.com/article/cqrs-and-mediatr-pattern-implementation-using-net-core-6-web-api/Images/Picture.png" alt=""><figcaption></figcaption></figure>

Dưới đây là một số điểm bổ sung về CQRS:

## **1. Tách biệt Lệnh (Commands) và Truy vấn (Queries):**

* **Commands**: Được sử dụng để cập nhật trạng thái hệ thống. Mỗi lệnh sẽ thực hiện một thay đổi nào đó, thường được xử lý theo cơ chế ghi.
* **Queries**: Được sử dụng để truy vấn dữ liệu, thực hiện các hoạt động đọc mà không thay đổi trạng thái của hệ thống.

## **2. Tối ưu hóa hiệu suất và khả năng mở rộng:**

* **Mô hình ghi** có thể được tối ưu hóa cho các thao tác cập nhật dữ liệu (write-heavy).
* **Mô hình đọc** có thể được tối ưu hóa để truy xuất dữ liệu nhanh chóng (read-heavy), có thể lưu trữ dữ liệu ở các dạng khác nhau hoặc thậm chí sử dụng các cơ chế như **caching** hay **materialized views** để tăng tốc độ.

## 3. **Lợi ích của CQRS:**

* **Hiệu suất**: Phân tách đọc và ghi giúp tối ưu hóa từng thành phần, từ đó cải thiện hiệu suất tổng thể của hệ thống.
* **Độc lập giữa đọc và ghi**: Bạn có thể mở rộng mô hình đọc và ghi riêng rẽ, tùy theo nhu cầu cụ thể của hệ thống.
* **Bảo trì dễ dàng hơn**: Các phần liên quan đến cập nhật và truy vấn không bị ràng buộc chặt chẽ với nhau, giúp mã nguồn dễ hiểu và dễ bảo trì.
* **Phù hợp với các hệ thống phức tạp**: Khi yêu cầu quản lý dữ liệu trở nên phức tạp, CQRS giúp tổ chức hệ thống rõ ràng và gọn gàng hơn.

## 4. **Thách thức khi áp dụng CQRS:**

* **Độ phức tạp tăng lên**: Việc sử dụng hai mô hình riêng biệt đòi hỏi phải quản lý và đồng bộ hóa dữ liệu giữa chúng, dẫn đến sự phức tạp trong việc phát triển và bảo trì.
* **Consistency**: Trong một số tình huống, khi ghi dữ liệu vào hệ thống, có thể xảy ra trạng thái không đồng nhất (eventual consistency) giữa các mô hình đọc và ghi.

## 5. **Event Sourcing**:

CQRS thường được kết hợp với **Event Sourcing**, trong đó mỗi thay đổi của hệ thống được lưu trữ dưới dạng một sự kiện thay vì chỉ cập nhật trực tiếp dữ liệu. Điều này giúp tạo ra một **audit log** và dễ dàng quay lại trạng thái trước đó khi cần thiết.



{% hint style="info" %}
* https://codewithmukesh.com/blog/cqrs-and-mediatr-in-aspnet-core/
* https://viblo.asia/p/trien-khai-trong-net-core-voi-mediatr-cqrs-pattern-Yym40KKoV91
* https://github.com/Rezakazemi890/Clean-Architecture-CQRS
* [https://www.c-sharpcorner.com/article/cqrs-and-mediatr-pattern-implementation-using-net-core-6-web-api/](https://www.c-sharpcorner.com/article/cqrs-and-mediatr-pattern-implementation-using-net-core-6-web-api/)
{% endhint %}



