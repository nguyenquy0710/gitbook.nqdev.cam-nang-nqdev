---
description: 'Nguồn: viblo.asia'
---

# Các thông số trong trang HAproxy Stats

Bài viết này sẽ giải thích các chỉ số đó để bạn có thể hiểu được ý nghĩa cụ thể của chúng và sử dụng những thông tin này để thay đổi cấu hình hệ thống cho phù hợp.

## Cấu hình trang HAproxy stats trong haproxy.cfg <a href="#cau-hinh-trang-haproxy-stats-trong-haproxycfg-0" id="cau-hinh-trang-haproxy-stats-trong-haproxycfg-0"></a>

### Frontend Stats

```
bind *:8404
stats enable
stats uri /stats
stats refresh 10s
stats admin if LOCALHOST
```

* bind: địa chỉ và cổng mà bạn sẽ sử dụng để truy cập trang stats
* stats uri: đường dẫn của URL
* stats refresh: tần suất trang stats tự động làm mới
* stats admin : hạn chế truy cập trang stats: chỉ tài khoản admin có thể truy cập. có thể thêm `stats auth <username:password>` để thực thi authentication basic

<figure><img src="../.gitbook/assets/image.png" alt=""><figcaption><p>HAProxy Statistics Report</p></figcaption></figure>

### Frontend Statistics <a href="#frontend-statistics-2" id="frontend-statistics-2"></a>

Frontend là thứ mà client kết nối với. Khi các request đi vào bộ cân bằng tải — và khi phản hồi được trả lại cho client — chúng sẽ chuyển qua frontend. Vì vậy, nó có quyền truy cập vào các thời gian end-to-end, kích thước thông báo và các chỉ báo tình trạng bao gồm toàn bộ vòng đời request / response.

#### **Session Rate**

Trong ngữ cảnh của frontend, mô tả tốc độ mà client đang kết nối với HAProxy.

1. **Cột Cur** cho biết số phiên hiện tại mà các phiên client hoặc các kết nối được thiết lập đầy đủ giữa client và server đang được tạo. Nếu bạn di chuột qua trường này, trang sẽ hiển thị các số liệu chi tiết sau:
   * _Current connection rate per second_: Số các client đang kết nối với HAProxy mỗi giây (chưa tạo phiên đầy đủ)
   * _Current session rate per secon_ : Số các phiên, là các thực thể giữ trạng thái của kết nối end-to-end client tới HAProxy và HAProxy tới backend server), đang được tạo mỗi giây
   * _Current request rate per second_: Số các HTTP request đang được nhận qua các kết nối đã thiết lập mỗi giây
2. **Cột Max** hiển thị hầu hết các phiên đã từng được sử dụng đồng thời. Nếu bạn di chuột qua trường này, trang sẽ hiển thị các số liệu chi tiết sau:
   * _Max connection rate per second_: Số kết nối lớn nhất mà client đã kết nối với HAProxy mỗi giây (chưa tạo phiên đầy đủ)
   * _Max session rate per second_: Số phiên lớn nhất mà client đã thiết lập, là các thực thể giữ trạng thái của kết nối end-to-end trong môi giây
   * _Max request rate per second_: Số HTTP request lớn nhất đã được nhận qua các kết nối đã thiết lập trong mỗi giây
3. **Cột Limit** hiển thị số phiên tối đa mỗi giây mà giao diện người dùng sẽ chấp nhận, như được đặt bởi rate-limit sesions. Nếu vượt quá giới hạn này, các kết nối bổ sung sẽ được giữ lại trong backlog của socket (trong bộ đệm hệ thống)
