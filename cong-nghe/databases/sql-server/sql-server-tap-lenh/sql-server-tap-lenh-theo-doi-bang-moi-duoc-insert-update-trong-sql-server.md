# SQL Server: Tập lệnh theo dõi bảng mới được Insert, Update trong SQL Server

Khi làm việc với cơ sở dữ liệu SQL Server, việc theo dõi các bảng mới được cập nhật hoặc thêm dữ liệu là rất quan trọng để kiểm soát thay đổi và khắc phục sự cố. Dưới đây là các phương pháp hiệu quả để xác định bảng nào mới được insert hoặc update.

### 1. Sử dụng System Dynamic Management Views (DMV)

#### Query cơ bản theo dõi thay đổi trong 24 giờ qua:

```sql
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    last_user_update AS LastUpdate,
    user_updates AS TotalUpdates,
    last_user_seek AS LastSeek,
    last_user_scan AS LastScan
FROM 
    sys.dm_db_index_usage_stats
WHERE 
    database_id = DB_ID()
    AND last_user_update > DATEADD(HOUR, -24, GETDATE())
ORDER BY 
    last_user_update DESC;
```

#### Query chi tiết với thông tin schema:

```sql
SELECT 
    t.name AS TableName,
    s.name AS SchemaName,
    ius.last_user_update AS LastUpdateTime,
    ius.user_updates AS TotalUpdates,
    ius.last_user_seek AS LastSeekTime,
    ius.last_user_scan AS LastScanTime
FROM 
    sys.dm_db_index_usage_stats ius
JOIN 
    sys.tables t ON ius.object_id = t.object_id
JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    ius.database_id = DB_ID()
    AND ius.last_user_update > DATEADD(HOUR, -24, GETDATE())
ORDER BY 
    ius.last_user_update DESC;
```

#### Check for recently modified tables:

```sql
-- Check for recently modified tables (last 24 hours)
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    last_user_update AS LastUpdate,
    user_updates AS TotalUpdates
FROM 
    sys.dm_db_index_usage_stats
WHERE 
    database_id = DB_ID()
    AND last_user_update > DATEADD(HOUR, -24, GETDATE())
ORDER BY 
    last_user_update DESC;
```

**Lưu ý**: Dữ liệu trong DMV sẽ bị reset mỗi khi SQL Server khởi động lại.

### 2. Sử dụng Change Tracking (Theo dõi thay đổi)

#### Bật Change Tracking cho database:

sql

```sql
ALTER DATABASE YourDatabaseName
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);
```

#### Bật Change Tracking cho bảng cụ thể:

sql

```sql
ALTER TABLE YourTableName
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON);
```

#### Truy vấn thông tin thay đổi:

sql

```sql
SELECT
    t.name AS TableName,
    CT.SYS_CHANGE_VERSION AS ChangeVersion,
    CT.SYS_CHANGE_OPERATION AS Operation,
    CT.SYS_CHANGE_COLUMNS AS ChangedColumns,
    CT.SYS_CHANGE_CONTEXT AS Context
FROM
    CHANGETABLE(CHANGES YourTableName, 0) AS CT
JOIN
    sys.tables t ON OBJECT_ID(CT.table_name) = t.object_id
ORDER BY
    CT.SYS_CHANGE_VERSION DESC;
```

### 3. Sử dụng Change Data Capture (CDC) - Phiên bản Enterprise

#### Bật CDC cho database:

sql

```sql
EXEC sys.sp_cdc_enable_db;
```

#### Bật CDC cho bảng cụ thể:

sql

```sql
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'YourTableName',
    @role_name = NULL,
    @capture_instance = N'YourTableName_Instance';
```

#### Truy vấn thay đổi:

sql

```sql
SELECT *
FROM cdc.dbo_YourTableName_CT
ORDER BY __$start_lsn DESC;
```

### 4. Phương pháp thủ công với Timestamp Columns

#### Thêm cột timestamp vào bảng:

sql

```sql
ALTER TABLE YourTableName 
ADD 
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
```

#### Tạo trigger để tự động cập nhật:

sql

```sql
CREATE TRIGGER trg_UpdateModifiedDate
ON YourTableName
AFTER UPDATE
AS
BEGIN
    UPDATE t
    SET ModifiedDate = GETDATE()
    FROM YourTableName t
    INNER JOIN inserted i ON t.PrimaryKey = i.PrimaryKey
END
```

#### Truy vấn các bảng được cập nhật gần đây:

sql

```sql
SELECT 
    TABLE_NAME,
    MAX(ModifiedDate) AS LastModified
FROM 
    INFORMATION_SCHEMA.TABLES t
JOIN 
    YourTableName ON 1=1
WHERE 
    ModifiedDate > DATEADD(HOUR, -24, GETDATE())
GROUP BY 
    TABLE_NAME
ORDER BY 
    LastModified DESC;
```

### 5. Tạo bảng Log để theo dõi thay đổi

#### Tạo bảng log:

sql

```sql
CREATE TABLE ChangeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128),
    ChangeType NVARCHAR(10),
    ChangeTime DATETIME DEFAULT GETDATE(),
    UserName NVARCHAR(128) DEFAULT SUSER_SNAME()
);
```

#### Tạo trigger để ghi log:

sql

```sql
CREATE TRIGGER trg_LogChanges
ON YourTableName
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @ChangeType NVARCHAR(10)
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ChangeType = 'UPDATE'
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ChangeType = 'INSERT'
    ELSE
        SET @ChangeType = 'DELETE'
        
    INSERT INTO ChangeLog (TableName, ChangeType)
    VALUES ('YourTableName', @ChangeType)
END
```

### Kết luận

Tùy vào nhu cầu và phiên bản SQL Server bạn đang sử dụng, có thể lựa chọn phương pháp phù hợp:

1. **DMV**: Nhanh, đơn giản nhưng dữ liệu không tồn tại lâu
2. **Change Tracking**: Phù hợp cho ứng dụng cần đồng bộ dữ liệu
3. **CDC**: Mạnh mẽ nhưng chỉ có trong phiên bản Enterprise
4. **Timestamp Columns & Triggers**: Linh hoạt, hoạt động trên mọi phiên bản
