# SQL Server: Tập lệnh để tìm tất cả các giá trị Mặc định với Cột

Trong bài đăng này, tôi đang chia sẻ một tập lệnh để tìm tất cả các giá trị mặc định của các cột trong SQL Server.\
Đôi khi, nó yêu cầu tìm các giá trị mặc định của một cột đang tạo ra sự cố trong quá trình di chuyển dữ liệu.

Bạn có thể dễ dàng tìm thấy các giá trị mặc định trong tập lệnh định nghĩa bảng, nhưng nếu bạn cần báo cáo về tất cả các giá trị mặc định của cơ sở dữ liệu, bạn chỉ muốn một tập lệnh để tìm tất cả các giá trị mặc định.

Sử dụng tập lệnh bên dưới, bạn có thể nhận được tất cả các giá trị mặc định và cũng như nếu bạn yêu cầu tìm giá trị mặc định cụ thể, bạn có thể thêm bộ lọc trong mệnh đề WHERE.

{% code overflow="wrap" lineNumbers="true" fullWidth="false" %}
```sql
SELECT SO.name AS TableName,
       SC.name AS ColumnName,
       SSM.text AS DefaultValue
FROM dbo.sysobjects AS SO
    INNER JOIN dbo.syscolumns AS SC ON SO.id = SC.id
    INNER JOIN dbo.syscomments AS SSM ON SC.cdefault = SSM.id
WHERE SO.xtype = 'U'
ORDER BY SO.name, SC.colid
```
{% endcode %}

#### Kết Luận

Trong bài viết này, chúng ta đã thảo luận về cách tìm tất cả các giá trị mặc định của các cột trong SQL Server sử dụng tập lệnh SQL đơn giản nhưng mạnh mẽ. Việc hiểu và sử dụng tập lệnh này có thể giúp bạn dễ dàng giải quyết những vấn đề liên quan đến giá trị mặc định trong quá trình di chuyển dữ liệu hoặc phát triển cơ sở dữ liệu của mình. Hãy nhớ thử nghiệm tập lệnh này trong môi trường phát triển trước khi áp dụng nó vào môi trường sản xuất, để đảm bảo hiệu quả và tính chính xác của quá trình làm việc.

Đừng quên tham khảo tài liệu thêm [tại đây](./) để nâng cao kiến thức và kỹ năng làm việc với SQL Server của bạn!

{% code overflow="wrap" %}
```markdown
Tài liệu tham khảo:
- https://www.thachphong.com/t/sql-server/sql-server-tap-lenh-de-tim-tat-ca-cac-gia-tri-mac-dinh-voi-cot_874
```
{% endcode %}
