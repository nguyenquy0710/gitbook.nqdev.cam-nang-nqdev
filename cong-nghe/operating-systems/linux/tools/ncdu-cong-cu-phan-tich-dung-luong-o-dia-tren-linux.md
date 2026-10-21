---
description: >-
  ncdu — công cụ phân tích dung lượng ổ đĩa tương tác trên Linux với giao diện
  ncurses: cài đặt, điều hướng, phím tắt, mẹo và cheat sheet thực chiến.
---

# ncdu – Công cụ phân tích dung lượng ổ đĩa tương tác trên Linux

Bạn SSH vào một server production lúc 2 giờ sáng vì cảnh báo "disk full". Chạy `df -h` thì thấy `/` đã đầy 98%, nhưng `du -sh /*` phải đợi cả phút và trả về một danh sách số liệu khô khan mà bạn không biết nên bắt đầu dọn từ đâu. Lúc này bạn cần một công cụ vừa **nhanh**, vừa **cho phép bạn duyệt trực tiếp** vào từng thư mục để tìm ra "thủ phạm" đang ngốn dung lượng.

Đó chính là `ncdu` (NCurses Disk Usage) — một công cụ dòng lệnh nhỏ gọn, quét ổ đĩa và hiển thị kết quả dưới dạng **giao diện TUI tương tác** (ncurses), cho phép bạn điều hướng, sắp xếp và thậm chí xoá file ngay trong giao diện.

Bài viết này thuộc chuỗi kiến thức thực chiến của **Cẩm nang NQDEV**. Thay vì liệt kê toàn bộ man page, chúng ta sẽ đi từ tình huống thực tế, rồi mới vào cú pháp, phím tắt và các mẹo vận hành.

***

## 1. ncdu là gì?

`ncdu` là tiện ích dòng lệnh **phân tích và hiển thị dung lượng sử dụng ổ đĩa** theo từng thư mục, với giao diện dựa trên thư viện **ncurses**. Nó được viết bằng C (phiên bản 1.x) / Zig (phiên bản 2.x), chạy hoàn toàn trong terminal, không cần GUI.

Cách hoạt động gồm hai pha:

1. **Pha quét (scan):** `ncdu` duyệt toàn bộ cây thư mục, tính tổng dung lượng của mỗi node (thư mục và file). Quá trình này có thể mất vài giây đến vài phút tuỳ kích thước ổ đĩa.
2. **Pha hiển thị (browse):** Sau khi quét xong, `ncdu` mở giao diện ncurses cho phép bạn duyệt, sắp xếp, xem chi tiết và xoá trực tiếp.

Điểm khác biệt lớn nhất so với `du`:

* **`du`** chỉ in ra danh sách số liệu — bạn phải đọc, so sánh và tự quyết định bước tiếp theo.
* **`ncdu`** cho bạn **điều hướng trực tiếp** vào thư mục lớn nhất, xem chi tiết từng item, sắp xếp theo nhiều tiêu chí, và xoá file ngay trong giao diện.

> 💡 ncdu không "tối ưu" hay "dọn dẹp" tự động — nó chỉ **hiển thị và cho phép bạn thao tác**. Quyết định xoá hay giữ vẫn là của bạn.

***

## 2. Vì sao dùng ncdu thay vì `du`?

Trong thực tế, `du` vẫn là công cụ mặc định và rất hữu ích cho script. Nhưng khi bạn cần **khám phá tương tác**, `du` bộc lộ nhiều hạn chế:

| Tiêu chí | `du` | `ncdu` |
| --- | --- | --- |
| Tốc độ quét | Nhanh | Nhanh (tương đương) |
| Hiển thị | Danh sách số liệu khô khan | Giao diện TUI tương tác |
| Điều hướng thư mục | Phải chạy lại lệnh | Phím ←/→, Enter trong giao diện |
| Sắp xếp | Phải pipe qua `sort` | Phím `s` (size), `n` (name), `C` (count) |
| Xem chi tiết item | `du -sh <path>` từng cái | Phím `i` hiển thị metadata |
| Xoá file | `rm` riêng | Phím `d` có xác nhận |
| Ẩn/hiện file ẩn | `--exclude` phức tạp | Phím `e` toggle |
| Xuất báo cáo | Redirect stdout | `-o file.json` rồi đọc lại bằng `-f` |
| Phù hợp script/CI | ✅ Xuất sắc | ❌ Không (TUI) |
| Phù hợp khám phá tương tác | ❌ Khó | ✅ Tuyệt vời |

