---
description: >-
  tcpdump – công cụ bắt và phân tích gói tin mạng trên Linux: cú pháp filter,
  cách debug service trong Docker mà không cần cài gì, và khi nào log đủ dùng.
---

# tcpdump – Công cụ bắt và phân tích gói tin mạng trên Linux

Có những lúc log ứng dụng nói _"mọi thứ bình thường"_ nhưng thực tế thì không: request không tới được service, client kết nối rồi treo im lặng, hoặc bạn cần biết chính xác **ai** đang gọi vào cổng đó lúc 3 giờ sáng.

Lúc này bạn cần nhìn **ở tầng dưới tầng ứng dụng** — tầng mạng. Và công cụ mặc định của mọi kỹ sư Linux là `tcpdump`.

Bài viết này thuộc chuỗi kiến thức thực chiến của **Cẩm nang NQDEV**. Nhưng thay vì liệt kê hết các flag của `tcpdump` (cuốn man page dài hơn cả cuốn sách này), chúng ta sẽ bắt đầu bằng **một tình huống thật**, rút ra 4 lỗi phổ biến, rồi mới đi vào cú pháp.

***

## 1. Bắt đầu từ một lệnh sai — và 4 lỗi trong đó

Một bạn đọc cần debug một service chạy trong Docker, tên container là `restream-10023`, đang lắng nghe ở port 8000. Bạn ấy chạy:

```bash
docker exec restream-10023 sh -c "apt-get update && apt-get install -y tcpdump"

tcpdump -A -n -i any port 8000
```

Ý tưởng hoàn toàn đúng. Nhưng cách làm thì có **4 vấn đề**, và chúng là 4 vấn đề tôi thấy lặp đi lặp lại hằng ngày.

***

### Lỗi 1: Dòng thứ hai thiếu `docker exec`

```bash
tcpdump -A -n -i any port 8000   # ❌ chạy trên HOST, không phải trong container
```

Dòng lệnh này chạy ở **host**, không phải bên trong container. Kết quả:

* Nếu host không cài `tcpdump` → `bash: tcpdump: command not found`
* Nếu host **có** cài → bạn capture trên interface của host, thấy traffic đi qua port đó, nhưng kèm theo traffic của mọi container khác cùng publish port 8000.

Sửa:

```bash
docker exec -it restream-10023 tcpdump -A -n -i any tcp port 8000
```

***

### Lỗi 2: `port 8000` khớp cả TCP lẫn UDP

Trong ngữ pháp filter của `tcpdump`, từ khoá `port` một mình là **hoặc** — nó khớp cả `tcp port 8000` lẫn `udp port 8000`.

Với một REST service, bạn gần như luôn muốn `tcp port 8000`. Bỏ `tcp` vào sẽ dễ bị nhiễu bởi traffic UDP tình cờ trùng số cổng (mDNS, QUIC, STUN…) mà bạn không quan tâm.

```bash
tcpdump -A -n -i any tcp port 8000   # ✅
```

> 💡 Quy tắc nhớ: **luôn tiền tố protocol** — `tcp port`, `udp port`, `icmp`. Đừng bao giờ để `port` trần.

***

### Lỗi 3: `-A` chỉ dùng được khi traffic là HTTP plaintext

`-A` ép `tcpdump` hiển thị phần **payload** dưới dạng ASCII. Nếu service của bạn chạy HTTP thường, đây là cách nhanh nhất để thấy request/response.

Nhưng nếu port đó là **HTTPS/TLS**, bạn sẽ nhìn thấy một màn hình toàn ký tự binary vô nghĩa:

```plaintext
14:22:31.884210 IP 172.18.0.5.51234 > 172.18.0.3.8000: Flags [.], seq 0:513, ack 1:1,
    win 502, options [nop,nop,TS val 88213 ecr 14122], length 513
... 3Í^J^C¯¾^H^k¢¡^A÷&^O^TÆ±^Qç^H¯^H¯^HÆ^_...
```

