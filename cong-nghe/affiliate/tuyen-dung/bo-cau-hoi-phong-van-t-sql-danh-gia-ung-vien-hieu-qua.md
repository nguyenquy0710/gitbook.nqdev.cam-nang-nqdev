# Bộ câu hỏi phỏng vấn T-SQL – Đánh giá ứng viên hiệu quả

## **1. Giới thiệu**

Phỏng vấn ứng viên cho vị trí liên quan đến SQL Server và T-SQL đòi hỏi bộ câu hỏi chi tiết để đánh giá kiến thức, kỹ năng phân tích, tối ưu hóa truy vấn và khả năng giải quyết vấn đề thực tế. Dưới đây là danh sách các câu hỏi quan trọng, mục đích đánh giá của chúng và cách ứng viên có thể trả lời.

## **2. Bộ Câu Hỏi Phỏng Vấn T-SQL**

### **A. Kiến thức nền tảng về SQL & T-SQL**

1. **Bạn biết gì về CTE (Common Table Expressions) trong T-SQL và khi nào sử dụng chúng?**
   * _Mục đích_: Kiểm tra sự hiểu biết về CTE, ứng dụng trong việc viết truy vấn phức tạp và tối ưu hóa mã SQL.
2. **Khi xóa dữ liệu của một bảng thì kích thước của bảng có giảm không?**
   * _Mục đích_: Đánh giá hiểu biết về quản lý không gian lưu trữ, tác động của `DELETE` và `TRUNCATE` đối với cơ sở dữ liệu.
3. **IDENTITY trong SQL là gì?**
   * _Mục đích_: Kiểm tra kiến thức về tự động tăng giá trị của một cột, thường dùng trong khóa chính.
4. **Index trong SQL là gì? Khi nào nên sử dụng Index?**
   * _Mục đích_: Đánh giá khả năng tối ưu hóa truy vấn bằng Index, hiểu về lợi ích và chi phí khi sử dụng.
5. **Sự khác nhau giữa JOIN và UNION?**
   * _Mục đích_: Kiểm tra khả năng phân biệt và ứng dụng đúng kỹ thuật trong kết hợp dữ liệu từ nhiều bảng.
6. **Bạn có thể giải thích các loại JOIN trong T-SQL không?**
   * _Mục đích_: Kiểm tra kiến thức về INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN.
7. **T-SQL là gì và nó khác gì so với SQL chuẩn?**
   * _Mục đích_: Xác định sự hiểu biết về T-SQL như một phần mở rộng của SQL Server với nhiều tính năng bổ sung.
8. **Cách sử dụng các câu lệnh GROUP BY và HAVING trong T-SQL?**
   * _Mục đích_: Đánh giá kỹ năng tổng hợp dữ liệu và lọc nhóm dữ liệu.

### **B. Xử lý dữ liệu & Hiệu suất**

9. **Bạn đã từng tối ưu hóa một truy vấn T-SQL chưa? Bạn làm cách nào để cải thiện hiệu suất của một truy vấn chậm?**
   * _Mục đích_: Kiểm tra khả năng phân tích truy vấn, sử dụng Execution Plan, Index, Partitioning, Caching.
10. **Bạn có thể giải thích về Index trong T-SQL và cách chúng cải thiện hiệu suất của truy vấn?**

* _Mục đích_: Kiểm tra hiểu biết về Clustered Index, Non-Clustered Index, Covering Index.

11. **Blocking trong SQL là gì?**

* _Mục đích_: Đánh giá khả năng xử lý xung đột truy cập dữ liệu đồng thời.

12. **Bạn có thể giải thích về các hàm window trong T-SQL như ROW\_NUMBER(), RANK(), và DENSE\_RANK()?**

* _Mục đích_: Kiểm tra khả năng sử dụng Window Functions để xử lý các bài toán xếp hạng dữ liệu.

### **C. Quản lý giao dịch và xử lý lỗi**

13. **Cách bạn xử lý lỗi trong T-SQL?**

* _Mục đích_: Kiểm tra kiến thức về TRY...CATCH và cách xử lý lỗi trong quá trình thực thi truy vấn.

14. **Giải thích về các transaction trong T-SQL và cách sử dụng COMMIT, ROLLBACK?**

* _Mục đích_: Kiểm tra khả năng quản lý tính nhất quán của dữ liệu khi thực hiện thay đổi.

15. **Trigger là gì?**

* _Mục đích_: Đánh giá hiểu biết về Triggers và cách sử dụng chúng để tự động hóa quy trình xử lý dữ liệu.

16. **View là gì? Lợi ích của Views là gì?**

* _Mục đích_: Kiểm tra khả năng sử dụng Views để tạo các truy vấn trừu tượng hóa dữ liệu.

### **D. Xử lý tình huống thực tế**

17. **Câu hỏi tình huống: Bạn đang làm việc trên một hệ thống quản lý bán hàng có cơ sở dữ liệu chứa thông tin về đơn hàng, sản phẩm và khách hàng. Một ngày, bạn nhận được yêu cầu rằng một số báo cáo tổng kết doanh thu hàng tháng của công ty đang bị chậm và không thể hoàn thành đúng hạn. Sau khi kiểm tra, bạn phát hiện rằng các truy vấn SQL chạy rất chậm, đặc biệt khi thực hiện các phép tính tổng hợp cho các đơn hàng và sản phẩm trong một khoảng thời gian dài. Hãy mô tả cách bạn sẽ tiếp cận vấn đề này, từ việc phân tích nguyên nhân cho đến các biện pháp tối ưu hóa truy vấn và hệ thống cơ sở dữ liệu để giải quyết tình huống trên.**

* _Mục đích_: Đánh giá khả năng phân tích, tư duy logic, xác định nguyên nhân gây chậm truy vấn và đề xuất giải pháp như Indexing, Partitioning, Query Optimization.

## **3. Kết luận**

Bộ câu hỏi trên giúp đánh giá toàn diện ứng viên từ kiến thức nền tảng về SQL/T-SQL, kỹ năng tối ưu hóa truy vấn, quản lý giao dịch, xử lý lỗi đến khả năng giải quyết tình huống thực tế. Khi phỏng vấn, nhà tuyển dụng có thể chọn lọc câu hỏi phù hợp với từng vị trí như DBA, Data Engineer hoặc SQL Developer.

***

📌 **Bạn đã từng phỏng vấn hoặc được phỏng vấn với các câu hỏi trên chưa? Hãy chia sẻ kinh nghiệm của bạn trong phần bình luận!** 🚀
