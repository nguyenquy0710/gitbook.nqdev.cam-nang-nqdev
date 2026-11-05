---
description: >-
  ss – Socket Statistics: công cụ hiện đại thay thế netstat trên Linux, xem
  socket, cổng listen, kết nối đang hoạt động và lọc mạnh mẽ ngay trong kernel.
---

# ss – Socket Statistics

Mọi vấn đề mạng đều bắt đầu từ cùng một câu hỏi: **ai đang nói chuyện với ai?**

Service web không phản hồi, kết nối database liên tục rơi, hay có thứ gì đó đang chiếm dụng port 3000. Trước khi sửa được bất cứ thứ gì, bạn cần **nhìn thấy** các kết nối đó.

Lệnh `ss` trả lời câu hỏi này ngay lập tức. Nó hiển thị mọi socket trên hệ thống Linux — cái gì đang lắng nghe, cái gì đang kết nối, cái gì đang chờ đóng. Đây là bản thay thế hiện đại cho `netstat`, và **nhanh hơn đáng kể** vì đọc trực tiếp từ kernel thay vì phân tích các file text trong `/proc`.

Bài viết này thuộc chuỗi kiến thức thực chiến của **Cẩm nang NQDEV**.

***

## 1. ss là gì và vì sao nhanh hơn netstat?

`ss` (Socket Statistics) là tiện ích dòng lệnh hiển thị thông tin về **socket mạng** trên hệ thống Linux. Nó là một phần của bộ công cụ `iproute2` — cùng họ với `ip`, `tc`, `bridge` — và là công cụ mặc định để kiểm tra socket trên Linux hiện đại.

Điểm khác biệt cốt lõi so với `netstat`:

* **netstat** đọc và phân tích các file text trong `/proc/net/` (tcp, udp, raw…), rồi tra bảng process ở `/proc/<pid>/fd/`. Cách này chậm và tốn CPU khi số lượng socket lớn.
* **ss** truy vấn kernel qua **netlink interface** (cụ thể là `NETLINK_INET_DIAG` / `NETLINK_SOCK_DIAG`), nhận dữ liệu có cấu trúc trực tiếp từ kernel space. Không cần parse text, không cần quét `/proc`.

> 💡 Hệ quả thực tế: trên máy chủ có hàng chục nghìn kết nối (load balancer, proxy, database), `ss` chạy trong vài mili-giây trong khi `netstat` có thể mất vài giây và gây spike CPU.

`ss` cũng hỗ trợ **lọc ngay trong kernel** (theo state, port, địa chỉ, protocol) nhờ cơ chế filter của `sock_diag`, nên bạn không cần pipe qua `grep`/`awk` cho các trường hợp phổ biến.

***

## 2. Cài đặt

Trong hầu hết bản phân phối Linux hiện đại, `ss` **đã được cài sẵn** vì thuộc gói `iproute2`. Kiểm tra nhanh:

```bash
ss --version
```

Nếu chưa có, cài theo distro:

{% tabs %}
{% tab title="Ubuntu / Debian" %}
```bash
sudo apt update
sudo apt install -y iproute2
```
{% endtab %}
{% tab title="CentOS / RHEL / Rocky / Alma" %}
```bash
sudo yum install -y iproute
# hoặc
sudo dnf install -y iproute
```
{% endtab %}
{% tab title="Alpine" %}
```bash
apk add --no-cache iproute2
```
{% endtab %}
{% tab title="Arch Linux" %}
```bash
sudo pacman -S iproute2
```
{% endtab %}
{% endtabs %}

> ⚠️ `ss` cần quyền để đọc thông tin process (PID/tên chương trình) của socket thuộc user khác. Chạy với `sudo` khi cần xem process của toàn hệ thống, hoặc cấp capability `cap_net_admin`/`cap_net_raw`.

***

## 3. Các option bạn sẽ dùng hằng ngày

