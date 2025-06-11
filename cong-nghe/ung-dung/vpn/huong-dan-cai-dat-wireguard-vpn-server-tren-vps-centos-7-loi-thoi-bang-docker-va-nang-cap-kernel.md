# Hướng dẫn cài đặt WireGuard VPN Server trên VPS CentOS 7 lỗi thời bằng Docker và nâng cấp kernel

## Giới thiệu

WireGuard là một giao thức VPN hiện đại, nhanh, nhẹ và bảo mật cao đang được nhiều người dùng lựa chọn thay thế cho OpenVPN. Tuy nhiên, để chạy WireGuard server trên các VPS CentOS 7 cũ, ta thường gặp một số khó khăn do kernel hệ thống không hỗ trợ module WireGuard. Bài viết này sẽ hướng dẫn bạn cách nâng cấp kernel CentOS 7 lên phiên bản mới để hỗ trợ WireGuard, đồng thời cài đặt WireGuard server bằng Docker rất đơn giản.

***

## Tại sao phải nâng cấp kernel?

CentOS 7 bản mặc định thường dùng kernel 3.10, quá cũ để hỗ trợ WireGuard vì:

* WireGuard cần module kernel mới (>= 5.x) để chạy hiệu quả.
* Kernel cũ không có sẵn module WireGuard và thường không thể nạp module này.
* Cài WireGuard mà không nâng kernel sẽ gặp lỗi như "Cannot find device wg0".

Vì vậy, cần nâng cấp kernel lên bản kernel-lt (long-term) mới nhất của ELRepo.

***

## Các bước nâng cấp kernel và cài WireGuard trên CentOS 7

Dưới đây là các bước chính bạn cần làm, kèm script tự động để bạn dễ thao tác.

### 1. Thêm ELRepo repository

ELRepo là kho phần mềm bên ngoài cung cấp kernel mới cho CentOS 7.

```bash
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
```

### 2. Cài kernel-lt (kernel dài hạn)

```bash
sudo yum --disablerepo="*" --enablerepo="elrepo-kernel" install kernel-lt kernel-lt-devel -y
```

### 3. Cập nhật GRUB để boot kernel mới

```bash
sudo grub2-set-default 0
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 4. Khởi động lại VPS

```bash
sudo reboot
```

### 5. Kiểm tra kernel mới sau reboot

```bash
uname -r
# Phải thấy kernel >= 5.4.x
```

### 6. Cài WireGuard tools

```bash
sudo yum install -y dkms wireguard-tools
sudo modprobe wireguard
```

***

## Cài WireGuard VPN server bằng Docker với wg-easy

Sau khi kernel đã hỗ trợ WireGuard, bạn có thể cài nhanh VPN server bằng Docker image `weejewel/wg-easy` rất tiện lợi.

#### Ví dụ docker-compose.yml:

```yaml
version: "3.8"
services:
  wireguard:
    image: weejewel/wg-easy
    container_name: wg-easy
    restart: unless-stopped
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    environment:
      - TZ=Asia/Ho_Chi_Minh
      - WG_HOST=your.vps.ip.or.domain
      - PASSWORD=your_webui_password
    volumes:
      - ./config:/etc/wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv6.conf.all.forwarding=1
```

#### Khởi chạy Docker container

```bash
docker-compose up -d
```

Truy cập giao diện web tại: `http://your.vps.ip.or.domain:51821` và đăng nhập bằng mật khẩu bạn đã đặt.

***

## Tổng kết ưu nhược điểm WireGuard

| Điểm mạnh                     | Điểm hạn chế                    |
| ----------------------------- | ------------------------------- |
| - Tốc độ nhanh, nhẹ, ổn định  | - Yêu cầu kernel mới (>=5.x)    |
| - Mã nguồn hiện đại, dễ audit | - Chưa phổ biến như OpenVPN     |
| - Cấu hình đơn giản           | - Cần kiến thức nâng cấp kernel |

***

## Lời khuyên khi sử dụng WireGuard trên CentOS 7

* Nâng cấp kernel là bước bắt buộc để chạy WireGuard server ổn định.
* Dùng Docker wg-easy giúp bạn triển khai nhanh, dễ quản lý.
* Nếu có điều kiện, bạn nên nâng cấp hẳn hệ điều hành lên CentOS 8/9 hoặc các distro mới hơn (Rocky, AlmaLinux, Ubuntu...) để có môi trường mới và bảo mật hơn.

***

## Mã nguồn script nâng cấp kernel và cài WireGuard tự động

```bash
#!/bin/bash

set -e

echo "=== Bắt đầu nâng cấp kernel và cài đặt WireGuard cho CentOS 7 ==="

if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root."
  exit 1
fi

yum install -y epel-release yum-utils wget

if ! yum repolist enabled | grep -q "^elrepo"; then
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
fi

yum clean all
yum makecache fast

yum --disablerepo="*" --enablerepo="elrepo-kernel" install -y kernel-lt kernel-lt-devel dkms wireguard-tools

grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Hoàn thành. Vui lòng khởi động lại VPS và chạy 'modprobe wireguard' sau khi reboot."
```

## Script cài đặt nâng cấp kernel + WireGuard cho CentOS 7

Dưới đây là **script shell `.sh` tự động** giúp bạn nâng cấp kernel lên `kernel-lt` mới nhất trên CentOS 7 (dùng ELRepo), cài WireGuard, và thiết lập môi trường cần thiết cho VPS quá cũ. Script có kèm kiểm tra cơ bản và thông báo rõ ràng.