**Khi nào dùng `du`:** script, cron, pipeline, khi bạn đã biết chính xác đường dẫn cần đo.

**Khi nào dùng `ncdu`:** khám phá tương tác, tìm "thủ phạm" dung lượng, dọn dẹp thủ công trên server.

***

## 3. Cài đặt

`ncdu` có sẵn trong repo của hầu hết distro. Chọn tab phù hợp với hệ điều hành của bạn:

{% tabs %}
{% tab title="Ubuntu / Debian" %}
```bash
sudo apt update
sudo apt install -y ncdu
```
Trên Ubuntu/Debian hiện đại, `ncdu` luôn có trong repo mặc định. Kiểm tra version sau khi cài:
```bash
ncdu --version
```
{% endtab %}
{% tab title="CentOS / RHEL / Rocky / Alma" %}
```bash
# CentOS 7 / RHEL 7
sudo yum install -y ncdu

# RHEL 8+ / Rocky / AlmaLinux
sudo dnf install -y ncdu
```
Nếu gặp lỗi `No matching package`, kiểm tra repo `epel-release` đã được bật chưa:
```bash
sudo dnf install -y epel-release
sudo dnf install -y ncdu
```
{% endtab %}
{% tab title="Alpine" %}
```bash
apk add --no-cache ncdu
```
Dùng `--no-cache` để không để lại cache làm phình image.
{% endtab %}
{% tab title="Arch Linux" %}
```bash
sudo pacman -S ncdu
```
{% endtab %}
{% tab title="macOS" %}
```bash
brew install ncdu
```
Trên macOS, `ncdu` cũng có thể cài qua MacPorts: `sudo port install ncdu`.
{% endtab %}
{% tab title="Windows (WSL)" %}
Trong WSL (Ubuntu), dùng cùng lệnh như Ubuntu:
```bash
sudo apt update && sudo apt install -y ncdu
```
Lưu ý: `ncdu` trên WSL chỉ quét filesystem của WSL (ext4), không quét trực tiếp ổ C: của Windows trừ khi mount.
{% endtab %}
{% endtabs %}

### 3.1. Build từ source (nếu cần version mới nhất)

Nếu repo distro chưa có `ncdu` 2.x và bạn cần tính năng mới:

```bash
# Cần zig (cho ncdu 2.x) hoặc gcc (cho 1.x)
git clone https://code.blicky.net/yorhel/ncdu.git
cd ncdu
# ncdu 2.x dùng Zig
zig build -Doptimize=ReleaseSafe
sudo cp zig-out/bin/ncdu /usr/local/bin/
```

> ⚠️ Với hầu hết use case production, version từ repo distro (1.x) đã đủ. Chỉ build từ source khi bạn thực sự cần tính năng của 2.x (ví dụ: export JSON schema mới, hiệu năng quét lớn hơn).

***

## 4. Sử dụng cơ bản

### 4.1. Quét thư mục hiện tại

```bash
ncdu
```

Lệnh này quét thư mục làm việc hiện tại (`pwd`) và mở giao diện ncurses sau khi quét xong.

### 4.2. Quét từ root (theo gợi ý của bạn)

```bash
ncdu /
```

Đây là lệnh thường dùng nhất khi điều tra "disk full". `ncdu` sẽ quét toàn bộ filesystem từ `/` và hiển thị giao diện sau khi hoàn tất.

> ⚠️ Quét từ `/` trên server lớn có thể mất **vài phút** và tốn RAM/CPU đáng kể. Xem phần 11 (mẹo) để biết cách giới hạn phạm vi quét.

### 4.3. Quét một đường dẫn cụ thể

```bash
ncdu /var/log
ncdu /home/user/projects
ncdu /opt/app/data
```

