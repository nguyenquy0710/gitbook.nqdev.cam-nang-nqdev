---
description: >-
  Tài liệu này tổng hợp những câu lệnh thiết yếu nhất trong quá trình vận hành
  thực tế, kèm theo giải thích rõ ràng và hướng dẫn sử dụng.
---

# Cẩm nang Elasticsearch: Bộ câu lệnh giám sát – chẩn đoán – tối ưu mà kỹ sư nào cũng cần

Elasticsearch là nền tảng tìm kiếm mạnh mẽ, nhưng để vận hành ổn định và hiệu quả, kỹ sư cần theo dõi liên tục sức khỏe của cluster, hiệu năng tìm kiếm, dung lượng lưu trữ và nhiều thông số quan trọng khác.

Khi hệ thống Elasticsearch bắt đầu lớn dần, chúng ta không chỉ quan tâm đến dữ liệu, mà còn phải theo dõi “sức khỏe” của cluster, hiệu năng tìm kiếm, chỉ số lưu trữ, cấu hình node và rất nhiều yếu tố khác. Bộ câu lệnh dưới đây là những lệnh thực tế, thường xuyên được dùng để giám sát – phân tích – khắc phục sự cố.

Bài viết sẽ giúp bạn hiểu **ý nghĩa – mục đích – khi nào nên sử dụng** từng câu lệnh, để biến việc vận hành Elasticsearch trở nên chủ động và hiệu quả hơn.

***

## **1. Nhóm lệnh \_cat: Giám sát nhanh, trực quan**

Các API `_cat` của Elasticsearch thường trả về dữ liệu dạng bảng rất dễ đọc.

### **1.1 Kiểm tra shards**

```
GET _cat/shards?v=true
```

➡️ Hiển thị danh sách shard, trạng thái, node đang giữ shard.\
Dùng khi: kiểm tra shard bị đỏ, shard unassigned hoặc số shard quá nhiều.

***

### **1.2 Kiểm tra nodes**

```
GET _cat/nodes?v&h=ip,name,heap.percent,ram.percent,uptime,node.role
```

➡️ Xem danh sách node: IP, tên node, % RAM, % heap, role, uptime.\
Dùng khi: cần phát hiện node sắp hết heap, node vừa restart hoặc node bất thường.

***

### **1.3 Kiểm tra indices cơ bản**

```
GET _cat/indices?v&h=index,docs.count,store.size
```

➡️ Xem nhanh số lượng tài liệu và dung lượng mỗi index.

#### Danh sách index nặng nhất:

```
GET _cat/indices?v&s=store.size:desc&bytes=mb
```

➡️ Rất hữu ích khi điều tra index chiếm nhiều dung lượng nhất gây đầy ổ đĩa.

***

## **2. Nhóm lệnh kiểm tra Node Stats**

### **2.1 Thống kê node tổng quát**

```
GET _nodes/stats?pretty
```

➡️ Cung cấp toàn bộ thống kê của node: CPU, RAM, JVM, IO, network…

***

### **2.2 Thống kê chuyên sâu về search**

```
GET _nodes/stats/indices/search
```

➡️ Xem latency search, query time, fetch time.\
Dùng khi: điều tra search chậm.

***

### **2.3 Thông tin của node cụ thể**

```
GET _nodes/esms-node-1/stats?pretty
```

➡️ Hữu ích khi chỉ một node gặp sự cố (latency cao, heap đầy…).

***

### **2.4 Slowlog hiện tại**

```
GET _nodes/slowlog
```

➡️ Lấy danh sách truy vấn chậm đã được Elasticsearch ghi log.

***

### **2.5 Thống kê JVM**

```
GET _nodes/stats/jvm
```

➡️ Dùng để xem GC time, memory pool, heap usage — rất quan trọng trong tuning hiệu năng.

***

### **2.6 Nút “hot thread”**

```
GET _nodes/hot_threads
```

➡️ Hiển thị các thread đang tiêu tốn CPU cao.\
Dùng khi: node bị treo, CPU spike, search chậm bất thường.

***

## **3. Nhóm lệnh \_cluster: Kiểm tra toàn hệ thống**

### **3.1 Tình trạng chung của cluster**

```
GET _cluster/health
```

➡️ Màu sắc (green / yellow / red) phản ánh toàn bộ trạng thái cluster.

***

### **3.2 Thống kê tổng quan**