Đó không phải lỗi của `tcpdump` — đó là **payload đã được mã hoá TLS**. Không có công cụ nào giải mã được nếu bạn không có session key.

Giải pháp thực tế:

* Muốn xem **cấu trúc** gói tin để đọc header → dùng `-X` (hex + ASCII cạnh nhau) hoặc `-XX`
* Muốn xem **payload** → chỉ khả thi với HTTP plaintext
* Muốn phân tích sâu → lưu ra file `.pcap` rồi mở bằng **Wireshark**

***

### Lỗi 4: `apt-get install` vào container đang chạy

```bash
docker exec restream-10023 sh -c "apt-get update && apt-get install -y tcpdump"
```

Ba hậu quả:

1. **Chậm** — mỗi lần capture mất thêm 10–20 giây chỉ để `apt-get update`.
2. **Sửa đổi container đang chạy** — bạn vừa thêm package vào một instance đang phục vụ production. Rủi ro thấp nhưng vẫn là sửa production trong lúc debug.
3. **Mất sạch khi container được recreate** — vài giờ sau là không có `tcpdump` nữa. Mọi thứ bạn "cài đặt" trên đó là tạm.

Và nhiều khi còn tệ hơn: image `scratch`, `distroless`, `alpine` có thể không có `apt` hoặc không có shell.

> 🎯 Nguyên tắc: **đừng cài công cụ debug vào container đang chạy.** Chúng ta có cách tốt hơn, ở phần 4.

***

## 2. tcpdump là gì?

`tcpdump` là tiện ích dòng lệnh **bắt (capture) và in ra gói tin mạng** đang đi qua một interface của hệ thống. Nó là frontend mặc định của thư viện **libpcap** — cũng là thư viện mà Wireshark, tcpflow và hàng trăm công cụ phân tích khác dùng chung.

Cú pháp tổng quát:

```bash
tcpdump [options] [filter expression]
```

Ba thành phần:

| Thành phần | Ví dụ | Ý nghĩa |
| --- | --- | --- |
| `options` | `-i eth0 -nn -s 0` | Cách bắt và hiển thị |
| `filter expression` | `tcp port 8000` | **Điều kiện lọc** (BPF) |
| output | `-w cap.pcap` | Nơi ghi kết quả |

Điểm mấu chốt cần nhớ về kiến trúc của nó:

> **Bộ lọc chạy ở kernel.** `tcpdump` đưa filter expression xuống tầng BPF ở kernel để lọc **trước khi** sao chép gói tin lên user space. Đây là lý do `tcpdump -i any` tiêu hao CPU rất thấp ngay cả trên interface 10 Gbps — phần lớn gói tin bị loại bỏ mà không bao giờ tới ứng dụng.

Hệ quả thực tế: **luôn viết filter càng chặt càng tốt**. Một lệnh không có filter sẽ kéo CPU core của máy lên 100% chỉ để in ra màn hình những thứ bạn không cần.

***

## 3. Cài đặt

{% tabs %}
{% tab title="Ubuntu / Debian" %}
```bash
sudo apt update
sudo apt install -y tcpdump
```
Trên Debian/Ubuntu hiện đại, `tcpdump` gần như luôn có sẵn trong image base.
{% endtab %}
{% tab title="CentOS / RHEL / Rocky" %}
```bash
sudo yum install -y tcpdump
# hoặc
sudo dnf install -y tcpdump
```
Trên RHEL 8+ thường cần bật repo `baseos` trước nếu gặp lỗi `No matching package`.
{% endtab %}
{% tab title="Alpine" %}
```bash
apk add --no-cache tcpdump
```
Lưu ý: dùng `--no-cache` để không để lại `/var/cache/apk` làm phình image.
{% endtab %}
{% tab title="macOS" %}
```bash
brew install tcpdump
```
Mặc định trên macOS cần `sudo`. Chạy trước khi cài sẽ nhận lỗi quyền.
{% endtab %}
{% endtabs %}

### Về quyền và cách `tcpdump` hạ quyền

