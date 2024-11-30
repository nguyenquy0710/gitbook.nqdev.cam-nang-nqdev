---
description: 'DBCC FREEPROCCACHE: Cách hoạt động và Ứng dụng trong SQL Server'
---

# DBCC FREEPROCCACHE

Trong quá trình vận hành SQL Server, việc quản lý bộ nhớ đóng vai trò cực kỳ quan trọng trong hiệu suất hệ thống. Một trong những công cụ hữu ích được cung cấp bởi SQL Server để kiểm soát và tối ưu hóa bộ nhớ là lệnh **DBCC FREEPROCCACHE**. Bài viết này sẽ giúp bạn hiểu rõ hơn về chức năng, cách sử dụng, và những trường hợp áp dụng thực tế của lệnh này.

***

## **1. DBCC FREEPROCCACHE là gì?**

**DBCC FREEPROCCACHE** là một câu lệnh trong SQL Server thuộc nhóm các Database Console Commands (DBCC), được sử dụng để làm sạch **Procedure Cache**. Procedure Cache là nơi SQL Server lưu trữ các Execution Plan (kế hoạch thực thi) của các truy vấn đã thực hiện, nhằm tái sử dụng chúng cho các truy vấn tương tự, giúp giảm chi phí tính toán và tăng tốc độ thực thi.

Tuy nhiên, trong một số trường hợp, Procedure Cache có thể chứa những kế hoạch lỗi thời hoặc không còn hiệu quả. Việc làm sạch Procedure Cache bằng DBCC FREEPROCCACHE sẽ buộc SQL Server phải tạo lại Execution Plan mới cho các truy vấn sau đó.

***

## **2. Cú pháp lệnh DBCC FREEPROCCACHE**

```sql
DBCC FREEPROCCACHE [ WITH NO_INFOMSGS ];
```

* **WITH NO\_INFOMSGS**: Tùy chọn này giúp ẩn các thông báo không cần thiết khi thực hiện lệnh.

***

## **3. Khi nào nên sử dụng DBCC FREEPROCCACHE?**

Mặc dù Procedure Cache giúp cải thiện hiệu suất, nhưng có một số trường hợp việc làm sạch cache là cần thiết:

### **3.1. Thay đổi cấu trúc cơ sở dữ liệu**

* Khi bạn thực hiện các thay đổi lớn như chỉnh sửa bảng, thêm/xóa cột, hoặc cập nhật index, các Execution Plan cũ có thể không còn phù hợp.

### **3.2. Tối ưu hóa hiệu suất**

* Trong quá trình tinh chỉnh truy vấn, bạn cần kiểm tra hiệu quả của các Execution Plan mới sau khi thay đổi các chỉ số (index), thống kê (statistics) hoặc query hints.

### **3.3. Giải quyết vấn đề hiệu suất bất thường**

* Nếu hệ thống gặp các vấn đề về hiệu suất, việc làm sạch Procedure Cache có thể là một bước khắc phục tạm thời để loại bỏ các Execution Plan không hiệu quả.

### **3.4. Kiểm tra và thử nghiệm**

* Khi bạn đang kiểm tra trong môi trường phát triển, làm sạch cache giúp đảm bảo rằng bạn đang đo hiệu suất của các Execution Plan mới, thay vì các kế hoạch đã được lưu trữ trước đó.

***

## **4. Ví dụ sử dụng DBCC FREEPROCCACHE**

### **4.1. Làm sạch toàn bộ Procedure Cache**

```sql
DBCC FREEPROCCACHE;
```

* Lệnh này sẽ xóa tất cả các Execution Plan trong Procedure Cache của hệ thống.

### **4.2. Làm sạch Execution Plan cụ thể**

Nếu bạn chỉ muốn xóa kế hoạch thực thi của một truy vấn cụ thể, bạn có thể sử dụng **DBCC FREEPROCCACHE** với **Plan Handle**.

1. Lấy Plan Handle của một truy vấn:

```sql
SELECT plan_handle 
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE text LIKE '%<từ khóa truy vấn>%';
```

2. Xóa kế hoạch với Plan Handle:

```sql
DBCC FREEPROCCACHE (<plan_handle>);
```

### 4.3. Không hiển thị thông báo

```sql
DBCC FREEPROCCACHE WITH NO_INFOMSGS;
```

* Lệnh này giúp hạn chế các thông báo không cần thiết, giữ sạch nhật ký hệ thống.

***

## **5. Các lưu ý khi sử dụng DBCC FREEPROCCACHE**

* **Ảnh hưởng đến hiệu suất**: Sau khi làm sạch Procedure Cache, SQL Server sẽ phải tạo lại Execution Plan mới cho các truy vấn, dẫn đến tăng tải hệ thống trong thời gian ngắn.
* **Không khuyến khích trong môi trường sản xuất**: Chỉ sử dụng khi cần thiết vì có thể gây ra hiện tượng giảm hiệu suất tạm thời.
* **Yêu cầu quyền cao**: Bạn cần có quyền **sysadmin** hoặc **serveradmin** để chạy lệnh này.
* **Không hoàn tác được**: Một khi đã làm sạch Procedure Cache, không thể khôi phục các Execution Plan cũ.

***

## **6. So sánh với các lệnh DBCC khác liên quan đến bộ nhớ**

| **Lệnh DBCC**         | **Chức năng**                                                                |
| --------------------- | ---------------------------------------------------------------------------- |
| DBCC FREEPROCCACHE    | Xóa Procedure Cache, buộc SQL Server tạo lại Execution Plan.                 |
| DBCC DROPCLEANBUFFERS | Làm sạch Buffer Cache, buộc SQL Server đọc dữ liệu từ đĩa thay vì từ bộ nhớ. |
| DBCC FLUSHPROCINDB    | Làm sạch Procedure Cache của một database cụ thể (SQL Server 2008 trở lên).  |

***

## **7. Kết luận**

**DBCC FREEPROCCACHE** là một công cụ mạnh mẽ trong SQL Server, giúp bạn kiểm soát và tối ưu hóa Procedure Cache để cải thiện hiệu suất hệ thống. Tuy nhiên, hãy sử dụng nó cẩn thận, đặc biệt trong môi trường sản xuất, để tránh gây ra các vấn đề không mong muốn.

Hy vọng bài viết này cung cấp cho bạn cái nhìn chi tiết và đầy đủ về **DBCC FREEPROCCACHE**. Nếu bạn có bất kỳ câu hỏi hoặc góp ý nào, hãy để lại bình luận dưới bài viết.

***

_Hãy theo dõi blog_ [_Cẩm nang NQDEV_](https://blogs.nhquydev.net/) _để cập nhật thêm nhiều kiến thức hữu ích về SQL Server và lập trình!_