```
GET _cluster/stats
```

➡️ Số node, index, shard, dung lượng, field types…

***

### **3.3 Xem settings cluster**

```
GET _cluster/settings
GET _cluster/settings?include_defaults=true
```

➡️ Dùng để xem các cấu hình hiện tại hoặc cả giá trị mặc định.

***

### **3.4 Nhiệm vụ đang pending**

```
GET _cluster/pending_tasks
```

➡️ Phát hiện bottleneck trong cluster, đặc biệt khi reallocation chậm.

***

### **3.5 Tổng dung lượng tất cả index**

```
GET _cluster/stats?filter_path=indices.*.size_in_bytes
```

➡️ Trả về **một con số duy nhất** – rất tiện khi monitoring.

***

## **4. Nhóm lệnh thống kê hiệu năng index**

### **4.1 Thống kê tổng quan index**

```
GET _stats
```

***

### **4.2 Kiểm tra cache của từng index**

```
GET _stats?filter_path=indices.*.*.query_cache.memory_size_in_bytes
```

➡️ Hữu ích để đánh giá cache có hoạt động như kỳ vọng không.

***

### **4.3 Kiểm tra lượng dữ liệu lưu trong store**

```
GET _stats/store?filter_path=indices.*.total.store.size_in_bytes
```

***

## **5. Nhóm lệnh Tasks: Theo dõi và xử lý tác vụ**

### **5.1 Xem các tác vụ liên quan đến search**

```
GET /_tasks?detailed=true&actions=*search*&group_by=parents
```

➡️ Dùng khi search bị treo hoặc chiếm tài nguyên lâu.

***

### **5.2 Hủy tất cả task đang chạy**

```
POST /_tasks/_cancel
```

➡️ Cứu cluster khi có truy vấn quá nặng, task lang thang gây nghẽn.

***

## **6. Snapshot & Restore**

```
GET _snapshot/_status?pretty
GET _snapshot/_all?pretty
```

➡️ Dùng khi theo dõi tiến trình snapshot hoặc kiểm tra repository.

***

## **7. Nhóm lệnh Settings của index và cluster**

### **7.1 Xem hoặc thay đổi settings**

```
GET _settings
PUT _settings { ... }
```

➡️ Điều chỉnh giới hạn fields, result window… tùy theo nhu cầu.

Ví dụ tăng giới hạn:

```json
{
  "index.max_result_window": 500000000,
  "index.mapping.total_fields.limit": 100000000
}
```

***

### **7.2 Cài đặt slowlog**

```json
{
  "index.indexing.slowlog.threshold.index.warn": "10s",
  "index.indexing.slowlog.threshold.index.info": "5s",
  "index.indexing.slowlog.threshold.index.debug": "2s",
  "index.indexing.slowlog.threshold.index.trace": "500ms",
  "index.indexing.slowlog.source": "1000"
}
```

➡️ Giúp phát hiện truy vấn hoặc indexing operation chậm.

***

### **7.3 Gỡ block read-only**

```
PUT /_all/_settings
{
  "index.blocks.read_only_allow_delete": null
}
```

➡️ Thường dùng khi cluster bị đầy disk khiến ES tự động khóa chỉ mục.

***

### **7.4 Điều chỉnh watermark tạm thời**

```
PUT _cluster/settings
{
  "transient": {
    "cluster.routing.allocation.disk.watermark.flood_stage": "95%",
    "cluster.routing.allocation.disk.watermark.high": "90%",
    "cluster.routing.allocation.disk.watermark.low": "85%",
    "cluster.info.update.interval": "1m"
  }
}
```

➡️ Cứu cụm tạm thời khi sắp đầy ổ đĩa.

***

## **8. Các lệnh vệ sinh hệ thống**

### **8.1 Xóa cache**

```
POST _cache/clear
```

### **8.2 Xóa toàn bộ scroll context**

```
DELETE _search/scroll/_all
```

➡️ Dùng khi scroll query để lại session nặng gây tăng RAM.

***

## **Kết luận**

Tài liệu này không chỉ liệt kê câu lệnh mà còn cung cấp ý nghĩa và ngữ cảnh sử dụng. Khi bạn nắm vững bộ lệnh này, việc giám sát – tối ưu – xử lý sự cố Elasticsearch trở nên chủ động và tiết kiệm thời gian hơn rất nhiều.