`tcpdump` cần quyền ở tầng thấp để mở **raw socket** trên interface. Hai cách:

```bash
sudo tcpdump -i eth0 tcp port 8000    # chạy bằng root
# hoặc cấp capability rồi chạy bình thường:
sudo setcap cap_net_raw,cap_net_admin+eip $(which tcpdump)
tcpdump -i eth0 tcp port 8000
```

Điểm mà ít người để ý: sau khi mở được interface, hầu hết bản phân phối sẽ **tự hạ quyền** tiến trình xuống user chuyên dụng `tcpdump`. Cơ chế này tồn tại vì lý do rất thực tế:

> ⚠️ Bản thân `tcpdump` phải nhận và xử lý dữ liệu thô từ mọi người trên mạng — kẻ tấn công có thể gửi gói tin cực kỳ xấu xí để khai thác chính công cụ debug của bạn. Cho chạy với quyền thấp giới hạn bề mặt tấn công.

***

## 4. Cách đúng để debug service trong Docker (không cần cài gì)

Đây là cách thay thế cho Lỗi 4, và là cách tôi khuyên dùng trong mọi tình huống production.

```bash
docker run --rm -it \
  --net=container:restream-10023 \
  --cap-add=NET_RAW --cap-add=NET_ADMIN \
  nicolaka/netshoot \
  tcpdump -i eth0 -nn -s 0 -A tcp port 8000
```

Giải thích từng thành phần:

| Thành phần | Tác dụng |
| --- | --- |
| `--rm` | Xoá container phụ sau khi thoát — không để lại rác |
| `--net=container:restream-10023` | **Join network namespace** của container đích → cùng góc nhìn mạng |
| `--cap-add=NET_RAW` | Quyền bắt gói tin (tương đương việc cần `root`) |
| `--cap-add=NET_ADMIN` | Quyền cần thiết khi bắt trên một số loại interface |
| `nicolaka/netshoot` | Image debug chuẩn, có sẵn tcpdump, tshark, dig, nmap, socat… |

Vì sao cách này tốt hơn:

* **Không sửa container đang chạy** — `restream-10023` không bị thay đổi một byte nào.
* **Không mất khi recreate** — không có gì để mất.
* **Cùng góc nhìn** — vì chung namespace nên bạn thấy đúng những gói tin container đích thấy, kể cả traffic nội bộ.
* **Rủi ro bằng 0** — `--rm` + container tách biệt, tự dọn dẹp.

> 💡 Nếu `nicolaka/netshoot` chưa có sẵn, Docker sẽ pull lần đầu (~hàng trăm MB). Lần sau khởi động sẽ tức thì.

### Cẩn thận interface

Trong container, interface thường là `eth0`, **không phải** `any`. Khi chạy `tcpdump` bằng `-i any`, output sẽ kèm tên interface ở đầu mỗi dòng:

```plaintext
eth0  IP 172.18.0.5.51234 > 172.18.0.3.8000: Flags [P.], ...
```

`any` trên host lại là lựa chọn hợp lý vì nó gom mọi interface (kể cả `docker0`, `veth*`) vào một chỗ.

***

## 5. Filter expression — trái tim của `tcpdump`

Filter expression là ngữ pháp **BPF (Berkeley Packet Filter)**. Hiểu nó là bạn đã dùng được `tcpdump` thoải mái.

### 5.1. Các primitive cơ bản

| Primitive | Ý nghĩa | Ví dụ |
| --- | --- | --- |
| `host X` | Chỉ host có địa chỉ X | `host 10.0.0.5` |
| `port N` | Chỉ cổng N | `port 8000` |
| `portrange A-B` | Dải cổng | `portrange 8000-8100` |
| `net X/Y` | Mạng con | `net 172.17.0.0/16` |
| `ip6 host X` | Host IPv6 | `ip6 host ::1` |
| `ether host X` | Địa chỉ MAC | `ether host 00:11:22:33:44:55` |