### 4.4. Quét với giới hạn một filesystem (`-x`)

```bash
ncdu -x /
```

Flag `-x` (hoặc `--one-file-system`) ngăn `ncdu` vượt qua mount point. Rất hữu ích khi bạn chỉ muốn đo `/` mà không bị lẫn dung lượng của `/mnt`, `/media`, các volume Docker mount.

### 4.5. Loại trừ thư mục/file (`--exclude`, `-X`)

```bash
# Loại trừ theo pattern (glob)
ncdu --exclude '*.log' /var

# Loại trừ một thư mục cụ thể
ncdu --exclude /proc --exclude /sys --exclude /dev /

# Loại trừ theo danh sách trong file
echo '/proc' > /tmp/exclude.txt
echo '/sys' >> /tmp/exclude.txt
echo '/dev' >> /tmp/exclude.txt
ncdu -X /tmp/exclude.txt /
```

### 4.6. Chế độ "không tương tác" — xuất ra file (`-o`)

```bash
# Quét và xuất kết quả ra file JSON
ncdu -o /tmp/report.json /var/log

# Quét và xuất ra stdout (dùng cho pipe)
ncdu -o - /var/log | gzip > /tmp/report.json.gz
```

### 4.7. Đọc lại báo cáo đã xuất (`-f`)

```bash
# Đọc file JSON đã xuất trước đó
ncdu -f /tmp/report.json
```

Cách này cho phép bạn quét trên server (chậm, tốn tài nguyên) rồi phân tích offline trên máy local — không cần SSH liên tục.

***

## 5. Giao diện ncurses tương tác

Sau khi quét xong, `ncdu` mở giao diện TUI. Màn hình điển hình:

```plaintext
ncdu 1.15.1 ~ Use the arrow keys to navigate, press ? for help
-- /var/log --------------------------------------------------------------------
   1.2 GiB [##########] /journal
 420.5 MiB [###       ] /nginx
 180.2 MiB [#         ] /app
  45.0 MiB [           ] syslog
  12.3 MiB [           ] auth.log
   8.1 MiB [           ] kern.log
   2.0 MiB [           ] ...
```

Các thành phần giao diện:

* **Thanh tiêu đề (top bar):** phiên bản `ncdu`, phím tắt help (`?`), và đường dẫn hiện tại.
* **Danh sách item:** mỗi dòng là một file/thư mục, với:
  * Kích thước (human-readable: GiB, MiB, KiB).
  * Thanh bar `[#...]` thể hiện tỷ lệ so với item lớn nhất trong thư mục hiện tại.
  * Tên item.
* **Dòng trạng thái (bottom):** tổng dung lượng, số lượng item, và một số thông tin bổ sung.

### 5.1. Điều hướng cơ bản

| Phím | Hành động |
| --- | --- |
| `↑` / `↓` (hoặc `k` / `j`) | Di chuyển lên/xuống |
| `Enter` hoặc `→` | Mở thư mục đang chọn |
| `←` hoặc `Backspace` | Quay về thư mục cha |
| `q` | Thoát ncdu |
| `?` | Mở màn hình help (danh sách phím tắt) |

### 5.2. Sắp xếp và hiển thị

| Phím | Hành động |
| --- | --- |
| `n` | Sắp xếp theo **tên** (name) |
| `s` | Sắp xếp theo **kích thước** (size) — mặc định |
| `C` (Shift+c) | Sắp xếp theo **số lượng item con** (count) |
| `a` | Toggle giữa **apparent size** (kích thước logic) và **disk usage** (dung lượng thực trên disk, có tính block size) |
| `e` | Toggle hiển thị **file ẩn** (bắt đầu bằng `.`) |
| `g` | Toggle hiển thị **thanh bar phần trăm** (graph) |
| `c` | Toggle hiển thị **số lượng item con** bên cạnh tên |
| `t` | Toggle sắp xếp **thư mục lên trước** file (dirs first) |

### 5.3. Thao tác nâng cao

