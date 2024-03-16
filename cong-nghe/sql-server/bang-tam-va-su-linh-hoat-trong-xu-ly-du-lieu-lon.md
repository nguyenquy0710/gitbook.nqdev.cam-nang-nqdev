---
description: >-
  Bảng tạm (temporary table) là một loại bảng tạm thời được sử dụng trong cơ sở
  dữ liệu để lưu trữ tạm thời các dữ liệu trong quá trình xử lý truy vấn. Sử
  dụng bảng tạm trong xử lý dữ liệu lớn có nhiều
---

# Bảng tạm và sự linh hoạt trong xử lý dữ liệu lớn

Bảng tạm (temporary table) là một công cụ quan trọng trong SQL Server để tạm thời lưu trữ dữ liệu trong quá trình thực hiện các truy vấn phức tạp. Tuy nhiên, nhiều người dùng vẫn chưa biết đầy đủ về các tính năng và cách sử dụng của bảng tạm. Trong bài viết này, chúng ta sẽ tìm hiểu thêm về bảng tạm và những điều bạn chưa biết về chúng.

<figure><img src="https://datas.quyit.id.vn/gitbook/blogs/sql-server/db-tempdb.png" alt=""><figcaption><p><em>temporary table</em></p></figcaption></figure>

## 1. Bảng tạm là gì?

Bảng tạm (temporary table) là một loại bảng được tạo ra trong bộ nhớ của SQL Server để lưu trữ tạm thời các dữ liệu trong quá trình xử lý truy vấn. Sử dụng bảng tạm trong xử lý dữ liệu lớn có nhiều ưu điểm, tuy nhiên cũng tồn tại những giới hạn và hạn chế.

## 2. Tại sao nên sử dụng bảng tạm?

Có nhiều ưu điểm khi sử dụng bảng tạm trong hệ thống có lượng dữ liệu lớn, trong đó có thể kể đến:

* Tốc độ truy vấn nhanh hơn: Vì dữ liệu được lưu trữ trong bộ nhớ RAM, nên truy vấn và xử lý sẽ nhanh hơn so với bảng vĩnh viễn lưu trữ trên ổ cứng.
* Giảm thiểu tải cho máy chủ: Khi sử dụng bảng tạm, các truy vấn không ảnh hưởng đến bảng chính, giúp giảm thiểu tải cho máy chủ.
* Tính linh hoạt cao: Bảng tạm được tạo ra để phục vụ cho mục đích cụ thể, có thể tạo và xóa bất cứ lúc nào, giúp tăng tính linh hoạt trong quá trình thực hiện truy vấn.

## 3. Các loại bảng tạm

Có hai loại bảng tạm chính: **bảng tạm (`#temporary table`)** và **bảng tạm chia sẻ (`##global temporary table`)**. Bảng tạm chỉ tồn tại trong phiên làm việc hiện tại, trong khi bảng tạm chia sẻ có thể được truy cập từ nhiều phiên làm việc khác nhau.

## 4. Cách sử dụng bảng tạm

Cách sử dụng bảng tạm phụ thuộc vào mục đích sử dụng và yêu cầu của từng truy vấn cụ thể. Tuy nhiên, dưới đây là một số ví dụ về cách sử dụng bảng tạm trong SQL Server:

### Sử dụng bảng tạm để lưu trữ tập hợp dữ liệu tạm thời

Trong nhiều trường hợp, bạn có thể cần tạm thời lưu trữ một tập hợp dữ liệu để sử dụng trong quá trình thực hiện các truy vấn khác. Ví dụ, bạn có thể muốn lưu trữ danh sách các sản phẩm mới nhất để hiển thị trên trang web của mình. Trong trường hợp này, bạn có thể sử dụng câu lệnh `SELECT INTO` để tạo bảng tạm và sao chép dữ liệu vào bảng đó như sau:

```sql
SELECT *
INTO #NewProducts
FROM Products
WHERE DateAdded >= '2022-01-01'
```

Trong ví dụ này, bảng tạm `#NewProducts` sẽ chứa tất cả các sản phẩm được thêm vào sau ngày 1/1/2022.

### Sử dụng bảng tạm để lưu trữ các kết quả truy vấn tạm thời

Trong nhiều trường hợp, bạn có thể muốn thực hiện các truy vấn phức tạp nhưng không muốn lưu kết quả vào một bảng lưu trữ vĩnh viễn. Trong trường hợp này, bạn có thể sử dụng bảng tạm để lưu trữ các kết quả truy vấn tạm thời. Ví dụ, bạn có thể sử dụng câu lệnh SELECT INTO để tạo bảng tạm và lưu trữ các kết quả truy vấn như sau:

```sql
SELECT Customers.CustomerID, Orders.OrderDate
INTO #CustomerOrders
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Customers.Country = 'USA'
```

Trong ví dụ này, bảng tạm `#CustomerOrders` sẽ chứa danh sách các đơn đặt hàng của khách hàng tại Hoa Kỳ, bao gồm mã khách hàng và ngày đặt hàng.

### Sử dụng bảng tạm để tối ưu hóa hiệu suất truy vấn

Trong nhiều trường hợp, bạn có thể sử dụng bảng tạm để tối ưu hóa hiệu suất truy vấn. Ví dụ, bạn có thể sử dụng bảng tạm để tạm thời lưu trữ kết quả của các truy vấn Các câu lệnh trên có thể được sử dụng để thực hiện các truy vấn phức tạp trên bảng tạm, giúp bạn xử lý dữ liệu một cách nhanh chóng và dễ dàng.

## 5. Lưu ý

Mặc dù bảng tạm có nhiều ưu điểm, tuy nhiên khi sử dụng trong các hệ thống có lượng dữ liệu lớn, bạn cần lưu ý những điểm sau để tránh gặp phải các vấn đề liên quan đến hiệu suất và tài nguyên của hệ thống.

1. **Tối ưu hóa truy vấn**: Việc tối ưu hóa truy vấn là cực kỳ quan trọng khi sử dụng bảng tạm. Bạn cần cân nhắc cách tối ưu hóa các truy vấn để tránh tình trạng thời gian chờ hoặc sử dụng quá nhiều tài nguyên của hệ thống.
2. **Xóa bảng tạm khi không sử dụng**: Bảng tạm tồn tại trong bộ nhớ RAM của hệ thống, nên khi không sử dụng nữa, bạn nên xóa bảng tạm để giải phóng tài nguyên cho hệ thống.
3. **Sử dụng bảng tạm đúng cách**: Sử dụng bảng tạm không đúng cách có thể dẫn đến các lỗi không mong muốn, ảnh hưởng đến hiệu suất và tính ổn định của hệ thống. Bạn cần tìm hiểu và nắm vững cách sử dụng bảng tạm đúng cách để tránh những rủi ro này.
4. **Sử dụng bảng tạm phù hợp với mục đích**: Bảng tạm không phải là giải pháp tốt nhất cho mọi tình huống. Bạn cần xác định mục đích sử dụng của mình và chọn loại bảng tạm phù hợp để đạt được hiệu quả tối đa.

## 6. Kết luận

Bảng tạm là một công cụ quan trọng trong SQL Server để xử lý dữ liệu tạm thời trong quá trình thực hiện các truy vấn phức tạp. Tuy nhiên, để sử dụng bảng tạm đúng cách và tránh các rủi ro liên quan đến hiệu suất và tài nguyên, bạn cần nắm vững những kiến thức cơ bản về bảng tạm và cách sử dụng chúng đúng cách.
