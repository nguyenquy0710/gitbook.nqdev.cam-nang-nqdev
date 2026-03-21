---
description: >-
  SMB (Samba) là giải pháp chia sẻ file phổ biến, nhưng khi mở cổng 445/139 trực
  tiếp ra internet, bạn đang tự đặt hệ thống vào tầm ngắm của tấn công mạng.
---

# SMB - Bảo mật chia sẻ thư mục SMB trên Ubuntu với iptables và WireGuard

Bài viết này hướng dẫn bạn xây dựng một hệ thống **an toàn** trên Ubuntu: chỉ cho phép truy cập SMB qua **WireGuard VPN** và kiểm soát chặt chẽ bằng **iptables** – tường lửa mạnh mẽ tích hợp sẵn trong nhân Linux.

***

### Mô hình triển khai

* **Ubuntu Server**: chạy đồng thời Samba (SMB) và WireGuard VPN.
* **Client**: kết nối VPN bằng WireGuard, nhận IP trong dải riêng (ví dụ `10.0.0.0/24`).
* **iptables**: chỉ cho phép truy cập đến cổng SMB (139, 445) từ các IP thuộc VPN. Mọi kết nối SMB từ mạng khác (kể cả internet) đều bị chặn.

***

### 1. Cài đặt Samba và tạo thư mục chia sẻ

#### 1.1. Cập nhật hệ thống

bash

```bash
sudo apt update && sudo apt upgrade -y
```

#### 1.2. Cài đặt Samba

bash

```bash
sudo apt install samba -y
```

#### 1.3. Tạo thư mục chia sẻ

Giả sử người dùng là `nqdev`:

bash

```bash
mkdir -p /home/nqdev/share
sudo chmod 0755 /home/nqdev/share
sudo chown -R nqdev:nqdev /home/nqdev/share
```

#### 1.4. Cấu hình Samba

Sao lưu file cấu hình gốc:

bash

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```

Mở file cấu hình:

bash

```bash
sudo nano /etc/samba/smb.conf
```

Thêm vào cuối file:

ini

```ini
[MyShare]
   comment = Thư mục chia sẻ qua VPN
   path = /home/nqdev/share
   browseable = yes
   read only = no
   guest ok = no
   valid users = nqdev
   create mask = 0755
   directory mask = 0755
```

Lưu và thoát.

#### 1.5. Thêm người dùng Samba

bash

```bash
sudo smbpasswd -a nqdev   # nhập mật khẩu Samba
sudo smbpasswd -e nqdev   # kích hoạt
```

#### 1.6. Khởi động dịch vụ Samba

bash

```bash
sudo systemctl restart smbd nmbd
sudo systemctl enable smbd nmbd
```

***

### 2. Cấu hình tường lửa iptables

iptables là tường lửa mặc định của Ubuntu. Chúng ta sẽ xây dựng các rule để:

* Chỉ cho phép kết nối đến cổng SMB từ dải VPN `10.0.0.0/24`.
* Mở các cổng cần thiết: SSH, WireGuard.
* Đặt chính sách mặc định an toàn.

#### 2.1. Xóa các rule cũ (nếu có)

bash

```bash
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
```

#### 2.2. Xây dựng bộ rule

Giả sử giao diện mạng chính là `eth0` (nếu dùng cloud có thể là `ens3`, `ens5` – kiểm tra bằng `ip a`).

bash

```bash
# Chính sách mặc định: DROP tất cả INPUT, FORWARD, ACCEPT OUTPUT
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Cho phép loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Cho phép các kết nối đã được thiết lập và liên quan
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Cho phép SSH (tuỳ chỉnh cổng nếu cần)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Cho phép WireGuard (UDP 51820)
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Cho phép truy cập SMB CHỈ từ dải VPN
sudo iptables -A INPUT -p tcp -s 10.0.0.0/24 --dport 139 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 10.0.0.0/24 --dport 445 -j ACCEPT

# Chặn mọi truy cập SMB khác (không bắt buộc vì policy đã DROP, nhưng để rõ ràng)
sudo iptables -A INPUT -p tcp --dport 139 -j DROP
sudo iptables -A INPUT -p tcp --dport 445 -j DROP

