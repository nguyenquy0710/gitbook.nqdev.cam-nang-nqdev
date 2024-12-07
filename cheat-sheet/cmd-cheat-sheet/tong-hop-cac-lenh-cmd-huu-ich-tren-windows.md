# Tổng hợp các lệnh CMD hữu ích trên Windows

Command Prompt (CMD) là một công cụ mạnh mẽ cho phép bạn thực hiện nhiều tác vụ trên hệ điều hành Windows thông qua giao diện dòng lệnh. Dưới đây là danh sách các lệnh CMD thông dụng và hữu ích dành cho người dùng ở nhiều cấp độ, từ cơ bản đến nâng cao.

***

## **1. Lệnh Hệ Thống**

| **Lệnh**                        | **Chức năng**                                                             |
| ------------------------------- | ------------------------------------------------------------------------- |
| `systeminfo`                    | Hiển thị thông tin chi tiết về hệ thống, như phiên bản Windows, RAM, CPU. |
| `hostname`                      | Hiển thị tên máy tính.                                                    |
| `tasklist`                      | Liệt kê tất cả các tiến trình đang chạy.                                  |
| `taskkill /im <tên-tiến-trình>` | Kết thúc một tiến trình cụ thể theo tên.                                  |
| `chkdsk`                        | Kiểm tra và sửa lỗi trên ổ đĩa.                                           |
| `sfc /scannow`                  | Quét và sửa lỗi các file hệ thống bị hỏng.                                |
| `shutdown /s /t 0`              | Tắt máy ngay lập tức.                                                     |
| `shutdown /r /t 0`              | Khởi động lại máy ngay lập tức.                                           |

***

## **2. Lệnh Quản Lý File và Thư Mục**

| **Lệnh**              | **Chức năng**                                                      |
| --------------------- | ------------------------------------------------------------------ |
| `dir`                 | Liệt kê tất cả các file và thư mục trong thư mục hiện tại.         |
| `cd <đường-dẫn>`      | Chuyển đến thư mục khác.                                           |
| `md <tên-thư-mục>`    | Tạo một thư mục mới.                                               |
| `rd <tên-thư-mục>`    | Xóa một thư mục (thư mục phải rỗng).                               |
| `del <tên-file>`      | Xóa một file.                                                      |
| `copy <nguồn> <đích>` | Sao chép file từ nguồn đến đích.                                   |
| `move <nguồn> <đích>` | Di chuyển file từ nguồn đến đích.                                  |
| `attrib`              | Thay đổi thuộc tính của file hoặc thư mục (ẩn, chỉ đọc, hệ thống). |

***

## **3. Lệnh Mạng**

| **Lệnh**                     | **Chức năng**                                           |
| ---------------------------- | ------------------------------------------------------- |
| `ipconfig`                   | Hiển thị cấu hình mạng (IP, gateway, DNS).              |
| `ping <địa-chỉ-ip/tên-miền>` | Kiểm tra kết nối mạng đến một địa chỉ IP hoặc tên miền. |
| `tracert <tên-miền>`         | Theo dõi đường đi của gói tin đến địa chỉ đích.         |
| `netstat`                    | Hiển thị danh sách các kết nối mạng đang hoạt động.     |
| `nslookup <tên-miền>`        | Kiểm tra thông tin DNS của một tên miền.                |
| `netsh wlan show profiles`   | Hiển thị danh sách các mạng Wi-Fi đã lưu.               |

***

## **4. Lệnh Quản Lý Người Dùng**

| **Lệnh**                              | **Chức năng**                                  |
| ------------------------------------- | ---------------------------------------------- |
| `net user`                            | Hiển thị danh sách tất cả người dùng trên máy. |
| `net user <tên-user> <mật-khẩu> /add` | Thêm một người dùng mới với mật khẩu chỉ định. |
| `net user <tên-user> /delete`         | Xóa người dùng.                                |
| `whoami`                              | Hiển thị tài khoản hiện tại đang đăng nhập.    |

***

## **5. Lệnh Nâng Cao**

| **Lệnh**                | **Chức năng**                                     |
| ----------------------- | ------------------------------------------------- |
| `diskpart`              | Truy cập công cụ quản lý ổ đĩa.                   |
| `format <ký-tự-ổ-đĩa>:` | Định dạng ổ đĩa.                                  |
| `bootrec /fixmbr`       | Sửa lỗi Master Boot Record (MBR).                 |
| `cipher /w:<đường-dẫn>` | Xóa dữ liệu một cách an toàn, không thể phục hồi. |
| `powercfg /energy`      | Kiểm tra hiệu suất năng lượng của máy tính.       |
| `regedit`               | Mở trình chỉnh sửa registry.                      |

***

## **6. Mẹo Sử Dụng CMD Hiệu Quả**

1. **Tăng quyền admin**: Luôn chạy CMD với quyền quản trị viên (Admin) để sử dụng đầy đủ các tính năng.
2. **Sử dụng phím mũi tên**: Phím mũi tên lên/xuống để xem lại các lệnh đã nhập trước đó.
3. **Chuyển hướng đầu ra**: Sử dụng `>` hoặc `>>` để lưu đầu ra của lệnh vào file. Ví dụ: `ipconfig > output.txt`.
4. **Kết hợp lệnh**: Sử dụng `&&` để chạy nhiều lệnh liên tiếp. Ví dụ: `dir && ipconfig`.

***

## **Kết Luận**

CMD là một công cụ không thể thiếu cho việc quản trị hệ thống và chẩn đoán sự cố. Việc nắm vững các lệnh CMD sẽ giúp bạn xử lý các tác vụ nhanh chóng và hiệu quả hơn. Hãy lưu lại cheat sheet này để tham khảo khi cần thiết nhé!

{% code title="Tài liệu tham khảo" overflow="wrap" lineNumbers="true" %}
```http
- https://github.com/security-cheatsheet/cmd-command-cheat-sheet
- https://www.bodhost.com/kb/windows-cmd-commands-cheat-sheet/
- https://serverspace.io/support/help/windows-cmd-commands-cheat-sheet/
```
{% endcode %}

Chúc bạn thành công! 🎉
