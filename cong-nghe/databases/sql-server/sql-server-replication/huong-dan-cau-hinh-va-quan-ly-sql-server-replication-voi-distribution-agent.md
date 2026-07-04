---
description: >-
  Trong bài viết này, Cẩm nang NQDEV sẽ hướng dẫn bạn cách kiểm tra, cấu hình và
  khắc phục các vấn đề phổ biến liên quan đến SQL Server Replication.
---

# Hướng dẫn cấu hình và quản lý SQL Server Replication với Distribution Agent

Đặc biệt, bài viết tập trung vào việc sử dụng **Snapshot Agent** và **Distribution Agent**, giúp bạn tối ưu hóa hiệu suất đồng bộ dữ liệu trong các môi trường thực tế.

***

## 1. **Kiểm tra cấu hình Snapshot Agent Profile**

### **Cách kiểm tra Snapshot Agent đang dùng**

Để xác định **Snapshot Agent Profile** của một publication, bạn có thể sử dụng truy vấn sau trong cơ sở dữ liệu **`distribution`**:

```sql
USE distribution
GO

SELECT 
    sa.publisher_db AS [Publisher Database],
    sa.name AS [Publication Name],
    sa.profile_id AS [Profile ID],
    ap.profile_name AS [Profile Name]
FROM dbo.MSsnapshot_agents sa
JOIN msdb..MSagent_profiles ap ON sa.profile_id = ap.profile_id
WHERE sa.publisher_db = 'TênCơSởDữLiệuCủaBạn';
```

Kết quả sẽ hiển thị tên database, tên publication và profile đang được sử dụng.

***

## 2. **Xem log của Snapshot Agent**

Nếu Snapshot Agent gặp lỗi hoặc bạn cần xem chi tiết quá trình thực thi, có thể kiểm tra log bằng cách:

### **Truy vấn log chi tiết**

```sql
USE distribution
GO

SELECT 
    sa.name AS PublicationName,
    sh.runstatus AS RunStatus,
    sh.start_time AS StartTime,
    sh.time AS EndTime,
    sh.comments AS LogMessage
FROM dbo.MSsnapshot_agents sa
    JOIN dbo.MSsnapshot_history sh ON sa.id = sh.agent_id
WHERE sh.agent_id = (
    SELECT id 
    FROM dbo.MSsnapshot_agents
    WHERE name = 'TênPublication'
)
ORDER BY sh.time DESC;
```

### **Chạy lại Snapshot Agent**

Nếu cần chạy lại Snapshot Agent để kiểm tra:

```sql
EXEC sys.sp_startpublication_snapshot @publication = 'TênPublication', -- sysname
                                      @publisher = NULL    -- sysname
```

***

## 3. **Giới hạn số lượng lệnh Bulk Insert trong Subscription**

Khi restore dữ liệu từ subscriber, bạn có thể cấu hình **Distribution Agent** để giới hạn số lượng lệnh trong mỗi batch:

### **Cấu hình các tham số quan trọng**

* **`-CommitBatchSize`**: Số lượng hàng trong một giao dịch batch.
* **`-CommitBatchThreshold`**: Số lượng lệnh (commands) trong một giao dịch batch.
* **`-BcpBatchSize`**: Số lượng hàng khi dùng Bulk Copy Program (BCP).

### **Thay đổi thông qua T-SQL**

Bạn có thể cập nhật cấu hình của Distribution Agent bằng cách:

```sql
USE distribution
GO

UPDATE msdb..MSagent_parameters
SET [value] = '1000' -- Giá trị mới
WHERE profile_id = (
    SELECT profile_id 
    FROM MSdistribution_agents 
    WHERE subscriber_db = 'TênDatabaseSubscription'
   )
AND parameter_name = '-CommitBatchSize';
```

Sau đó khởi động lại Distribution Agent:

```sql
-- EXEC sp_start_job @job_name = 'TênJobCủaDistributionAgent';
```

***

## 4. **Giải thích chi tiết các tham số Distribution Agent**

