---
description: >-
  Hướng dẫn tích hợp Kira AI vào VS Code qua GitHub Copilot Chat để Vibe Coding —
  kết nối API AI đa mô hình, chi phí thấp, tốc độ cao.
---

# Tích hợp Kira AI vào VS Code để Vibe Coding

Vibe Coding là phương pháp lập trình nơi bạn mô tả ý tưởng bằng ngôn ngữ tự nhiên và để AI sinh code thay bạn. Thay vì gõ từng dòng code thủ công, bạn chỉ cần **gõ prompt** — AI sẽ viết code, gợi ý logic và hoàn thiện dự án.

Tuy nhiên, GitHub Copilot mặc định cần licence trả phí để dùng full feature. **Kira AI** mang đến một giải pháp thay thế: tích hợp API AI đa mô hình (tương thích OpenAI SDK) trực tiếp vào **GitHub Copilot Chat** trong VS Code — không cần cài thêm extension nào khác.

Bài viết này hướng dẫn bạn từng bước thực hiện, từ lấy API Key đến demo chat và sinh code thực tế.

## Kira AI là gì

* **Kira AI:** Nền tảng API AI tập trung, hỗ trợ chat, tạo ảnh, video, TTS. Tương thích 100% format OpenAI SDK — chỉ cần đổi `baseURL` là dùng được.
* **Tốc độ:** Khoảng 150ms cho mỗi phản hồi, phù hợp cho coding real-time.
* **Gói miễn phí:** Đăng ký tài khoản nhận ngay 50.000 tokens — đủ để thử nghiệm và vibe coding cơ bản.

## Yêu cầu

* **IDE:** Visual Studio Code (phiên bản mới nhất khuyến nghị)
* **Extension:** GitHub Copilot + GitHub Copilot Chat (đã cài sẵn trên大多数 VS Code distribution)
* **Tài khoản:** Kira AI (đăng ký miễn phí tại kiraai.vn)
* **Kết nối Internet**

## Hướng dẫn từng bước

### Bước 1: Lấy API Key từ Kira AI

