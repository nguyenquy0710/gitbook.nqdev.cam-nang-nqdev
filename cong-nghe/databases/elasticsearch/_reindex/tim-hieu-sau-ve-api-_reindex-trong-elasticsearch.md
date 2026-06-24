# Tìm hiểu sâu về API \_reindex trong Elasticsearch

API **\_reindex** trong Elasticsearch là một công cụ mạnh mẽ để sao chép hoặc chuyển đổi dữ liệu giữa các index. Bằng cách sử dụng API này, bạn có thể sao chép dữ liệu từ index này sang index khác, thay đổi cấu trúc của dữ liệu trong quá trình sao chép, và thực hiện các thao tác phức tạp khác. Dưới đây là một cái nhìn chi tiết về các tính năng và tùy chọn hỗ trợ trong API `_reindex`.

## 1. **Cấu Trúc Cơ Bản Của API \_Reindex**

Cấu trúc cơ bản của một yêu cầu `_reindex` như sau:

```json
POST _reindex
{
  "source": {
    "index": "source_index",  // Tên index nguồn
    "query": {                 // (Tùy chọn) Truy vấn lọc dữ liệu từ index nguồn
      "match_all": {}
    },
    "size": 1000               // (Tùy chọn) Số lượng tài liệu lấy trong mỗi lần truy vấn
  },
  "dest": {
    "index": "destination_index",  // Tên index đích
    "op_type": "index"             // Phương thức ghi tài liệu vào index đích (mặc định là "index")
  }
}
```

Trong đó:

* **source.index**: Chỉ định index nguồn.
* **source.query**: Câu truy vấn (query) để lọc dữ liệu trong index nguồn.
* **source.size**: Chỉ định số lượng tài liệu mà mỗi lần truy vấn sẽ lấy.
* **dest.index**: Chỉ định index đích mà dữ liệu sẽ được chuyển đến.

## 2. **Các Tùy Chọn Chính Trong API \_Reindex**

Dưới đây là các tùy chọn mà bạn có thể sử dụng trong API `_reindex` để tùy chỉnh hành động sao chép dữ liệu:

### **2.1 `op_type`**

*   **Mô tả**: Chỉ định hành động ghi tài liệu vào index đích. Có hai giá trị chính:

    * `index` (mặc định): Tạo mới tài liệu trong index đích hoặc ghi đè tài liệu nếu tài liệu có `_id` trùng với tài liệu đã tồn tại.
    * `create`: Chỉ tạo tài liệu mới nếu tài liệu chưa tồn tại trong index đích. Nếu tài liệu đã tồn tại (có `_id` trùng), nó sẽ trả về lỗi.

    **Ví dụ**:
* ```json
  "op_type": "create"
  ```

### **2.2 `size`**

* **Mô tả**: Chỉ định số lượng tài liệu được lấy trong mỗi lần truy vấn khi di chuyển dữ liệu.
*   **Sử dụng**: Nếu bạn có một lượng dữ liệu lớn, bạn có thể muốn điều chỉnh giá trị này để tối ưu hiệu suất.

    **Ví dụ**:
* ```json
  "size": 5000  // Lấy 5000 tài liệu mỗi lần
  ```

### **2.3 `script`**

*   **Mô tả**: Sử dụng để thay đổi hoặc xử lý dữ liệu trong quá trình reindex. Bạn có thể áp dụng các script để sửa đổi giá trị của trường hoặc thêm các trường mới vào tài liệu trong quá trình sao chép.

    **Ví dụ**: Thêm một trường mới vào tài liệu trong index đích.
* ```json
  "script": {
    "source": "ctx._source['new_field'] = 'value'"
  }
  ```

### **2.4 `conflicts`**

*   **Mô tả**: Xử lý các xung đột khi ghi dữ liệu vào index đích.

    * `abort`: Mặc định, nếu có xung đột, hành động sẽ bị hủy bỏ.
    * `proceed`: Tiếp tục quá trình nếu có xung đột và bỏ qua tài liệu gây xung đột.

    **Ví dụ**:
* ```json
  "conflicts": "proceed"
  ```

### **2.5 `wait_for_completion`**

