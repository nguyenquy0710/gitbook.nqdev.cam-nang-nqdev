---
description: >-
  Kira AI — cổng kết nối API AI đa mô hình, tương thích OpenAI SDK. Hỗ trợ chat,
  tạo ảnh, video, TTS và WordPress Plugin. White-Label, không lock-in nhà cung
  cấp.
---

# Kira AI — Cổng kết nối API AI đa mô hình, tích hợp trong 5 phút

Kira AI là nền tảng API AI tập trung, hỗ trợ cả **Web Client** (chat trực tiếp trên trình duyệt) và **REST API** tương thích 100% format OpenAI. Bạn có thể dùng SDK OpenAI hiện tại, chỉ cần đổi `baseURL` là tích hợp ngay.

Ngoài chat, Kira AI còn hỗ trợ tạo ảnh, video, text-to-speech và có sẵn **WordPress Plugin** để tạo nội dung SEO tự động. Hỗ trợ White-Label và đa mô hình — không bị lock-in vào một nhà cung cấp duy nhất.

### **Thông số kết nối API** <a href="#user-content-thong-so-ket-noi" id="user-content-thong-so-ket-noi"></a>



| Param    | Value                                   |
| -------- | --------------------------------------- |
| Base URL | `https://kiraai.vn/api/v1`              |
| Auth     | `Authorization: Bearer <KIRA_API_KEY>`  |
| Compat   | OpenAI SDK (đổi `baseURL` là dùng được) |

#### Models



| Model                  | Mục đích                                                  |
| ---------------------- | --------------------------------------------------------- |
| `kira-3.5-flash`       | Mặc định, đa năng, tốc độ cao                             |
| `kira-3-flash-preview` | Preview mới nhất                                          |
| `kira-2.5-flash`       | Tốc độ cao                                                |
| `kira-2.5-pro`         | Lý luận logic, code chuyên nghiệp, phân tích tài liệu dài |

### **API Chat** <a href="#user-content-api-chat" id="user-content-api-chat"></a>



Endpoint: `POST /chat/completions` (OpenAI-compatible)

{% code title="Node.js — OpenAI SDK" overflow="wrap" lineNumbers="true" %}
```js
import OpenAI from "openai";

const openai = new OpenAI({
  baseURL: "https://kiraai.vn/api/v1",
  apiKey: "YOUR_KIRA_API_KEY"
});

const completion = await openai.chat.completions.create({
  model: "kira-3.5-flash",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Xin chào Kira AI!" }
  ]
});

console.log(completion.choices[0].message.content);
```
{% endcode %}

### **API: Image Generation** <a href="#user-content-api-image" id="user-content-api-image"></a>



Endpoint: `POST /images/generations`

**Models:**

* `kira-3-pro-image-preview` — chất lượng cao
* `kira-3.1-flash-image-preview` — tốc độ cao

**Aspect ratios:** `1:1`, `16:9`, `9:16`, `4:3`, `3:4`

{% code title="curl" overflow="wrap" lineNumbers="true" %}
```bash
curl -X POST https://kiraai.vn/api/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KIRA_API_KEY" \
  -d '{
    "model": "kira-3-pro-image-preview",
    "prompt": "cyber-punk city in rain, neon lights, high resolution",
    "aspect_ratio": "16:9"
  }'
```
{% endcode %}

### **API: Text-to-Speech (TTS)** <a href="#user-content-api-tts" id="user-content-api-tts"></a>



Endpoint: `POST /audio/speech` (OpenAI-compatible)

#### Giọng đọc



| OpenAI voice | Kira voice |
| ------------ | ---------- |
| `alloy`      | Kore       |
| `echo`       | Fenrir     |
| `fable`      | Puck       |
| `onyx`       | Charon     |
| `nova`       | Aoede      |

{% tabs %}
{% tab title="cURL" %}
{% code title="terminal" overflow="wrap" %}
```bash
curl -X POST https://kiraai.vn/api/v1/audio/speech \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KIRA_API_KEY" \
  -d '{
    "model": "kira-2.5-flash",
    "input": "Chào mừng bạn đến với Kira AI.",
    "voice": "alloy"
  }' --output output.mp3
```
{% endcode %}
{% endtab %}
{% tab title="Node.js" %}
{% code title="Node.js — OpenAI SDK" overflow="wrap" lineNumbers="true" %}
```js
import fs from "fs";
import OpenAI from "openai";

const openai = new OpenAI({
  baseURL: "https://kiraai.vn/api/v1",
  apiKey: "YOUR_KIRA_API_KEY"
});

const mp3 = await openai.audio.speech.create({
  model: "kira-2.5-flash",
  voice: "alloy",
  input: "Chào mừng bạn đến với Kira AI."
});

const buffer = Buffer.from(await mp3.arrayBuffer());
await fs.promises.writeFile("output.mp3", buffer);
```
{% endcode %}
{% endtab %}
{% endtabs %}

