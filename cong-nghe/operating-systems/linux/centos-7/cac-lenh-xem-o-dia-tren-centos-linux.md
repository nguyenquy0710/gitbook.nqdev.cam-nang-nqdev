---
description: >-
  Hướng dẫn các lệnh xem ổ đĩa trên CentOS/Linux: df -h, lsblk, fdisk -l và
  du -sh kèm ví dụ output, bảng so sánh và mẹo vặt.
---

# Các Lệnh Xem Ổ Đĩa Trên CentOS / Linux

Khi quản trị VPS hoặc máy chủ CentOS, kiểm tra ổ đĩa là tác vụ gần như hằng ngày: xem còn bao nhiêu dung lượng trống, phân vùng nào đang đầy, ổ cứng nào đang gắn trên hệ thống. Bài viết này tổng hợp 4 lệnh cốt lõi mà bạn cần nắm chắc: `df -h`, `lsblk`, `fdisk -l` và `du -sh` — kèm ví dụ output thực tế và gợi ý dùng lệnh nào cho từng tình huống.

## Khi Nào Cần Xem Ổ Đĩa?

* **Website/Service báo lỗi `No space left on device`:** Cần `df -h` để xác định phân vùng nào đang đầy.
* **Cần biết hệ thống đang có những ổ cứng, phân vùng nào:** Dùng `lsblk` để xem tổng quan dạng cây.
* **Cần chi tiết bảng phân vùng, sector, loại GPT/MBR:** Dùng `fdisk -l`.
* **Cần tìm thư mục nào đang "ngốn" nhiều dung lượng:** Dùng `du -sh` kết hợp `sort`.

## Tổng Quan Nhanh Các Lệnh

| Lệnh | Chức năng chính | Cần root? |
| ----- | ----- | ----- |
| `df -h` | Dung lượng đã dùng và còn trống của các phân vùng đang mount | Không |
| `lsblk` | Danh sách ổ đĩa và phân vùng dạng cây phân cấp | Không |
| `fdisk -l` | Chi tiết tất cả ổ cứng và bảng phân vùng (sector, boot flag...) | Có |
| `du -sh` | Dung lượng thực tế mà một thư mục cụ thể chiếm dụng | Tùy thư mục |

## 1. `df -h` — Xem Dung Lượng Đã Dùng Và Còn Trống

`df` (disk free) hiển thị dung lượng trên các filesystem đang được mount. Tùy chọn `-h` (human-readable) giúp hiển thị kích thước theo định dạng dễ đọc như GB, MB thay vì số block thô.

{% code title="Xem dung lượng các phân vùng đang mount" overflow="wrap" lineNumbers="true" %}
```bash
df -h
```
{% endcode %}

Ví dụ output:

{% code title="Output của df -h" overflow="wrap" %}
```plaintext
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        75G   23G   49G  32% /
/dev/sda5        24G   22G  1.2G  95% /home
/dev/sda3        29G   25G  2.6G  91% /data
/dev/sda1       289M   22M  253M   8% /boot
tmpfs           252M    0   252M   0% /dev/shm
```
{% endcode %}

* **Filesystem:** Tên device hoặc filesystem (ví dụ `/dev/sda2`, `tmpfs`).
* **Size:** Tổng dung lượng của phân vùng.
* **Used:** Dung lượng đã sử dụng.
* **Avail:** Dung lượng còn trống.
* **Use%:** Phần trăm đã sử dụng — chú ý phân vùng nào gần 100%.
* **Mounted on:** Điểm mount (thư mục gốc của phân vùng).

### Các tùy chọn hữu ích

* **-T (--print-type):** Hiển thị thêm cột Type (xfs, ext4, tmpfs...) — rất hữu ích khi cần biết filesystem đang dùng.
* **-i (--inodes):** Hiển thị thông tin inode thay vì dung lượng — dùng khi nghi ngờ hết inode.
* **-t TYPE:** Chỉ hiển thị filesystem loại TYPE, ví dụ `df -t xfs`.
* **-x TYPE:** Loại trừ loại filesystem, ví dụ `df -x tmpfs` để bỏ qua tmpfs cho output gọn hơn.

