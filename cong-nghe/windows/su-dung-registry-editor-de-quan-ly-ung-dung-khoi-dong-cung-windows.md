---
description: >-
  Hướng Dẫn Kiểm Tra và Quản Lý Ứng Dụng Khởi Động Tự Động (Startup Apps) Trên
  Windows Bằng Registry Editor
---

# Hướng dẫn quản lý ứng dụng khởi động Windows bằng Registry Editor

## **Giới thiệu**

Khi bạn khởi động máy tính Windows, một số ứng dụng sẽ tự động chạy ngầm. Điều này có thể làm chậm thời gian khởi động và ảnh hưởng đến hiệu suất hệ thống. Việc kiểm tra và quản lý các ứng dụng khởi động là cần thiết để tối ưu hóa tốc độ và đảm bảo máy tính hoạt động mượt mà.

Trong bài viết này, [Cẩm nang NQDEV](../) sẽ hướng dẫn bạn cách sử dụng **Registry Editor** để xem và kiểm soát danh sách các ứng dụng khởi động tự động trên Windows.

***

## **1. Tại** sao cần kiểm tra các ứng dụng khởi động tự động?

* **Tối ưu hóa hiệu suất khởi động**: Giảm số lượng ứng dụng không cần thiết giúp hệ thống khởi động nhanh hơn.
* **Tăng cường bảo mật**: Một số phần mềm độc hại có thể tự động thêm mình vào danh sách startup. Kiểm tra sẽ giúp phát hiện và loại bỏ chúng.
* **Kiểm soát hoạt động nền**: Giảm tải cho CPU và bộ nhớ RAM khi chỉ giữ lại các ứng dụng thực sự cần thiết.

***

## **2. Cách** kiểm tra ứng dụng startup trong Registry Editor

### **Bước 1: Mở Registry Editor**

1. Nhấn tổ hợp phím **Windows + R** để mở cửa sổ **Run**.
2. Gõ **regedit** và nhấn **Enter**.
3. Nếu có hộp thoại xác nhận quyền quản trị, chọn **Yes** để tiếp tục.

***

### **Bước 2: Điều** hướng đến các mục Startup

Bạn có thể tìm thấy danh sách các ứng dụng khởi động tự động tại các vị trí sau:

1.  **Dành cho người dùng hiện tại**:

    ```mathematica
    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
    ```

    * Chứa danh sách ứng dụng chỉ khởi động cho tài khoản người dùng hiện tại.
2.  **Dành cho tất cả người dùng**:

    ```mathematica
    HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
    ```

    * Chứa danh sách ứng dụng khởi động cho tất cả tài khoản trên máy tính.
3.  **Dành cho ứng dụng 32-bit trên Windows 64-bit**:

    ```mathematica
    HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run
    ```

    * Kiểm tra ứng dụng 32-bit trên hệ thống 64-bit.

***

### **Bước 3: Kiểm** tra và quản lý ứng dụng khởi động

* Mỗi mục trong thư mục **Run** sẽ có:
  * **Tên ứng dụng**: Hiển thị tên phần mềm hoặc dịch vụ.
  * **Dữ liệu giá trị**: Chứa đường dẫn đến file thực thi của chương trình.

#### **Ví dụ:**

```vbnet
Name: OneDrive  
Data: "C:\Program Files\Microsoft OneDrive\OneDrive.exe" /background
```

* **Xóa ứng dụng khỏi startup**:\
  Nhấp chuột phải vào ứng dụng cần xóa và chọn **Delete**.
* **Thêm ứng dụng mới vào startup**:
  1. Nhấp chuột phải vào vùng trống, chọn **New -> String Value**.
  2. Đặt tên cho giá trị mới.
  3. Nhấp đúp vào giá trị đó và nhập đường dẫn đến file thực thi của ứng dụng.

***

## **3. Lưu** ý quan trọng khi sử dụng Registry Editor

1. **Sao lưu Registry trước khi chỉnh sửa**:
   * Chọn **File -> Export** để tạo bản sao lưu.
   * Nếu có lỗi xảy ra, bạn có thể phục hồi bằng cách sử dụng file đã xuất.
2. **Không xóa các mục hệ thống quan trọng**:
   * Hãy chắc chắn bạn hiểu rõ ứng dụng trước khi xóa bất kỳ mục nào.
3. **Kiểm tra ứng dụng đáng ngờ**:
   * Nếu thấy một ứng dụng không rõ nguồn gốc, hãy tìm kiếm tên của nó trên Google để xác minh tính hợp lệ.

***

## **4. Các** giải pháp bổ sung để quản lý startup

Ngoài Registry Editor, bạn cũng có thể sử dụng các công cụ khác:

* **Task Manager** (Windows 10/11):
  1. Nhấn **Ctrl + Shift + Esc** để mở **Task Manager**.
  2. Chuyển sang tab **Startup** để xem danh sách ứng dụng khởi động và bật/tắt chúng.
* **Phần mềm bên thứ ba**:
  * **Autoruns**: Công cụ miễn phí từ Microsoft hỗ trợ quản lý chi tiết các mục startup.
  * **CCleaner**: Cho phép kiểm soát và tối ưu hóa danh sách ứng dụng khởi động.

***

## **5. Kết luận**

Quản lý danh sách ứng dụng khởi động tự động là một bước quan trọng để tối ưu hóa hiệu suất và đảm bảo tính bảo mật cho hệ thống Windows. Thông qua **Registry Editor**, bạn có thể dễ dàng kiểm tra, thêm hoặc xóa các mục startup theo ý muốn.

Hy vọng bài viết này từ **Cẩm nang NQDEV** sẽ giúp bạn nắm bắt được cách kiểm soát ứng dụng khởi động một cách an toàn và hiệu quả. Nếu có bất kỳ câu hỏi hoặc thắc mắc nào, đừng ngần ngại để lại bình luận bên dưới.

**Cẩm nang NQDEV – Chia sẻ kiến thức công nghệ hữu ích!** 🚀
