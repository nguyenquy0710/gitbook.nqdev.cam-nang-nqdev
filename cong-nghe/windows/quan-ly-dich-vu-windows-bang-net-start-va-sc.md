---
description: >-
  Hướng dẫn dùng lệnh net start và sc để quản lý, khởi động, dừng, tạo và cấu
  hình dịch vụ Windows, kèm ví dụ và script tự động hóa thực tế.
---

# Cẩm nang quản lý dịch vụ Windows bằng lệnh net start và sc

### 1. Giới thiệu

Trong hệ điều hành **Windows**, các **dịch vụ (services)** đóng vai trò quan trọng trong việc duy trì hoạt động ổn định của hệ thống – từ in ấn, mạng, bảo mật cho đến phần mềm chạy nền.

Để quản lý các dịch vụ này, Windows cung cấp hai công cụ dòng lệnh mạnh mẽ:

* **`net start` / `net stop`** – dùng để **bật hoặc tắt dịch vụ** nhanh chóng.
* **`sc` (Service Control)** – cho phép **tạo, xóa, cấu hình và kiểm tra chi tiết dịch vụ**.

Bài viết này sẽ hướng dẫn bạn **từng bước từ cơ bản đến nâng cao**, giúp bạn nắm rõ cách dùng, điểm khác biệt và ứng dụng thực tế của hai công cụ này.

***

### 2. Lệnh `net start` – Quản lý dịch vụ cơ bản

#### ✅ Cú pháp:

```
net start [tên_dịch_vụ]
```

#### 🔹 Một số ví dụ phổ biến:

1.  **Xem danh sách các dịch vụ đang chạy:**

    ```
    net start
    ```
2.  **Khởi động một dịch vụ cụ thể (ví dụ Print Spooler):**

    ```
    net start "Print Spooler"
    ```
3.  **Dừng dịch vụ:**

    ```
    net stop "Print Spooler"
    ```

🟢 **Ưu điểm:**

* Dễ dùng, nhanh chóng.
* Phù hợp khi bạn chỉ cần bật/tắt dịch vụ.

🔴 **Hạn chế:**

* Không thể tạo, cấu hình hoặc xóa dịch vụ.
* Không hiển thị chi tiết trạng thái.

***

### 3. Lệnh `sc` – Công cụ điều khiển dịch vụ nâng cao

`sc` (Service Control) là công cụ dòng lệnh mạnh mẽ giúp bạn tương tác sâu hơn với hệ thống dịch vụ Windows.

#### ✅ Cú pháp chung:

```
sc [lệnh] [tên_dịch_vụ] [các_tham_số_khác]
```

#### 📋 Các lệnh thông dụng nhất:

| Lệnh        | Chức năng                   |
| ----------- | --------------------------- |
| `sc start`  | Khởi động dịch vụ           |
| `sc stop`   | Dừng dịch vụ                |
| `sc delete` | Xóa dịch vụ                 |
| `sc query`  | Kiểm tra trạng thái dịch vụ |
| `sc create` | Tạo dịch vụ mới             |
| `sc config` | Cấu hình thông số dịch vụ   |

***

### 4. Tạo dịch vụ tùy chỉnh bằng `sc create`

Khi bạn cần chạy một ứng dụng hoặc tiến trình nền như một dịch vụ Windows, hãy dùng `sc create`.

#### 🧾 Cú pháp:

```
sc create [Tên_dịch_vụ] binPath= "[Đường_dẫn_đến_file_thực_thi]" start= [kiểu_khởi_động]
```

#### 📘 Ví dụ:

Tạo dịch vụ tên **MyService** chạy tự động khi khởi động máy:

```
sc create MyService binPath= "C:\Tools\MyApp.exe" start= auto
```

> ⚠️ **Lưu ý:** Sau dấu `=` cần có khoảng trắng (`start= auto`), và file `.exe` phải hỗ trợ chạy dạng dịch vụ.

***

### 5. Kiểm tra và cấu hình dịch vụ bằng `sc`

#### 🔹 Kiểm tra trạng thái dịch vụ:

```
sc query MyService
```

Kết quả hiển thị:

```
SERVICE_NAME: MyService
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 4  RUNNING
```

* `STATE: 4 RUNNING` → dịch vụ đang chạy
* `STATE: 1 STOPPED` → dịch vụ đã dừng

#### 🔹 Cấu hình kiểu khởi động:

```
sc config MyService start= auto
```

