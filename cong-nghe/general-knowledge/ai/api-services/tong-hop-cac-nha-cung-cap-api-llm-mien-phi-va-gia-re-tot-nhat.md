---
description: >-
  Tổng hợp nhà cung cấp API LLM miễn phí và giá rẻ: Google AI Studio, Groq,
  Cerebras, Cloudflare, OpenRouter, TokenPlus, DeepSeek.
---

# Tổng hợp các nhà cung cấp API LLM Miễn Phí và Giá Rẻ Tốt Nhất

Ngày càng nhiều nhà cung cấp LLM mở gói **Free Tier** thực sự (không bắt thẻ tín dụng) hoặc mô hình **Pay-As-You-Go** với giá cực rẻ. Bài viết tổng hợp các lựa chọn tốt nhất hiện nay, kèm code mẫu cấu hình `base_url` để bạn có thể hoán đổi provider chỉ bằng một dòng code.

## Đặc điểm chung của các gói Free Tier

* **Không bắt buộc thẻ tín dụng:** Đăng ký bằng email là có thể dùng ngay, phù hợp cho học tập, prototype và dự án cá nhân.
* **Quota làm mới định kỳ:** Giới hạn theo **RPM** (request/phút), **TPM** (token/phút) hoặc **RPD** (request/ngày), thường reset mỗi ngày hoặc mỗi phút.
* **Chuẩn OpenAI-compatible:** Hầu hết đều hỗ trợ endpoint `/v1/chat/completions` và SDK OpenAI. Chỉ cần đổi `base_url` và `api_key` là chạy được, không cần viết lại code.

{% hint style="info" %}
Với chuẩn OpenAI-compatible, bạn có thể hoán đổi provider (Google AI Studio, Groq, OpenRouter, TokenPlus...) mà không cần thay đổi logic ứng dụng — chỉ đổi `base_url` và `api_key`.
{% endhint %}

## Phần 1: Các nhà cung cấp có gói Miễn Phí (Free Tier) thực sự

### 1. Google AI Studio — Tối ưu nhất cho đa tác vụ & Context lớn

