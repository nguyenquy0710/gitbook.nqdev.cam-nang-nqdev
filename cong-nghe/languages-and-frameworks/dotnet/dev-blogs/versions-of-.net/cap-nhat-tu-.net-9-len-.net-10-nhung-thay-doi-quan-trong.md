---
description: >-
  .NET 10 Preview 1 cải thiện hiệu suất, hỗ trợ AVX10.2, nâng cấp OpenAPI 3.1,
  tối ưu Entity Framework Core và Blazor. Những thay đổi này giúp lập trình viên
  có trải nghiệm tốt hơn và hiệu suất cao hơn.
---

# Cập nhật từ .NET 9 lên .NET 10: Những thay đổi quan trọng

Microsoft vừa ra mắt **.NET 10 Preview 1**, mang lại nhiều cải tiến đáng kể so với **.NET 9**. Bài viết này sẽ đi sâu vào những thay đổi quan trọng trong **runtime, thư viện, C# 14, ASP.NET Core, .NET MAUI và Entity Framework Core**, giúp bạn hiểu rõ những điểm mới và so sánh với phiên bản trước.

📢 **Nguồn tham khảo**:

* Blog chính thức: [NET 10 Preview 1](https://devblogs.microsoft.com/dotnet/dotnet-10-preview-1/)
* Video cập nhật: [NET Previews Unboxed - .NET 10 Preview 1, C# 14, HybridCache & More](https://youtu.be/VncMk8ryxV8)

## Bảng so sánh thay đổi từ .NET 9 lên .NET 10

| Thành phần                                                   | .NET 9                               | .NET 10                                                        | Ưu điểm                                                            | Nhược điểm                                     |
| ------------------------------------------------------------ | ------------------------------------ | -------------------------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------- |
| **Runtime**                                                  | Không hỗ trợ AVX10.2                 | Hỗ trợ AVX10.2, cải thiện hiệu suất trên CPU mới               | Tăng tốc xử lý vector, tối ưu hiệu suất cho phần cứng hiện đại     | Chỉ có lợi khi chạy trên CPU hỗ trợ AVX10.2    |
| **Chứng chỉ (Certificate)**                                  | Chỉ hỗ trợ SHA-1                     | Thêm phương thức `FindByThumbprint` hỗ trợ thuật toán băm khác | Bảo mật cao hơn, linh hoạt hơn trong tìm kiếm chứng chỉ            | Cần cập nhật code nếu đang dùng SHA-1          |
| **Đọc dữ liệu PEM**                                          | Không hỗ trợ ASCII/UTF-8             | Hỗ trợ đọc dữ liệu PEM từ file ASCII hoặc UTF-8                | Dễ dàng thao tác với dữ liệu PEM mà không cần chuyển đổi định dạng | Không ảnh hưởng lớn nếu không làm việc với PEM |
| **Hiệu suất ZipArchive**                                     | Chưa tối ưu                          | Cải thiện hiệu suất và quản lý bộ nhớ                          | Giảm thời gian xử lý file nén, tiết kiệm tài nguyên                | Cần kiểm tra lại trên hệ thống có tải lớn      |
| **C# 14 - `nameof` trong generic**                           | Bị giới hạn                          | Cho phép sử dụng `nameof` trong generic chưa giữ kết           | Linh hoạt hơn trong lập trình, dễ đọc code hơn                     | Chưa có tác động tiêu cực rõ rệt               |
| **Thuộc tính hỗ trợ bởi trường (`field` backed properties)** | Chưa hỗ trợ                          | Hỗ trợ cú pháp mới cho thuộc tính có trường hỗ trợ             | Giảm boilerplate code, dễ bảo trì                                  | Thay đổi cú pháp có thể gây nhầm lẫn ban đầu   |
| **ASP.NET Core - Blazor**                                    | Chưa hỗ trợ `RowClass` cho QuickGrid | Hỗ trợ `RowClass` và script Blazor như tài sản web tĩnh        | Cải thiện khả năng tùy chỉnh giao diện và quản lý script tốt hơn   | Chỉ hữu ích cho dự án Blazor                   |
| **OpenAPI**                                                  | Chỉ hỗ trợ OpenAPI 3.0               | Hỗ trợ OpenAPI 3.1 và YAML                                     | Cập nhật theo chuẩn mới nhất, hỗ trợ định dạng YAML                | Cần kiểm tra tương thích với các hệ thống cũ   |
| **.NET MAUI**                                                | Chưa tối ưu hoàn toàn                | Cải thiện chất lượng và hiệu năng                              | Ứng dụng đa nền tảng chạy mượt hơn, ít lỗi hơn                     | Cần thử nghiệm kỹ trước khi đưa vào sản phẩm   |
| **Entity Framework Core - LINQ & SQL translation**           | Chưa tối ưu                          | Dịch LINQ sang SQL hiệu quả hơn                                | Tối ưu truy vấn, cải thiện hiệu suất                               | Cần kiểm tra kỹ nếu có truy vấn phức tạp       |
| **ExecuteUpdateAsync**                                       | Chỉ chấp nhận biểu thức lambda       | Hỗ trợ lambda thường                                           | Giảm hạn chế khi cập nhật dữ liệu, code dễ viết hơn                | Có thể cần điều chỉnh nếu đang sử dụng cách cũ |

## Phân tích chi tiết một số thay đổi quan trọng

### 1. Hỗ trợ AVX10.2 trong Runtime

**Giải thích:** AVX10.2 là một tập lệnh SIMD mới giúp tối ưu hiệu suất xử lý vector trên các CPU hiện đại. Việc hỗ trợ AVX10.2 trong .NET 10 giúp cải thiện tốc độ thực thi các tác vụ liên quan đến tính toán hiệu năng cao. **Tài liệu tham khảo:** [AVX10.2 và tối ưu hiệu suất](https://devblogs.microsoft.com/dotnet/avx10-2/)

### 2. Cải tiến OpenAPI 3.1 và hỗ trợ YAML

**Giải thích:** OpenAPI 3.1 là phiên bản mới của tiêu chuẩn mô tả API REST, giúp cải thiện khả năng định nghĩa và xác thực API. Việc hỗ trợ YAML giúp việc quản lý cấu hình API dễ dàng hơn. **Tài liệu tham khảo:** OpenAPI 3.1 Overview

### 3. Entity Framework Core - LINQ Translation

**Giải thích:** Việc dịch LINQ sang SQL trong EF Core 10 được tối ưu giúp cải thiện hiệu suất truy vấn. Giảm thời gian phản hồi từ database và tối ưu hóa các câu lệnh SQL được tạo ra từ LINQ. **Tài liệu tham khảo:** [EF Core Query Translation](https://learn.microsoft.com/en-us/ef/core/querying/)

## Kết luận

.NET 10 mang lại nhiều nâng cấp đáng kể về hiệu suất, bổ sung tính năng và tăng tính linh hoạt cho các API. Tuy nhiên, một số thay đổi có thể yêu cầu cập nhật lại code hoặc kiểm tra tương thích với hệ thống hiện tại. Đối với các nhà phát triển, việc nâng cấp từ **.NET 9 lên .NET 10** sẽ giúp cải thiện hiệu suất và dễ dàng tích hợp các tính năng mới.

📢 Đừng quên xem thêm chi tiết trong [**blog chính thức**](https://devblogs.microsoft.com/dotnet/dotnet-10-preview-1/) và video cập nhật [**tại đây**](https://youtu.be/VncMk8ryxV8)!
