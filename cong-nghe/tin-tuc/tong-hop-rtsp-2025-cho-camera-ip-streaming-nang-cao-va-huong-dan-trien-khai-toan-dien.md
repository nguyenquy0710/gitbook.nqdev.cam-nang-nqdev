# Tổng hợp RTSP 2025 cho camera IP – Streaming nâng cao và hướng dẫn triển khai toàn diện

Trong thế giới camera IP, việc truy xuất luồng trực tiếp không chỉ để xem hình ảnh mà còn phục vụ cho nhiều bài toán chuyên sâu như ghi hình NVR, phân tích AI, xử lý video server-side, hay tích hợp vào các hệ thống IoT. Ở trung tâm của những nhu cầu đó chính là **RTSP**, giao thức streaming phổ biến nhất hiện nay.

Trong bài viết này, _Cẩm nang NQDEV_ sẽ giúp bạn:

* Nắm được **danh sách RTSP cập nhật 2025 theo từng dòng camera phổ biến**.
* Hiểu rõ sự khác biệt giữa **RTSP – RTMP – HLS**, và khi nào nên chọn giao thức nào.
* Thành thạo **lấy luồng RTSP từ bất kỳ camera nào bằng ONVIF Device Manager (ODM)**.

Bài viết mang tính ứng dụng thực tiễn, phù hợp cho kỹ thuật viên, nhà phát triển phần mềm, lẫn người dùng đang triển khai hệ thống camera.

***

## **1. Danh sách RTSP 2025 theo model camera IP phổ biến**

Dưới đây là **tổng hợp RTSP URL cập nhật 2025**, được chuẩn hóa theo tài liệu của hãng và từ các mẫu triển khai thực tế.

> Lưu ý: Đa phần camera dùng cấu trúc chung:\
> `rtsp://username:password@IP:554/…`

***

### **1.1. Hikvision (2025)**

**Luồng chính (Main Stream):**

```
rtsp://user:pass@ip/Streaming/Channels/101/
```

**Luồng phụ (Sub Stream):**

```
rtsp://user:pass@ip/Streaming/Channels/102/
```

Hikvision thường rất ổn định, phù hợp cho NVR, AI và xử lý real-time.

***

### **1.2. Dahua (2025)**

**Main stream:**

```
rtsp://user:pass@ip/cam/realmonitor?channel=1&subtype=0
```

**Sub stream:**

```
rtsp://user:pass@ip/cam/realmonitor?channel=1&subtype=1
```

Dahua hỗ trợ nhiều profile encoder, đặc biệt dễ dùng cho VMS.

***

### **1.3. Ezviz**

```
rtsp://user:pass@ip:554/h264_stream
```

> Nhiều model Ezviz cần bật chế độ RTSP trong "Local Storage" hoặc "Advanced Settings".

***

### **1.4. Imou (KBVision OEM)**

```
rtsp://user:pass@ip/cam/realmonitor?channel=1&subtype=0
```

Dùng chung với cấu trúc của Dahua.

***

### **1.5. TP-Link / Tapo (2025)**

Tapo mới đã hỗ trợ RTSP qua HomeKit & Tapo Care:

```
rtsp://user:pass@ip/stream1
rtsp://user:pass@ip/stream2
```

***

### **1.6. Yoosee**

```
rtsp://ip/onvif1
rtsp://ip/onvif2
```

Một số model phải bật “RTSP Service” trong phần nâng cao.

***

### **1.7. ONVIF Generic (áp dụng cho hầu hết camera IP)**

```
rtsp://user:pass@ip:554/Streaming/Channels/101
```

**Channel 101 / 102** gần như là tiêu chuẩn chung trên nhiều brand OEM.

***

### **1.8. Camera Trung Quốc – No Brand / Generic**

```
rtsp://user:pass@ip/live/ch00_0
rtsp://user:pass@ip/live/ch00_1
rtsp://user:pass@ip:554/user=USER&password=PASS&channel=1&stream=0.sdp?
```

### **1.9.** Vivotek / Vantech / Generic

```
rtsp://user:pass@ip/live.sdp
rtsp://user:pass@ip:554/ch01/0
```

Mỗi dòng OEM sẽ thay đổi đôi chút nhưng phần lớn theo cấu trúc trên.

***

