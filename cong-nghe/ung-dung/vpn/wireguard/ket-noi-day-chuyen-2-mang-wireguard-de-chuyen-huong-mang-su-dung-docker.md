# Kết nối dây chuyền 2 mạng Wireguard để chuyển hướng mạng sử dụng Docker

<figure><img src="https://thuanbui.me/wp-content/uploads/2023/07/wireguard-chain-connection-docker-1200x675.png" alt=""><figcaption></figcaption></figure>

Mới đây, mình nhận được 1 yêu cầu hướng dẫn cách cấu hình kết nối dây chuyền 2 mạng Wireguard với nhau để chuyển hướng mạng gián tiếp. Mô hình hoạt động sẽ như hình minh hoạ dưới đây:

<figure><img src="https://thuanbui.me/wp-content/uploads/2023/07/wireguard-chain-connection-docker-1200x675.png" alt=""><figcaption></figcaption></figure>

Sau khi nghiên cứu, mình đã tìm ra được cách thiết lập chuyển hướng dây chuyền 2 mạng Wireguard để chia sẻ trong bài viết hôm nay.

Bài viết này được dựa trên 2 bài viết mình đã chia sẻ trước đây về Wireguard Docker

* [Thiết lập WireGuard client bằng Docker trên máy chủ Linux](https://thuanbui.me/thiet-lap-wireguard-client-bang-docker-tren-may-chu-linux/)
* [Chuyển hướng mạng của Docker Container đi qua WireGuard VPN](https://thuanbui.me/docker-container-wireguard-vpn/)

### I. Yêu cầu chuẩn bị

* Máy tính / điện thoại làm client kết nối, đã được cài đặt WireGuard client
* Một VPS (VPS A) làm trung gian đã được [cài đặt sẵn Docker và Docker Compose](https://thuanbui.me/huong-dan-cai-dat-docker-docker-compose-tren-ubuntu-20-04/). IP: `111.111.111.111`
* Một VPS (VPA B) làm đã được thiết lập sẵn WireGuard VPN Server, sử dụng [wg-easy](https://thuanbui.me/wg-easy-wireguard-vpn-server-web-ui/) để thiết lập. IP: `222.222.222.222`
* File cấu hình WireGuard client được tạo ra bởi WireGuard Server trên VPS B, có dạng như dưới đây

```yaml
[Interface]
PrivateKey = sO7U9OS0s5vxxxdfY1aNHzVYXpJhKAaU/HG9MyfaWU=
Address = 10.9.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = 9NknLwkQRaxxxsfNr9wKIC15KsqRvN5eOwUZxuhDFWI=
PresharedKey = xhqj9bnxxxuuFtzbVJ5GJPD6D4YAMHdk6RbL5JVkT+M=
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
Endpoint = 252.222.96.107:51822
Code language: YAML (yaml)
```

### II. Tạo Wireguard Server (VPS B)

Tạo Wireguard Server trên VPS B theo hướng dẫn ở đây

<figure><img src="https://thuanbui.me/wp-content/uploads/2021/09/wg-easy-800x450.png" alt=""><figcaption></figcaption></figure>

### III. Tạo Docker network (VPS A)

Để có thể điều hướng mạng bằng routing table, container Wireguard client cần sử dụng IP tĩnh để tránh rắc rối về sau. Mình sẽ tạo 1 mạng docker bridge mới với tên gọi `wgnet` bằng lệnh

```yaml
docker network create --subnet 10.10.0.0/24 wgnetCode language: YAML (yaml)
```

Kiểm tra lại thông số của `wgnet` bằng lệnh `docker inspect wgnet`

```json
[
    {
        "Name": "wgnet",
        "Id": "3776c37e5afbac33ccb583122a0d86aade3714c551c6d1770db906e4e54652b0",
        "Created": "2023-07-22T01:00:29.485635848+01:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.10.0.0/24",
                    "Gateway": "10.10.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
Code language: JSON / JSON with Comments (json)
```

### IV. Cấu hình WireGuard server (VPS A)

Tạo Wireguard Server trên VPS A cũng dùng [wg-easy](https://thuanbui.me/wg-easy-wireguard-vpn-server-web-ui/) tương tự như trên VPS B. Tuy nhiên, cần chú ý thay đổi thông số `WG_DEFAULT_ADDRESS` khác với subnet đã sử dụng trên VPS B.

Ví dụ:

* VPS B: `WG_DEFAULT_ADDRESS=10.9.0.x`
* VPS A: `WG_DEFAULT_ADDRESS=10.8.0.x`

Nếu hai subnet trùng nhau sẽ khiến phần cấu hình routing table ở phần sau gặp lỗi.

Ngoài ra, cần phải cấu hình cho container này kết nối vào network `wgnet` bằng cách thêm vào các dòng sau

```yaml
networks:
  default:
    name: wgnet
    external: trueCode language: YAML (yaml)
```

File `docker-compose.yml` trên VPS A sẽ tương tự như sau

```yaml
version: "3.8"
services:
  wg-easy:
    environment:
      # ⚠️ Required:
      # Change this to your host's public address
      - WG_HOST=22.22.22.22

      # Optional:
      - PASSWORD=10h30
      - WG_PORT=51820
      - WG_DEFAULT_ADDRESS=10.8.0.x
      # - WG_DEFAULT_DNS=1.1.1.1
      # - WG_MTU=1420
      # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
      # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
      # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
      # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
      # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt
      
    image: weejewel/wg-easy
    container_name: wireguard-server
    volumes:
      - .:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
networks:
  default:
    name: wgnet
    external: trueCode language: YAML (yaml)
```

Tiếp theo, tại file cấu hình Wireguard client và cài đặt trên máy tính / điện thoại dùng để kết nối.

### V. Cấu hình Wireguard client (VPS A)

#### 1. Tạo file cấu hình wg0.conf

Trong bài này mình sẽ lấy file cấu hình từ Wireguad VPN Server từ VPS B đã được thiết lập bằng wg-easy. Truy cập vào dashboard của wg-easy, tạo client mới và tải file cấu hình về, có nội dung tương tự như dưới đây

```yaml
[Interface]
PrivateKey = sO7U9OS0s5vxxxdfY1aNHzVYXpJhKAaU/HG9MyfaWU=
Address = 10.9.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = 9NknLwkQRaxxxsfNr9wKIC15KsqRvN5eOwUZxuhDFWI=
PresharedKey = xhqj9bnxxxuuFtzbVJ5GJPD6D4YAMHdk6RbL5JVkT+M=
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
Endpoint = 252.222.96.107:51822Code language: YAML (yaml)
```

Với cấu hình này, một đường truyền tunnel sẽ được tạo ra và tất cả kết nối bên trong WireGuard container sẽ đi qua tunnel này. Tuy nhiên, chúng ta muốn còn kết nối của máy chủ, nằm ngoài container đi qua Wireguard Tunnel. Do đó, cần phải cấu hình NAT để kết nối đi đúng hướng bằng lệnh sau:

```nginx
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADECode language: Nginx (nginx)
```

Để thiết lập tự động, mình sẽ dùng thông số `PostUp` và `PreDown` trong file cấu hình của WireGuard.

* PostUp: lệnh sẽ chạy sau khi WireGuard tunnel được tạo.
* PostDown: lệnh sẽ chạy trước khi WireGuard tunnel bị hủy.

```nginx
PostUp = iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o wg+ -j MASQUERADECode language: Nginx (nginx)
```

Lưu lại cấu hình cuối cùng trong thư mục `~/wireguad-client/config/wg0.conf`

```javascript
mkdir -p ~/wireguard-client/config
nano ~/wireguard-client/config/wg0.confCode language: JavaScript (javascript)
```

Nhập vào nội dung sau và lưu lại

```yaml
[Interface]
PrivateKey = sO7U9OS0s5vxxxdfY1aNHzVYXpJhKAaU/HG9MyfaWU=
Address = 10.9.0.2/24
DNS = 1.1.1.1
PostUp = iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o wg+ -j MASQUERADE

[Peer]
PublicKey = 9NknLwkQRaxxxsfNr9wKIC15KsqRvN5eOwUZxuhDFWI=
PresharedKey = xhqj9bnxxxuuFtzbVJ5GJPD6D4YAMHdk6RbL5JVkT+M=
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
Endpoint = 252.222.96.107:51822Code language: YAML (yaml)
```

#### 2. Tạo Wireguard client container

Tạo file `docker-compose.yml` để thiết lập Wireguard Client

```bash
cd ~/wireguard-client
nano docker-compose.ymlCode language: Bash (bash)
```

Nhập vào nội dung sau

```yaml
services:
  wireguard:
    image: lscr.io/linuxserver/wireguard
    container_name: wireguard-client
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Ho_Chi_Minh
    volumes:
      - ./config:/config
      - /lib/modules:/lib/modules
    networks:
      default:
        ipv4_address: 10.10.0.2
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
networks:
  default:
    name: wgnet
    external: trueCode language: YAML (yaml)
```

Các thông số cần chú ý:

* Phần `networks` được cấu hình để WireGuard container kết nối vào Docker netwok `wgnet` đã tạo trước đó.
* Dòng 17: cấu hình IP tĩnh cho container `10.10.0.2`

Kích hoạt Docker container bằng lệnh `docker-compose up -d`

Để bảo đảm WireGuard Tunnel đã được tạo thành công, kiểm tra lại logs bằng lệnh `docker logs wireguard-client`. Nếu thấy nó kết thúc với nội dung như dưới đây nghĩa là Tunnel đã được tạo thành công

```yaml
[#] ip -4 route add 0.0.0.0/0 dev wg0 table 51820
[#] ip -4 rule add not fwmark 51820 table 51820
[#] ip -4 rule add table main suppress_prefixlength 0
[#] iptables-restore -n
[#] iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE
[ls.io-init] done.
Code language: YAML (yaml)
```

Nếu trong logs hiện ra lỗi như dưới đây, bạn cần chỉnh sửa lại dòng `AllowedIPs` trong file wg0.conf, xóa `::/0` và chỉ chừa lại  `0.0.0.0/0`. Sau đó khởi động lại container.

```python
Error: IPv6 is disabled on nexthop device.
[#] resolvconf -d wg0 -f
[#] ip link delete dev wg0Code language: Python (python)
```

Kiểm tra xem Wireguard-client đã kết nối thành công chưa bằng lệnh

```bash
docker exec wireguard-client curl -s ifconfig.meCode language: Bash (bash)
```

Nếu thấy kết quả trả về là IP của VPS B nghĩa là Container đã kết nối thành công đến VPS B.

### VI. Cấu hình routing table (VPS A)

#### 1. Trước khi chỉnh sửa

Đầu tiên, kiểm tra thông số của mạng `wgnet`

```nginx
docker network inspect wgnetCode language: Nginx (nginx)
```

Kết quả sẽ hiện ra 2 container `wireguard-client` (đang kết nối đến VPS B) và `wireguard-server` (đang có kết nối từ máy tính ở nhà vào) đang được kết nối vào.

```javascript
   "Containers": {
            "689ba546576337de722cf85f286c9fcb01229152a935f6aa41ca5b83b1d6639e": {
                "Name": "wireguard-client",
                "EndpointID": "7f56478d20d086570d121486e4f84b610387420841dc64cc87a03bff6d38ea8c",
                "MacAddress": "02:42:0a:0a:00:02",
                "IPv4Address": "10.10.0.2/24",
                "IPv6Address": ""
            },
            "9761f07474eab357e6369c8a69e0b677836699ff3e1519011b70690620e10c56": {
                "Name": "wireguard-server",
                "EndpointID": "a45ba1746bbc2d7dd94931f4d752bb303caebbfc051875340258373e0fd346f5",
                "MacAddress": "02:42:0a:0a:00:03",
                "IPv4Address": "10.10.0.3/24",
                "IPv6Address": ""
            }
        },
Code language: JavaScript (javascript)
```

Kiểm tra IP của máy tính đang kết nối vào VPS A bằng cách truy cập `https://ifconfig.me`. Nếu đang kết nối thành công, kết quả sẽ hiện ra IP của VPS A `111.111.111.111`

#### 2. Chỉnh sửa routing table trên wireguard-server container

Trên VPS A, để chuyển kết nối từ container wireguard-server (IP: `10.10.0.3`) đi qua wireguard-client (IP: `10.10.0.2`), mình sẽ sửa lại routing table trong container Wireguard-server như sau

```yaml
docker exec --privileged wireguard-server ip rule add from 10.8.0.0/24 table 120
docker exec --privileged wireguard-server ip route add default via 10.10.0.2 table 120
Code language: YAML (yaml)
```

Giải thích:

1. Tạo routing table mới với id 120, các truy cập từ subnet `10.8.0.0/24` sẽ đi qua routing table này.
2. Chuyển hướng kết nối mặc định của routing table 120 sẽ đi qua IP `10.10.0.2`, là IP của Wireguard-client.

Chú ý: Mỗi khi khởi động lại container wireguard-server, routing table sẽ tự động bị reset, bạn cần phải chạy lại 2 lệnh trên để thiết lập lại kết nối.

#### 3. Xác nhận kết nối thành công

Trên máy tính đang kết nối vào VPS A, truy cập lại `https://ifconfig.me`.

Nếu thấy hiện ra IP của VPS B `222.222.222.222` nghĩa là kết nối bắc cầu đã được thực hiện thành công. Từ PC –> VPS A –> VPS B.

Chúc bạn thực hiện thành công