# (Tuỳ chọn) Cho phép ping để kiểm tra
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
```

**Lưu ý quan trọng**: Khi policy INPUT là DROP, nếu bạn chưa có rule cho SSH, bạn sẽ bị khóa mất kết nối. Hãy chắc chắn đã thêm rule SSH trước khi áp dụng policy DROP. Để an toàn, bạn có thể thực thi từng bước và kiểm tra.

#### 2.3. Lưu rule iptables

Cài gói lưu trữ rule:

bash

```bash
sudo apt install iptables-persistent -y
sudo netfilter-persistent save
```

Khi khởi động lại, các rule sẽ tự động được phục hồi.

***

### 3. Cài đặt WireGuard

#### 3.1. Cài đặt gói WireGuard

bash

```bash
sudo apt install wireguard -y
```

#### 3.2. Tạo khóa cho server

bash

```bash
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod 600 /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

#### 3.3. Tạo file cấu hình server `/etc/wireguard/wg0.conf`

bash

```bash
sudo nano /etc/wireguard/wg0.conf
```

Nội dung:

ini

```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <private-key-của-server>   # thay bằng nội dung file private.key

# PostUp/PostDown: cho phép chuyển tiếp gói tin và NAT để client VPN có thể ra internet
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <public-key-của-client>    # sẽ thêm sau khi tạo key client
AllowedIPs = 10.0.0.2/32
```

#### 3.4. Bật chuyển tiếp IP (IP forwarding)

bash

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### 3.5. Khởi động WireGuard

bash

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

***

### 4. Cấu hình client WireGuard

Trên máy client (Windows, macOS, Linux), cài đặt WireGuard và tạo cặp khóa.

**Ví dụ trên Linux client**:

bash

```bash
wg genkey | tee client_private.key
cat client_private.key | wg pubkey > client_public.key
```

Tạo file cấu hình (ví dụ `wg0.conf`):

ini

```ini
[Interface]
PrivateKey = <private-key-client>
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = <public-key-server>
Endpoint = <địa-chỉ-ip-công-cộng-của-server>:51820
AllowedIPs = 10.0.0.0/24
```

* `AllowedIPs = 10.0.0.0/24`: chỉ gửi lưu lượng đến dải VPN qua tunnel. Nếu muốn tất cả lưu lượng internet đều qua VPN, đặt `0.0.0.0/0` (nhưng cần NAT trên server).

Sau khi có file cấu hình, import vào ứng dụng WireGuard và kích hoạt.

***

### 5. Kiểm tra và sử dụng

#### 5.1. Kiểm tra kết nối VPN

Từ client, ping địa chỉ VPN của server:

bash

```bash
ping 10.0.0.1
```

Nếu ping thành công, WireGuard đã hoạt động.

#### 5.2. Truy cập SMB qua VPN

**Trên Windows**:

* Mở File Explorer, nhập `\\10.0.0.1\MyShare`
* Đăng nhập với tài khoản Samba `nqdev` và mật khẩu đã đặt.

**Trên Linux client**:

* Dùng `smbclient`:

bash

```bash
smbclient //10.0.0.1/MyShare -U nqdev
```

* Hoặc mount:

bash

```bash
sudo mount -t cifs //10.0.0.1/MyShare /mnt/share -o username=nqdev,password=yourpass
```

#### 5.3. Kiểm tra tường lửa

Từ một máy không nằm trong VPN (hoặc từ chính server nhưng không qua wg0), thử telnet đến cổng 445:

bash

```bash
telnet 10.0.0.1 445   # từ client đã kết nối VPN sẽ thành công
telnet <ip-public> 445 # từ internet sẽ bị chặn
```

***

### 6. Một số lưu ý và xử lý sự cố

* **Mất kết nối SSH sau khi cấu hình iptables**: hãy truy cập bằng console (nếu có) hoặc khởi động lại vào chế độ recovery để sửa rule. Luôn kiểm tra rule SSH trước khi đặt policy DROP.
* **Samba yêu cầu xác thực nhưng không thể kết nối**: kiểm tra `valid users` trong `smb.conf` và đảm bảo người dùng Samba đã được kích hoạt.
* **WireGuard không khởi động**: kiểm tra log bằng `sudo journalctl -u wg-quick@wg0`.
* **Để mở thêm cổng khác qua VPN**: thêm các rule iptables tương tự với dải `10.0.0.0/24`.

***

### 7. Kết luận

Bạn đã thiết lập thành công một hệ thống chia sẻ file SMB an toàn trên Ubuntu, sử dụng iptables để kiểm soát truy cập và WireGuard để mã hóa đường truyền. Giải pháp này phù hợp cho các tổ chức hoặc cá nhân cần truy cập dữ liệu từ xa với mức độ bảo mật cao.

***

**Cẩm nang NQDEV** – Kiến thức IT thực chiến, dễ hiểu và áp dụng ngay.