{% code title="Kết hợp nhiều tùy chọn" overflow="wrap" lineNumbers="true" %}
```bash
df -hT
df -h -x tmpfs -x devtmpfs
```
{% endcode %}

{% code title="Output của df -hT" overflow="wrap" %}
```plaintext
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/sda2      xfs        75G   23G   49G  32% /
/dev/sda1      xfs       289M   22M  253M   8% /boot
```
{% endcode %}

{% hint style="info" %}
`df` chỉ thống kê các filesystem **đang mount**, không phải dung lượng vật lý của ổ cứng. Muốn xem cấu trúc ổ cứng thực tế, hãy dùng `lsblk` hoặc `fdisk -l`.
{% endhint %}

## 2. `lsblk` — Xem Danh Sách Ổ Đĩa Và Phân Vùng Dạng Cây

`lsblk` (list block devices) đọc thông tin trực tiếp từ kernel và hiển thị danh sách ổ đĩa cùng phân vùng dưới dạng cây phân cấp trực quan — ổ đĩa vật lý là cấp cao nhất, các phân vùng nằm bên dưới. Lệnh này không cần quyền root và là lựa chọn đầu tiên khi cần cái nhìn tổng quan nhanh.

{% code title="Xem danh sách ổ đĩa và phân vùng" overflow="wrap" lineNumbers="true" %}
```bash
lsblk
```
{% endcode %}

Ví dụ output:

{% code title="Output của lsblk" overflow="wrap" %}
```plaintext
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   80G  0 disk
├─sda1   8:1    0  500M  0 part /boot
├─sda2   8:2    0   75G  0 part /
└─sda3   8:3    0  4.5G  0 part [SWAP]
sr0     11:0    1 1024M  0 rom
```
{% endcode %}

* **NAME:** Tên device rút gọn (`sda`, `sda1`...).
* **MAJ:MIN:** Số major/minor của device.
* **RM:** Removable device (1 = thiết bị tháo rời như USB).
* **SIZE:** Kích thước ổ đĩa/phân vùng.
* **RO:** Read-only (1 = chỉ đọc).
* **TYPE:** Loại device — `disk` (ổ đĩa vật lý), `part` (phân vùng), `rom` (ổ đĩa quang).
* **MOUNTPOINT:** Thư mục đang mount, `[SWAP]` nếu là phân vùng swap.

### Các tùy chọn hữu ích

* **-f:** Hiển thị thêm filesystem type và UUID — rất cần khi cấu hình `/etc/fstab`.
* **-p:** Hiển thị đường dẫn đầy đủ (`/dev/sda1`) thay vì tên rút gọn.
* **-m:** Hiển thị ownership và permission của device.
* **-a:** Hiển thị cả các device rỗng (không có phân vùng).

{% code title="Xem filesystem type và UUID" overflow="wrap" lineNumbers="true" %}
```bash
lsblk -f
```
{% endcode %}

{% code title="Output của lsblk -f" overflow="wrap" %}
```plaintext
NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda
├─sda1 xfs           a1b2c3d4-e5f6-4a5b-9c8d-1e2f3a4b5c6d /boot
├─sda2 xfs           e5f6a7b8-c9d0-4e5f-8a9b-0c1d2e3f4a5b /
└─sda3 swap          1234abcd-5678-9def-0123-456789abcdef [SWAP]
```
{% endcode %}

{% hint style="info" %}
Nhận biết USB drive bằng cột `RM` — nếu giá trị là `1` thì đó là thiết bị tháo rời được, không phải ổ cứng gắn trong.
{% endhint %}

## 3. `fdisk -l` — Xem Chi Tiết Ổ Đĩa Và Bảng Phân Vùng

`fdisk` là công cụ quản lý partition table kinh điển trên Linux. Tùy chọn `-l` (list) liệt kê tất cả ổ cứng và phân vùng kèm thông tin chi tiết về sector, kích thước và loại phân vùng. Lệnh này **yêu cầu quyền root**.

{% code title="Xem chi tiết tất cả ổ cứng và bảng phân vùng" overflow="wrap" lineNumbers="true" %}
```bash
sudo fdisk -l
```
{% endcode %}

