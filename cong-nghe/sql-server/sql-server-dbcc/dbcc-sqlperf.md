---
description: >-
  Lệnh DBCC SQLPERF(LOGSPACE) trong SQL Server được sử dụng để cung cấp thông
  tin về trạng thái và không gian sử dụng của Transaction Log cho tất cả các cơ
  sở dữ liệu trong instance SQL Server.
---

# DBCC SQLPERF

Cụ thể, lệnh này sẽ hiển thị các thông tin sau:

## Các cột trong kết quả:

1. **Database Name**: Tên của cơ sở dữ liệu.
2. **Log Size (MB)**: Kích thước tổng thể của Transaction Log (bao gồm cả phần đã sử dụng và chưa sử dụng), tính bằng MB.
3. **Log Space Used (%)**: Phần trăm không gian log đã được sử dụng. Nếu giá trị này cao (gần 100%), có thể chỉ ra rằng Transaction Log đang gần đầy hoặc không thể thu hồi không gian.
4. **Log Space Remaining (%)**: Phần trăm không gian log còn lại (không gian chưa được sử dụng).
5. **Status**: Trạng thái của Transaction Log, chẳng hạn như "0" nếu Transaction Log có thể thu hồi không gian, hoặc "1" nếu Transaction Log không thể thu hồi không gian.

### Ví dụ kết quả:

```
Database Name   Log Size (MB)   Log Space Used (%)   Log Space Remaining (%)   Status
--------------- --------------- -------------------- ------------------------ -------
TestDB           1000            80                   20                        0
ProductionDB     500             40                   60                        0
```

* **Log Size (MB)**: 1GB cho TestDB và 500MB cho ProductionDB.
* **Log Space Used (%)**: TestDB đã sử dụng 80% không gian trong khi ProductionDB chỉ sử dụng 40%.
* **Status**: Nếu giá trị là `0`, điều này có nghĩa là Transaction Log có thể được thu hồi không gian (log đang được sử dụng đúng cách).

## Mục đích sử dụng:

* Giúp bạn giám sát mức độ sử dụng Transaction Log và xác định xem có cần phải sao lưu log để giải phóng không gian hay không.
* Kiểm tra xem Transaction Log có thể tự động thu hồi không gian hay không (dựa trên trạng thái "Status").

Nếu thấy phần trăm sử dụng log quá cao, bạn có thể cần sao lưu log hoặc điều chỉnh cấu hình để giảm bớt việc sử dụng không gian log.