| Phím | Hành động |
| --- | --- |
| `i` | Hiển thị **thông tin chi tiết** của item đang chọn (đường dẫn đầy đủ, kích thước, loại, quyền, mtime…) |
| `d` | **Xoá** item đang chọn (có hộp thoại xác nhận) |
| `r` | **Quét lại** (rescan) thư mục hiện tại |
| `b` | Mở **shell** trong thư mục hiện tại (rất hữu ích để chạy lệnh khác) |
| `q` | Thoát |

### 5.4. Phím tắt đầy đủ (cheat sheet phím tắt)

| Phím | Chức năng | Ghi chú |
| --- | --- | --- |
| `↑` / `k` | Lên | Di chuyển con trỏ |
| `↓` / `j` | Xuống | Di chuyển con trỏ |
| `Enter` / `→` / `l` | Vào thư mục | Mở directory |
| `←` / `h` / `Backspace` | Lên cha | Parent directory |
| `n` | Sort by name | Tên A→Z |
| `s` | Sort by size | Lớn→nhỏ (mặc định) |
| `C` | Sort by count | Số item con |
| `a` | Toggle apparent/disk | Apparent size vs disk usage |
| `e` | Toggle hidden | Hiện/ẩn file `.` |
| `g` | Toggle graph | Thanh bar % |
| `c` | Toggle counts | Số item con |
| `t` | Toggle dirs-first | Thư mục lên trước |
| `i` | Item info | Metadata chi tiết |
| `d` | Delete | Có xác nhận |
| `r` | Rescan | Quét lại |
| `b` | Shell | Mở shell tại thư mục |
| `?` | Help | Danh sách phím tắt |
| `q` | Quit | Thoát |

> 💡 Nếu bạn quên phím tắt, bấm `?` bất cứ lúc nào — ncdu sẽ hiển thị toàn bộ danh sách.

***

## 6. Các tình huống thực tế (use cases)

### 6.1. Điều tra "disk full" trên production

```bash
# Bước 1: xác nhận ổ đĩa nào đầy
df -h

# Bước 2: quét từ root, giới hạn một filesystem
sudo ncdu -x /

# Bước 3: trong giao diện, đi vào thư mục lớn nhất (Enter)
#         xem chi tiết item (i), xoá nếu cần (d)
```

**Quy trình gợi ý:**

1. Mở `ncdu -x /`.
2. Nhìn vào thanh bar — thư mục nào có bar dài nhất là "thủ phạm".
3. `Enter` vào thư mục đó, lặp lại.
4. Khi tìm được file/thư mục cụ thể, bấm `i` để xem metadata (đặc biệt là mtime — file cũ có thể xoá an toàn hơn).
5. Bấm `d` để xoá (có xác nhận), hoặc `b` để mở shell và chạy lệnh dọn dẹp khác (ví dụ: `journalctl --vacuum-size=100M`).

### 6.2. Dọn dẹp log directory

```bash
sudo ncdu /var/log
```

Trong giao diện:
* Sort by size (`s`) để thấy file log lớn nhất.
* Bấm `i` để xem mtime — file log cũ (vài tháng) thường an toàn để xoá hoặc nén.
* Xoá trực tiếp bằng `d`, hoặc mở shell (`b`) để chạy `gzip`/`logrotate`.

### 6.3. Tìm thư mục Docker/Volumes ngốn dung lượng

```bash
sudo ncdu /var/lib/docker
```

Thường `/var/lib/docker/overlay2` và `/var/lib/docker/volumes` là hai nơi lớn nhất. Sau khi xác định, bạn có thể dùng `docker system prune` hoặc `docker volume prune` thay vì xoá thủ công (an toàn hơn).

### 6.4. Phân tích dung lượng theo user (home directory)

```bash
sudo ncdu /home
```

Sort by size (`s`) để thấy user nào dùng nhiều nhất. Drill down vào từng user để tìm thư mục lớn (`.cache`, `node_modules`, `.local/share/Trash`…).

### 6.5. Quét server rồi phân tích offline

```bash
# Trên server (chạy trong screen/tmux để không bị mất khi mất kết nối)
sudo ncdu -o /tmp/server-report.json -x /

# Copy về máy local
scp user@server:/tmp/server-report.json ./

# Phân tích offline
ncdu -f server-report.json
```