| Option | Ý nghĩa |
| --- | --- |
| `-t` | Socket TCP |
| `-u` | Socket UDP |
| `-l` | Chỉ các socket đang **listening** (đang chờ kết nối) |
| `-a` | **Tất cả** socket (cả listening và non-listening/established) |
| `-n` | Hiển thị **số** (IP và port raw), không resolve tên service/host |
| `-p` | Hiển thị **PID và tên chương trình** sở hữu socket |
| `-i` | Hiển thị thông tin nội bộ TCP (RTT, retransmit, cwnd…) |
| `-m` | Hiển thị mức sử dụng bộ nhớ của socket |
| `-s` | In **tóm tắt** thống kê socket theo state và protocol |
| `-4` / `-6` | Chỉ IPv4 / IPv6 |
| `-o` | Hiển thị timer (keepalive, timewait…) |
| `-e` | Hiển thị thông tin mở rộng (uid, inode…) |

Quy ước hay dùng: **`-n` luôn đi kèm** để tránh DNS reverse lookup làm chậm lệnh, và **`-p` cần sudo** để thấy process của user khác.

***

## 4. Xem cái gì đang lắng nghe trên máy

Câu hỏi đầu tiên khi debug service: **port nào đang listen, chương trình nào sở hữu?**

```bash
ss -tlnp
```

Kết quả mẫu:

```plaintext
State   Recv-Q  Send-Q  Local Address:Port   Peer Address:Port  Process
LISTEN  0       128     0.0.0.0:22          0.0.0.0:*         users:(("sshd",pid=1234,fd=3))
LISTEN  0       128     127.0.0.1:3306      0.0.0.0:*         users:(("mysqld",pid=5678,fd=10))
LISTEN  0       128     0.0.0.0:80          0.0.0.0:*         users:(("nginx",pid=9012,fd=6))
```

Bạn đã biết ngay: SSH listen port 22, MySQL port 3306 (chỉ localhost), nginx port 80.

> 💡 `ss -tlnp` = **t**cp + **l**isten + **n**umeric + **p**rocess. Đây là lệnh bạn sẽ gõ nhiều nhất.

### 4.1. "Port already in use" — tìm thủ phạm

Mọi dev đều gặp lỗi này. Có thứ đang squat port bạn cần. Tìm nó:

```bash
ss -tlnp | grep :3000
```

Hoặc dùng **filter tích hợp** của `ss` (không cần grep):

```bash
ss -tlnp sport = :3000
```

Biết được process nào đang chiếm, bạn quyết định kill hay đổi port.

***

## 5. Xem các kết nối đang hoạt động

Listening socket là những cái **chờ** kết nối. Còn kết nối **đang diễn ra** thì sao?

```bash
ss -tn
```

Hiển thị các kết nối TCP đã established:

```plaintext
State  Recv-Q  Send-Q  Local Address:Port    Peer Address:Port
ESTAB  0       0       192.168.1.100:54321  93.184.216.34:443
ESTAB  0       0       192.168.1.100:54322  151.101.1.69:443
```

Máy của bạn đang nói chuyện với hai server remote trên port 443 (HTTPS).

Thêm `-p` để xem chương trình nào đang giữ kết nối:

```bash
ss -tnp
```

***

## 6. Tóm tắt nhanh: bao nhiêu kết nối?

Không cần liệt kê từng socket, chỉ muốn tổng quan:

```bash
ss -s
```

Kết quả mẫu:

```plaintext
Total: 156
TCP:   42 (estab 15, closed 8, orphaned 0, timewait 7)

Transport  Total  IP   IPv6
TCP        34     28   6
UDP        8      6    2
```

Hữu ích khi kiểm tra nhanh xem có đang chạm giới hạn connection không, hoặc có bất thường về số lượng TIME-WAIT.

***

## 7. Lọc tích hợp — điểm mạnh của ss

Đây là nơi `ss` vượt trội so với `netstat`: thay vì pipe qua `grep`, bạn lọc **trực tiếp** bằng cú pháp của `ss`.

### 7.1. Theo trạng thái (state)

```bash
ss state established
ss state listening
ss state time-wait
ss state close-wait
```

### 7.2. Theo cổng (port)

```bash
ss sport = :80          # Source port 80
ss dport = :443         # Destination port 443
ss sport ge :1024       # Source port >= 1024
ss dport le :1024       # Destination port <= 1024
```