### **API: Video Generation** <a href="#user-content-api-video" id="user-content-api-video"></a>



Async — Operation model (2 bước):

**Bước 1:** `POST /videos/generations` → nhận `operation_id` (UUID)

**Bước 2:** `GET /videos/operations/:uuid` poll trạng thái, nhận link download khi hoàn tất.

Model: `kira-3.1-generate-001`

### **Pricing & Token Usage** <a href="#user-content-pricing" id="user-content-pricing"></a>



| Gói                      | Token / tháng                        | Số ảnh ước tính |
| ------------------------ | ------------------------------------ | --------------- |
| Kira Mini 1.0 (Miễn phí) | 50.000 tokens — không hỗ trợ tạo ảnh | 0 ảnh           |
| Kira Standard            | 5.000.000 tokens                     | ≈ 5.000 ảnh     |
| Kira Pro                 | 12.000.000 tokens                    | ≈ 12.000 ảnh    |
| Kira Enterprise          | Không giới hạn (5M tokens/ngày)      | Không giới hạn  |

#### Token consumption video



Giả định: **15.000 token/phút** (trung bình).

| Gói             | Số video 5 phút | Tổng phút          |
| --------------- | --------------- | ------------------ |
| Kira Standard   | ≈ 66 video      | ≈ 330 phút         |
| Kira Pro        | ≈ 160 video     | ≈ 800 phút         |
| Kira Enterprise | ≈ 66 video/ngày | ≈ 9.900 phút/tháng |

> Các con số trên là ước tính, thực tế phụ thuộc vào model và độ phân giải bạn chọn.

### **WordPress Plugin** <a href="#user-content-wordpress-plugin" id="user-content-wordpress-plugin"></a>



Plugin Kira AI biến WordPress của bạn thành một CMS thông minh với AI:

1. **Tạo nội dung bài viết** — Focus Keyword + Prompt → HTML chuẩn SEO (H2/H3/H4), tích hợp Rank Math + Yoast
2. **Featured Image tự động** — ảnh khớp nội dung, tỉ lệ tuỳ chọn, auto alt text, lưu Media Library
3. **Row Actions** — AI Tạo ảnh, AI Viết lại Title, AI Viết lại Nội dung
4. **Taxonomies** — AI tạo `term_image` + mô tả cho category/tag
5. **Media Library Studio** — Prompt → tạo ảnh bất kỳ
6. **Log API** — Quản lý log trong wp-admin

#### Cài đặt



1. Install plugin **Kira AI** từ WordPress Plugin Directory
2. Cấu hình **API Key** trong settings
3. **Kiểm tra kết nối** API
4. Chọn post types áp dụng
5. Bắt đầu sử dụng

### **Kết luận** <a href="#user-content-ket-luan" id="user-content-ket-luan"></a>



Kira AI là giải pháp API AI all-in-one dễ tích hợp nhờ tương thích OpenAI SDK. Dù bạn cần chat, tạo ảnh, video, TTS hay tự động hóa nội dung WordPress, Kira AI đều đáp ứng được với mức giá linh hoạt từ miễn phí đến enterprise.

> 🚀 **Kiếm thu nhập với chương trình Affiliate Kira AI** — Giới thiệu bạn bè, đồng nghiệp sử dụng Kira AI và nhận hoa hồng hấp dẫn. Đăng ký ngay tại: [**https://kiraai.vn/?ref=nguyenquyitpro**](https://kiraai.vn/?ref=nguyenquyitpro)

**Tài liệu tham khảo:**

* [Kira AI Chat](https://kiraai.vn/chat)
* [Kira AI Guide](https://kiraai.vn/guide)
* [Kira AI Documents](https://kiraai.vn/documents)
* [Kira AI Image](https://kiraai.vn/images)
* [Kira AI Video](https://kiraai.vn/videos)
* [Kira Voices](https://kiraai.vn/voices)
* [WordPress Plugin Kira AI](https://huykira.net/tich-hop-ai-vao-wordpress-voi-plugin-kira-ai/)