Cách này **tránh SSH liên tục** và **không tốn tài nguyên server** trong lúc bạn đang khám phá.

### 6.6. So sánh apparent size vs disk usage

```bash
ncdu /var/lib/postgresql
```

Bấm `a` để toggle giữa:
* **Apparent size:** kích thước logic của file (như `ls -l`).
* **Disk usage:** dung lượng thực trên disk, tính theo block size (4 KiB/block) — thường lớn hơn apparent size do padding.

Khi debug "tại sao disk full nhưng file nhỏ", disk usage sẽ cho bạn câu trả lời (file sparse, block size lớn, v.v.).

***

## 7. Tùy chọn dòng lệnh nâng cao

| Flag | Tên đầy đủ | Ý nghĩa & khi nào dùng |
| --- | --- | --- |
| `-x` / `--one-file-system` | one file system | Không vượt mount point — **luôn dùng khi quét `/`** |
| `-q` / `--slow-ui-updates` | slow ui updates | Giảm tần suất cập nhật UI khi quét qua mạng chậm (NFS/SMB) |
| `-r` | read-only | Chế độ chỉ đọc: **không cho xoá file** — an toàn khi đưa cho người khác |
| `-o FILE` | output | Xuất kết quả ra file JSON (hoặc `-` cho stdout) |
| `-f FILE` | file | Đọc kết quả từ file JSON đã xuất |
| `-0` / `-1` / `-2` | compression | Mức nén khi xuất (`-0` không nén, `-2` nén gzip) |
| `--exclude PATTERN` | exclude | Loại trừ theo glob pattern |
| `-X FILE` | exclude-from | Loại trừ theo danh sách trong file |
| `--color SCHEME` | color | Bảng màu: `off`, `dark`, `dark-bg` |
| `--confirm-quit` | confirm quit | Hỏi xác nhận trước khi thoát (tránh thoát nhầm) |
| `--si` | SI units | Dùng đơn vị SI (1000) thay vì binary (1024) |
| `-h` / `--help` | help | Hiển thị help |
| `--version` | version | Hiển thị version |

### 7.1. Chế độ read-only (`-r`) — rất đáng dùng

```bash
sudo ncdu -r /var/log
```

Với `-r`, phím `d` (delete) bị vô hiệu hoá. Đây là cách **an toàn** để đưa `ncdu` cho đồng nghiệp hoặc để tự bạn khám phá mà không lo xoá nhầm.

### 7.2. Slow UI updates (`-q`) cho filesystem mạng

```bash
ncdu -q /mnt/nfs-share
```

Khi quét qua NFS/SMB, việc cập nhật UI liên tục làm chậm quá trình. `-q` giảm tần suất cập nhật, tăng tốc quét.

### 7.3. Màu sắc (`--color`)

```bash
# Tắt màu (hữu ích khi redirect hoặc terminal không hỗ trợ)
ncdu --color off /

# Bảng màu tối
ncdu --color dark /
```

### 7.4. Xác nhận trước khi thoát (`--confirm-quit`)

```bash
ncdu --confirm-quit /
```

Tránh thoát nhầm khi đang khám phá sâu — đặc biệt hữu ích khi bạn đã quét mất vài phút.

***

## 8. So sánh ncdu với các công cụ khác

### 8.1. Bảng so sánh nhanh

| Tiêu chí | `du` | `ncdu` | `dust` | `gdu` | `baobab` (GUI) |
| --- | --- | --- | --- | --- | --- |
| Loại | CLI | TUI (ncurses) | TUI (Rust) | TUI (Go) | GUI (GNOME) |
| Tốc độ quét | Nhanh | Nhanh | Rất nhanh | Rất nhanh | Trung bình |
| Tương tác | ❌ | ✅ | ✅ | ✅ | ✅ |
| Xoá file trong UI | ❌ | ✅ | ✅ | ✅ | ✅ |
| Export báo cáo | ✅ (stdout) | ✅ (JSON) | ❌ | ✅ (JSON) | ❌ |
| Phù hợp script/CI | ✅ Xuất sắc | ❌ | ❌ | ⚠️ | ❌ |
| Cài đặt | Có sẵn | Repo distro | Cargo/binary | Binary | Desktop env |
| Tài nguyên | Thấp | Thấp | Thấp | Thấp | Cao (GUI) |
| Phù hợp server headless | ✅ | ✅ | ✅ | ✅ | ❌ |