*   **Mô tả**: Chỉ định xem yêu cầu `_reindex` có thực hiện đồng bộ (wait for completion) hay không.

    * `true` (mặc định): Yêu cầu sẽ chờ đợi và trả kết quả khi quá trình reindex hoàn tất.
    * `false`: Yêu cầu sẽ trả ngay kết quả mà không đợi quá trình reindex hoàn tất.

    **Ví dụ**:
* ```json
  "wait_for_completion": false  // Quá trình reindex sẽ không đợi và trả kết quả ngay
  ```

### **2.6 `scroll`**

*   **Mô tả**: Tùy chọn này cho phép bạn sử dụng cơ chế **scroll** khi di chuyển một lượng lớn dữ liệu, giúp phân tách việc di chuyển dữ liệu thành nhiều phần nhỏ.

    * `scroll`: Thời gian scroll, ví dụ `10m` (10 phút).

    **Ví dụ**:
* ```json
  "scroll": "10m"  // Chỉ định thời gian scroll là 10 phút
  ```

### **2.7 `routing`**

*   **Mô tả**: Chỉ định chiến lược phân phối tài liệu vào các shard khi reindex. Thường được sử dụng khi bạn có shard riêng biệt và muốn điều chỉnh dữ liệu vào shard cụ thể.

    **Ví dụ**:
* ```json
  "routing": "user_id"  // Phân phối tài liệu vào shard dựa trên trường "user_id"
  ```

## 3. **Các Tình Huống Sử Dụng API \_Reindex**

Dưới đây là một số tình huống điển hình khi sử dụng **API \_reindex** trong Elasticsearch:

### **3.1 Di Chuyển Dữ Liệu Giữa Các Index**

Giả sử bạn muốn chuyển toàn bộ dữ liệu từ index `old_index` sang index `new_index`, có thể sử dụng `_reindex` mà không cần bất kỳ truy vấn hay điều kiện đặc biệt nào:

```json
POST _reindex
{
  "source": {
    "index": "old_index"
  },
  "dest": {
    "index": "new_index"
  }
}
```

### **3.2 Di Chuyển Dữ Liệu Với Điều Kiện Lọc**

Bạn có thể chỉ di chuyển một phần dữ liệu đáp ứng điều kiện lọc. Ví dụ, chỉ di chuyển các tài liệu có trường `date` nhỏ hơn ngày **1/1/2021**:

```json
POST _reindex
{
  "source": {
    "index": "old_index",
    "query": {
      "range": {
        "date": {
          "lt": "2021-01-01"
        }
      }
    }
  },
  "dest": {
    "index": "new_index"
  }
}
```

### **3.3 Chỉnh Sửa Dữ Liệu Trong Quá Trình Reindex**

Nếu bạn muốn thay đổi dữ liệu khi di chuyển, có thể sử dụng **script** để thêm hoặc chỉnh sửa các trường trong tài liệu.

```json
POST _reindex
{
  "source": {
    "index": "old_index"
  },
  "dest": {
    "index": "new_index",
    "script": {
      "source": "ctx._source['new_field'] = 'new_value'"
    }
  }
}
```

### **3.4 Reindex Với Điều Kiện Xung Đột**

Khi sử dụng `op_type: create`, bạn có thể gặp phải xung đột nếu tài liệu với `_id` đã tồn tại. Bạn có thể sử dụng tùy chọn `conflicts` để xử lý tình huống này.

```json
POST _reindex
{
  "source": {
    "index": "old_index"
  },
  "dest": {
    "index": "new_index",
    "op_type": "create",
    "conflicts": "proceed"
  }
}
```

## 4. **Tổng Kết**

API **\_reindex** trong Elasticsearch cung cấp nhiều tùy chọn linh hoạt để di chuyển, sao chép và chuyển đổi dữ liệu giữa các index. Các tính năng mạnh mẽ như lọc dữ liệu qua `query`, chỉnh sửa dữ liệu qua `script`, xử lý xung đột qua `conflicts`, và phân phối tài liệu qua `routing` giúp người dùng tối ưu hóa quy trình sao chép dữ liệu trong các môi trường Elasticsearch phức tạp.

Thông qua việc hiểu và sử dụng các tùy chọn này, bạn có thể đảm bảo rằng quá trình di chuyển dữ liệu sẽ diễn ra một cách hiệu quả, an toàn và tối ưu hóa tài nguyên.
