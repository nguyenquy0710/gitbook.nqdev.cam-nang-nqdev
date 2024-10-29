---
description: >-
  Khi xây dựng các ứng dụng web API hiện đại với ASP.NET Core, hiệu suất và khả
  năng tối ưu hóa bộ nhớ là hai yếu tố được nhiều lập trình viên quan tâm.
---

# ASP.NET Core Web API với ASP.NET Core Web API (Native AOT): Bạn nên chọn loại nào?

Khi xây dựng các ứng dụng web API hiện đại với ASP.NET Core, hiệu suất và khả năng tối ưu hóa bộ nhớ là hai yếu tố được nhiều lập trình viên quan tâm. Microsoft hiện cung cấp hai tùy chọn chính cho việc phát triển web API: **ASP.NET Core Web API** và **ASP.NET Core Web API (Native AOT)**.

Trong đó, **Native AOT (Ahead-Of-Time Compilation)** đang được xem là một cải tiến mới, giúp ứng dụng đạt hiệu suất cao hơn. Vậy sự khác biệt chính giữa hai phương pháp này là gì? Bài viết này sẽ giúp bạn hiểu rõ ưu nhược điểm của mỗi tùy chọn để từ đó đưa ra quyết định phù hợp nhất cho dự án của mình.

## So sánh chi tiết ASP.NET Core Web API và Native AOT