### 8.2. Phân tích chi tiết

{% tabs %}
{% tab title="du (coreutils)" %}
**Ưu điểm:**
* Có sẵn trên mọi hệ thống Unix/Linux — không cần cài.
* Xuất sắc cho script, cron, pipeline (`du -sh /var/* | sort -rh`).
* Nhẹ, không tốn RAM.

**Nhược điểm:**
* Không tương tác — phải chạy lại lệnh cho mỗi thư mục.
* Output khô khan, khó so sánh trực quan.
* Không có chức năng xoá trong UI.

**Khi dùng:** script, tự động hoá, khi đã biết đường dẫn cần đo.
{% endtab %}
{% tab title="ncdu" %}
**Ưu điểm:**
* Giao diện ncurses trực quan, điều hướng bằng phím.
* Xoá file ngay trong UI có xác nhận.
* Export/import JSON — phân tích offline.
* Nhẹ, phù hợp server headless.
* Có sẵn trong repo hầu hết distro.

**Nhược điểm:**
* Không phù hợp script/CI (TUI).
* Pha quét vẫn tốn thời gian trên filesystem lớn.
* Version 1.x thiếu một số tính năng của các tool mới hơn.

**Khi dùng:** khám phá tương tác, điều tra "disk full", dọn dẹp thủ công.
{% endtab %}
{% tab title="dust (du + rust)" %}
**Ưu điểm:**
* Viết bằng Rust, **rất nhanh** — quét song song.
* Output dạng tree trực quan ngay trong terminal (không cần TUI riêng).
* Không cần tương tác — phù hợp cả script lẫn xem nhanh.

**Nhược điểm:**
* Không có TUI tương tác đầy đủ (không xoá file trong UI).
* Cần cài từ cargo hoặc binary release.

**Khi dùng:** xem nhanh top thư mục lớn nhất, thay thế `du | sort`.
{% endtab %}
{% tab title="gdu (Go Disk Usage)" %}
**Ưu điểm:**
* Viết bằng Go, quét **cực nhanh** (parallel).
* TUI tương tác đầy đủ, hỗ trợ xoá file.
* Export JSON.

**Nhược điểm:**
* Binary mới, ít phổ biến hơn `ncdu`.
* Một số distro chưa có trong repo.

**Khi dùng:** filesystem rất lớn (TB), cần tốc độ tối đa.
{% endtab %}
{% tab title="baobab (Disk Usage Analyzer)" %}
**Ưu điểm:**
* GUI trực quan với biểu đồ tròn (pie chart) và treemap.
* Dễ dùng cho người không quen CLI.

**Nhược điểm:**
* Cần desktop environment (GNOME) — **không dùng được trên server headless**.
* Tốn tài nguyên hơn.

**Khi dùng:** máy desktop Linux, phân tích trực quan cho end-user.
{% endtab %}
{% endtabs %}

> 🎯 **Khuyến nghị của Cẩm nang NQDEV:** Trên server production headless, `ncdu` vẫn là lựa chọn **mặc định và an toàn nhất** — có sẵn, nhẹ, tương tác tốt, và hỗ trợ export để phân tích offline. Chỉ chuyển sang `gdu`/`dust` khi filesystem quá lớn và tốc độ quét là bottleneck.

***

## 9. Mẹo và best practices

### 9.1. Luôn dùng `-x` khi quét `/`

```bash
sudo ncdu -x /
```

Nếu không dùng `-x`, `ncdu` sẽ quét cả `/proc`, `/sys`, `/dev`, các mount point NFS/SMB, và các volume Docker — làm chậm quá trình và cho kết quả sai lệch (dung lượng "ảo" từ procfs/sysfs).

### 9.2. Loại trừ các pseudo-filesystem

```bash
sudo ncdu --exclude /proc --exclude /sys --exclude /dev --exclude /run /
```