## **2. So sánh RTSP – RTMP – HLS: Nên dùng giao thức nào cho camera IP?**

Đây là phần quan trọng nhất khi triển khai hệ thống streaming.\
Mỗi giao thức có mục tiêu và ưu điểm riêng.

***

### **2.1. RTSP – Chuẩn cho camera IP & AI real-time**

| Đặc điểm   | Mô tả                                   |
| ---------- | --------------------------------------- |
| Độ trễ     | **Thấp (0.3–1s)**                       |
| Ứng dụng   | Camera IP, xử lý AI, NVR                |
| Chạy trên  | LAN/Internet                            |
| Ưu điểm    | Tốc độ, ổn định, dùng nhiều trong ONVIF |
| Nhược điểm | Không tối ưu cho web, cần player hỗ trợ |

**RTSP phù hợp nhất khi bạn:**

* xem camera nội bộ,
* pull stream cho AI (YOLO, DeepStream…)
* cần độ trễ thấp,
* push qua server trung gian.

***

### **2.2. RTMP – Chuẩn streaming cũ nhưng vẫn hữu dụng**

| Đặc điểm   | Mô tả                                         |
| ---------- | --------------------------------------------- |
| Độ trễ     | 1–3s                                          |
| Ứng dụng   | Push lên Wowza, YouTube, Facebook             |
| Ưu điểm    | Rất ổn định cho ingest                        |
| Nhược điểm | Không hỗ trợ native trên web, bị thay thế dần |

**Dùng RTMP khi cần**: đẩy camera lên server hoặc livestream.

***

### **2.3. HLS – Chuẩn streaming Web-HTML5**

| Đặc điểm   | Mô tả                                |
| ---------- | ------------------------------------ |
| Độ trễ     | 6–20s                                |
| Ứng dụng   | Web, mobile, CDN                     |
| Ưu điểm    | Tương thích mọi trình duyệt hiện đại |
| Nhược điểm | Độ trễ cao nhất                      |

**Chọn HLS khi bạn:**

* muốn xem trên web mà không cài app,
* cần ổn định, nhưng không yêu cầu real-time.

***

### **2.4. Chốt lại: Nên chọn giao thức nào?**

| Mục đích                     | Giao thức phù hợp |
| ---------------------------- | ----------------- |
| AI, phân tích hình ảnh       | **RTSP**          |
| Livestream, push server      | **RTMP**          |
| Xem trên web, app            | **HLS**           |
| Hệ thống camera truyền thống | **RTSP + ONVIF**  |
|                              |                   |

### **2.5.** So sánh RTSP – RTMP – HLS

| Giao thức | Độ trễ | Ổn định | Ứng dụng                             |
| --------- | ------ | ------- | ------------------------------------ |
| RTSP      | 0.3–1s | Cao     | Giám sát, AI, NVR                    |
| RTMP      | 1–3s   | Cao     | Livestream lên server / YouTube / FB |
| HLS       | 6–20s  | Rất cao | Web / Mobile / CDN                   |

**Tóm tắt:**

* RTSP: **real-time**, nội bộ, AI.
* RTMP: livestream, push server.
* HLS: web & mobile, ổn định nhưng trễ cao.

***

## **3. Hướng dẫn lấy RTSP bằng ONVIF Device Manager (ODM)**

Đây là cách **đơn giản nhất** để lấy URL RTSP đúng chuẩn cho mọi loại camera, kể cả OEM hoặc model không rõ hãng.

1. Tải **ODM** (Windows).
2. Đảm bảo camera + PC cùng mạng LAN.
3. ODM quét camera → nhập username/password.
4. Chọn tab **Media → Live Video → Profile**.
5. Copy link RTSP đúng chuẩn (Main/Substream).

> Ví dụ: `rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/101`

***

### **3.1. Cài đặt ONVIF Device Manager**

Tải ODM (Windows) và mở ứng dụng.

* Camera và máy tính phải **cùng mạng LAN**.
* Đảm bảo camera đã bật ONVIF hoặc chế độ mở (NAT/Port).

***

### **3.2. Đăng nhập camera trong ODM**

ODM sẽ tự tìm camera → chọn thiết bị → nhập:

* Username
* Password

Ngay lập tức bạn sẽ thấy thông tin camera, model, firmware.

***

### **3.3. Lấy RTSP của camera**

