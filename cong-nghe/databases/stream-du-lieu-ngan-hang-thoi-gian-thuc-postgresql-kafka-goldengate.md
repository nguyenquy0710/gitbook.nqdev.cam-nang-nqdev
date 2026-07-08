---
description: >-
  Xây dựng CDC pipeline từ PostgreSQL sang Kafka dùng Oracle GoldenGate — loại bỏ batch jobs về đêm, stream giao dịch ngân hàng với độ trễ dưới 10 giây.
---

# Stream dữ liệu ngân hàng thời gian thực với PostgreSQL, Kafka và GoldenGate

Hệ thống core banking truyền thống vận hành theo mô hình batch: cuối ngày dump dữ liệu từ OLTP sang Data Warehouse, sáng hôm sau mới có báo cáo. Bài viết này giới thiệu kiến trúc **CDC (Change Data Capture)** dùng Oracle GoldenGate để stream giao dịch từ PostgreSQL lên Kafka với độ trễ mili-giây, loại bỏ hoàn toàn batch jobs về đêm.

<figure><img src="https://substack-post-media.s3.amazonaws.com/public/images/a5abb09f-ae11-4520-b8fa-ec670b5525ae_1536x1024.png" alt="Kiến trúc CDC với Oracle GoldenGate"><figcaption><p>Kiến trúc tổng quan CDC pipeline từ PostgreSQL sang Kafka qua Oracle GoldenGate</p></figcaption></figure>

## **CDC với Oracle GoldenGate là gì?**

Oracle GoldenGate CDC là cơ chế capture các thay đổi ở mức row (INSERT, UPDATE, DELETE) từ source database và đồng bộ sang target system theo thời gian thực.

Thay vì quét full-table, GoldenGate kết nối trực tiếp vào Logical Replication mechanism của PostgreSQL, đọc file **WAL (Write-Ahead Logging)**, decode các thay đổi, và vận chuyển chúng với độ trễ mili-giây.

## **Tại sao streaming data lại quan trọng?**

Hầu hết core banking system vẫn dùng batch model:
- Giao dịch dump từ OLTP → Data Warehouse lúc nửa đêm
- Báo cáo, fraud detection, dashboard của chi nhánh **sáng hôm sau** mới phản ánh số liệu hôm qua
- Chậm trễ trong phát hiện gian lận và ra quyết định

Chuyển sang CDC streaming architecture loại bỏ hoàn toàn độ trễ này — dữ liệu có sẵn **ngay khi giao dịch xảy ra**.

<figure><img src="https://substack-post-media.s3.amazonaws.com/public/images/c6cc8c04-1d19-4ffa-bdec-438cb3211ca1_765x179.png" alt="So sánh CDC streaming vs batch"><figcaption><p>So sánh giữa batch processing truyền thống và CDC streaming real-time</p></figcaption></figure>

## **Kiến trúc hệ thống**

Luồng dữ liệu gồm 4 thành phần chính:

```
PostgreSQL (WAL) → Replication Slot → Extract → Trail File → Replicat → Kafka
```

<figure><img src="https://substack-post-media.s3.amazonaws.com/public/images/b35ed680-fe71-45ad-82b4-7f76d4dabff6_1536x1024.png" alt="Oracle GoldenGate 26ai Microservices Architecture"><figcaption><p>Kiến trúc Oracle GoldenGate 26ai (Microservices Architecture) với 4 thành phần cốt lõi</p></figcaption></figure>

### 1. Logical Replication Slot (tại Source PostgreSQL)

Mặc định PostgreSQL ghi đè/xoá WAL ngay sau khi flush xuống disk để tiết kiệm dung lượng. Nếu CDC system bị chậm hoặc mất kết nối, WAL có thể bị xoá trước khi được đọc → mất dữ liệu.

**Replication Slot** giải quyết vấn đề này: nó hoạt động như một "anchor", buộc PostgreSQL giữ WAL đến khi GoldenGate xác nhận đã consume. Đồng thời, thông qua output plugin (`pgoutput`), nó decode WAL (nhị phân) thành các logical events (INSERT/UPDATE/DELETE).

### 2. Extract Process (Collection)

Extract đóng vai trò logical decoding client, kết nối trực tiếp vào PostgreSQL Replication Slot. Nó nhận **Logical Change Records (LCRs)**, chuẩn hoá các data type đặc thù của PostgreSQL sang format chung, và ghi vào Trail File.

### 3. Trail File (Local Buffer)

Trail Files là các file nhị phân lưu transaction theo thứ tự. Chúng đóng vai trò buffer quan trọng để decouple tốc độ đọc của Extract và tốc độ ghi của Replicat:

- Nếu Kafka gặp sự cố, Extract vẫn tiếp tục đọc WAL và giải phóng disk cho Postgres
- Dữ liệu pending được lưu an toàn trong Trail File, không bị mất

### 4. Replicat Process (Big Data Sync)

Sử dụng GoldenGate for Big Data, Replicat đóng vai trò Kafka Producer. Nó đọc tuần tự Trail Files, chuyển đổi dữ liệu sang JSON hoặc Avro, và push messages vào các topic tương ứng trên Apache Kafka.

## **Lợi ích khi áp dụng**

* **Loại bỏ batch jobs về đêm:** Dữ liệu sẵn sàng real-time, không cần cửa sổ ETL vào 0h-6h sáng
* **Giảm tải source database:** Chỉ đọc WAL, không chạy full-table scan query
* **Độ trễ mili-giây:** Giao dịch banking xuất hiện trên Kafka chỉ sau vài giây
* **Exactly-once semantics:** GoldenGate đảm bảo mỗi thay đổi được deliver đúng một lần
* **Không mất dữ liệu:** Replication Slot + Trail File đảm bảo WAL không bị xoá trước khi xử lý xong

## **Use cases điển hình**

* **Real-time fraud detection:** Stream giao dịch vào Kafka → Spark Streaming / Flink phát hiện bất thường ngay lập tức
* **Dashboard thời gian thực:** Branch manager thấy số dư/giao dịch mà không cần đợi batch sáng hôm sau
* **Data Lake ingestion:** Đẩy dữ liệu từ core banking vào Delta Lake / Iceberg qua Kafka Connect
* **Caching invalidation:** Khi dữ liệu thay đổi, publish event → invalidate cache (Redis) tức thì
* **Microservices event bus:** Các service downstream subscribe vào Kafka topic để phản ứng với thay đổi dữ liệu

## **Kết luận**

CDC với Oracle GoldenGate là giải pháp proven cho bài toán streaming dữ liệu từ core banking PostgreSQL lên Kafka. Kiến trúc 4 thành phần (Replication Slot → Extract → Trail File → Replicat) vừa đảm bảo không mất dữ liệu, vừa không gây áp lực lên source database — giúp ngân hàng thoát khỏi batch model truyền thống và vận hành theo hướng event-driven, thời gian thực.

<figure><img src="https://img.vietqr.io/image/MB-VQRQAAXGO9340-gjSyj8L.png?amount=10000&#x26;accountName=NGUYEN%20HUU%20QUY&#x26;addInfo=Mua%20ca%20phe%20cho%20NQDEV" alt=""><figcaption></figcaption></figure>
