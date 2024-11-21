# Các bước để thay đổi nơi lưu trữ tệp log trong SQL Server

Để thay đổi vị trí lưu trữ tệp **log** của một cơ sở dữ liệu trong SQL Server, bạn cần làm theo các bước dưới đây. Việc này giúp bạn quản lý không gian lưu trữ hiệu quả hơn, đặc biệt là khi ổ đĩa lưu trữ log hiện tại đầy hoặc nếu bạn muốn tách các tệp log và dữ liệu ra khỏi nhau để cải thiện hiệu suất.

## Tóm Tắt Các Bước

1. [Kiểm tra vị trí hiện tại của tệp log.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-1.-kiem-tra-vi-tri-tep-log-hien-tai)
2. [Đặt cơ sở dữ liệu ở chế độ Single-User.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-2.-tat-cac-ket-noi-va-dat-co-so-du-lieu-o-che-do-single-user-tuy-chon)
3. [Di chuyển tệp log sang vị trí mới với lệnh `ALTER DATABASE`.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-3.-di-chuyen-tep-log-sang-vi-tri-moi)
4. [Kiểm tra lại vị trí của tệp log.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-4.-kiem-tra-lai-cac-tep-da-duoc-thay-doi)
5. [Đặt lại cơ sở dữ liệu ở chế độ Multi-User.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-5.-khoi-dong-lai-co-so-du-lieu-o-che-do-multi-user-neu-can-thiet)
6. [Xoá tệp log cũ nếu cần.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-6.-xoa-tep-log-cu-tuy-chon)
7. [Thực hiện sao lưu lại cơ sở dữ liệu và tệp log.](cac-buoc-de-thay-doi-noi-luu-tru-tep-log-trong-sql-server.md#id-7.-backup-va-kiem-tra-lai)

Nếu bạn gặp phải bất kỳ vấn đề nào trong quá trình này, đừng ngần ngại yêu cầu thêm hướng dẫn!

## **1. Kiểm tra vị trí tệp log hiện tại**

Trước khi di chuyển tệp log, bạn cần kiểm tra vị trí hiện tại của tệp log trong cơ sở dữ liệu.

```sql
-- Kiểm tra vị trí các tệp dữ liệu và log của cơ sở dữ liệu
USE <database_name>;
GO
SELECT name, physical_name AS current_location
FROM sys.master_files
WHERE database_id = DB_ID('<database_name>');
```

Kết quả trả về sẽ cung cấp tên tệp (`name`) và vị trí tệp hiện tại (`current_location`).

## **2. Tắt các kết nối và đặt cơ sở dữ liệu ở chế độ Single User (tùy chọn)**

Để di chuyển tệp log, bạn có thể cần tắt các kết nối tới cơ sở dữ liệu đó. Điều này đảm bảo rằng không có giao dịch nào đang thực hiện trên cơ sở dữ liệu khi bạn thay đổi vị trí tệp.

```sql
-- Đặt cơ sở dữ liệu ở chế độ single user (chỉ cho phép một kết nối duy nhất)
ALTER DATABASE <database_name> SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
```

Lệnh này sẽ ngắt tất cả các kết nối đang mở đến cơ sở dữ liệu và đảm bảo rằng bạn có thể thực hiện các thay đổi mà không gặp phải lỗi khóa.

## **3. Di chuyển tệp Log sang vị trí mới**

Sử dụng câu lệnh `ALTER DATABASE` để thay đổi vị trí tệp log. Bạn cần xác định đường dẫn mới nơi bạn muốn lưu trữ tệp log.

```sql
-- Di chuyển tệp log sang vị trí mới
ALTER DATABASE <database_name>
MODIFY FILE (NAME = <log_file_name>, FILENAME = 'D:\NewLocation\logfile.ldf');
```

Trong đó:

* `<database_name>` là tên của cơ sở dữ liệu.
* `<log_file_name>` là tên của tệp log (thường là `log` hoặc tên khác mà bạn đã cấu hình).
* `'D:\NewLocation\logfile.ldf'` là đường dẫn đầy đủ tới thư mục và tên tệp log mới mà bạn muốn di chuyển đến.

## **4. Kiểm tra lại các tệp đã được thay đổi**

Sau khi thay đổi vị trí của tệp log, bạn có thể kiểm tra lại để chắc chắn rằng tệp log đã được di chuyển thành công.

```sql
-- Kiểm tra lại vị trí tệp log sau khi di chuyển
SELECT name, physical_name AS current_location
FROM sys.master_files
WHERE database_id = DB_ID('<database_name>');
```

## **5. Khởi động lại cơ sở dữ liệu ở chế độ Multi-User (nếu cần thiết)**

Sau khi di chuyển tệp log, bạn có thể chuyển cơ sở dữ liệu về chế độ **Multi-User** để cho phép nhiều kết nối.

```sql
-- Đặt lại cơ sở dữ liệu ở chế độ Multi-User
ALTER DATABASE <database_name> SET MULTI_USER;
```

## **6. Xoá tệp log cũ (tùy chọn)**

Nếu bạn muốn xoá tệp log cũ sau khi đã di chuyển, bạn có thể sử dụng câu lệnh `ALTER DATABASE` để loại bỏ tệp log không còn sử dụng nữa.

```sql
-- Xoá tệp log cũ (nếu không còn sử dụng)
ALTER DATABASE <database_name>
REMOVE FILE <log_file_name>;
```

Lệnh này sẽ xóa tệp log cũ mà bạn đã di chuyển sang một vị trí mới.

## 7. **Backup và Kiểm tra lại**

Sau khi thay đổi vị trí của tệp log, hãy đảm bảo thực hiện sao lưu lại cơ sở dữ liệu và tệp log để bảo vệ dữ liệu.

```sql
-- Backup toàn bộ cơ sở dữ liệu
BACKUP DATABASE <database_name> TO DISK = 'D:\Backups\<database_name>.bak';

-- Backup tệp log
BACKUP LOG <database_name> TO DISK = 'D:\Backups\<database_name>_log.trn';
```

## Lưu Ý Quan Trọng

1. **Đảm bảo đường dẫn mới có đủ không gian**: Trước khi di chuyển tệp log, đảm bảo rằng ổ đĩa hoặc thư mục đích có đủ dung lượng để chứa tệp log.
2. **Chú ý đến phục hồi trong trường hợp khẩn cấp**: Khi di chuyển tệp log, nếu bạn gặp phải sự cố hoặc lỗi, có thể mất khả năng phục hồi cơ sở dữ liệu nếu không sao lưu đầy đủ.
3. **Tránh di chuyển trong quá trình sao lưu hoặc giao dịch lớn**: Di chuyển tệp log trong khi có các giao dịch lớn hoặc khi sao lưu có thể gây lỗi hoặc ảnh hưởng đến hiệu suất của cơ sở dữ liệu.
4. **Không di chuyển tệp log trong Recovery Models đặc biệt**: Nếu cơ sở dữ liệu đang ở chế độ **Full Recovery Model**, bạn nên cẩn thận hơn khi di chuyển tệp log, vì các tệp log phục vụ cho việc sao lưu và phục hồi điểm thời gian.