Toán tử so sánh: `eq` (bằng), `ne` (khác), `lt` (nhỏ hơn), `le` (nhỏ hơn hoặc bằng), `gt` (lớn hơn), `ge` (lớn hơn hoặc bằng).

### 7.3. Theo địa chỉ (address)

```bash
ss dst 93.184.216.34           # Kết nối TỚI IP này
ss src 192.168.1.0/24          # Kết nối TỪ subnet này
```

### 7.4. Kết hợp (combined)

```bash
ss state established '( dport = :443 or sport = :443 )'
```

> ⚠️ **Luôn bọc biểu thức có `and`/`or` trong dấu nháy đơn.** Nếu không, shell sẽ tách `or` thành một lệnh riêng và `ss` báo lỗi khó hiểu.

***

## 8. Khi kết nối có vấn đề

### 8.1. Ứng dụng chậm — kiểm tra chất lượng TCP

```bash
ss -ti
```

Hiển thị thông tin nội bộ TCP: thời gian khứ hồi (RTT), số lần retransmit, congestion window. Nếu thấy retransmission count cao → mạng đang drop packet.

### 8.2. Receive queue đang đầy?

```bash
ss -tn | awk '$2 > 0 {print}'
```

Cột `Recv-Q` tăng dần nghĩa là ứng dụng **không đọc dữ liệu đủ nhanh**. Đây là tín hiệu backpressure — ứng dụng cần scale hoặc tối ưu xử lý.

### 8.3. Theo dõi số lượng kết nối liên tục

```bash
watch -n 1 'ss -tan state established | wc -l'
```

### 8.4. Thống kê số lượng kết nối theo IP

Khi cần biết IP nào đang tạo nhiều kết nối nhất (phát hiện abuse, DDoS, crawl, hoặc connection leak):

**Đếm tổng số kết nối established trên một port:**

```bash
ss -tn state established '( sport = :443 )' | wc -l
```

**Thống kê và sắp xếp số lượng kết nối theo IP đối phương (peer/client):**

```bash
ss -tn state established '( sport = :443 )' | awk 'NR>1 {print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
```

Kết quả dạng `437  110.35.77.1` — nghĩa là IP `110.35.77.1` đang có 437 kết nối.

**Lọc kết hợp theo cổng và địa chỉ IP cụ thể:**

```bash
# IP đích (remote) là 110.35.77.1
ss -tn state established '( sport = :443 and dst 110.35.77.1 )'

# IP nguồn (local) là 110.35.77.1
ss -tn state established '( sport = :443 and src 110.35.77.1 )'
```

> 💡 Cột `$4` = Local Address:Port, cột `$5` = Peer Address:Port. Chọn đúng cột tuỳ bạn muốn đếm theo IP local hay IP remote. Thêm `| head` để chỉ xem top N.

***

## 9. UDP

UDP không có trạng thái kết nối như TCP, nhưng bạn vẫn xem được các service đang listen:

```bash
ss -ulnp
```

Các service thường xuất hiện ở đây: DNS (port 53), DHCP (67/68), NTP (123).

***

## 10. Hiểu các trạng thái socket

Khi nhìn thấy trạng thái kết nối, đây là những gì quan trọng:

| Trạng thái | Ý nghĩa |
| --- | --- |
| **LISTEN** | Đang chờ kết nối đến. Đây là server của bạn. |
| **ESTAB** | Kết nối đang hoạt động, dữ liệu có thể chảy. |
| **TIME-WAIT** | Kết nối đã đóng, socket linger ngắn để bắt gói tin lạc. Nhiều TIME-WAIT là bình thường với server bận. |
| **CLOSE-WAIT** | Phía remote đã đóng, nhưng ứng dụng của bạn **chưa** đóng. Nếu tích luỹ → ứng dụng có bug, không đóng connection đúng cách. |
| **FIN-WAIT-1 / FIN-WAIT-2** | Đang trong quá trình đóng kết nối. |
| **SYN-SENT / SYN-RECV** | Đang bắt tay (handshake) TCP. |

> ⚠️ **CLOSE-WAIT tích luỹ** là dấu hiệu classic của connection leak trong ứng dụng (không gọi `close()`). Nếu thấy hàng trăm CLOSE-WAIT → kiểm tra code xử lý connection pool.

