# SQL Server: Cách khởi động SQLServer bỏ qua Database bị lỗi

Khi một database trong SQL Server bị lỗi, nó có thể ngăn toàn bộ instance khởi động thành công. Bài viết này sẽ hướng dẫn bạn các phương pháp khởi động SQL Server mà không load các database bị lỗi.

### 🔍 Nguyên nhân database lỗi ngăn khởi động SQL Server

SQL Server thực hiện quá trình recovery trên tất cả databases khi khởi động. Nếu một database bị lỗi trong quá trình này, instance có thể không khởi động được. Các lỗi thường gặp bao gồm:

* File database bị hỏng
* Transaction log bị lỗi
* Disk đầy hoặc không truy cập được
* Page corruption

### 🛠️ Các phương pháp khởi động SQL Server bỏ qua database lỗi

#### 1. Sử dụng Trace Flag 3608

Trace Flag 3608 yêu cầu SQL Server chỉ khởi động master database, bỏ qua recovery cho tất cả database khác.

**Cách thực hiện:**

1. Mở **SQL Server Configuration Manager**
2. Chuột phải vào SQL Server instance → **Properties**
3. Chọn tab **Startup Parameters**
4. Thêm tham số: `-T3608`
5. Nhấn **Add** → **OK**
6. Khởi động lại SQL Server service

sql

```sql
-- Sau khi khởi động thành công, đặt database lỗi ở chế độ OFFLINE
ALTER DATABASE [DatabaseName] SET OFFLINE WITH ROLLBACK IMMEDIATE;

-- Gỡ bỏ trace flag sau khi xử lý xong
```

#### 2. Đặt database ở chế độ EMERGENCY hoặc OFFLINE

Nếu có thể kết nối đến SQL Server, bạn có thể đặt database lỗi ở chế độ khẩn cấp:

sql

```sql
-- Đặt database ở chế độ EMERGENCY
ALTER DATABASE [DatabaseName] SET EMERGENCY;

-- Sau đó đặt thành OFFLINE
ALTER DATABASE [DatabaseName] SET OFFLINE WITH ROLLBACK IMMEDIATE;
```

#### 3. Di chuyển file database lỗi

Phương pháp vật lý bằng cách di chuyển file database khỏi thư mục data:

1. Dừng SQL Server service
2. Di chuyển file .mdf và .ldf của database lỗi sang thư mục khác
3. Khởi động lại SQL Server
4. Database sẽ hiển thị trạng thái "Recovery Pending"
5. Xóa database lỗi bằng lệnh:

sql

```sql
DROP DATABASE [DatabaseName];
```

### 📝 Các bước khắc phục chi tiết

#### Bước 1: Xác định database gây lỗi

Kiểm tra SQL Server error log để xác định database nào đang gây lỗi:

* File log thường ở: `C:\Program Files\Microsoft SQL Server\MSSQLXX.InstanceName\MSSQL\Log\`

#### Bước 2: Áp dụng phương pháp phù hợp

Chọn một trong các phương pháp trên dựa trên tình huống cụ thể

#### Bước 3: Khôi phục database (nếu có thể)

Sau khi SQL Server khởi động thành công:

* Khôi phục từ backup nếu có
* Sử dụng DBCC CHECKDB để sửa chữa

sql

```sql
-- Đặt database ở chế độ SINGLE_USER
ALTER DATABASE [DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Chạy sửa chữa
DBCC CHECKDB ([DatabaseName], REPAIR_ALLOW_DATA_LOSS);

-- Đặt lại chế độ MULTI_USER
ALTER DATABASE [DatabaseName] SET MULTI_USER;
```

### ⚠️ Lưu ý quan trọng

1. **Luôn sao lưu dữ liệu** trước khi thực hiện bất kỳ thao tác sửa chữa nào
2. **Trace Flag 3608** chỉ nên dùng tạm thời, gỡ bỏ sau khi xử lý xong
3. Phương pháp **REPAIR\_ALLOW\_DATA\_LOSS** có thể gây mất dữ liệu
4. Kiểm tra nguyên nhân gốc gây lỗi database để tránh tái diễn

### 💡 Mẹo phòng ngừa

* Thiết lập backup thường xuyên và kiểm tra tính toàn vẹn của backup
* Sử dụng tính năng Database Consistency Checks (DBCC CHECKDB) định kỳ
* Giám sát dung lượng disk và tình trạng hardware
* Sử dụng tính năng Auto Close một cách thận trọng

### 📞 Hỗ trợ

Nếu bạn gặp khó khăn trong quá trình thực hiện, hãy truy cập [diễn đàn NQDEV](https://blogs.nhquydev.net/) để được hỗ trợ thêm.

_Tác giả: Nguyễn Quý - Chuyên gia SQL Server tại NQDEV_\
&#xNAN;_&#x4E;gày cập nhật: 11/09/2025_
