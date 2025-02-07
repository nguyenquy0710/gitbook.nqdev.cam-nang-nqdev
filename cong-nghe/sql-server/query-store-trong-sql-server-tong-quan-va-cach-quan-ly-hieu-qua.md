# Query Store trong SQL Server - Tổng Quan và Cách Quản Lý Hiệu Quả

## **1. Giới thiệu về Query Store**

Query Store là một tính năng quan trọng trong SQL Server (bắt đầu từ phiên bản SQL Server 2016), giúp theo dõi, lưu trữ và phân tích hiệu suất truy vấn. Đây là công cụ mạnh mẽ cho DBA (Database Administrator) để tối ưu hóa các kế hoạch thực thi (Execution Plan) và phát hiện các vấn đề về hiệu suất.

## **2. Tác dụng của Query Store**

### **Ưu điểm của Query Store**

* **Giám sát hiệu suất truy vấn lâu dài**: Lưu trữ dữ liệu về truy vấn, kế hoạch thực thi và số liệu thống kê giúp theo dõi hiệu suất qua thời gian.
* **Phân tích kế hoạch thực thi truy vấn**: So sánh kế hoạch cũ và mới, phát hiện sự thay đổi bất thường.
* **Phục hồi kế hoạch truy vấn**: Cho phép ép buộc SQL Server sử dụng một kế hoạch thực thi tối ưu thông qua **Force Plan**.
* **Giảm thiểu việc điều tra thủ công**: Tự động lưu trữ thông tin giúp dễ dàng phân tích hiệu suất.
* **Tích hợp sẵn trong SQL Server**: Không cần công cụ bên ngoài.

### **Nhược điểm của Query Store**

* **Tăng sử dụng tài nguyên (CPU, I/O và bộ nhớ)**: Ghi nhận dữ liệu liên tục có thể ảnh hưởng đến hiệu suất hệ thống.
* **Tiêu tốn dung lượng đĩa**: Nếu không kiểm soát tốt, Query Store có thể làm tăng dung lượng file dữ liệu .mdf.
* **Không thể chỉ định file lưu trữ riêng biệt**: Query Store luôn sử dụng file chính của cơ sở dữ liệu.
* **Có thể gây ảnh hưởng đến hiệu suất nếu không được cấu hình đúng cách**.

## **3. Operation Mode trong Query Store**

Operation Mode là thuộc tính kiểm soát cách Query Store hoạt động:

### **1. Read Write (Mặc định)**

* **Chế độ đầy đủ**: Cho phép ghi nhận tất cả các truy vấn và kế hoạch thực thi.
* **Hữu ích khi cần theo dõi hiệu suất, tối ưu truy vấn và quản lý kế hoạch thực thi**.
*   **Câu lệnh kích hoạt:**

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE = ON;
    ALTER DATABASE [YourDatabase] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
    ```

### **2. Read Only**

* **Chỉ đọc, không ghi dữ liệu mới**.
* **Hữu ích trong bảo trì hoặc khi không muốn Query Store tiếp tục ghi nhận dữ liệu**.
*   **Câu lệnh kích hoạt:**

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE (OPERATION_MODE = READ_ONLY);
    ```

### **3. Off**

* **Vô hiệu hóa hoàn toàn Query Store**.
* **Hữu ích khi muốn tiết kiệm tài nguyên hệ thống**.
*   **Câu lệnh tắt Query Store:**

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE = OFF;
    ```

## **4. Cách Đọc và Ghi Dữ Liệu từ Query Store**

SQL Server tự động ghi dữ liệu vào Query Store khi có truy vấn được thực thi. Để đọc dữ liệu, bạn có thể truy vấn các bảng hệ thống:

{% code title="=== Check Query Store ===" %}
```sql
SELECT qsq.query_id, qsp.plan_id
    , qsrs.execution_type_desc
    , qsrs.count_executions
    , qsrs.last_duration
    , qsrs.min_duration
    , qsrs.avg_duration
    , qsrs.max_duration
    , qsqt.query_sql_text
    , CONVERT(XML, qsp.query_plan) AS query_plan
FROM sys.query_store_query AS qsq
    INNER JOIN sys.query_store_plan AS qsp ON qsp.query_id = qsq.query_id
    INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsrs.plan_id = qsp.plan_id
    LEFT JOIN sys.query_store_query_text AS qsqt ON qsq.query_text_id = qsqt.query_text_id
WHERE 1=1
    -- Lọc các truy vấn đã thực thi trong 7 ngày qua
    AND qsrs.last_execution_time > DATEADD(DAY, -7, GETDATE())
    
    -- Lọc các truy vấn có thời gian thực thi trung bình (avg_duration) lớn hơn 1000 mili-giây
    AND qsrs.avg_duration > 1000
ORDER BY qsrs.avg_duration DESC, qsq.query_id ASC
GO
```
{% endcode %}

Nếu muốn hiển thị **Execution Plan** dưới dạng XML:

```sql
SELECT CONVERT(XML, qsp.query_plan) AS query_plan FROM sys.query_store_plan AS qsp;
```

## **5. Quản lý Dung Lượng Query Store**

Query Store sử dụng chung dung lượng với file dữ liệu chính (.mdf). Để kiểm soát dung lượng lưu trữ:

*   **Giới hạn dung lượng tối đa**:

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 500);
    ```
*   **Xóa dữ liệu cũ tự động**:

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE (CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30));
    ```
*   **Tắt Query Store nếu không cần sử dụng**:

    ```sql
    ALTER DATABASE [YourDatabase] SET QUERY_STORE = OFF;
    ```

## **6. Khi nào nên sử dụng Query Store?**

✅ **Bật Read Write** khi cần giám sát hiệu suất liên tục. ✅ **Bật Read Only** khi muốn phân tích dữ liệu cũ nhưng không muốn ghi mới. ✅ **Tắt Query Store** nếu hệ thống gặp vấn đề về tài nguyên hoặc không cần theo dõi truy vấn.

## **sql7. Kết luận**

Query Store là một công cụ mạnh mẽ giúp theo dõi và tối ưu hóa hiệu suất truy vấn trong SQL Server. Tuy nhiên, bạn cần kiểm soát dung lượng lưu trữ, cấu hình hợp lý để tránh ảnh hưởng đến hiệu suất hệ thống. Nếu được sử dụng đúng cách, Query Store sẽ giúp bạn tiết kiệm thời gian và công sức trong việc quản lý cơ sở dữ liệu.

***

🔥 **Bạn đang sử dụng Query Store như thế nào? Hãy để lại bình luận và chia sẻ kinh nghiệm của bạn!** 🚀