Hoặc dùng file exclude để tái sử dụng:

```bash
cat > /tmp/ncdu-exclude.txt << 'EOF'
/proc
/sys
/dev
/run
/tmp
EOF
sudo ncdu -X /tmp/ncdu-exclude.txt /
```

### 9.3. Chạy trong `screen`/`tmux` trên server

Quét `/` trên server lớn có thể mất 5–15 phút. Nếu mất kết nối SSH, tiến trình bị kill và phải làm lại từ đầu:

```bash
# Trong tmux
tmux new -s ncdu-scan
sudo ncdu -x -o /tmp/report.json /

# Detach: Ctrl+B rồi D
# Attach lại sau: tmux attach -t ncdu-scan
```

### 9.4. Dùng `-r` (read-only) khi đưa cho người khác

```bash
sudo ncdu -r /var/log
```

Tránh người khác (hoặc chính bạn trong lúc mệt) xoá nhầm file production.

### 9.5. Export để phân tích offline

```bash
# Trên server
sudo ncdu -o /tmp/report.json -x /

# Trên máy local
ncdu -f report.json
```

Lợi ích: không cần SSH liên tục, không tốn tài nguyên server trong lúc khám phá, và có thể chia sẻ file JSON cho đồng nghiệp.

### 9.6. Kết hợp với `du` cho script

```bash
# Top 10 thư mục lớn nhất trong /var (không tương tác)
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

Dùng `du` cho tự động hoá, `ncdu` cho khám phá. Hai công cụ bổ sung cho nhau.

### 9.7. Kiểm tra trước khi xoá

Trước khi bấm `d` trong `ncdu`, hãy:
1. Bấm `i` để xem metadata (mtime, quyền, loại file).
2. Nếu không chắc, dùng `b` để mở shell và chạy `ls -la`, `file`, `lsof` để xác nhận file không đang được process nào sử dụng.
3. Với file log, cân nhắc **nén** (`gzip`) thay vì xoá — an toàn hơn và có thể khôi phục.

### 9.8. ncdu và file đang được process sử dụng

Xoá file đang được process giữ open (ví dụ: log file đang được ghi) bằng `d` trong `ncdu` sẽ **giải phóng dung lượng trong `df` nhưng process vẫn giữ file handle** — dung lượng không thực sự được trả lại cho đến khi process restart hoặc reopen file.

> ⚠️ Với log file đang active, hãy dùng `truncate -s 0 file.log` hoặc `> file.log` thay vì xoá — an toàn hơn và process tiếp tục ghi bình thường.

### 9.9. Hiệu năng trên filesystem rất lớn

* Quét `/` trên server có hàng triệu file (ví dụ: mail server, cache server) có thể mất 10–30 phút và tốn vài GB RAM.
* Cân nhắc quét từng mount point riêng: `ncdu /var`, `ncdu /home`, `ncdu /opt`.
* Nếu quá chậm, chuyển sang `gdu` (Go) hoặc `dust` (Rust) — quét song song nhanh hơn đáng kể.

***

## 10. Xử lý sự cố (troubleshooting)

### 10.1. "Permission denied" khi quét

```bash
# Chạy với sudo
sudo ncdu /