### 5.2. Toán tử logic

Ba toán tử: `and`, `or`, `not` — **không phải** `&&`, `||`, `!`.

```bash
# Cổng 8000 HOẶC 443
tcpdump -i eth0 "port 8000 or port 443"

# Host 10.0.0.5 VÀ cổng 8000 (traffic hai chiều)
tcpdump -i eth0 "host 10.0.0.5 and port 8000"

# Loại trừ SSH để giảm nhiễu
tcpdump -i eth0 "not port 22"

# HTTP HOẶC HTTPS, trừ SSH
tcpdump -i eth0 "tcp port 80 or tcp port 443"

# Theo dõi traffic đi (outbound) của host này
tcpdump -i eth0 "host 10.0.0.5 and greater 1024"
```

> ⚠️ **Luôn bọc filter có `and`/`or`/`not` trong dấu nháy kép.** Nếu không, `shell` sẽ tách `or` thành một lệnh riêng và `tcpdump` sẽ báo lỗi rất khó hiểu. Đây là nguyên nhân phổ biến nhất khiến người mới nghĩ `tcpdump` bị hỏng.

### 5.3. Filter theo hướng và giá trị

```bash
# Traffic đi ra từ host A, vào host B
tcpdump -i eth0 "src host 10.0.0.5 and dst host 10.0.0.10"

# Chỉ traffic đi (request) — bỏ qua response
tcpdump -i eth0 "src port 8000"

# Gói tin lớn hơn 1024 byte — thường là bulk transfer
tcpdump -i eth0 "greater 1024"

# Đếm số gói tin của một host
tcpdump -i eth0 "host 10.0.0.5" -w - | wc -l
```

***

## 6. Bảng các flag quan trọng

| Flag | Tên đầy đủ | Ý nghĩa & khi nào dùng |
| --- | --- | --- |
| `-i` | interface | Interface bắt. `any` = mọi interface, `eth0` = cụ thể |
| `-n` | — | Không phân giải tên host. **Luôn dùng** |
| `-nn` | — | Không phân giải cả tên port (`http` → `80`) |
| `-A` | ASCII | In payload dạng ASCII. Chỉ dùng cho plaintext |
| `-X` | — | In payload dạng hex + ASCII cạnh nhau |
| `-XX` | — | In **cả header** + payload dạng hex + ASCII |
| `-s` | snaplen | Số byte mỗi gói. `-s 0` = trọn gói |
| `-w` | write | Ghi ra file `.pcap` thay vì in ra màn hình |
| `-r` | read | Đọc file `.pcap` (không cần interface) |
| `-c` | count | Dừng sau N gói tin — rất hữu ích để tránh spam |
| `-v` | verbose | Chi tiết hơn; `-vv`, `-vvv` tăng dần (hiển thị header + options) |
| `-e` | — | Hiện header link-layer (địa chỉ MAC nguồn/đích) |
| `-tttt` | — | Timestamp dạng ngày + giờ:phút:giây, rất dễ đọc |
| `-tt` | — | Timestamp tuyệt đối, định dạng máy phân tích dùng |
| `-B` | buffer size | Kích thước buffer kernel (bytes). Mặc định thường là 2 MB |
| `-G` | rotate | Xoay vòng file theo thời gian (giây) — chống đầy disk |
| `-C` | — | Xoay vòng file theo dung lượng (MB) |
| `-Z` | user | Chạy với user cụ thể sau khi mở interface |
| `-K` | dont-verify | Bỏ kiểm tra checksum (nhanh hơn, **không nên** dùng khi debug payload) |

### 6.1. `-s 0` — đừng bao giờ bỏ qua

Đây là flag bị bỏ sót nhiều nhất. Mặc định `snaplen` của `tcpdump` là **262144 byte**. Với gói tin lớn hơn, nó cắt bớt — và **header của các protocol phía trên (TCP, HTTP, TLS) bị cắt mất**.