Vào tab:

> **Media → Live Video**

ODM sẽ hiển thị RTSP trực tiếp, ví dụ:

```
rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/101
```

Hoặc dạng:

```
rtsp://username:password@ip/cam/realmonitor?channel=1&subtype=0
```

ODM luôn trả về **đúng URL theo tiêu chuẩn ONVIF**, giúp bạn tránh lỗi sai định dạng.

## **4. Chuyển RTSP → HLS / WebRTC**

#### **4.1. RTSP → HLS với FFmpeg**

```
ffmpeg -i rtsp://user:pass@IP:554/stream \
       -c:v copy -c:a aac \
       -f hls \
       -hls_time 2 \
       -hls_list_size 5 \
       -hls_flags delete_segments \
       /path/to/output.m3u8
```

* `hls_time`: thời gian mỗi segment (giây)
* `hls_list_size`: số segment lưu trong playlist
* `delete_segments`: xóa segment cũ để tiết kiệm dung lượng

#### **4.2. RTSP → WebRTC**

* Sử dụng **Media Server** (Janus, Ant Media, Wowza, Kurento)
* Input: RTSP URL
* Output: WebRTC → phát trực tiếp trên trình duyệt, độ trễ \~0.5–1s

> Lợi ích: web & mobile đều xem trực tiếp, real-time.

***

## **5. Tạo server streaming**

#### **5.1. Nginx + RTMP module**

* Nginx có module RTMP → push RTSP → RTMP/HLS
* Tối ưu cho web, mobile, livestream nội bộ.

**Cấu hình mẫu:**

```
rtmp {
    server {
        listen 1935;
        application live {
            live on;
            record off;
        }
    }
}
```

* Push bằng FFmpeg:

```
ffmpeg -i rtsp://user:pass@IP:554/stream \
       -c copy -f flv rtmp://server/live/streamkey
```

***

#### **5.2. Wowza / Ant Media / FFmpeg Server**

* **Wowza**: nhận RTSP, push RTMP/HLS/WebRTC, hỗ trợ multi-bitrate.
* **Ant Media**: hỗ trợ low-latency WebRTC.
* **FFmpeg standalone**: RTSP → HLS hoặc RTMP, lightweight, dễ triển khai.

***

## **6. Bộ sưu tập RTSP test camera công cộng**

Dùng để thử nghiệm phần mềm hoặc streaming server:

| Nguồn                    | Link mẫu                                                           |
| ------------------------ | ------------------------------------------------------------------ |
| Public MotionJPEG        | `http://194.87.80.21/mjpg/video.mjpg`                              |
| Wowza RTSP Test          | `rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov` |
| GitHub / AzwadFawadHasan | Các link MJPEG/RTSP mẫu cho dev                                    |

> Lưu ý: Đây chỉ dùng **mục đích thử nghiệm**, không dùng cho triển khai thương mại.

***

## **7. Kết luận**

RTSP vẫn là xương sống của mọi hệ thống camera IP trong năm 2025 – đặc biệt khi nhu cầu phân tích hình ảnh và tích hợp AI ngày càng mạnh mẽ. Việc hiểu rõ sự khác nhau giữa RTSP, RTMP và HLS giúp bạn triển khai đúng mục tiêu, tránh lãng phí tài nguyên, đồng thời tối ưu trải nghiệm người xem.

Ngoài ra, sử dụng ONVIF Device Manager giúp bạn lấy RTSP **nhanh – chính xác – không cần thử từng mẫu**, phù hợp cho mọi kỹ thuật viên và lập trình viên.

* RTSP vẫn là **chuẩn mạnh nhất cho camera IP** và AI real-time.
* RTMP, HLS, WebRTC phục vụ **mục đích livestream / web** khác nhau.
* **ONVIF Device Manager** là cách nhanh và chính xác để lấy RTSP URL.
* FFmpeg, Nginx, Wowza, Ant Media cho phép **xây dựng server streaming** linh hoạt, đa dạng.
* Bộ sưu tập RTSP test giúp bạn **thử nghiệm phần mềm mà không cần camera thật**.

Với hướng dẫn này, bạn có thể **triển khai hệ thống camera IP đầy đủ từ 2025**, từ lấy link, test, tích hợp AI, đến phát trực tiếp trên web/mobile.
