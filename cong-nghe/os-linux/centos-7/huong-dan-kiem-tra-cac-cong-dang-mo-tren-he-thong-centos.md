---
description: >-
  Khi quản trị hệ thống Linux, việc kiểm tra các cổng mạng đang mở là một tác vụ
  quan trọng để theo dõi và đảm bảo an ninh.
---

# Hướng Dẫn Kiểm Tra Các Cổng Đang Mở Trên Hệ Thống CentOS

Trên CentOS, bạn có thể sử dụng nhiều công cụ như `ss`, `netstat`, `lsof`, `firewalld` và `nmap` để xem các cổng nào đang lắng nghe (listening) và đảm bảo rằng các dịch vụ không mong muốn không hoạt động. Dưới đây là các phương pháp phổ biến để thực hiện điều này.

### **1. Sử Dụng `ss` (Socket Statistics)**

`ss` là công cụ tích hợp sẵn trong các hệ thống Linux hiện đại, bao gồm CentOS, và là lựa chọn thay thế cho `netstat`. Công cụ này cho phép bạn xem nhanh các kết nối mạng và các cổng đang mở.

* **Lệnh**:
* ```bash
  ss -tuln
  ```
* **Ý nghĩa của các tùy chọn**:
  * `-t`: Liệt kê các kết nối TCP.
  * `-u`: Liệt kê các kết nối UDP.
  * `-l`: Chỉ liệt kê các cổng đang lắng nghe (listening).
  * `-n`: Hiển thị địa chỉ IP và cổng dưới dạng số, không phân giải tên miền hoặc tên dịch vụ.

Ví dụ, sau khi chạy lệnh này, kết quả có thể trông như sau:

```plaintext
State    Recv-Q   Send-Q   Local Address:Port     Peer Address:Port
LISTEN   0        128      *:80                   *:*
LISTEN   0        128      *:22                   *:*
```

### **2. Sử Dụng `netstat`**

`netstat` là công cụ quen thuộc với nhiều quản trị viên hệ thống để kiểm tra các kết nối mạng và các cổng đang mở. Tuy nhiên, `netstat` có thể không được cài đặt sẵn trên CentOS, đặc biệt là các phiên bản mới hơn. Trong trường hợp này, bạn có thể cài đặt `net-tools` để có lệnh `netstat`.

* **Lệnh**:
* ```bash
  netstat -nutpl
  ```

Lệnh này cho ra kết quả tương tự như `ss`, hiển thị danh sách các cổng đang lắng nghe. Nếu chưa cài `netstat`, bạn có thể cài đặt qua lệnh:

* ```bash
  netstat -nutpl
  ```

Lệnh này cho ra kết quả tương tự như `ss`, hiển thị danh sách các cổng đang lắng nghe. Nếu chưa cài `netstat`, bạn có thể cài đặt qua lệnh:

```bash
sudo yum install net-tools
```

### **3. Sử Dụng `lsof` (List Open Files)**

`lsof` là công cụ mạnh mẽ có thể liệt kê tất cả các tệp và kết nối mở trên hệ thống, bao gồm các kết nối mạng.

* **Lệnh**:
* ```bash
  lsof -i -n
  ```
* **Ý nghĩa của các tùy chọn**:
  * `-i`: Liệt kê tất cả các kết nối mạng.
  * `-n`: Không phân giải tên miền hoặc địa chỉ IP, chỉ hiển thị các địa chỉ IP và cổng dưới dạng số.

Kết quả sẽ hiển thị danh sách các dịch vụ đang nghe trên các cổng mạng, ví dụ:

```sql
$ netstat -nutpl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp6       0      0 :::9100                 :::*                    LISTEN      1419/node_exporter
udp6       0      0 ::1:323                 :::*                                997/chronyd
```

### **4. Sử Dụng `firewalld` (Tường Lửa Mặc Định Trên CentOS)**

Nếu bạn sử dụng `firewalld` - công cụ quản lý tường lửa mặc định trên CentOS 7 và các phiên bản mới hơn, bạn có thể dễ dàng liệt kê các dịch vụ và cổng được phép qua tường lửa.

* **Lệnh**:
* ```bash
  sudo firewall-cmd --list-ports
  ```

Lệnh này sẽ trả về danh sách các cổng đang mở trong tường lửa. Ví dụ, kết quả có thể như sau:

```plaintext
80/tcp 22/tcp
```

### **5. Sử Dụng** `iptables`

Để liệt kê các quy tắc (rules) trong `iptables`, bạn có thể sử dụng lệnh:

```bash
sudo iptables -L -n -v
```

* `-L` : Liệt kê các quy tắc trong tường lửa.
* `-n` : Hiển thị địa chỉ IP và cổng dưới dạng số, không phân giải tên miền.
* `-v` : Hiển thị chi tiết về số lượng kết nối và lưu lượng mạng qua các quy tắc.

Kết quả sẽ trông giống như sau:

```sql
Chain INPUT (policy ACCEPT 1234 packets, 23456 bytes)
 pkts bytes target     prot opt in     out     source               destination         
 1234  23456 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
 5678  67890 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
 4321  12345 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
```

Ở đây, cổng 22 (SSH) và cổng 80 (HTTP) đang mở và được phép qua firewall. Bạn có thể tìm thấy các cổng mà bạn muốn kiểm tra trong các mục `dpt:<port_number>`.

### **6. Sử Dụng `nmap` (Network Mapper)**

`nmap` là công cụ mạnh mẽ giúp quét các cổng và khám phá các dịch vụ mạng trên một thiết bị. Tuy nhiên, `nmap` có thể không được cài đặt sẵn, bạn có thể cài đặt bằng lệnh:

```bash
sudo yum install nmap
```

* **Lệnh quét cổng trên localhost**:
* ```bash
  nmap -sT -O localhost
  ```
* **Ý nghĩa của các tùy chọn**:
  * `-sT`: Thực hiện quét kết nối TCP.
  * `-O`: Thử nhận diện hệ điều hành của máy chủ.

Lệnh này sẽ liệt kê các cổng đang mở trên máy chủ và các dịch vụ đang chạy. Đây là cách dễ dàng để kiểm tra bảo mật cổng mạng khi bạn quản trị nhiều dịch vụ trên một hệ thống CentOS.

## Tóm Tắt Các Lệnh Chính

| Công Cụ       | Lệnh                             | Mục Đích                                                  |
| ------------- | -------------------------------- | --------------------------------------------------------- |
| **ss**        | `ss -tuln`                       | Liệt kê các cổng TCP và UDP đang mở                       |
| **netstat**   | `netstat -tuln`                  | Liệt kê cổng đang mở (cần cài `net-tools`)                |
| **lsof**      | `lsof -i -n`                     | Liệt kê tất cả các kết nối mạng đang mở                   |
| **firewalld** | `sudo firewall-cmd --list-ports` | Liệt kê các cổng mở trong firewall                        |
| **nmap**      | `nmap -sT -O localhost`          | Quét cổng mở trên máy tính và phát hiện dịch vụ đang chạy |

## Kết Luận

Qua hướng dẫn trên, bạn có thể dễ dàng kiểm tra và quản lý các cổng mạng đang mở trên hệ thống CentOS, từ đó giúp bảo vệ hệ thống khỏi các lỗ hổng bảo mật. Lựa chọn công cụ phù hợp phụ thuộc vào nhu cầu cụ thể của bạn, như kiểm tra nhanh hay quét toàn diện. Hy vọng các phương pháp này sẽ hỗ trợ bạn quản lý và đảm bảo an ninh mạng hiệu quả hơn!