Ví dụ output:

{% code title="Output của fdisk -l" overflow="wrap" %}
```plaintext
Disk /dev/sda: 80 GiB, 85899345920 bytes, 167772160 sectors
Disk model: Virtual disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x000d5a1e

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sda1  *       2048   1026047   1024000  500M 83 Linux
/dev/sda2       1026048 158308351 157282304   75G 83 Linux
/dev/sda3      158308352 167772159   9463808  4.5G 82 Linux swap / Solaris
```
{% endcode %}

* **Disk model:** Model ổ cứng (hữu ích trên máy vật lý).
* **Disklabel type:** Loại bảng phân vùng — `dos` (MBR) hoặc `gpt` (GPT).
* **Device:** Tên phân vùng.
* **Boot:** Dấu `*` đánh dấu phân vùng boot.
* **Start/End/Sectors:** Vị trí và số sector — dùng khi khôi phục dữ liệu hoặc phân tích chi tiết.
* **Id/Type:** Mã và loại phân vùng (`83` = Linux, `82` = Linux swap).

### Các biến thể thường dùng

{% code title="Xem một ổ cụ thể và kiểm tra loại bảng phân vùng" overflow="wrap" lineNumbers="true" %}
```bash
# Xem chỉ riêng ổ /dev/sda
sudo fdisk -l /dev/sda

# Kiểm tra nhanh bảng phân vùng GPT hay MBR
sudo fdisk -l | grep "Disklabel type"
```
{% endcode %}

{% hint style="warning" %}
`fdisk -l` cần quyền root — luôn chạy với `sudo`. Khi dùng `fdisk` ở chế độ tương tác (không có `-l`) để thao tác ghi, hãy hết sức cẩn thận vì thay đổi partition table có thể làm mất dữ liệu.
{% endhint %}

## 4. `du -sh` — Kiểm Tra Dung Lượng Thực Tế Của Thư Mục

`du` (disk usage) tính toán dung lượng mà các file và thư mục đang chiếm dụng. Tùy chọn `-s` (summarize) chỉ hiển thị tổng dung lượng, kết hợp `-h` (human-readable) để đọc dễ dàng. Đây là lệnh quan trọng nhất khi cần tìm "thủ phạm" chiếm dung lượng.

{% code title="Xem dung lượng thực tế của một thư mục" overflow="wrap" lineNumbers="true" %}
```bash
du -sh /var/log
```
{% endcode %}

Ví dụ output:

{% code title="Output của du -sh" overflow="wrap" %}
```plaintext
2.3G	/var/log
```
{% endcode %}

### Các tùy chọn hữu ích

* **-s (--summarize):** Chỉ hiển thị tổng dung lượng, không liệt kê từng thư mục con.
* **-h (--human-readable):** Hiển thị kích thước theo K, M, G.
* **-a (--all):** Hiển thị cả file lẫn thư mục con.
* **--max-depth=N:** Hiển thị cây thư mục con tới độ sâu N.

### Tìm thư mục chiếm nhiều dung lượng nhất

Kết hợp `du` với `sort` và `head` để tìm nhanh 10 thư mục "ngốn" dung lượng nhất:

{% code title="Top thư mục chiếm nhiều dung lượng" overflow="wrap" lineNumbers="true" %}
```bash
du -sh /var/* 2>/dev/null | sort -rh | head -n 10
du -h --max-depth=1 / 2>/dev/null | sort -rh | head -n 10
```
{% endcode %}

{% code title="Output ví dụ" overflow="wrap" %}
```plaintext
2.3G	/var/log
1.8G	/var/lib
800M	/var/www
```
{% endcode %}

{% hint style="info" %}
Thêm `2>/dev/null` để bỏ qua các thư mục không có quyền đọc — tránh output bị "phủ" bởi các thông báo lỗi Permission denied.
{% endhint %}

## Phân Biệt `df` Và `du`

Hai lệnh này dễ gây nhầm lẫn vì đều hiển thị dung lượng, nhưng bản chất khác nhau:

{% tabs %}
{% tab title="df" %}
`df` đo ở mức **filesystem đang mount** (block-level) — đọc trực tiếp metadata của filesystem. Kết quả phản ánh dung lượng thực tế mà phân vùng cấp phát, không cần quét từng file. Nhanh, chính xác cho câu hỏi "phân vùng còn bao nhiêu?".
{% endtab %}
{% tab title="du" %}
`du` quét **từng file và thư mục** trên đĩa, cộng dồn kích thước lại. Kết quả chậm hơn nhưng trả lời đúng câu hỏi "thư mục này đang chiếm bao nhiêu?". Lưu ý: file đã bị xóa nhưng process còn giữ handle vẫn chiếm dung lượng — lúc này `df` vẫn báo đầy dù `du` không thấy.
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Khi đã xóa file mà `df -h` vẫn báo phân vùng đầy, nguyên nhân thường là một process vẫn đang giữ file đã xóa. Kiểm tra bằng `lsof | grep deleted` rồi restart process đó.
{% endhint %}

## Lệnh Nào Dùng Khi Nào?

| Tình huống | Lệnh gợi ý |
| ----- | ----- |
| Còn bao nhiêu dung lượng trống trên server? | `df -h` |
| Hệ thống đang có những ổ cứng, phân vùng nào? | `lsblk` |
| Cần UUID và filesystem type để mount (cấu hình `/etc/fstab`) | `lsblk -f` hoặc `sudo blkid` |
| Cần chi tiết bảng phân vùng, sector, boot flag | `sudo fdisk -l` |
| Thư mục nào chiếm nhiều dung lượng nhất? | `du -sh /path` kết hợp `sort -rh` |
| Phân vùng đang đầy, tìm file lớn | `df -h` → `find / -xdev -type f -size +100M -exec ls -lh {} \;` |

## Mẹo Vặt

* **Theo dõi liên tục:** `watch -n 5 df -h` tự cập nhật kết quả mỗi 5 giây — hữu ích khi đang theo dõi dung lượng biến động.
* **Bỏ qua tmpfs cho output gọn:** `df -h -x tmpfs -x devtmpfs`.
* **Kiểm tra inode khi disk còn trống nhưng báo đầy:** `df -i` — hết inode cũng gây lỗi "No space left on device".
* **Tìm các file lớn hơn 100MB:** `find / -xdev -type f -size +100M -exec ls -lh {} \; 2>/dev/null`.
* **Phát hiện file đã xóa nhưng còn giữ:** `lsof +L1` liệt kê các file bị xóa mà process vẫn đang mở.
* **Trên CentOS:** tất cả các lệnh trên đều có sẵn trong bộ `coreutils`/`util-linux`, không cần cài đặt thêm gói nào.

## Kết Luận

Bốn lệnh trên tạo thành bộ công cụ đủ để xử lý hầu hết tình huống liên quan đến ổ đĩa trên CentOS/Linux: `df -h` cho câu hỏi dung lượng còn trống, `lsblk` cho cái nhìn tổng quan cấu trúc ổ đĩa, `fdisk -l` khi cần chi tiết bảng phân vùng, và `du -sh` khi phải tìm thủ phạm chiếm dung lượng. Hãy bắt đầu với `df -h` + `lsblk` cho kiểm tra nhanh hằng ngày, và dành `fdisk -l` + `du` cho các ca "khó chịu" hơn. Chúc bạn quản trị hệ thống hiệu quả!

## Tài liệu tham khảo

* [How to Check Disk Partitions in Linux (TecMint)](https://www.tecmint.com/list-disks-partitions-linux/)
* [Linux - Các lệnh kiểm tra thông số VPS/Server (Viblo)](https://viblo.asia/p/linux-cac-lenh-linux-kiem-tra-cac-thong-so-vpsserver-Qbq5QEbw5D8)
* [Xem Disk Và Partition Trên Linux Hiệu Quả Bằng 7 Lệnh Thực Tế (TungLe.Blog)](https://tungle.blog/2026/03/xem-disk-partition-linux.html)
* [Lệnh (command line) xem dung lượng trên máy chủ Linux (Mắt Bão)](https://wiki.matbao.net/kb/lenh-command-line-xem-dung-luong-tren-may-chu-linux/)