# Hoặc cấp quyền đọc cho user hiện tại (không khuyến nghị trên production)
```

`ncdu` cần quyền đọc trên mọi thư mục để quét. Nếu không có quyền, nó sẽ bỏ qua thư mục đó và hiển thị cảnh báo.

### 10.2. ncdu bị treo / chậm khi quét

* **Nguyên nhân:** quét qua NFS/SMB, hoặc gặp thư mục có hàng triệu file.
* **Giải pháp:** dùng `-q` (slow ui updates), hoặc loại trừ thư mục lớn bằng `--exclude`, hoặc quét từng mount point riêng.

### 10.3. Giao diện bị vỡ (ký tự lạ)

* **Nguyên nhân:** terminal không hỗ trợ UTF-8 hoặc ncurses.
* **Giải pháp:** đặt `LANG=en_US.UTF-8` (hoặc `C.UTF-8`), hoặc dùng `--color off`. Kiểm tra: `echo $TERM` (nên là `xterm-256color` hoặc tương đương).

### 10.4. Không xoá được file dù bấm `d`

* Kiểm tra bạn có đang chạy ở chế độ read-only (`-r`) không.
* Kiểm tra quyền ghi trên file/thư mục (cần `sudo` nếu file thuộc root).
* File có thể đang được process giữ open — xem 9.8.

### 10.5. File `.json` xuất ra quá lớn

* Dùng nén: `ncdu -0` (không nén) mặc định; thêm `-1` hoặc `-2` để nén gzip.
* Hoặc chỉ xuất thư mục cụ thể thay vì toàn bộ `/`.

***

## 11. Cheat sheet

```bash
# === Cơ bản ===
ncdu                          # quét thư mục hiện tại
ncdu /                        # quét từ root
ncdu /var/log                 # quét đường dẫn cụ thể
ncdu -x /                     # quét root, không vượt mount point

# === Loại trừ ===
ncdu --exclude /proc --exclude /sys --exclude /dev /
ncdu -X /tmp/exclude.txt /

# === Export / Import ===
ncdu -o /tmp/report.json /var/log     # xuất ra file
ncdu -o - /var/log | gzip > r.json.gz # xuất ra stdout + nén
ncdu -f /tmp/report.json              # đọc lại file

# === An toàn ===
ncdu -r /var/log                      # read-only (không cho xoá)
ncdu --confirm-quit /                 # hỏi xác nhận trước khi thoát
ncdu -q /mnt/nfs                     # slow ui updates (filesystem mạng)
ncdu --color off /                    # tắt màu

# === Phím tắt trong giao diện ===
# ↑/↓ hoặc j/k : di chuyển
# Enter / →    : vào thư mục
# ← / Backspace: lên cha
# n            : sort by name
# s            : sort by size (mặc định)
# C            : sort by count
# a            : toggle apparent/disk size
# e            : toggle file ẩn
# g            : toggle graph bar
# c            : toggle counts
# t            : toggle dirs-first
# i            : item info (metadata)
# d            : delete (có xác nhận)
# r            : rescan
# b            : mở shell tại thư mục
# ?            : help
# q            : quit

# === Kết hợp với du (script) ===
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

***

## 🧭 Kết luận

`ncdu` là công cụ **không thể thiếu** trong bộ công cụ của bất kỳ sysadmin, DevOps hay backend developer nào vận hành server Linux. Nó không làm điều gì "ma thuật" — nó chỉ **hiển thị rõ ràng** và **cho phép bạn thao tác trực tiếp** với dung lượng ổ đĩa, thay vì phải đoán mò từ output của `du`.

Thứ tự suy nghĩ đúng khi gặp "disk full":

> 1. **`df -h`** — xác nhận ổ đĩa nào đầy.
> 2. **`du -sh /var/* | sort -rh`** — xem nhanh top thư mục (script).
> 3. **`ncdu -x /`** — khám phá tương tác để tìm "thủ phạm".
> 4. **Xoá/dọn dẹp** — ưu tiên nén log, `docker system prune`, `journalctl --vacuum-size`, thay vì xoá file đang active.
> 5. **`truncate -s 0`** cho file đang được process ghi, thay vì xoá.

Và ba điều chắc chắn phải nhớ:

1. **Luôn dùng `-x`** khi quét `/` — tránh bị lẫn dung lượng từ mount point và pseudo-filesystem.
2. **Dùng `-r` (read-only)** khi đưa `ncdu` cho người khác hoặc khi bạn mệt và sợ xoá nhầm.
3. **Export ra JSON** (`-o`) để phân tích offline — tiết kiệm thời gian SSH và tài nguyên server.

> 💬 Bạn đang điều tra "disk full" trên server và không biết bắt đầu từ đâu? Chạy `df -h` để xác nhận, sau đó `sudo ncdu -x /` và đi vào thư mục có thanh bar dài nhất. Nếu cần an toàn, thêm `-r`. Nếu filesystem quá lớn, quét từng mount point riêng (`ncdu /var`, `ncdu /home`) thay vì toàn bộ `/`.