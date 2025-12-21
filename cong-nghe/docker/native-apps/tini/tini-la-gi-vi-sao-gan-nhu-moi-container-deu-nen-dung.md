---
description: >-
  Trong thế giới container hoá, nơi ứng dụng được đóng gói gọn nhẹ và chạy độc
  lập, có một “người hùng thầm lặng” nhưng cực kỳ quan trọng: tini.
---

# Tini là gì? Vì sao gần như mọi container đều nên dùng?

Dù kích thước chỉ vài kilobytes, tini lại giải quyết một vấn đề cốt lõi — điều mà rất nhiều lập trình viên chỉ nhận ra khi ứng dụng bắt đầu bị treo, zombie process tăng dần, hoặc các tín hiệu điều khiển (SIGTERM, SIGINT…) không hoạt động như mong đợi.

***

## **1. Vì sao cần một init process trong container?**

Khác với hệ điều hành truyền thống, một container **không có đầy đủ hệ thống init** để quản lý tiến trình. Điều này dẫn đến một loạt vấn đề:

#### **■ Zombie process không được thu gom**

Các tiến trình con kết thúc nhưng không được `wait()` → trở thành zombie → chiếm tài nguyên và dồn ứ theo thời gian.

#### **■ Ứng dụng không nhận đúng tín hiệu tắt**

Docker gửi `SIGTERM` để dừng container.\
Nhưng nếu ứng dụng nằm dưới nhiều lớp process, tín hiệu có thể **không truyền xuống** đúng nơi cần thiết.

#### **■ Container dừng chậm, shutdown không sạch**

Khi ứng dụng không nhận tín hiệu, Docker buộc phải `SIGKILL` → dừng đột ngột → rủi ro mất dữ liệu hoặc ngắt kết nối không an toàn.

Chính vì vậy, cần một tiến trình đứng ở PID 1 đủ “khôn ngoan” để xử lý tín hiệu và thu gom tiến trình con.

***

## **2. Tini – init system tối giản nhưng hiệu quả**

#### **Tini làm gì?**

* Đóng vai trò **PID 1** bên trong container.
* Nhận và chuyển tiếp mọi tín hiệu chuẩn (SIGTERM, SIGINT…) đến ứng dụng của bạn.
* Thu gom zombie process để tránh tràn tài nguyên.
* Đảm bảo container dừng đúng cách, an toàn và có kiểm soát.

#### **Điểm nổi bật**

* **Rất nhẹ** – chỉ vài kilobytes.
* **Không phụ thuộc phức tạp** – không cần cấu hình nhiều.
* **Ổn định và được Docker khuyên dùng**.
* **Tích hợp sẵn trong Docker (tùy chọn `--init`)**.

***

## **3. So sánh Tini với các giải pháp khác**

### **a/ So với việc không dùng init (chạy thẳng ứng dụng)**

| Tiêu chí       | Không init              | Tini                 |
| -------------- | ----------------------- | -------------------- |
| Xử lý tín hiệu | Thường sai lệch, bỏ sót | Đầy đủ, chính xác    |
| Zombie process | Dễ phát sinh            | Được thu gom tự động |
| Shutdown       | Chậm hoặc không sạch    | An toàn, theo chuẩn  |
| Độ ổn định     | Phụ thuộc ứng dụng      | Đồng đều, ổn định    |
| Thiết lập      | Dễ nhưng rủi ro         | Chỉ thêm 1 dòng lệnh |

**Kết luận:** tini giải quyết triệt để các vấn đề mà ứng dụng đơn lẻ không thể tự xử lý.

***

### **b/ So với s6, runit hoặc systemd**

| Công cụ        | Trọng lượng | Độ phức tạp  | Mục đích               |
| -------------- | ----------- | ------------ | ---------------------- |
| **systemd**    | Nặng        | Rất phức tạp | Quản lý dịch vụ đầy đủ |
| **s6 / runit** | Nhẹ vừa     | Vừa phải     | Supervisor + init      |
| **tini**       | Siêu nhẹ    | Tối giản     | Chỉ làm init + signal  |
| **Không init** | Rất nhẹ     | Không có     | Nhiều rủi ro           |

**Tini hợp lý nhất** khi bạn chỉ cần một init an toàn, đơn giản, không rườm rà.

***

## **4. Cách dùng Tini trong Docker**

#### **Cách 1: Bật init tích hợp sẵn của Docker**

```bash
docker run --init your-image
```

#### **Cách 2: Dùng trực tiếp trong Dockerfile**

```dockerfile
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["your_app"]
```

#### **Dùng Alpine Linux (rất phổ biến)**

```dockerfile
apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
```

***

## **Kết luận – Một lựa chọn nhỏ, mang lại sự ổn định lớn**

Tuy nhỏ bé, **tini lại đóng vai trò nền tảng để container vận hành ổn định và chuyên nghiệp**.\
Trong môi trường triển khai thực tế — từ server cá nhân đến hệ thống Kubernetes quy mô lớn — tini giúp ứng dụng:

* Vận hành an toàn
* Xử lý tín hiệu chính xác
* Dọn dẹp tiến trình sạch sẽ
* Giảm lỗi khó đoán và tiết kiệm tài nguyên

Nếu bạn hướng đến một hệ thống bền vững, dễ bảo trì, việc bổ sung tini vào container là một bước nhỏ nhưng có tầm nhìn dài hạn.