1. Truy cập [https://kiraai.vn](https://kiraai.vn) và đăng ký tài khoản mới.
2. Sau khi đăng nhập, vào **Dashboard** → chọn **Quản lý API key**.
3. Nhấn **Tạo API Key mới** — đặt tên cho key (ví dụ: `vs-code-copilot`).
4. **Sao chép API Key ngay lập tức** — Kira AI sẽ không hiển thị lại key sau khi đóng hộp thoại vì lý do bảo mật.

{% hint style="warning" %}
Hãy lưu API Key ở nơi an toàn (ví dụ: password manager). Nếu mất key, bạn cần tạo key mới thay vì xem lại key cũ.
{% endhint %}

### Bước 2: Mở cài đặt Custom Model trong VS Code

1. Mở VS Code, nhấn `Ctrl + Shift + P` (hoặc `Cmd + Shift + P` trên macOS) để mở Command Palette.
2. Gõ **"Copilot: Open Settings"** hoặc vào **File → Preferences → Settings**.
3. Tìm section **GitHub Copilot Chat** → tìm mục **Models**.
4. Chọn **Edit in settings.json** để mở tệp cấu hình.

### Bước 3: Cấu hình endpoint Kira AI

Thêm cấu hình custom model vào tệp `settings.json` với thông số kết nối của Kira AI:

{% code title="settings.json — Cấu hình Kira AI trong VS Code" overflow="wrap" lineNumbers="true" %}
```json
{
  "github.copilot.chat.models": [
    {
      "id": "kira-3.5-flash",
      "name": "Kira 3.5 Flash",
      "baseUrl": "https://kiraai.vn/api/v1",
      "modelId": "kira-3.5-flash",
      "apiKey": "YOUR_KIRA_API_KEY"
    },
    {
      "id": "kira-2.5-pro",
      "name": "Kira 2.5 Pro",
      "baseUrl": "https://kiraai.vn/api/v1",
      "modelId": "kira-2.5-pro",
      "apiKey": "YOUR_KIRA_API_KEY"
    },
    {
      "id": "kira-2.5-flash",
      "name": "Kira 2.5 Flash",
      "baseUrl": "https://kiraai.vn/api/v1",
      "modelId": "kira-2.5-flash",
      "apiKey": "YOUR_KIRA_API_KEY"
    }
  ]
}
```
{% endcode %}

{% hint style="info" %}
Thay `YOUR_KIRA_API_KEY` bằng API Key thực tế bạn nhận ở Bước 1. Bạn có thể cấu hình nhiều model cùng lúc để chuyển đổi linh hoạt trong quá trình làm việc.
{% endhint %}

### Bước 4: Thông số kết nối

Bảng tóm tắt thông số cần thiết khi cấu hình:

| Thông số | Giá trị |
| --- | --- |
| Base URL | `https://kiraai.vn/api/v1` |
| Auth | `Authorization: Bearer <API_KEY>` |
| Compatibility | OpenAI SDK (đổi `baseURL` là dùng được) |

### Bước 5: Chọn model khi sử dụng

Sau khi cấu hình xong, mở **Copilot Chat** trong VS Code. Ở hộp thoại chọn model, bạn sẽ thấy danh sách các model Kira AI đã thêm.

Bảng model khả dụng trên Kira AI:

| Model | Loại | Mục đích chính |
| --- | --- | --- |
| `kira-3.5-flash` | Chat | Mặc định, đa năng, tốc độ cao — phù hợp vibe coding hàng ngày |
| `kira-3.5-pro` | Chat | Lý luận logic phức tạp, code chuyên nghiệp |
| `kira-2.5-pro` | Chat | Phân tích tài liệu dài, code logic cao |
| `kira-2.5-flash` | Chat | Tốc độ cao, phù hợp chat nhanh và gợi ý code đơn giản |
| `kira-3.0-image` | Image | Tạo ảnh từ prompt text |
| `kira-3.0-tts` | Audio | Tổng hợp giọng nói text-to-speech |

{% hint style="info" %}
Để vibe coding hiệu quả, hãy bắt đầu với `kira-3.5-flash` — model mặc định đa năng, tốc độ cao. Khi cần phân tích code phức tạp hơn, chuyển sang `kira-2.5-pro`.
{% endhint %}

### Bước 6: Demo chat và sinh code

Bây giờ bạn có thể bắt đầu vibe coding ngay trong VS Code. Mở Copilot Chat và thử các prompt sau:

**Tạo function đơn giản:**

```
Viết hàm Python nhận vào danh sách số nguyên, trả về danh sách các số chia hết cho 3 kèm bình phương của chúng
```

**Sinh API endpoint:**

```
Viết ASP.NET Core Web API endpoint POST /api/orders nhận JSON body chứa CustomerId và ProductIds, validate rồi lưu vào database
```

**Debug và giải thích code:**

```
Giải thích đoạn code này và đề xuất cải thiện performance: [dán code vào đây]
```

**Refactor code:**

```
Refactor đoạn code này thành Clean Architecture với Repository Pattern và CQRS
```

GitHub Copilot Chat sẽ sử dụng model Kira AI để trả lời và sinh code trực tiếp trong editor — bạn chỉ cần Accept hoặc Reject từng phần.

## Lợi ích khi dùng Kira AI với VS Code

* **Tốc độ ~150ms:** Phản hồi nhanh, không bị gián đoạn flow coding.
* **Tương thích OpenAI SDK:** Dùng được với mọi tool hỗ trợ OpenAI format — không bị lock-in.
* **Chi phí thấp:** Gói Standard chỉ 50.000đ/tháng cho 5 triệu tokens, Pro 100.000đ/tháng cho 12 triệu tokens.
* **Gói miễn phí 50k tokens:** Đủ để thử nghiệm và vibe coding dự án nhỏ.
* **Đa model:** Chọn model phù hợp — từ flash tốc độ cao đến pro lý luận phức tạp.
* **Không cần extension thêm:** Tích hợp trực tiếp qua GitHub Copilot Chat, không cần cài extension bên thứ ba.

## Lưu ý quan trọng

{% hint style="warning" %}
API Key chỉ hiển thị **một lần** khi tạo. Nếu mất, bạn cần tạo key mới. Hãy lưu key ở nơi an toàn ngay sau khi nhận.
{% endhint %}

{% hint style="info" %}
Các model Kira AI (tiền tố `kira-`) sử dụng token từ gói đăng ký. Để dùng model đối tác (GPT, DeepSeek, Claude...), bạn cần nạp tiền vào ví VND và thanh toán theo mức giá riêng.
{% endhint %}

* **Token consumption:** Input + output token đều bị tính. Kiểm tra `usage` trong response để theo dõi.
* **Rate limit:** Gói miễn phí có giới hạn request — upgrade lên Standard hoặc Pro nếu cần dùng nhiều.
* **Lưu ý bảo mật:** Không commit API Key vào repository. Dùng environment variable hoặc password manager.

## Kết luận

Tích hợp Kira AI vào VS Code qua GitHub Copilot Chat là cách nhanh nhất để bắt đầu vibe coding mà không cần đầu tư nhiều vào licence Copilot đắt đỏ. Với tốc độ ~150ms, đa model và chi phí hợp lý, Kira AI phù hợp cho cả lập trình viên cá nhân và team nhỏ muốn tận dụng AI trong quy trình phát triển.

---

👉 **Đăng ký tài khoản Kira AI ngay** tại [https://kiraai.vn/?ref=nguyenquyitpro](https://kiraai.vn/?ref=nguyenquyitpro) để nhận **50.000 tokens miễn phí** và bắt đầu vibe coding ngay hôm nay. Đây là link affiliate — khi bạn đăng ký qua link này, tác giả sẽ nhận được hoa hồng từ Kira AI mà **không ảnh hưởng** đến quyền lợi của bạn.

**Tài liệu tham khảo:**

* [Kira AI — Cổng kết nối API AI đa mô hình, tích hợp trong 5 phút](general-knowledge/ai/ai-platforms/kira-ai-cong-ket-noi-api-ai-da-mo-hinh-tich-hop-trong-5-phut.md)
* [Kira AI Documents](https://kiraai.vn/documents)
* [GitHub Copilot Chat Custom Models](https://code.visualstudio.com/docs/copilot/chat/github-copilot-chat)
* [Kira AI Chat](https://kiraai.vn/chat)