Hậu quả: bạn nhìn thấy dòng output nhưng phần payload bị thiếu, và dễ tưởng là service trả về response rỗng. Nhớ vấn đề `-A` ra binary ở Lỗi 3 — một phần nguyên nhân cũng là snaplen.

```bash
tcpdump -i eth0 -nn -s 0 -A tcp port 8000   # ✅ luôn có -s 0
```

### 6.2. `-c` — vô hùng quá dễ quên

```bash
# Bắt đúng 50 gói tin rồi tự dừng
tcpdump -i eth0 -nn -c 50 tcp port 8000
```

Dùng khi bạn muốn lấy "một mẫu" mà không muốn phải `Ctrl-C`, đặc biệt khi output đang pipe sang file.

***

## 7. Lưu file `.pcap` — cách làm chuyên nghiệp

Đây là cách chúng ta khuyên dùng thay vì đọc ASCII trong terminal. File `.pcap` là **định dạng chuẩn** mọi công cụ phân tích mạng đều hiểu.

### 7.1. Capture trong container rồi copy ra ngoài

```bash
# Bước 1: capture vào file ngay trong container
docker exec restream-10023 tcpdump -i eth0 -nn -s 0 -w /tmp/cap.pcap tcp port 8000

# (Ctrl-C để dừng)

# Bước 2: copy ra máy local
docker cp restream-10023:/tmp/cap.pcap ./cap.pcap

# Bước 3: dọn dẹp trong container
docker exec restream-10023 rm -f /tmp/cap.pcap
```

### 7.2. Hoặc capture trực tiếp ra host, không cần `docker cp`

```bash
docker run --rm \
  --net=container:restream-10023 \
  --cap-add=NET_RAW --cap-add=NET_ADMIN \
  -v "$(pwd):/work" \
  nicolaka/netshoot \
  tcpdump -i eth0 -nn -s 0 -w /work/cap.pcap tcp port 8000
```

### 7.3. Giới hạn dung lượng — KHÔNG được bỏ qua trên production

`tcpdump -w` không tự dừng. Một server tắc cổ HTTP có thể tạo **vài GB mỗi giờ**. Đây là cách chết nhanh nhất để đầy disk production.

```bash
# Xoay vòng theo dung lượng: file .pcap0, .pcap1, ... mỗi file 100 MB
tcpdump -i eth0 -nn -s 0 -C 100 -W 5 -w cap.pcap tcp port 8000

# Hoặc xoay vòng theo thời gian: mỗi 60 giây một file
tcpdump -i eth0 -nn -s 0 -G 60 -w 'cap-%Y%m%d-%H%M%S.pcap' tcp port 8000
```

| Flag | Ý nghĩa |
| --- | --- |
| `-C N` | Xoay vòng file khi đạt N megabyte |
| `-W N` | Giữ tối đa N file, ghi đè file cũ nhất |
| `-G N` | Xoay vòng theo N giây |

> 🔒 **Luôn đặt giới hạn** khi capture trên production. Và nhớ: file `.pcap` là **dữ liệu bí mật** — xem phần 10.

### 7.4. Đọc lại file đã bắt

```bash
# In ra terminal
tcpdump -nn -r cap.pcap

# Cùng filter khi đọc như khi bắt
tcpdump -nn -r cap.pcap 'tcp port 8000'

# Chỉ xem header, không cần payload
tcpdump -nn -r cap.pcap -c 20
```

Tính năng này cực kỳ giá trị: bạn có thể **bắt một lần, phân tích nhiều lần**, không cần chạy lại trên production.

### 7.5. Công cụ mở file `.pcap`

| Công cụ | Dùng khi |
| --- | --- |
| **Wireshark** | GUI — phân tích sâu, filter hiển thị, follow TCP stream |
| **tshark** | CLI — lấy field theo lệnh, phù hợp CI/script |
| `tcpdump -r` | Xem nhanh, không cần cài gì thêm |

```bash
# Với tshark: lấy đúng các field bạn cần
tshark -r cap.pcap -Y 'tcp.port == 8000' \
  -T fields -e frame.time -e ip.src -e ip.dst -e http.request.method -e http.request.uri
```

