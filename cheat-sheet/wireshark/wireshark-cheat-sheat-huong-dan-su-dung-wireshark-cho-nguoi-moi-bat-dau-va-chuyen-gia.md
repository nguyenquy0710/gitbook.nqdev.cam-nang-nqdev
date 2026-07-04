---
description: >-
  Wireshark là công cụ phân tích mạng phổ biến nhất hiện nay, được sử dụng để
  giám sát, phân tích và khắc phục các vấn đề liên quan đến mạng.
---

# Wireshark Cheat Sheat: Hướng dẫn sử dụng Wireshark cho người mới bắt đầu và chuyên gia

Với giao diện mạnh mẽ và nhiều tính năng, **Wireshark** có thể phức tạp nếu bạn mới bắt đầu. Dưới đây là cheat sheet tổng hợp các lệnh, phím tắt và mẹo để bạn làm chủ Wireshark hiệu quả.

***

## **1. Tổng Quan về Wireshark**

### Wireshark là gì?

Wireshark là một trình phân tích giao thức mạng, cho phép bạn chụp và kiểm tra lưu lượng mạng theo thời gian thực. Nó hỗ trợ nhiều giao thức, từ HTTP, TCP, UDP đến DNS, SSL/TLS.

### **Ứng dụng của Wireshark**:

* Phân tích sự cố mạng.
* Phát hiện các lỗ hổng bảo mật.
* Học tập và nghiên cứu về mạng.

***

## **2. Phím Tắt Wireshark Cần Biết**

| **Phím Tắt**       | **Chức năng**                       |
| ------------------ | ----------------------------------- |
| `Ctrl + E`         | Bắt đầu hoặc dừng chụp gói tin.     |
| `Ctrl + K`         | Mở hộp thoại Capture Options.       |
| `Ctrl + Shift + S` | Lưu tất cả các gói tin đã chụp.     |
| `Ctrl + F`         | Tìm kiếm trong các gói tin đã chụp. |
| `Ctrl + P`         | Hiển thị các giao diện mạng.        |
| `Ctrl + W`         | Đóng file hiện tại.                 |
| `Shift + Ctrl + T` | Theo dõi luồng (TCP Stream).        |

***

## **3. Bộ Lọc (Filters)**

Bộ lọc là trái tim của Wireshark, giúp bạn thu hẹp phạm vi phân tích.

### **3.1. Bộ lọc hiển thị (Display Filters)**

| **Bộ Lọc**               | **Ý Nghĩa**                                          |
| ------------------------ | ---------------------------------------------------- |
| `ip.addr == 192.168.1.1` | Hiển thị tất cả lưu lượng đến hoặc đi từ địa chỉ IP. |
| `tcp.port == 80`         | Lọc lưu lượng qua cổng 80 (HTTP).                    |
| `udp.port == 53`         | Lọc lưu lượng DNS.                                   |
| `http`                   | Hiển thị tất cả các gói HTTP.                        |
| `tls`                    | Hiển thị tất cả các gói TLS/SSL.                     |
| `dns`                    | Hiển thị lưu lượng DNS.                              |
| \`!(arp                  |                                                      |

### **3.2. Bộ lọc chụp (Capture Filters)**

| **Bộ Lọc**           | **Ý Nghĩa**                                    |
| -------------------- | ---------------------------------------------- |
| `host 192.168.1.1`   | Chỉ chụp lưu lượng từ hoặc đến IP 192.168.1.1. |
| `port 443`           | Chỉ chụp lưu lượng qua cổng 443 (HTTPS).       |
| `net 192.168.1.0/24` | Chỉ chụp lưu lượng trong mạng con.             |
| `tcp`                | Chỉ chụp lưu lượng TCP.                        |
| `udp`                | Chỉ chụp lưu lượng UDP.                        |
| `icmp`               | Chỉ chụp lưu lượng ICMP.                       |

***

## **4. Các Tính Năng Nổi Bật**

### **4.1. Theo Dõi Dữ Liệu Theo Dòng (Follow Stream)**

* **TCP Stream**: Chọn một gói TCP → Nhấn `Ctrl + Shift + T` để theo dõi luồng giao tiếp của TCP.
* **UDP Stream**: Chọn gói UDP → Sử dụng `Follow UDP Stream`.

### **4.2. Phân Tích Giao Thức**

* **Statistics** → Protocol Hierarchy: Hiển thị thống kê các giao thức trong file pcap.
* **Statistics** → IO Graphs: Tạo biểu đồ để xem lượng lưu lượng theo thời gian.

### **4.3. Xuất File Pcap**

* **File** → Export Specified Packets: Xuất một phần hoặc toàn bộ các gói tin đã chụp.

### **4.4. Giải Mã Giao Thức (Decrypt TLS/SSL)**

Wireshark hỗ trợ giải mã lưu lượng TLS/SSL nếu bạn có private key.

1. Vào **Edit → Preferences → Protocols → TLS**.
2. Chọn file key `.key` để giải mã lưu lượng.

***

## **5. Các Lệnh CLI của Wireshark (Tshark)**

Wireshark đi kèm công cụ dòng lệnh là **tshark**.

| **Lệnh**                               | **Chức năng**                               |
| -------------------------------------- | ------------------------------------------- |
| `tshark -i eth0`                       | Chụp gói tin trên giao diện `eth0`.         |
| `tshark -r file.pcap`                  | Đọc file pcap.                              |
| `tshark -w output.pcap`                | Lưu gói tin đã chụp vào file `output.pcap`. |
| `tshark -Y "http.request"`             | Chỉ hiển thị các gói HTTP request.          |
| `tshark -T fields -e ip.src -e ip.dst` | Hiển thị địa chỉ IP nguồn và đích.          |

***

## **6. Mẹo Sử Dụng Wireshark Hiệu Quả**

1. **Sử dụng Display Filters trước**: Tập trung vào việc hiển thị dữ liệu cần thiết trước khi phân tích chi tiết.
2. **Lọc theo giao thức**: Sử dụng các từ khóa như `http`, `dns`, `tcp` để nhanh chóng tìm giao thức bạn cần.
3. **Dùng phím tắt**: Phím tắt giúp bạn làm việc nhanh hơn trong các tác vụ thường xuyên.
4. **Lưu các bộ lọc thường dùng**: Bạn có thể lưu các bộ lọc hay sử dụng để không phải nhập lại.

***

## **7. Tài liệu tham khảo**

{% code overflow="wrap" lineNumbers="true" %}
```markdown
- [Wireshark Cheat Sheet](https://assets.ctfassets.net/kvf8rpi09wgk/a2PBJT7Qq9XL7Bbf81Ajh/e28b9c889edc13ddb1e81ed5ce678809/Wireshark_Cheat_Sheet__6_.pdf)
- [The Ultimate Wireshark Cheat Sheet](https://cyberforge.academy/the-ultimate-wireshark-cheat-sheet-for-cybersecurity-professionals/)
- [GH: Wireshark Cheatsheet](https://github.com/lyudaio/cheatsheets/blob/main/security/tools/wireshark.md)
```
{% endcode %}

***

## **Kết Luận**

Wireshark là một công cụ không thể thiếu cho các nhà quản trị mạng, chuyên gia bảo mật và những ai muốn tìm hiểu về mạng. Với cheat sheet này, bạn sẽ có thể làm chủ các tính năng quan trọng và tối ưu hóa việc sử dụng Wireshark trong công việc. Hãy thực hành và khám phá thêm các tính năng mới để tận dụng tối đa công cụ mạnh mẽ này!
