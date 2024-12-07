# Chi tiết giao diện trong Registry Editor

Registry Editor (Regedit) có giao diện trực quan với hai phần chính: **Thanh bên trái** (chứa cấu trúc cây thư mục) và **Thanh bên phải** (hiển thị chi tiết các giá trị). Dưới đây là hướng dẫn chi tiết về từng phần giao diện:

***

## **1. Thanh bên trái (Cây thư mục Registry)**

Thanh bên trái hiển thị cấu trúc cây của các khóa Registry (keys) và được chia thành 5 nhánh chính:

### **a. Các nhánh chính trong Registry**

1. **HKEY\_CLASSES\_ROOT (HKCR):**
   * Chứa thông tin về kiểu tệp (file type) và liên kết của chúng với các ứng dụng.
   * Ví dụ: `.txt` liên kết với **Notepad**.
2. **HKEY\_CURRENT\_USER (HKCU):**
   * Lưu trữ cấu hình và tùy chỉnh của người dùng hiện tại.
   * Bao gồm cài đặt về desktop, trình duyệt, giao diện hệ thống, và phần mềm đã cài đặt.
3. **HKEY\_LOCAL\_MACHINE (HKLM):**
   * Chứa các cấu hình hệ thống chung, áp dụng cho tất cả người dùng.
   * Bao gồm thông tin về phần cứng, driver, và phần mềm.
4. **HKEY\_USERS (HKU):**
   * Chứa thông tin cấu hình của tất cả người dùng trên hệ thống.
   * Từng thư mục con đại diện cho một người dùng với một Security Identifier (SID) duy nhất.
5. **HKEY\_CURRENT\_CONFIG (HKCC):**
   * Chứa thông tin cấu hình phần cứng hiện tại, như cài đặt màn hình và thiết bị.

### **b. Các thao tác trên thanh bên trái**

* **Mở rộng khóa:** Nhấn vào dấu `>` bên cạnh tên khóa để hiển thị các khóa con.
* **Tìm kiếm khóa:** Sử dụng tổ hợp phím `Ctrl + F` để tìm nhanh khóa hoặc giá trị.
* **Tạo khóa mới:**
  * Nhấp chuột phải vào một khóa > chọn **New > Key**.
* **Xóa khóa:** Nhấp chuột phải vào khóa > chọn **Delete** > xác nhận.

***

## **2. Thanh bên phải (Chi tiết giá trị và dữ liệu)**

Thanh bên phải hiển thị các **giá trị (values)** của khóa được chọn trong thanh bên trái. Mỗi giá trị có ba thành phần chính:

### **a. Thành phần của giá trị**

1. **Name (Tên):**
   * Là tên của giá trị.
   * Mỗi giá trị trong một khóa phải có tên duy nhất.
2. **Type (Loại dữ liệu):**
   * Loại dữ liệu của giá trị. Các loại thường gặp:
     * **String (REG\_SZ):** Chuỗi ký tự.
     * **Binary (REG\_BINARY):** Dữ liệu nhị phân.
     * **DWORD (REG\_DWORD):** Giá trị số 32-bit.
     * **QWORD (REG\_QWORD):** Giá trị số 64-bit.
     * **Multi-String (REG\_MULTI\_SZ):** Chuỗi đa dòng.
     * **Expandable String (REG\_EXPAND\_SZ):** Chuỗi có chứa biến môi trường.
3. **Data (Dữ liệu):**
   * Giá trị thực tế của key. Ví dụ:
     * Chuỗi ký tự cho REG\_SZ.
     * Giá trị nhị phân cho REG\_BINARY.
     * Số thập phân hoặc hệ 16 cho REG\_DWORD và REG\_QWORD.

### **b. Các thao tác trên thanh bên phải**

* **Chỉnh sửa giá trị:**
  * Nhấp đúp vào giá trị để mở hộp thoại chỉnh sửa.
  * Thay đổi dữ liệu trong ô **Value data**.
* **Tạo giá trị mới:**
  * Nhấp chuột phải vào không gian trống > chọn **New > (loại giá trị)**.
* **Xóa giá trị:**
  * Nhấp chuột phải vào giá trị > chọn **Delete** > xác nhận.
* **Sao chép dữ liệu:**
  * Nhấp chuột phải vào giá trị > chọn **Copy Name** hoặc **Copy Data**.

***

## **3. Thanh công cụ và menu điều hướng**

### **a. Menu chính**

1. **File:**
   * **Export:** Sao lưu Registry thành file `.reg`.
   * **Import:** Khôi phục dữ liệu từ file `.reg`.
   * **Exit:** Thoát khỏi Registry Editor.
2. **Edit:**
   * **Find (Ctrl + F):** Tìm kiếm khóa hoặc giá trị.
   * **Find Next (F3):** Tiếp tục tìm kiếm.
   * **Delete:** Xóa khóa hoặc giá trị được chọn.
   * **Rename:** Đổi tên khóa hoặc giá trị.
3. **View:**
   * **Status Bar:** Hiển thị trạng thái ở cuối cửa sổ.
   * **Refresh (F5):** Làm mới giao diện.
4. **Help:**
   * Truy cập tài liệu hỗ trợ của Microsoft về Registry Editor.

### **b. Thanh địa chỉ**

* Hiển thị đường dẫn của khóa đang được chọn.
* Có thể nhập trực tiếp đường dẫn để đi nhanh đến một khóa.

***

## **4. Thanh trạng thái (Status Bar)**

* Nằm ở cuối cửa sổ, hiển thị thông tin về khóa hoặc giá trị đang chọn.
* Ví dụ: Đường dẫn đầy đủ của một khóa hoặc tên giá trị.

***

## **5. Hộp thoại chỉnh sửa giá trị**

Khi nhấp đúp vào một giá trị trong thanh bên phải, hộp thoại chỉnh sửa sẽ xuất hiện. Gồm các phần:

* **Value name:** Tên giá trị (không chỉnh sửa được).
* **Value data:** Dữ liệu cần thay đổi.
* **Base:** Lựa chọn hệ thập phân (Decimal) hoặc hệ 16 (Hexadecimal) cho REG\_DWORD và REG\_QWORD.

***

## **Tóm tắt thao tác cơ bản trên từng giao diện**

| **Thành phần**          | **Chức năng**                   | **Phím tắt/Thao tác**                     |
| ----------------------- | ------------------------------- | ----------------------------------------- |
| **Thanh bên trái**      | Duyệt và mở khóa Registry       | Nhấn `>` hoặc `Enter`                     |
| **Thanh bên phải**      | Hiển thị và chỉnh sửa giá trị   | Nhấp đúp hoặc nhấp chuột phải > Chọn lệnh |
| **Menu điều hướng**     | Truy cập các tính năng nâng cao | `Alt` để kích hoạt menu                   |
| **Thanh địa chỉ**       | Tìm hoặc điều hướng nhanh       | Nhập đường dẫn và nhấn `Enter`            |
| **Hộp thoại chỉnh sửa** | Thay đổi dữ liệu giá trị        | Nhập dữ liệu mới và nhấn **OK**           |

***

## **Lưu ý khi thao tác trên từng giao diện**

1. Luôn sao lưu Registry trước khi thay đổi.
2. Không xóa hoặc chỉnh sửa nếu bạn không chắc chắn về tác dụng.
3. Sử dụng **Find** và **Find Next** để tìm kiếm nhanh chóng trong cây Registry.

Chúc bạn thao tác an toàn và hiệu quả!