> 💡 Bạn có thể chạy `tshark` ngay trong `netshoot` — không cần cài trên máy local:
> ```bash
> docker run --rm -v "$(pwd):/work" nicolaka/netshoot \
>   tshark -r /work/cap.pcap -Y 'tcp.port == 8000' -T fields -e ip.src -e ip.dst
> ```

***

## 8. Đọc hiểu output của `tcpdump`

Một dòng output đầy đủ:

```plaintext
14:22:31.884210 IP 172.18.0.5.51234 > 172.18.0.3.8000: Flags [P.], seq 513:1026, ack 1026:1026, win 502, length 513
```

Bóc từng trường:

| Trường | Giá trị | Ý nghĩa |
| --- | --- | --- |
| Timestamp | `14:22:31.884210` | Giờ nhận gói tin. Mặc định là local time |
| `IP` | `IP` | Tầng trên cùng mà `tcpdump` đọc được. Có `IP6` nếu là IPv6 |
| Source | `172.18.0.5.51234` | IP + ephemeral port của client |
| `>` | `>` | Hướng đi của gói tin |
| Destination | `172.18.0.3.8000` | IP + cổng đích |
| Flags | `[P.]` | Xem bảng bên dưới |
| seq/ack | `513:1026` | Byte sequence number đang truyền |
| win | `502` | Kích thước receive window — nhỏ bất thường nghĩa là người nhận xử lý chậm |
| length | `513` | Độ dài payload (không tính header TCP) |

### 8.1. Bảng cờ TCP (`Flags`) — thứ bạn sẽ nhìn nhiều nhất

| Ký hiệu | Tên | Ý nghĩa khi thấy trong log |
| --- | --- | --- |
| `S` | SYN | Bắt đầu thiết lập kết nối |
| `.` | ACK | Gói tin thường có xác nhận |
| `F` | FIN | Một bên đóng kết nối |
| `R` | RST | **Đóng đột ngột** — thường là lỗi |
| `P` | PSH | Đẩy dữ liệu lên tầng ứng dụng |
| `U` | URG | Dữ liệu khẩn cấp |

### 8.2. Các dấu hiệu đáng chú ý

| Bạn thấy | Nghi vấn |
| --- | --- |
| RST liên tục | Service chưa listen, sai port, hoặc firewall chặn |
| SYN liên tục, không có SYN-ACK | SYN flood, hoặc firewall drop |
| SYN-ACK rồi RST | Client đóng vì đã timeout chờ ACK |
| `win` nhỏ dần liên tục | Có thể là dấu hiệu TCP zero-window |
| SYN retransmit liên tục | Mạng mất gói tin, hoặc MTU / PMTU black-hole |

Và cách trực tiếp nhất để thấy các kịch bản trên là thêm `-tttt` và `-v`:

```bash
tcpdump -i eth0 -nn -tttt -v -S 0 tcp port 8000
```

***

## 9. Khi nào KHÔNG cần dùng tcpdump

Đây là phần nhiều người bỏ qua, và là phần **tiết kiệm thời gian nhất**.

Nếu bạn chỉ muốn biết "ai đang gọi service của tôi và service trả về gì", thì **log ứng dụng đã có sẵn tất cả thông tin đó** — ở dạng dễ đọc hơn nhiều, không cần bắt gói tin, không cần lo quyền, không lo rò rỉ dữ liệu ngoài ý muốn.

{% hint style="info" %}
**Nguyên tắc: dùng tầng thấp nhất chỉ khi tầng cao không trả lời được câu hỏi.** Tầng ứng dụng hiểu ngữ nghĩa request; tầng mạng chỉ hiểu byte.
{% endhint %}

### 9.1. So sánh nhanh