Dưới đây là các tham số quan trọng bạn cần biết khi cấu hình **Distribution Agent**:

<table><thead><tr><th width="321">Tham số</th><th width="247">Ý nghĩa</th><th>Ví dụ cấu hình</th></tr></thead><tbody><tr><td><strong><code>-BcpBatchSize</code></strong></td><td>Số lượng hàng trong mỗi batch BCP.</td><td><code>100000</code></td></tr><tr><td><strong><code>-CommitBatchSize</code></strong></td><td>Số hàng được commit trong một giao dịch batch.</td><td><code>100</code></td></tr><tr><td><strong><code>-CommitBatchThreshold</code></strong></td><td>Số lệnh được thực hiện trong một giao dịch batch.</td><td><code>1000</code></td></tr><tr><td><strong><code>-PollingInterval</code></strong></td><td>Khoảng thời gian (giây) giữa các lần kiểm tra dữ liệu mới.</td><td><code>5</code></td></tr><tr><td><strong><code>-MaxBcpThreads</code></strong></td><td>Số luồng tối đa được sử dụng cho BCP.</td><td><code>1</code></td></tr><tr><td><strong><code>-QueryTimeout</code></strong></td><td>Thời gian tối đa (giây) chờ một truy vấn SQL trước khi timeout.</td><td><code>1800</code> (30 phút)</td></tr><tr><td><strong><code>-SkipErrors</code></strong></td><td>Bỏ qua các lỗi được chỉ định thay vì dừng agent.</td><td><code>Không cấu hình</code></td></tr><tr><td><strong><code>-KeepAliveMessageInterval</code></strong></td><td>Thời gian giữa các keep-alive message để kiểm tra kết nối giữa publisher và subscriber.</td><td><code>300</code> giây (5 phút)</td></tr></tbody></table>

***

## 5. **Kinh nghiệm tối ưu hóa**

* **Giảm độ trễ**: Nếu bạn cần dữ liệu cập nhật nhanh, giảm **`-PollingInterval`** (ví dụ từ `5` xuống `2` giây).
* **Tăng hiệu suất Bulk Insert**: Điều chỉnh **`-CommitBatchSize`** và **`-BcpBatchSize`** phù hợp với kích thước dữ liệu.
* **Theo dõi log thường xuyên**: Đặt **`-TransactionsPerHistory`** nhỏ hơn để ghi log chi tiết hơn trong môi trường cần giám sát.

***

## 6. **Kết luận**

Bài viết trên cung cấp hướng dẫn từ cơ bản đến nâng cao giúp bạn quản lý và tối ưu hóa SQL Server Replication với **Snapshot Agent** và **Distribution Agent**. Nếu bạn gặp vấn đề hoặc muốn tối ưu hiệu suất hệ thống, hãy thử áp dụng các cấu hình này để cải thiện.

{% code title="Tài liệu tham khảo:" lineNumbers="true" %}
```http
https://learn.microsoft.com/en-us/sql/relational-databases/replication/sql-server-replication?view=sql-server-ver16
https://www.sql.edu.vn/microsoft-sql-server/replication/
https://bartoszlewandowski.blog/tag/sql-server-repl/
https://www.mssqltips.com/sqlservertip/3287/sql-server-transactional-replication-error-could-not-find-stored-procedure-error-and-how-to-recover-it-by-using-spscriptpublicationcustomprocs/
https://learn.microsoft.com/en-us/sql/relational-databases/replication/transactional/transactional-articles-specify-how-changes-are-propagated?view=sql-server-ver15
https://sqlserver-dba.co.uk/sql-server/sql-server-error-14151-severity-18-replication-s-agen.html

```
{% endcode %}

***

Hy vọng bài viết này sẽ hữu ích cho bạn đọc của [**Cẩm nang NQDEV**](https://app.gitbook.com/o/ZnO3U2gDjowIXUi3yNwm/s/riO9WU3lEu4DXKD3d9zp/)! Nếu có thắc mắc hoặc cần thêm thông tin, hãy để lại bình luận nhé. 😊
