---
description: >-
  LoopBack là một framework Node.js và TypeScript mã nguồn mở, có khả năng mở
  rộng cao, từng đoạt giải thưởng dựa trên Express.
---

# Hướng dẫn cài đặt LoopBack 4 và khởi tạo dự án đầu tiên

<figure><img src="https://loopback.io/pages/en/lb4/imgs/lb4-high-level.png" alt=""><figcaption><p>LoopBack 4</p></figcaption></figure>



## **1. Cài đặt LoopBack CLI**

Để bắt đầu, bạn cần cài đặt CLI của LoopBack 4. CLI là công cụ hỗ trợ tạo và quản lý các thành phần trong ứng dụng LoopBack.

* **Bước 1:** Cài đặt Node.js (nếu chưa có). Bạn có thể tải Node.js từ [Node.js Download](../../nodejs/). LoopBack yêu cầu Node.js phiên bản từ 14 trở lên.
*   **Bước 2:** Cài đặt LoopBack CLI bằng cách chạy lệnh sau trong terminal:

    ```bash
    npm install -g @loopback/cli
    ```



    **Lưu ý:** Sử dụng `sudo` nếu cần quyền admin:

    ```bash
    sudo npm install -g @loopback/cli
    ```


*   Kiểm tra CLI đã được cài đặt thành công:

    ```bash
    lb4 --version
    ```



## **2. Khởi tạo dự án LoopBack**

*   **Bước 1:** Tạo một thư mục mới cho dự án (không bắt buộc nhưng nên thực hiện).

    ```bash
    mkdir my-loopback-app
    cd my-loopback-app
    ```


*   **Bước 2:** Sử dụng lệnh CLI để tạo dự án LoopBack:

    ```bash
    lb4 app
    ```


* **Bước 3:** Bạn sẽ được yêu cầu cung cấp một số thông tin:
  * **Project name:** (Tên dự án, mặc định là `my-loopback-app`).
  * **Description:** (Mô tả dự án, tùy chọn).
  * **Application class name:** (Tên lớp chính của ứng dụng, mặc định là `Application`).
  * **Select features to enable:** (Các tính năng bạn muốn bật như ESLint, Prettier, etc.).
* Sau khi cung cấp thông tin, CLI sẽ tự động tạo cấu trúc thư mục và các tệp mã nguồn.

## **3. Cài đặt các gói phụ thuộc**

*   Trong thư mục dự án vừa tạo, chạy lệnh sau để cài đặt tất cả các gói phụ thuộc:

    ```bash
    npm install
    ```



## **4. Chạy ứng dụng**

*   Để khởi động ứng dụng, chạy lệnh:

    ```bash
    npm start
    ```


*   Nếu thành công, bạn sẽ thấy thông báo tương tự:

    ```markdown
    Server is running at http://127.0.0.1:3000
    Try http://127.0.0.1:3000/ping
    ```



## **5. Kiểm tra API**

* Mở trình duyệt và truy cập:
  * _http://127.0.0.1:3000/explorer_: Đây là giao diện **API Explorer** tự động được tạo dựa trên OpenAPI.
  * _http://127.0.0.1:3000/ping_: Endpoint `/ping` để kiểm tra xem ứng dụng hoạt động.

## **6. Cấu trúc thư mục dự án**

Khi tạo xong, dự án sẽ có cấu trúc cơ bản như sau:

```markdown
my-loopback-app/
├── src/
│   ├── controllers/       # Nơi chứa các controller
│   ├── models/            # Định nghĩa các model
│   ├── repositories/      # Repository truy cập dữ liệu
│   ├── datasources/       # Kết nối cơ sở dữ liệu
│   ├── application.ts     # Lớp chính của ứng dụng
│   ├── index.ts           # Điểm vào của ứng dụng
├── package.json           # Thông tin về dự án và các gói npm
├── tsconfig.json          # Cấu hình TypeScript
├── .eslintrc.js           # Cấu hình ESLint
```

## **7. Tiếp theo: Tạo các thành phần trong ứng dụng**

* Sử dụng CLI để tạo thêm các thành phần:
  *   **Controller:**

      ```bash
      lb4 controller
      ```


  *   **Model:**

      ```bash
      lb4 model
      ```


  *   **Repository:**

      ```bash
      lb4 repository
      ```


  *   **Datasource:**

      ```bash
      lb4 datasource
      ```



### **Ví dụ: Tạo ứng dụng Todo**

* Tham khảo tài liệu Todo Tutorial để thực hành xây dựng ứng dụng Todo từ đầu.

Vậy là bạn đã hoàn tất việc cài đặt và khởi tạo dự án LoopBack đầu tiên. Hãy tiếp tục phát triển API của bạn!