* **Website:** [aistudio.google.com](https://aistudio.google.com)
* **Model miễn phí:** Gemini Flash, Gemini Flash-Lite, Gemma (các biến thể).
* **Hạn mức (Rate Limit) — gói Free (tham khảo, có thể thay đổi):**
  * Gemini 2.5 Flash: ~10 RPM, ~250K TPM, ~250 RPD.
  * Gemini 2.5 Flash-Lite: ~15 RPM, ~250K TPM, ~1.000 RPD.
  * Gemini 2.0 Flash: ~15 RPM, ~1M TPM, ~200 RPD.
  * (Gói trả phí nâng lên hàng nghìn RPM/TPM và không giới hạn RPD theo billing.)
* **Điểm mạnh:**
  * **Context window khổng lồ** (lên đến hàng triệu token), phù hợp phân tích tài liệu dài, codebase lớn.
  * **Đa phương thức:** xử lý ảnh, âm thanh, video, PDF trong cùng một prompt.
  * **Function Calling** chuẩn, dùng tốt cho AI Agent và tool use.
* **Lưu ý:** Gói Free có thể dùng dữ liệu prompt để cải thiện sản phẩm — **không đưa dữ liệu nhạy cảm** (PII, secret, dữ liệu khách hàng) vào prompt khi dùng gói miễn phí.

### 2. Groq — Tốc độ suy luận vô địch

* **Website:** [console.groq.com](https://console.groq.com)
* **Model:** Llama 3.1 8B, Llama 3.3 70B, Qwen, GPT-OSS, Whisper Large v3.
* **Hạn mức (Rate Limit) — gói Free (tham khảo):**
  * Llama 3.1 8B Instant: ~30 RPM, ~6.000 TPM, ~14.400 RPD.
  * Llama 3.3 70B Versatile: ~30 RPM, ~6.000 TPM, ~1.000 RPD.
  * Whisper Large v3: ~20 RPM, ~28.800 giây audio/ngày.
  * (Giới hạn TPM/RPD khác nhau theo từng model; kiểm tra console.groq.com/settings/limits.)
* **Điểm mạnh:** Chip **LPU** (Language Processing Unit) cho tốc độ sinh token cực nhanh, độ trễ gần 0. Phù hợp voice bot, streaming chat, kiểm tra nhanh và các ứng dụng cần phản hồi tức thì.

### 3. Cerebras Inference

* **Website:** [inference.cerebras.ai](https://inference.cerebras.ai)
* **Model:** GPT OSS 120B, Qwen, GLM (preview).
* **Hạn mức (Rate Limit) — gói Free (tham khảo):**
  * ~5 RPM cho phần lớn model.
  * Tối đa ~1 triệu token/ngày (RPD token-based).
  * Một số model preview có thể có giới hạn thấp hơn; kiểm tra inference.cerebras.ai.
* **Điểm mạnh:** **Wafer-Scale Engine** cho tốc độ gõ chữ gần tức thì, throughput cao cho model lớn. Phù hợp khi cần chạy model lớn với tốc độ cao.

### 4. Cloudflare Workers AI

* **Website:** [developers.cloudflare.com/workers-ai](https://developers.cloudflare.com/workers-ai)
* **Model:** DeepSeek, Qwen, Mistral, Llama, Whisper.
* **Hạn mức (Rate Limit) — gói Free (tham khảo):**
  * 10.000 Neurons/ngày (free tier).
  * Mỗi request tốn số Neurons khác nhau tùy model & độ dài output; tác vụ nhẹ ≈ vài chục đến vài trăm Neurons → hàng nghìn request/ngày.
  * Gói trả phí: tính theo Neurons sử dụng (pay-as-you-go).
* **Điểm mạnh:** Tích hợp **edge serverless** của Cloudflare, độ trễ thấp toàn cầu, dễ deploy cùng Workers/Pages. Phù hợp ứng dụng edge và serverless.

### 5. Cohere & Mistral AI — Chuyên dụng cho doanh nghiệp & Code

* **Cohere:**
  * **Trial Key** miễn phí: 1.000 request/tháng, ~20 request/phút (RPM).
  * Mạnh về **Search, RAG, Embeddings và Rerank** — rất phù hợp cho hệ thống tìm kiếm và retrieval.
* **Mistral AI:**
  * **Free Mode** (xác minh SĐT): rate limit thấp, thường ~1–5 RPM cho model nhẹ/code; giới hạn token/ngày theo tier.
  * Phù hợp cho tác vụ code generation và chat nhẹ; kiểm tra console.mistral.ai cho giới hạn chính xác theo model.

### 6. Local LLMs qua Ollama / LM Studio

* **Chi phí:** Miễn phí 100%, chạy trên GPU/CPU cá nhân.
* **Rate Limit:** Không có (self-hosted) — giới hạn duy nhất là phần cứng (VRAM/RAM, throughput). Có thể tự cấu hình concurrency/queue.
* **Bảo mật:** Tuyệt đối — dữ liệu không rời khỏi máy, không giới hạn request, **offline** hoàn toàn.
* **Phù hợp:** Dữ liệu nhạy cảm, môi trường air-gapped, thử nghiệm model open-source (Llama, Qwen, Mistral...) mà không lo quota.

{% hint style="warning" %}
Local LLM cần phần cứng đủ mạnh (GPU VRAM) để chạy model lớn. Với máy yếu, ưu tiên model nhỏ (7B–8B) hoặc dùng quantization.
{% endhint %}

## Phần 2: Các giải pháp Trung gian & Model Giá Siêu Rẻ (Pay-As-You-Go)

### 1. OpenRouter — Một API Key, hàng trăm model

* **Website:** [openrouter.ai](https://openrouter.ai)
* **Gói Free:** Model có hậu tố `:free` — ~20 RPM, 50 request/ngày; nạp ≥$10 → ~1.000 request/ngày (và tăng RPM).
* **Gói trả phí:** So sánh giá token realtime giữa các nhà cung cấp, **tự động fallback/routing** khi một provider lỗi.
* **Rate Limit (tham khảo):** Free ~20 RPM/50 RPD; có credit ~20 RPM/1.000 RPD; gói trả phí theo credit & model provider.
* **Điểm mạnh:** Đa dạng model, một API Key gọi được cả OpenAI, Anthropic, Google, Meta... Phù hợp khi muốn thử nhiều model mà không quản lý nhiều key.

### 2. TokenPlus — Tối ưu chi phí nhờ Cache-hit

* **Website:** [tokenplus.net](https://tokenplus.net)
* **Tương thích:** Chuẩn API OpenAI & Anthropic — chỉ cần đổi `base_url`.
* **Chi phí:** Tối ưu nhờ **cache-hit** (prompt lặp lại chỉ tính phí rất thấp, từ $0.0002–$0.004/1M token).
* **Rate Limit (tham khảo):** Tùy gói/credit; hỗ trợ quản lý quota theo key/phòng ban; failover tự động khi provider nguồn lỗi.
* **Tính năng:** Tự động failover, quản lý ngân sách/quota theo phòng ban/thành viên. Phù hợp doanh nghiệp cần kiểm soát chi phí và availability.

### 3. DeepSeek API — Rẻ cho chat & reasoning

* **Website:** [platform.deepseek.com](https://platform.deepseek.com)
* **Giá:** ~$0.14–$0.28/1M token cho chat & reasoning.
* **Rate Limit (tham khảo):** Pay-As-You-Go; giới hạn theo tier tài khoản (TPM/RPM tăng khi nạp credit); mặc định đủ cho production quy mô nhỏ-trung bình; kiểm tra platform.deepseek.com cho chính xác.
* **Điểm mạnh:** Rẻ hơn 5–10 lần so với model cùng phân khúc của Mỹ. Phù hợp **background agent** và coding hàng loạt (batch processing).

### 4. Các model Flash / Mini của "ông lớn"

* **Google Gemini 2.5/3.x Flash-Lite:** Vài cent đến $0.10/1M token — rẻ, context lớn, đa phương thức. Rate limit theo tier Google AI / Vertex AI (free tier như Gemini Flash-Lite ở trên).
* **OpenAI GPT-4o-mini:** Rẻ, ổn định, **JSON mode & Tool call** hoàn thiện. Rate limit phụ thuộc tier tài khoản OpenAI (TPM/RPM tăng theo usage tier); mặc định đủ cho production nhỏ.

## Bảng so sánh nhanh

| Nhà cung cấp | Loại hình | Yêu cầu thẻ tín dụng? | Thế mạnh nổi bật |
| --- | --- | --- | --- |
| Google AI Studio | Miễn phí | Không | Context lớn, đa phương thức |
| Groq | Miễn phí | Không | Tốc độ gõ chữ nhanh nhất |
| Cerebras | Miễn phí | Không | Tốc độ cao, quota triệu token/ngày |
| Cloudflare Workers AI | Miễn phí | Không | Edge serverless, độ trễ thấp toàn cầu |
| Cohere / Mistral | Miễn phí (trial) | Không | Search, RAG, Embeddings, Code |
| Ollama / LM Studio | Local (Self-hosted) | Không | Bảo mật 100%, offline |
| OpenRouter | Free & Giá rẻ | Không (với model `:free`) | Đa dạng model, một API Key |
| TokenPlus | Giá rẻ | Không bắt buộc thẻ lúc đầu | Tối ưu chi phí nhờ Cache-hit, tương thích OpenAI & Claude |
| DeepSeek API | Giá rẻ | Có (Pay-As-You-Go) | Rẻ 5–10×, chat & reasoning |
| Gemini Flash-Lite / GPT-4o-mini | Giá rẻ | Có (Pay-As-You-Go) | Ổn định, JSON mode, Tool call |

## Bảng hạn mức (Rate Limit) tham khảo

> Lưu ý: Rate limit thay đổi thường xuyên theo chính sách nhà cung cấp và tier tài khoản. Các giá trị dưới đây là **tham khảo** cho gói Free/entry-level; luôn kiểm tra docs chính thức trước khi triển khai production.

| Nhà cung cấp | Gói | RPM | TPM | RPD / Ngày | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| Google AI Studio | Free | 10–15 | 250K–1M | 200–1.000 | Tùy model; Flash-Lite cao hơn |
| Groq | Free | ~30 | ~6.000 | 1.000–14.400 | Tùy kích thước model |
| Cerebras | Free | ~5 | — | ~1M token | Giới hạn theo token/ngày |
| Cloudflare Workers AI | Free | — | — | 10.000 Neurons | Tương đương hàng nghìn request nhẹ |
| Cohere | Trial | ~20 | — | 1.000/tháng | 1.000 req/tháng |
| Mistral | Free Mode | 1–5 | — | Theo tier | Cần xác minh SĐT |
| Ollama / LM Studio | Local | Không giới hạn | Không giới hạn | Không giới hạn | Giới hạn bởi phần cứng |
| OpenRouter | Free (`:free`) | ~20 | — | 50 (1.000 nếu nạp ≥$10) | Nạp $10 nâng quota |
| TokenPlus | Pay-As-You-Go | Theo gói | Theo gói | Theo quota key | Quản lý theo phòng ban |
| DeepSeek | Pay-As-You-Go | Theo tier | Theo tier | Không cố định | Tăng khi nạp credit |
| Gemini Flash-Lite / GPT-4o-mini | Pay-As-You-Go | Theo tier | Theo tier | Không cố định | Ổn định, JSON mode |

## Code mẫu: cấu hình `base_url` với OpenAI SDK (Python)

Với chuẩn OpenAI-compatible, chỉ cần đổi `base_url` và `api_key`. Dưới đây là ví dụ cho các provider phổ biến:

{% tabs %}
{% tab title="Google AI Studio (Gemini)" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
    api_key="YOUR_GEMINI_API_KEY",
)

resp = client.chat.completions.create(
    model="gemini-2.0-flash",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% tab title="Groq" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="https://api.groq.com/openai/v1",
    api_key="YOUR_GROQ_API_KEY",
)

resp = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% tab title="OpenRouter" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="YOUR_OPENROUTER_API_KEY",
)

resp = client.chat.completions.create(
    model="meta-llama/llama-3.3-70b-instruct:free",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% tab title="TokenPlus" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="https://api.tokenplus.net/v1",
    api_key="YOUR_TOKENPLUS_API_KEY",
)

resp = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% tab title="DeepSeek" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="https://api.deepseek.com/v1",
    api_key="YOUR_DEEPSEEK_API_KEY",
)

resp = client.chat.completions.create(
    model="deepseek-chat",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% tab title="Ollama (Local)" %}
{% code title="Python" overflow="wrap" lineNumbers="true" %}
```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama",  # Ollama không kiểm tra key
)

resp = client.chat.completions.create(
    model="llama3.2",
    messages=[{"role": "user", "content": "Xin chào!"}],
)
print(resp.choices[0].message.content)
```
{% endcode %}
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Mẹo: Dùng biến môi trường `OPENAI_BASE_URL` và `OPENAI_API_KEY` để chuyển provider mà không cần sửa code — chỉ đổi env.
{% endhint %}

## Lời khuyên triển khai thực tế

* **Giai đoạn Test & Prototype:** Dùng **Google AI Studio** (phân tích context dài, đa phương thức) kết hợp **Groq** (test logic phản hồi nhanh, streaming).
* **Giai đoạn Deploy Production quy mô nhỏ:** Tích hợp qua **OpenRouter** hoặc **TokenPlus** để tận dụng fallback tự động, cache token và quản lý quota theo team.
* **Dữ liệu nhạy cảm:** Ưu tiên **Ollama/LM Studio** (local) hoặc gói trả phí có cam kết không dùng dữ liệu huấn luyện.
* **Tối ưu chi phí:** Bắt đầu với model Flash/Mini (Gemini Flash-Lite, GPT-4o-mini) cho tác vụ đơn giản; chỉ escalate lên model lớn khi cần.

## Tài liệu tham khảo

* [Tino — LLM lấy API Key miễn phí](https://tino.vn/blog/llm-lay-api-key-mien-phi/)
* [Invent with Python — Free LLMs](https://inventwithpython.com/blog/free-llms.html)
* [TokenPlus](https://tokenplus.net/)
* [Free LLM list (GitHub)](https://github.com/nejib1/Free-LLM)
* [Google AI Studio](https://aistudio.google.com)
* [Groq Console](https://console.groq.com)
* [Cerebras Inference](https://inference.cerebras.ai)
* [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai)
* [OpenRouter](https://openrouter.ai)
* [DeepSeek Platform](https://platform.deepseek.com)