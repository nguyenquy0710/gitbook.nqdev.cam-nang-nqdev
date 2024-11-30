# Tự tin làm chủ mạng lưới: Cẩm nang tính toán địa chỉ IP từ A đến Z

## Tìm hiểu về cách tính địa chỉ IP

Địa chỉ IP (Internet Protocol) là một mã số định danh duy nhất được gán cho mỗi thiết bị kết nối với mạng internet. Nó đóng vai trò như địa chỉ nhà của thiết bị trên mạng, giúp các thiết bị khác có thể định vị và giao tiếp với nhau.

Bài viết này sẽ hướng dẫn bạn cách tính địa chỉ IP, bao gồm phân tích địa chỉ IP, giải thích công thức tính lớp và VLAN của địa chỉ IP.

## **Phân tích địa chỉ IP:**

Địa chỉ IP được chia thành 4 phần, mỗi phần được biểu diễn bởi một số thập phân từ 0 đến 255. Các phần này được ngăn cách nhau bởi dấu chấm. Ví dụ: 192.168.1.1 là một địa chỉ IP.

### **Công thức tính lớp:**

Địa chỉ IP được chia thành 5 lớp: A, B, C, D và E. Lớp mạng được xác định bởi 8 bit đầu tiên của địa chỉ IP. Dưới đây là công thức tính lớp địa chỉ IP:

* Lớp A: 0 - 127 (126 mạng)
* Lớp B: 128 - 191 (16384 mạng)
* Lớp C: 192 - 223 (2.097.152 mạng)
* Lớp D: 224 - 239 (được sử dụng cho multicast)
* Lớp E: 240 - 254 (được sử dụng cho nghiên cứu)

### **VLAN:**

VLAN (Virtual Local Area Network) là một mạng LAN ảo được tạo ra trên một mạng LAN vật lý. VLAN giúp chia nhỏ mạng LAN thành các nhóm nhỏ hơn, giúp tăng cường bảo mật và quản lý mạng hiệu quả hơn.

## **Cách tính địa chỉ IP:**

Để tính địa chỉ IP, bạn cần biết:

* Lớp mạng
* Số mạng con
* Số máy chủ trong mỗi mạng con

### **Công thức tính địa chỉ IP:**

* Địa chỉ mạng: Lấy số mạng và dịch sang hệ nhị phân.
* Địa chỉ mạng con: Lấy số mạng con và dịch sang hệ nhị phân.
* Địa chỉ máy chủ: Lấy số máy chủ và dịch sang hệ nhị phân.

#### **Ví dụ:**

Giả sử bạn muốn tính địa chỉ IP cho mạng sau:

* Lớp mạng: B
* Số mạng con: 254
* Số máy chủ trong mỗi mạng con: 254

### **Địa chỉ mạng:**

Lớp B có 8 bit đầu tiên là 10 (1010 trong hệ nhị phân).

#### **Địa chỉ mạng con:**

Số mạng con 254 được dịch sang hệ nhị phân là 11111110.

#### **Địa chỉ máy chủ:**

Số máy chủ 254 được dịch sang hệ nhị phân là 11111110.

#### **Địa chỉ IP:**

Kết hợp các phần địa chỉ mạng, mạng con và máy chủ, ta có địa chỉ IP là:

1010.11111110.11111110

## **Kết luận:**

Bài viết này đã hướng dẫn bạn cách tính địa chỉ IP, bao gồm phân tích địa chỉ IP, giải thích công thức tính lớp và VLAN của địa chỉ IP.

### **Lưu ý:**

Bài viết này chỉ cung cấp thông tin cơ bản về cách tính địa chỉ IP. Để có thể tính toán chính xác địa chỉ IP cho mạng của bạn, bạn cần tham khảo thêm các tài liệu chuyên môn và có kiến thức về mạng máy tính.

<img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"><img src="https://twemoji.maxcdn.com/v/14.0.2/72x72/2615.png" alt="☕️" data-size="line"> _Nếu thấy nội dung này bổ ích, hãy mời tôi một tách cà phê nha!_ [_**https://me.momo.vn/nhquydev**_](https://me.momo.vn/nhquydev)
