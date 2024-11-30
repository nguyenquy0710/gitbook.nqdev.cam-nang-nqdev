---
description: 'Nguồn: devopsvn.tech'
---

# Redis mất dữ liệu khi restart

Mặc đinh khi restart thì Redis mất dữ liệu. Làm thế nào để tránh mất dữ liệu?

<figure><img src="../../.gitbook/assets/image.png" alt=""><figcaption></figcaption></figure>

Có hai phương pháp khắc phục: sử dụng RDB (Redis Database) hoặc AOF (Append Only File)

## Redis Database - RDB

RDB là phương pháp tạo snapshots và khôi phục dữ liệu thủ công bằng câu lệnh Redis, mặc định tệp tin snapshots tên là **`dump.rdb`**. Để tạo snapshots bạn chạy câu lệnh [**`SAVE`**](https://redis.io/commands/save) hoặc [**`BGSAVE`**](https://redis.io/commands/bgsave), ví dụ:

```
save 30 500
```

Câu lệnh trên chỉ định Redis tự động tạo snapshots mỗi 30 giây nếu có ít nhất 500 key thay đổi.

## Append Only File - AOF

AOF là cấu hình để Redis lưu toàn bộ _write operation_ đã thực thi vào tệp tin. Khi Redis bị restart nó sẽ chạy lại tệp tin đó. Bạn bật AOF lên trong tệp tin cấu hình Redis như sau:

```
sudo nano /path/to/redis.conf
```

Tìm `appendonly` và sửa thành `yes`:

```
appendonly yes
```

Khi bạn bật thuộc tính này lên bất kì câu lệnh nào làm thay đổi dữ liệu Redis sẽ được lưu vào AOF. **Lưu ý** khi bật AOF có ảnh hưởng tới hiệu suất của Redis. Nếu máy chủ đủ mạnh thì bạn nên chạy câu lệnh snapshots từng giây, phương pháp này không gây ảnh hưởng tới hiệu suất của Redis. Tìm hiểu chi tiết tại [**Redis persistence**](https://redis.io/docs/management/persistence/)**.**

<img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"><img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích, hãy mời tôi một tách cà phê nha!_ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