***

## 11. Kịch bản thực tế

### Service không khởi động được

```bash
sudo ss -tlnp | grep :8080
```

Tìm xem thứ gì đang chặn port.

### Quá nhiều kết nối

```bash
ss -s
```

Kiểm tra xem có đang chạm giới hạn (file descriptor, `nf_conntrack`, v.v.) không.

### Ứng dụng không tới được server

```bash
ss -tn dst 10.0.0.50
```

Xem kết nối có tồn tại hay đang bị kẹt.

### Giám sát số lượng kết nối

```bash
watch -n 1 'ss -tan state established | wc -l'
```

***

## 12. So sánh với netstat (bảng chuyển đổi)

Nếu bạn đang chuyển từ `netstat` sang `ss`, hầu hết lệnh dịch trực tiếp:

| netstat | ss | Ghi chú |
| --- | --- | --- |
| `netstat -tulpn` | `ss -tulpn` | Giống hệt |
| `netstat -an` | `ss -an` | Tất cả socket, dạng số |
| `netstat -tn` | `ss -tn` | TCP connections |
| `netstat -s` | `ss -s` | Thống kê tổng quan |
| `netstat -r` | `ip route` | Routing table — `ss` không xử lý routing |
| `netstat -i` | `ip -s link` | Thống kê interface |

> 💡 `ss` chỉ dành cho **socket**. Routing table và interface statistics thuộc về `ip route` / `ip -s link`.

***

## 13. Giám sát socket với LibreNMS

Nếu bạn đang vận hành giám sát hệ thống với **LibreNMS**, có thể dùng application **Socket Statistics (ss)** để poll trạng thái socket từ xa qua SNMP. Script `ss.py` (agent) chạy lệnh `ss` trên host và trả về số lượng socket theo type và address family.

Tóm tắt các bước:

1. Copy script về host:
   ```bash
   wget https://github.com/librenms/librenms-agent/raw/master/snmp/ss.py -O /etc/snmp/ss.py
   chmod +x /etc/snmp/ss.py
   ```
2. Thêm vào `snmpd.conf`:
   ```plaintext
   extend ss /etc/snmp/ss.py
   ```
3. (Tuỳ chọn) Tạo `/etc/snmp/ss.json` để lọc socket type / address family.
4. Restart `snmpd`.

> 📌 Nếu SELinux ở chế độ Enforcing, cần thêm module cho `snmpd_t` để cho phép `netlink_tcpdiag_socket`.

Đây là cách giám sát xu hướng socket (ví dụ số lượng TIME-WAIT, connection leak) mà không cần SSH vào từng máy.

***

## 14. Mẹo và lưu ý

* **Luôn dùng `-n`** để tránh DNS reverse lookup làm chậm lệnh — đặc biệt trên máy chủ production.
* **`Recv-Q` / `Send-Q`**:
  * Với socket **listening**: `Recv-Q` = số connection đang chờ accept (backlog), `Send-Q` = backlog tối đa.
  * Với socket **established**: `Recv-Q` = byte chưa được ứng dụng đọc, `Send-Q` = byte chưa ACK bởi peer.
* **Quyền**: `ss -p` cần root (hoặc capability) để thấy process của socket thuộc user khác.
* **`ss` không capture gói tin** — nó chỉ xem trạng thái socket. Để bắt gói tin dùng `tcpdump`.
* **Kết hợp với `watch`** để theo dõi realtime: `watch -n 1 'ss -s'`.
* **`ss` đọc từ kernel** — kết quả luôn là trạng thái hiện tại, không có cache.

***

## Tài liệu tham khảo

* [ss – Socket Statistics (YouGetSignal)](https://www.yougetsignal.com/vi/library/ss-socket-statistics-0s3cejt)
* [LibreNMS — Socket Statistics (ss) Application](https://docs.librenms.org/Extensions/Applications/Socket%20Statistics%20%28ss%29/)
* `man ss` — trang manual chính thức trên hệ thống Linux

<img src="https://me.momo.vn/nhquydev" alt="Momo" data-size="line"> _Nếu thấy nội dung này bổ ích..._ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
