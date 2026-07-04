---
description: >-
  Redis là một cơ sở dữ liệu NoSQL hiệu năng cao, thường được sử dụng để lưu trữ
  dữ liệu trong bộ nhớ (in-memory) nhằm tăng tốc độ truy xuất và xử lý.
---

# Redis Cheat Sheat: Hướng dẫn nhanh cho người mới bắt đầu

Bài viết này sẽ cung cấp cho bạn một **Redis Cheat Sheet** tổng hợp các lệnh cơ bản, hữu ích để làm việc với Redis hiệu quả hơn.

***

## **Redis là gì?**

Redis (REmote DIctionary Server) là cơ sở dữ liệu NoSQL in-memory, mã nguồn mở, thường được sử dụng để:

* Lưu trữ bộ nhớ đệm (cache).
* Xử lý hàng đợi công việc.
* Phân tích dữ liệu thời gian thực.

Redis hỗ trợ nhiều kiểu dữ liệu như **String**, **List**, **Set**, **Hash**, và **Sorted Set**, giúp nó linh hoạt và mạnh mẽ trong nhiều ứng dụng.

## **1. Khởi Đầu Với Redis**

### **Cài Đặt Redis**

* Cài đặt Redis qua package manager:
* ```bash
  sudo apt update && sudo apt install redis
  ```
* Khởi động Redis server:
* ```bash
  redis-server
  ```
* Kết nối đến Redis CLI:
* ```bash
  redis-cli
  ```

***

## **2. Lệnh Cơ Bản**

| **Lệnh**        | **Chức năng**                                      |
| --------------- | -------------------------------------------------- |
| `PING`          | Kiểm tra kết nối đến Redis server (trả về `PONG`). |
| `SET key value` | Lưu một giá trị vào key.                           |
| `GET key`       | Lấy giá trị của key.                               |
| `DEL key`       | Xóa một key.                                       |
| `EXISTS key`    | Kiểm tra xem key có tồn tại hay không.             |
| `KEYS pattern`  | Tìm tất cả các key khớp với pattern.               |
| `FLUSHALL`      | Xóa toàn bộ dữ liệu trong Redis.                   |
| `FLUSHDB`       | Xóa tất cả dữ liệu trong database hiện tại.        |

***

## **3. Làm Việc Với TTL (Time-to-Live)**

| **Lệnh**             | **Chức năng**                                      |
| -------------------- | -------------------------------------------------- |
| `EXPIRE key seconds` | Thiết lập thời gian sống cho key (tính bằng giây). |
| `TTL key`            | Xem thời gian sống còn lại của key.                |
| `PERSIST key`        | Xóa TTL, biến key thành key vĩnh viễn.             |

***

## **4. Các Kiểu Dữ Liệu Trong Redis**

### **4.1. Chuỗi (String)**

| **Lệnh**               | **Chức năng**                                  |
| ---------------------- | ---------------------------------------------- |
| `APPEND key value`     | Thêm `value` vào cuối giá trị của `key`.       |
| `STRLEN key`           | Lấy độ dài của giá trị trong key.              |
| `INCR key`             | Tăng giá trị số nguyên của key lên 1.          |
| `DECR key`             | Giảm giá trị số nguyên của key đi 1.           |
| `INCRBY key increment` | Tăng giá trị số nguyên của key theo bước tăng. |

***

### **4.2. Danh Sách (List)**

| **Lệnh**                | **Chức năng**                                          |
| ----------------------- | ------------------------------------------------------ |
| `LPUSH key value`       | Thêm một giá trị vào đầu danh sách.                    |
| `RPUSH key value`       | Thêm một giá trị vào cuối danh sách.                   |
| `LPOP key`              | Lấy và xóa phần tử đầu tiên trong danh sách.           |
| `RPOP key`              | Lấy và xóa phần tử cuối cùng trong danh sách.          |
| `LRANGE key start stop` | Lấy các phần tử từ `start` đến `stop` trong danh sách. |

***

### **4.3. Tập Hợp (Set)**

| **Lệnh**              | **Chức năng**                                    |
| --------------------- | ------------------------------------------------ |
| `SADD key value`      | Thêm một giá trị vào tập hợp.                    |
| `SREM key value`      | Xóa giá trị khỏi tập hợp.                        |
| `SMEMBERS key`        | Lấy tất cả các giá trị trong tập hợp.            |
| `SISMEMBER key value` | Kiểm tra xem giá trị có nằm trong tập hợp không. |
| `SUNION key1 key2`    | Lấy hợp của hai tập hợp.                         |

***

### **4.4. Tập Hợp Có Thứ Tự (Sorted Set)**

| **Lệnh**                    | **Chức năng**                                |
| --------------------------- | -------------------------------------------- |
| `ZADD key score value`      | Thêm một giá trị với điểm số vào sorted set. |
| `ZRANGE key start stop`     | Lấy các giá trị theo thứ tự tăng dần.        |
| `ZRANGEBYSCORE key min max` | Lấy các giá trị trong khoảng điểm số.        |
| `ZREM key value`            | Xóa một giá trị khỏi sorted set.             |

***

### **4.5. Băm (Hash)**

| **Lệnh**               | **Chức năng**                               |
| ---------------------- | ------------------------------------------- |
| `HSET key field value` | Thêm một cặp field-value vào hash.          |
| `HGET key field`       | Lấy giá trị của một field trong hash.       |
| `HDEL key field`       | Xóa một field trong hash.                   |
| `HGETALL key`          | Lấy tất cả các field và giá trị trong hash. |

***

## **5. Quản Lý Database**

| **Lệnh**       | **Chức năng**                                  |
| -------------- | ---------------------------------------------- |
| `SELECT index` | Chuyển đổi sang database khác (mặc định là 0). |
| `DBSIZE`       | Xem số lượng key trong database hiện tại.      |
| `SAVE`         | Lưu dữ liệu vào file dump.rdb.                 |
| `BGSAVE`       | Lưu dữ liệu không đồng bộ vào file dump.rdb.   |
| `INFO`         | Hiển thị thông tin server Redis.               |

***

## **6. Sao Lưu và Khôi Phục Dữ Liệu**

* **Sao lưu**: Redis lưu dữ liệu tự động trong file `dump.rdb` hoặc bạn có thể thực hiện lệnh:
* ```bash
  SAVE
  ```
* **Khôi phục**: Đưa file `dump.rdb` vào thư mục Redis data directory, sau đó khởi động lại Redis server.

***

## **7. Mẹo Sử Dụng Redis Hiệu Quả**

1. **Sử dụng TTL để tối ưu bộ nhớ**: Đặt TTL cho các key không cần lưu trữ lâu dài.
2. **Theo dõi hiệu năng**: Sử dụng lệnh `MONITOR` để theo dõi hoạt động của Redis trong thời gian thực.
3. **Phân loại dữ liệu**: Sử dụng tiền tố (prefix) cho các key để quản lý dữ liệu dễ dàng hơn. Ví dụ: `user:1:name`, `user:1:age`.

***

## **8. Tài Liệu Tham Khảo**

* [Redis Official Cheat Sheet](https://redis.io/learn/howtos/quick-start/cheat-sheet)
* Redis Command Documentation

***

## **Kết Luận**

Redis là một công cụ mạnh mẽ với khả năng xử lý nhanh và hiệu quả. Hiểu rõ các lệnh và kiểu dữ liệu trong Redis sẽ giúp bạn tận dụng tối đa lợi ích mà nó mang lại. Hãy lưu lại cheat sheet này để tham khảo khi làm việc với Redis! 🚀
