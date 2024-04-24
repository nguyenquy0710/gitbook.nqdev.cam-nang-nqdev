---
description: >-
  https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-shrinkdatabase-transact-sql?view=sql-server-ver16
---

# DBCC SHRINKDATABASE

## Ảnh hưởng của lệnh DBCC SHRINKDATABASE

Lệnh `DBCC SHRINKDATABASE` trong SQL Server được sử dụng để thu nhỏ kích thước của tệp dữ liệu (.mdf) và tệp nhật ký (.ldf) trong cơ sở dữ liệu. Việc thu nhỏ tệp cơ sở dữ liệu có thể giải phóng không gian đĩa và cải thiện hiệu suất trong một số trường hợp. Tuy nhiên, cũng có một số tác động tiềm ẩn cần lưu ý:

### **Tác động tích cực:**

* **Giải phóng không gian đĩa:** Thu nhỏ tệp dữ liệu sẽ giải phóng không gian đĩa trống không sử dụng, giúp bạn tiết kiệm dung lượng lưu trữ.
* **Cải thiện hiệu suất:** Tệp dữ liệu bị phân mảnh có thể ảnh hưởng đến hiệu suất truy vấn. Thu nhỏ tệp dữ liệu có thể giúp loại bỏ phân mảnh và cải thiện hiệu suất truy vấn.
* **Giảm thời gian sao lưu:** Tệp dữ liệu nhỏ hơn sẽ được sao lưu nhanh hơn.

### **Tác động tiêu cực:**

* **Chặn truy cập:** Lệnh `DBCC SHRINKDATABASE` có thể chặn truy cập vào cơ sở dữ liệu trong khi nó đang được thực thi. Do đó, cần thực hiện lệnh này vào thời điểm ít người sử dụng hệ thống.
* **Mất hiệu suất tạm thời:** Việc thu nhỏ tệp dữ liệu có thể làm giảm hiệu suất truy vấn trong thời gian ngắn.
* **Nguy cơ mất dữ liệu:** Mặc dù rất hiếm gặp, nhưng việc thu nhỏ tệp dữ liệu có thể dẫn đến mất dữ liệu nếu xảy ra lỗi trong quá trình thực thi.

### **Lưu ý về mất dữ liệu:**

Lệnh `DBCC SHRINKDATABASE` **không trực tiếp xóa dữ liệu** khỏi cơ sở dữ liệu. Thay vào đó, nó chỉ thu nhỏ kích thước của tệp dữ liệu bằng cách loại bỏ không gian trống. Do đó, **lệnh này không gây mất dữ liệu hiện có** trong cơ sở dữ liệu.

Tuy nhiên, cần lưu ý rằng:

* **Lỗi trong quá trình thực thi:** Nếu xảy ra lỗi trong khi thực thi lệnh `DBCC SHRINKDATABASE`, có thể dẫn đến mất dữ liệu. Do đó, **nên sao lưu cơ sở dữ liệu trước khi thu nhỏ tệp**.
* **Mất dữ liệu do phân mảnh nghiêm trọng:** Trong trường hợp tệp dữ liệu bị phân mảnh nghiêm trọng, việc thu nhỏ tệp có thể dẫn đến mất dữ liệu.
