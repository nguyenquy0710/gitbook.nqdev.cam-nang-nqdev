---
description: >-
  FFmpeg là tập hợp các thư viện và công cụ để xử lý nội dung đa phương tiện như
  âm thanh, video, phụ đề và siêu dữ liệu liên quan.
---

# FFmpeg

#### 🛠️ Cách 1: Lấy trực tiếp URL luồng từ TikTok Live (dùng `yt-dlp` + `ffmpeg`)

Cách này hiệu quả nếu TikTok cung cấp luồng qua giao thức chuẩn (HLS/RTMP) và bạn có thể trích xuất được URL.

**Bước 1: Cài đặt `yt-dlp`**

`yt-dlp` là công cụ mạnh mẽ để tải video và trích xuất luồng từ nhiều trang web, bao gồm TikTok.

bash

```
# Trên Ubuntu/Debian
sudo apt update && sudo apt install yt-dlp ffmpeg -y

# Trên macOS (dùng Homebrew)
brew install yt-dlp ffmpeg

# Trên Windows: tải từ https://github.com/yt-dlp/yt-dlp/releases và cài ffmpeg riêng
```

**Bước 2: Lấy URL luồng trực tiếp từ TikTok Live**

Giả sử bạn có link TikTok Live hợp lệ (ví dụ: `https://www.tiktok.com/@ten_nguoi_dung/live`), chạy lệnh:

bash

```
yt-dlp -g "https://www.tiktok.com/@ten_nguoi_dung/live"
```

Lệnh này sẽ in ra URL luồng video (có thể là `.m3u8` hoặc `.flv`). Nếu có nhiều luồng (âm thanh riêng), bạn có thể thêm tùy chọn `-f` để chọn chất lượng.

> **Lưu ý:** Một số TikTok Live yêu cầu cookie đăng nhập. Nếu gặp lỗi, hãy thử xuất cookie từ trình duyệt và dùng `--cookies-from-browser`:
>
> bash
>
> ```
> yt-dlp -g --cookies-from-browser chrome "https://www.tiktok.com/@ten_nguoi_dung/live"
> ```

**Bước 3: Dùng `ffmpeg` để relay lên YouTube**

Sau khi có URL luồng (ví dụ `https://.../stream.m3u8`), bạn chạy ffmpeg để đọc và đẩy lên YouTube:

bash

```
ffmpeg -i "URL_LUONG_TIKTOK" -c copy -f flv "RTMP_YOUTUBE"
```

Trong đó:

* `URL_LUONG_TIKTOK` là URL bạn vừa lấy được.
* `RTMP_YOUTUBE` là địa chỉ RTMP kèm stream key từ YouTube Studio (ví dụ: `rtmp://a.rtmp.youtube.com/live2/xxxx-xxxx-xxxx`).

**Ví dụ hoàn chỉnh (chạy trong loop để tự động kết nối lại):**

bash

```
#!/bin/bash
YOUTUBE_RTMP="rtmp://a.rtmp.youtube.com/live2/STREAM_KEY"
TIKTOK_LIVE_URL="https://www.tiktok.com/@ngocnhi_269/live"

while true; do
    echo "Lấy URL luồng TikTok..."
    STREAM_URL=$(yt-dlp -g --cookies-from-browser chrome "$TIKTOK_LIVE_URL" 2>/dev/null | tail -n1)
    if [ -n "$STREAM_URL" ]; then
        echo "Relay từ $STREAM_URL lên YouTube..."
        ffmpeg -i "$STREAM_URL" -c copy -f flv "$YOUTUBE_RTMP"
    else
        echo "Không lấy được URL, thử lại sau 10s..."
    fi
    sleep 10
done
```

***

#### 🖥️ Cách 2: Thu lại màn hình (Screen Capture) dùng `ffmpeg`

Nếu không lấy được URL trực tiếp, bạn vẫn có thể dùng ffmpeg để ghi lại màn hình đang xem TikTok Live (giống OBS). Cách này hoạt động với mọi live stream nhưng chất lượng phụ thuộc vào cấu hình máy và độ trễ cao hơn.

**Trên Linux (X11):**

bash

```
ffmpeg -f x11grab -s 1920x1080 -i :0.0+0,0 \
       -f alsa -i default \
       -c:v libx264 -preset ultrafast -b:v 2500k \
       -c:a aac -b:a 128k \
       -f flv "rtmp://a.rtmp.youtube.com/live2/STREAM_KEY"
```

* `-s 1920x1080`: độ phân giải thu màn hình.
* `-i :0.0+0,0`: tọa độ màn hình (có thể điều chỉnh).
* `-f alsa -i default`: thu âm thanh từ hệ thống.

**Trên Windows:**

bash

```
ffmpeg -f gdigrab -framerate 30 -i desktop \
       -f dshow -i audio="Microphone (Realtek Audio)" \
       -c:v libx264 -preset ultrafast -b:v 2500k \
       -c:a aac -b:a 128k \
       -f flv "rtmp://a.rtmp.youtube.com/live2/STREAM_KEY"
```

* `-f gdigrab -i desktop`: thu toàn màn hình.
* `-f dshow -i audio="..."`: thu âm thanh (cần kiểm tra tên thiết bị âm thanh).

**Trên macOS:**

bash

```
ffmpeg -f avfoundation -i "1:0" -framerate 30 \
       -c:v libx264 -preset ultrafast -b:v 2500k \
       -c:a aac -b:a 128k \
       -f flv "rtmp://a.rtmp.youtube.com/live2/STREAM_KEY"
```

* `-i "1:0"`: thu màn hình (1) và micro (0), có thể thay đổi.

***

#### ⚠️ Cảnh báo quan trọng

1. **Bản quyền nội dung**: Việc phát lại livestream của người khác khi chưa được phép có thể vi phạm bản quyền và dẫn đến khóa kênh YouTube/TikTok.
2. **Tính hợp lệ của link**: Link bạn cung cấp hiện không phải là live, hãy kiểm tra lại tài khoản có đang phát trực tiếp hay không.
3. **Stream key YouTube**: Lấy từ YouTube Studio → tab "Phát trực tiếp" → "Tạo luồng mới" → chọn "Phần mềm mã hóa". Key có thời hạn và chỉ dùng cho một phiên.

Nếu bạn cần hướng dẫn chi tiết hơn về cách lấy stream key hoặc cài đặt cookie cho yt-dlp, hãy cho mình biết nhé!