| Mục tiêu debug | Dùng cái này thay vì tcpdump |
| --- | --- |
| nginx | `docker exec <container> tail -f /var/log/nginx/access.log` |
| uvicorn / FastAPI | Khởi động lại với `UVICORN_LOG_LEVEL=debug` |
| Node.js / Express | Middleware `morgan` |
| Gunicorn | `--access-logfile -` |
| Chưa biết app là gì | `docker logs -f <container>` — luôn rẻ nhất, thử trước tiên |

```bash
# Xem log không cần vào trong container
docker logs -f restream-10023

# Theo dõi log kèm timestamp
docker logs -f -t restream-10023

# Chỉ 100 dòng gần nhất
docker logs --tail 100 restream-10023
```

### 9.2. Chọn đúng công cụ theo mục tiêu

| Câu hỏi bạn đang trả lời | Công cụ phù hợp |
| --- | --- |
| **Ai / IP nào** đang gọi port X? | Access log hoặc `.pcap` — **không dùng `-A`** |
| Nội dung request/response là gì? | `-s 0 -X`, hoặc `.pcap` — chỉ khi plain HTTP |
| Request có **tới được** service không? | `tcpdump` trên interface **host** + `docker port <container>` |
| Có gì đang **chậm / treo**? | `.pcap` có timestamp, để thấy retry và khoảng trống latency |
| Service có **lỗi 5xx** không? | Log ứng dụng — tcpdump không cho bạn biết mã HTTP |
| Có phải vấn đề **DNS** không? | `dig`, `nslookup` — không cần bắt gói tin |

### 9.3. Ba bước chuẩn bị trước khi capture

Trước khi bắt gói tin, hãy thu hẹp phạm vi đi — phần lớn sự cố mạng được phát hiện từ những bước rẻ hơn nhiều:

```bash
# 1. Cổng này có thực sự đang listen không?
ss -tulnp | grep 8000

# 2. Port có được publish ra host không?
docker port restream-10023

# 3. Container có đang chạy, có bị restart loop không?
docker ps -a --filter name=restream-10023
docker inspect restream-10023 --format '{{.State.Status}} restarts={{.RestartCount}}'

# 4. Kết nối hiện tại trông có bất thường không?
ss -tan | grep 8000
```

Bài liên quan trong cẩm nang: [ss - Socket Statistics](ss-socket-statistics.md).

> 🎯 Nếu cổng **không listen**, bạn không cần `tcpdump` — không có gì để capture. Vấn đề nằm chỗ khác.

***

## 10. Bảo mật — đọc phần này trước khi capture trên production

File `.pcap` chứa **payload thô của mọi gói tin**. Trong đó có:

* `Authorization: Bearer <token>` và `Cookie: session=...` của mọi request
* Mật khẩu gửi trong body của request `POST /login`
* Dữ liệu cá nhân: email, số điện thoại, số CCCD, địa chỉ
* Nội dung tin nhắn của hệ thống chat, streaming

{% hint style="warning" %}
**Một file `.pcap` chia sẻ sai chỗ là một sự cố lộ dữ liệu (data breach).** Nếu bạn định đưa file pcap lên ticket, Slack, GitHub hay gửi cho bên thứ ba — hãy cân nhắc:

* Lọc trước ở tầng capture, chỉ lấy đúng IP và đúng cổng cần debug
* Bỏ `-A` nếu bạn không thật sự cần payload
* Lưu file ở nơi giới hạn quyền truy cập, mã hoá ở chỗ lưu trữ
* Xoá file ngay khi debug xong
{% endhint %}

Ngoài ra, cần lưu ý về pháp lý và môi trường:

> ⚠️ Ở nhiều quốc gia, bắt và phân tích traffic mà không có sự đồng ý của các bên liên quan là **vi phạm pháp luật**. Chỉ capture trên hệ thống bạn có quyền, và thông báo các bên liên quan khi luật pháp địa phương yêu cầu.

Về mặt kỹ thuật, bạn còn nên biết:

* **`tcpdump` không mã hoá gì cả.** Nếu chạy không có `sudo`, dữ liệu vẫn nằm trong memory của user của bạn — đây là lý do package thường được cấu hình drop quyền xuống user `tcpdump` thay vì chạy full root.
* **File pcap không tự mã hoá.** Lưu trên ổ đĩa plaintext là lỗ hổng. Cân nhắc `gpg` hoặc LUKS cho thư mục lưu trữ.
* **Bộ lọc là phòng tuyến đầu.** Bắt trần `-i any` trên host bận nghĩa là bạn đang ghi lại traffic của toàn bộ khách hàng trên máy — vi phạm bảo mật dữ liệu mà không hề có ý định đó.

***

## 11. Cheat sheet

```bash
# === Cơ bản ===
tcpdump -i eth0                                  # bắt trên interface cụ thể
tcpdump -i any -nn                               # mọi interface, không phân giải tên

# === Luôn dùng khi debug ===
tcpdump -i eth0 -nn -s 0 tcp port 8000           # filter chặt + snaplen trọn gói

# === Xem payload ===
tcpdump -i eth0 -nn -s 0 -A tcp port 8000        # ASCII (chỉ plain HTTP)
tcpdump -i eth0 -nn -s 0 -X tcp port 8000        # hex + ASCII (đọc được cả header)
tcpdump -i eth0 -nn -s 0 -v -XX tcp port 8000    # tối đa thông tin

# === Giới hạn để không bị ngập ===
tcpdump -i eth0 -nn -c 50 tcp port 8000          # dừng sau 50 gói
tcpdump -i eth0 -nn -C 100 -W 5 -w cap.pcap ...  # xoay vòng 100 MB, giữ 5 file

# === Lưu file pcap ===
tcpdump -i eth0 -nn -s 0 -w cap.pcap tcp port 8000

# === Đọc lại file ===
tcpdump -nn -r cap.pcap
tcpdump -nn -r cap.pcap 'tcp port 8000'

# === Trong Docker, KHÔNG cần cài gì ===
docker run --rm -it --net=container:<name> \
  --cap-add=NET_RAW --cap-add=NET_ADMIN \
  nicolaka/netshoot tcpdump -i eth0 -nn -s 0 tcp port 8000

# === Chẩn đoán ===
tcpdump -i eth0 -nn -tttt -v -s 0 tcp port 8000  # timestamp dễ đọc + chi tiết
tcpdump -i eth0 -nn "tcp port 443 and not host 10.0.0.5"
tcpdump -i eth0 -nn -e "arp or icmp"             # ARP + ping
tcpdump -i eth0 -nn "tcp[tcpflags] & tcp-syn != 0" # chỉ SYN (dò SYN flood)
```

***

## 🧭 Kết luận

`tcpdump` là công cụ **mạnh nhưng không phải công cụ đầu tiên bạn nên với tay**.

Thứ tự suy nghĩ đúng:

> 1. **`docker logs`** và access log — rẻ nhất, đọc được, đã có sẵn
> 2. **`ss` / `netstat`** để xác nhận cổng có thực sự listen
> 3. **`tcpdump`** chỉ khi hai bước trên không đủ câu trả lời
> 4. **`.pcap` + Wireshark** khi vấn đề nằm thực sự ở tầng mạng

Và ba điều chắc chắn phải nhớ:

1. **`-s 0`** — không có nó, bạn nhìn thấy payload bị cắt cụt và tưởng service trả về rỗng.
2. **Filter phải chặt và có `tcp`.** Một filter quá rộng trên production là cách nhanh nhất để đốt CPU server.
3. **Đừng cài `tcpdump` vào container đang chạy.** `--net=container:<name>` cho bạn cùng góc nhìn mà không để lại dấu vết nào.

***

> 💬 Bạn đang debug một service cụ thể và không biết nên bắt đầu từ đâu? Kiểm tra port có listen chưa (`ss -tulnp`), đọc log (`docker logs`), rồi mới quyết định có cần tới `tcpdump` hay không. Nếu cần, dùng filter hẹp nhất có thể và nhớ giới hạn dung lượng file.