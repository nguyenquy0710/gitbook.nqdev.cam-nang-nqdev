---
description: >-
  Linux Path Cheatsheet không đơn thuần là một bảng ghi nhớ thư mục. Thực chất,
  nó là bản đồ tư duy của toàn bộ hệ điều hành Linux.
---

# Sơ đồ Linux Filesystem là gì và vì sao Dev cần hiểu?

Khi làm việc với Linux, rất nhiều lập trình viên bắt đầu bằng việc học lệnh: `ls`, `cd`, `chmod`, `systemctl`, `docker`… Tuy nhiên, không ít người rơi vào tình trạng **“biết gõ lệnh nhưng không hiểu hệ thống”**. Nguyên nhân cốt lõi nằm ở việc bỏ qua **Linux filesystem** – nền tảng mà toàn bộ hệ điều hành vận hành trên đó.

**Linux Path Cheatsheet** không đơn thuần là một bảng ghi nhớ các thư mục như `/bin`, `/etc`, `/var`. Thực chất, nó là **bản đồ tư duy của toàn bộ hệ điều hành Linux**, phản ánh cách kernel, user, service và ứng dụng tương tác với nhau thông qua filesystem.

Trong **Cẩm nang NQDEV**, chúng tôi xem việc hiểu filesystem là **bước chuyển từ “dùng Linux” sang “làm chủ Linux”**.

***

### Linux filesystem – nền móng của mọi câu lệnh

Trong Linux:

* Lệnh là file
* Thiết bị là file
* Thông tin hệ thống cũng là file

Mọi thao tác bạn thực hiện – từ chạy một script, cấu hình server, cho tới debug production – đều xoay quanh việc **đọc, ghi hoặc thực thi file** trong filesystem.

Vì vậy, nếu không hiểu:

* File nằm ở đâu
* Thư mục đó có vai trò gì
* Ai được phép can thiệp vào nó

thì việc dùng lệnh chỉ dừng lại ở mức _thuộc cú pháp_, không phải _hiểu hệ thống_.

***

### Root filesystem `/` – gốc rễ của toàn bộ hệ điều hành

Linux không có ổ đĩa kiểu C:, D:.\
Mọi thứ bắt đầu từ **root `/`**.

Sơ đồ Linux Filesystem cho thấy từ `/` tỏa ra các nhánh, mỗi nhánh đảm nhiệm **một trách nhiệm duy nhất**, không chồng chéo và không ngẫu nhiên.

Đây là điểm khác biệt cốt lõi giữa Linux và nhiều hệ điều hành khác:\
👉 **Cấu trúc phản ánh tư duy thiết kế, không chỉ là cách lưu trữ.**

***

### Nhóm thư mục thực thi: nơi các lệnh bạn dùng hằng ngày “sống”

#### `/bin` – Command binaries

Chứa các lệnh cơ bản:

* `ls`, `cp`, `mv`, `cat`
* `chmod`, `chown`

Những lệnh quen thuộc trong bài\
👉 **Tập lệnh Linux hay dùng – Cẩm nang NQDEV**\
thực chất là các file thực thi nằm trong `/bin`.

Điều này giúp bạn hiểu rằng:

> Khi gõ một lệnh, Linux chỉ đang chạy một file cụ thể trong filesystem.

***

#### `/sbin` – System binaries

Dành cho các lệnh quản trị:

* `mount`, `ip`, `reboot`
* `fsck`, `shutdown`

Sai lầm phổ biến của Dev mới là dùng các lệnh trong `/sbin` mà không hiểu hậu quả, dẫn tới lỗi hệ thống hoặc downtime.

***

### `/etc` – nơi quyết định hệ thống vận hành ra sao

Nếu `/bin` là nơi lệnh nằm, thì `/etc` là nơi **lệnh nghe theo**.

Toàn bộ cấu hình hệ thống:

* Web server
* Database
* SSH
* Cron\
  đều tập trung tại đây.

Trong tư duy của **NQDEV Platform**:

> Hiểu `/etc` quan trọng hơn nhớ thêm 10 câu lệnh mới.

***

### Không gian người dùng: `/home` và `/root`

* `/home`: môi trường làm việc an toàn cho user
* `/root`: home của superuser, quyền lực tuyệt đối

Một Dev có tư duy hệ thống sẽ:

* Viết code, test script trong `/home`
* Chỉ dùng `/root` khi thật sự cần

Đây là ranh giới giữa **làm việc an toàn** và **phá hệ thống trong im lặng**.

***

### `/proc` và `/sys` – Linux ở tầng sâu hơn

Hai thư mục này không chứa file thật, mà là **filesystem ảo do kernel tạo ra**.

* `/proc`: thông tin CPU, RAM, process
* `/sys`: thiết bị, driver, power

Các lệnh như `top`, `free`, `uptime` không “tự đoán” thông tin, mà **đọc dữ liệu trực tiếp từ đây**.

👉 Hiểu `/proc` giúp bạn debug hiệu năng như một system engineer thực thụ.

***

### `/var` và `/tmp` – nơi dữ liệu thay đổi liên tục

* `/var`: log, cache, runtime data
* `/tmp`: file tạm, có thể bị xóa sau reboot

Rất nhiều sự cố production xuất phát từ việc:

* Không kiểm soát log trong `/var/log`
* Lưu nhầm dữ liệu quan trọng trong `/tmp`

***

### Vì sao Dev nên học Linux filesystem sớm?

Hiểu Linux filesystem giúp bạn:

* Dùng lệnh đúng ngữ cảnh
* Tránh thao tác nguy hiểm
* Debug nhanh hơn
* Tư duy hệ thống tốt hơn khi làm DevOps, Backend, Cloud

Trong **Cẩm nang NQDEV**, chúng tôi không khuyến khích học Linux theo kiểu:

> Thuộc lệnh → xong

Mà theo hướng:

> **Filesystem → Lệnh → Service → Tự động hóa**

***

### Kết luận

**Linux Path Cheatsheet** không phải để học thuộc, mà để:

* Nhìn vào là hiểu hệ thống đang vận hành thế nào
* Biết lệnh mình chạy sẽ tác động tới đâu
* Làm việc với Linux một cách tự tin, có kiểm soát

Để kết nối lý thuyết với thực hành, bạn nên đọc song song:\
👉 **Tập lệnh Linux hay dùng**\
🔗 [https://blogs.nhquydev.net/os-linux/tap-lenh-linux-hay-dung](https://blogs.nhquydev.net/os-linux/tap-lenh-linux-hay-dung)

Khám phá thêm nhiều bài nền tảng khác tại:\
🔗 [https://blogs.nhquydev.net/](https://blogs.nhquydev.net/)

**Cẩm nang NQDEV** – xây nền tảng vững chắc để đi đường dài với Linux và hệ thống.