| Giá trị    | Ý nghĩa                        |
| ---------- | ------------------------------ |
| `auto`     | Tự động khởi động cùng Windows |
| `demand`   | Khởi động thủ công             |
| `disabled` | Vô hiệu hóa dịch vụ            |

***

### 6. So sánh nhanh `net start` và `sc`

| Tiêu chí                     | `net start` / `net stop` | `sc`                         |
| ---------------------------- | ------------------------ | ---------------------------- |
| Mức độ phức tạp              | Dễ dùng                  | Nâng cao                     |
| Chức năng chính              | Bật/tắt dịch vụ          | Quản lý toàn diện            |
| Tạo/xóa dịch vụ              | ❌ Không                  | ✅ Có                         |
| Hiển thị trạng thái chi tiết | ❌ Không                  | ✅ Có (`sc query`)            |
| Đối tượng phù hợp            | Người dùng phổ thông     | Quản trị viên, kỹ thuật viên |

***

### 7. Tự động hóa quản lý dịch vụ bằng file Batch (.bat)

Khi bạn cần thao tác thường xuyên, việc dùng **file `.bat`** sẽ giúp tiết kiệm thời gian và tự động hóa quá trình.

***

#### 🧩 Ví dụ 1 – Trình quản lý dịch vụ mini

**📄 File: `service-control.bat`**

```bat
@echo off
title Trinh quan ly dich vu Windows
echo =========================================
echo      CONG CU QUAN LY DICH VU WINDOWS
echo =========================================
echo.
echo 1. Kiem tra trang thai dich vu
echo 2. Khoi dong dich vu
echo 3. Dung dich vu
echo 4. Xoa dich vu
echo 5. Thoat
echo.

set /p choice=Nhap lua chon (1-5): 
set /p service=Nhap ten dich vu: 

if "%choice%"=="1" (
    sc query "%service%"
) else if "%choice%"=="2" (
    net start "%service%"
) else if "%choice%"=="3" (
    net stop "%service%"
) else if "%choice%"=="4" (
    sc stop "%service%"
    sc delete "%service%"
    echo Da xoa dich vu "%service%"
) else (
    echo Tam biet!
)
pause
```

💡 _Cách dùng:_

* Lưu file `.bat` → chạy với quyền **Administrator**
* Nhập số tương ứng với thao tác bạn muốn thực hiện.

***

#### 🧩 Ví dụ 2 – Tự động kiểm tra và khởi động lại dịch vụ bị dừng

**📄 File: `auto-restart-service.bat`**

```bat
@echo off
set servicename=MyService

:loop
sc query "%servicename%" | find "RUNNING" >nul
if errorlevel 1 (
    echo [%date% %time%] Dich vu %servicename% khong chay. Dang khoi dong lai...
    net start "%servicename%"
) else (
    echo [%date% %time%] Dich vu %servicename% van dang hoat dong.
)
timeout /t 60 >nul
goto loop
```

✅ **Tác dụng:**

* Kiểm tra dịch vụ mỗi 60 giây.
* Nếu phát hiện dừng → tự động khởi động lại.
* Có thể chạy ẩn bằng **Task Scheduler** khi khởi động Windows.

***

### 8. Mẹo và thủ thuật hữu ích

| Nhiệm vụ                           | Lệnh tương ứng                                 |
| ---------------------------------- | ---------------------------------------------- |
| Xem toàn bộ dịch vụ (kể cả dừng)   | `sc query type= service state= all`            |
| Ghi log trạng thái dịch vụ ra file | `sc query MyService >> C:\Logs\service.log`    |
| Dừng rồi khởi động lại dịch vụ     | `net stop MyService && net start MyService`    |
| Tự động chạy script khi bật máy    | Dùng **Task Scheduler** → Trigger “At startup” |

***

### 9. Kết luận – Làm chủ dòng lệnh, tối ưu hệ thống

Khi nắm vững `net start` và `sc`, bạn có thể:

* **Kiểm soát toàn bộ dịch vụ Windows** bằng vài dòng lệnh.
* **Tự động hóa** việc khởi động, dừng, khởi tạo hoặc khắc phục lỗi dịch vụ.
* **Tiết kiệm thời gian** và giảm rủi ro thao tác sai trong môi trường thực tế.

{% hint style="info" %}
💬 **Gợi ý cho người dùng nâng cao:**\
Bạn có thể kết hợp thêm **PowerShell** để tạo log chi tiết, gửi thông báo, hoặc tự động khởi động lại dịch vụ khi phát hiện sự cố – giúp quản lý hệ thống chuyên nghiệp hơn nữa.
{% endhint %}