* [**Hiệu suất và tốc độ khởi động**](asp.net-core-web-api-voi-asp.net-core-web-api-native-aot-ban-nen-chon-loai-nao.md#id-1.-kha-nang-toi-uu-hoa-hieu-suat): Nêu bật sự khác biệt trong cách biên dịch giữa JIT và AOT, cùng tác động đến tốc độ khởi động của ứng dụng.
* [**Kích thước và tài nguyên bộ nhớ**](asp.net-core-web-api-voi-asp.net-core-web-api-native-aot-ban-nen-chon-loai-nao.md#id-2.-kich-thuoc-ung-dung): Tập trung vào sự khác biệt về kích thước ứng dụng và mức sử dụng tài nguyên của hai phương pháp.
* [**Tính năng và khả năng tương thích**](asp.net-core-web-api-voi-asp.net-core-web-api-native-aot-ban-nen-chon-loai-nao.md#id-3.-tinh-tuong-thich-va-ho-tro-tinh-nang): Làm rõ các tính năng mà mỗi loại API hỗ trợ, đặc biệt với tính năng động và các thư viện của .NET.
* [**Ứng dụng thực tế và trường hợp sử dụng**](asp.net-core-web-api-voi-asp.net-core-web-api-native-aot-ban-nen-chon-loai-nao.md#id-4.-truong-hop-su-dung-phu-hop): Đưa ra những tình huống cụ thể để lập trình viên chọn đúng phiên bản theo yêu cầu hiệu suất và môi trường triển khai.

### **1. Khả năng tối ưu hóa hiệu suất**

Một trong những điểm khác biệt đáng chú ý nhất giữa **ASP.NET Core Web API** và **ASP.NET Core Web API (Native AOT)** là cách mà mã nguồn được biên dịch và thực thi.

* **ASP.NET Core Web API**: Đây là bản web API thông thường của .NET Core, hoạt động dựa trên .NET Runtime có sẵn. Mã nguồn được biên dịch qua **JIT (Just-In-Time Compilation)** khi ứng dụng chạy lần đầu, nghĩa là chỉ khi có yêu cầu từ người dùng, mã nguồn mới bắt đầu được biên dịch thành mã máy để thực thi. Dù cách làm này giúp ứng dụng linh hoạt và có thể xử lý nhiều thao tác phức tạp, nhưng lại làm chậm thời gian khởi động ban đầu vì phải thực hiện biên dịch ngay lúc chạy.
* **ASP.NET Core Web API (Native AOT)**: Native AOT sử dụng **biên dịch Ahead-Of-Time (AOT)**, biên dịch toàn bộ mã nguồn trước khi ứng dụng được khởi động. Do đó, thời gian khởi động nhanh hơn đáng kể, vì mã nguồn đã sẵn sàng được thực thi ngay mà không cần chờ biên dịch. Điều này giúp tối ưu hiệu suất, đặc biệt là trong các trường hợp yêu cầu thời gian phản hồi nhanh hoặc trong môi trường hạn chế về tài nguyên.

### **2. Kích thước ứng dụng**

Một yếu tố quan trọng khác là kích thước của ứng dụng, điều này ảnh hưởng đến tài nguyên hệ thống và hiệu suất tổng thể của API.

* **ASP.NET Core Web API**: Vì phải bao gồm .NET Runtime, nên kích thước ứng dụng lớn hơn. Tuy nhiên, kích thước tăng thêm này giúp ứng dụng linh hoạt hơn, hỗ trợ nhiều API của .NET mà Native AOT không có. Do đó, trong những dự án không giới hạn tài nguyên hoặc yêu cầu bộ nhớ quá cao, đây vẫn là một lựa chọn tốt.
* **ASP.NET Core Web API (Native AOT)**: Kích thước của ứng dụng Native AOT nhỏ hơn, do loại bỏ các thành phần không cần thiết và tối ưu hóa mã nguồn để chỉ bao gồm những gì ứng dụng cần. Điều này rất phù hợp khi bạn cần một ứng dụng gọn nhẹ, chẳng hạn như các dịch vụ microservice chạy trên các container nhỏ, IoT hoặc các thiết bị có giới hạn bộ nhớ.

### **3. Tính tương thích và hỗ trợ tính năng**

Tính tương thích với các tính năng động và thư viện .NET đầy đủ là một khía cạnh quan trọng cần xem xét khi lựa chọn giữa ASP.NET Core Web API và Native AOT.

* **ASP.NET Core Web API**: Do sử dụng .NET Runtime đầy đủ, bản thông thường của ASP.NET Core Web API có khả năng hỗ trợ các thư viện và tính năng động của .NET, bao gồm **reflection** và các API động khác. Nếu dự án của bạn cần dùng đến reflection hoặc các thư viện yêu cầu dynamic programming, bản Web API thông thường sẽ là lựa chọn hợp lý hơn.
* **ASP.NET Core Web API (Native AOT)**: Native AOT gặp một số hạn chế trong việc hỗ trợ các tính năng dynamic. Vì mã đã được biên dịch trước thành mã máy, nên không thể dễ dàng sử dụng các tính năng reflection hoặc dynamic API, vốn yêu cầu biên dịch và thực thi tại thời điểm chạy. Do đó, nếu bạn cần sử dụng các thư viện yêu cầu tính năng này, Native AOT sẽ không phải là lựa chọn tối ưu.

### **4. Trường hợp sử dụng phù hợp**

* **ASP.NET Core Web API**: Phù hợp với các ứng dụng cần sự linh hoạt, dễ bảo trì và không yêu cầu tối ưu hóa hiệu suất quá cao. Đây cũng là lựa chọn phổ biến cho các ứng dụng web API lớn với nhiều tính năng phức tạp hoặc các dự án có khả năng mở rộng cao.
* **ASP.NET Core Web API (Native AOT)**: Rất thích hợp cho các ứng dụng nhỏ gọn, cần khởi động nhanh, đặc biệt là các microservice trong hệ thống phân tán hoặc chạy trên các thiết bị hạn chế tài nguyên. Native AOT còn là lựa chọn lý tưởng cho các ứng dụng yêu cầu hiệu suất cao hoặc chạy trong môi trường đám mây, nơi tốc độ khởi động và sử dụng tài nguyên tối ưu là ưu tiên hàng đầu.

## **Bảng tóm tắt so sánh**

Dưới đây là bảng tóm tắt so sánh giữa **ASP.NET Core Web API** và **ASP.NET Core Web API (Native AOT)** để giúp bạn có cái nhìn tổng quan rõ ràng hơn:

| **Tiêu chí**              | **ASP.NET Core Web API**                     | **ASP.NET Core Web API (Native AOT)**                    |
| ------------------------- | -------------------------------------------- | -------------------------------------------------------- |
| **Hiệu suất**             | Tốt nhưng khởi động chậm hơn                 | Nhanh hơn nhờ biên dịch trước với Native AOT             |
| **Thời gian khởi động**   | Lâu hơn do phải biên dịch Just-In-Time (JIT) | Nhanh hơn đáng kể nhờ biên dịch Ahead-Of-Time (AOT)      |
| **Kích thước ứng dụng**   | Lớn hơn do cần thêm .NET Runtime             | Nhỏ gọn vì loại bỏ các thành phần không cần thiết        |
| **Hỗ trợ tính năng động** | Đầy đủ (reflection và dynamic API)           | Hạn chế (không hỗ trợ reflection và một số API động)     |
| **Trường hợp sử dụng**    | Ứng dụng linh hoạt, không cần tối ưu quá cao | Ứng dụng nhỏ gọn, khởi động nhanh, hạn chế về tài nguyên |
| **Khả năng tương thích**  | Hỗ trợ đầy đủ thư viện và tính năng của .NET | Giới hạn trong một số thư viện, không hỗ trợ đầy đủ .NET |

## **Kết luận**

ASP.NET Core Web API và Native AOT đều có những ưu điểm và hạn chế riêng, và việc chọn lựa phụ thuộc nhiều vào yêu cầu cụ thể của dự án. Nếu bạn cần một ứng dụng linh hoạt, có khả năng mở rộng, hỗ trợ tốt các tính năng động của .NET, thì **ASP.NET Core Web API** là lựa chọn tốt. Trong khi đó, nếu bạn muốn tối ưu hóa kích thước ứng dụng và thời gian khởi động cho các môi trường hạn chế, **Native AOT** sẽ là lựa chọn sáng giá. Mong rằng bài viết này đã giúp bạn hiểu rõ hơn về các lựa chọn này và có thể đưa ra quyết định phù hợp cho dự án của mình.