{% hint style="warning" %}
\=========================================================

⚠️ **Lưu ý: Sử dụng script này đồng nghĩa với việc bạn tự chịu trách nhiệm.**

**Script được cung cấp để tham khảo. Không chịu trách nhiệm nếu có sự cố.**

\=========================================================
{% endhint %}

{% code title="upgrade_kernel_wireguard.sh" %}
```bash
#!/bin/bash
# =========================================================
# ⚠️ Lưu ý: Sử dụng script này đồng nghĩa với việc bạn tự chịu trách nhiệm.
# Script được cung cấp để tham khảo. Không chịu trách nhiệm nếu có sự cố.
# =========================================================
#
# upgrade_kernel_wireguard.sh
#
# Script tự động nâng cấp kernel lên kernel-lt mới nhất cho CentOS 7
# và cài đặt WireGuard VPN.
#
# === Hướng dẫn sử dụng ===
#
# 1. Tạo file, ví dụ: upgrade_kernel_wireguard.sh
# 2. Dán nội dung script này vào file trên
# 3. Cấp quyền thực thi: chmod +x upgrade_kernel_wireguard.sh
# 4. Chạy script với quyền root: sudo ./upgrade_kernel_wireguard.sh
# 5. Sau khi script chạy xong, khởi động lại VPS: sudo reboot
# 6. Sau reboot, kiểm tra kernel mới bằng lệnh: uname -r
#    (phiên bản kernel phải là khoảng 5.4.x hoặc mới hơn)
# 7. Nạp module WireGuard: sudo modprobe wireguard
# 8. Kiểm tra module WireGuard đã được nạp: lsmod | grep wireguard
#
# Nếu có lỗi hoặc cần hỗ trợ, liên hệ admin hoặc tham khảo tài liệu ELRepo.
#

set -e

echo "=== Bắt đầu nâng cấp kernel và cài đặt WireGuard cho CentOS 7 ==="

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root (sudo)."
  exit 1
fi

# Cài các gói cần thiết trước
echo "Cài đặt epel-release, yum-utils, và wget..."
yum install -y epel-release yum-utils wget

# Thêm repo ELRepo nếu chưa có
if ! yum repolist enabled | grep -q "^elrepo"; then
  echo "Thêm ELRepo repository..."
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
else
  echo "ELRepo đã được cài đặt."
fi

# Cập nhật metadata repo
yum clean all
yum makecache fast

# Tải và cài kernel-lt mới nhất từ ELRepo mirror
KERNEL_LATEST="kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm"
KERNEL_DEVEL_LATEST="kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm"

# MIRROR="https://mirrors.netix.net/elrepo/kernel/el7/x86_64/RPMS"
MIRROR="https://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/"

echo "Tải kernel-lt và kernel-lt-devel bản mới nhất..."
# https://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm
wget "${MIRROR}/${KERNEL_LATEST}" -O /tmp/${KERNEL_LATEST}
# https://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm
wget "${MIRROR}/${KERNEL_DEVEL_LATEST}" -O /tmp/${KERNEL_DEVEL_LATEST}

echo "Cài đặt kernel mới..."
yum localinstall -y /tmp/${KERNEL_LATEST} /tmp/${KERNEL_DEVEL_LATEST}

# Đặt kernel mới làm mặc định boot
echo "Cập nhật grub để khởi động với kernel mới..."
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg

# Cài WireGuard và công cụ hỗ trợ
echo "Cài đặt WireGuard..."
yum install -y dkms wireguard-tools

echo "Đã cài đặt xong. Vui lòng khởi động lại VPS để áp dụng kernel mới."
echo "Sau khi reboot, bạn có thể chạy 'modprobe wireguard' để tải module WireGuard."

echo "=== Hoàn thành ==="

```
{% endcode %}

***

## 📌 **Lưu ý trách nhiệm (Disclaimer)**

> **Vui lòng cân nhắc kỹ trước khi sử dụng script này.**\
> Script được cung cấp với mục đích hỗ trợ và tham khảo. Tôi không chịu trách nhiệm với bất kỳ sự cố nào có thể xảy ra trong quá trình sử dụng, bao gồm nhưng không giới hạn: lỗi hệ thống, mất dữ liệu, hoặc các rủi ro bảo mật.\
> Hãy đảm bảo bạn sao lưu dữ liệu và hiểu rõ các thao tác trước khi thực hiện.

> **Please use this script at your own discretion.**\
> This script is provided as-is for reference and support purposes only. I take no responsibility for any potential issues arising from its use, including but not limited to system errors, data loss, or security risks.\
> Make sure to back up your data and understand the operations before proceeding.

***

## Kết luận

**WireGuard VPN** server là lựa chọn tuyệt vời cho VPN hiện đại. Tuy nhiên với CentOS 7 cũ, bạn cần nâng cấp kernel trước khi chạy WireGuard server. Sử dụng ELRepo để nâng cấp kernel-lt là cách đơn giản và ổn định nhất. Sau đó, bạn có thể triển khai VPN server bằng Docker tiện lợi.

Nếu bạn có câu hỏi hay cần hỗ trợ thêm, đừng ngần ngại để lại bình luận bên dưới hoặc liên hệ trực tiếp với mình.

***

**Chúc bạn thành công!**
