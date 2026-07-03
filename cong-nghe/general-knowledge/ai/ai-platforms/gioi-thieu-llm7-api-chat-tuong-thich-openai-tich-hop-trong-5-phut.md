---
description: >-
  Giới thiệu LLM7.io — API chat tương thích OpenAI SDK, miễn phí hoặc Pro
  $12/tháng, hỗ trợ streaming, JSON mode, function calling và image recognition.
---

# Giới thiệu LLM7: API chat tương thích OpenAI, tích hợp trong 5 phút

LLM7 là nền tảng API chat cung cấp giao diện web **LLM7.chat** và REST API **LLM7.io**, tương thích trực tiếp với OpenAI SDK. Bạn có thể bắt đầu ngay mà không cần đăng ký bằng cách dùng `api_key="unused"`, hoặc đăng ký token tại **dash.llm7.io** để nhận mức giới hạn cao hơn.

### **LLM7 là gì?** <a href="#user-content-llm7-la-gi" id="user-content-llm7-la-gi"></a>



* **LLM7.chat:** Giao diện web giống ChatGPT, đăng nhập bằng Google, dùng miễn phí.
* **LLM7.io:** REST API tại `https://api.llm7.io/v1`, tương thích 100% với OpenAI Python/JS SDK.
* **Dashboard (dash.llm7.io):** Quản lý token, theo dõi usage, kiểm tra Pro allowance.

### **Tính năng chính** <a href="#user-content-tinh-nang-chinh" id="user-content-tinh-nang-chinh"></a>



* **Chat Completions:** Text generation với model selector `default`, `fast`, `pro` hoặc model ID cụ thể.
* **Streaming:** Stream token theo chunk để giảm latency UI.
* **JSON Mode:** Ép model trả về JSON hợp lệ, phù hợp structured data extraction.
* **Function Calling:** Gọi function từ app, model tự quyết định khi nào cần dùng tool.
* **Image Recognition:** Gửi ảnh + text để OCR, caption, visual Q\&A.
* **Models API:** Endpoint `/v1/models` trả về danh sách model realtime với pricing, context window và capability flags.

### **Bảng so sánh các gói** <a href="#user-content-so-sanh-goi" id="user-content-so-sanh-goi"></a>



| Tiêu chí     | Anonymous      | Free Token     | Pro ($12/tháng)             |
| ------------ | -------------- | -------------- | --------------------------- |
| Yêu cầu/giây | 1              | 2              | 25                          |
| Yêu cầu/phút | 10             | 40             | 1.500                       |
| Yêu cầu/giờ  | 60             | 100            | 15.000                      |
| Token/ngày   | 500.000        | 1.000.000      | Dynamic theo billing period |
| Model access | `turbo` models | `turbo` models | `turbo` + `pro` models      |

### **Hướng dẫn bắt đầu** <a href="#user-content-huong-dan" id="user-content-huong-dan"></a>



#### 1. Cài đặt SDK



\{% code title="terminal" overflow="wrap" %\}

```
pip install openai
```

\{% endcode %\}

#### 2. Cấu hình client



\{% tabs %\} \{% tab title="Anonymous (không cần đăng ký)" %\} \{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
import openai

client = openai.OpenAI(
    base_url="https://api.llm7.io/v1",
    api_key="unused",
)
```

\{% endcode %\} \{% endtab %\} \{% tab title="Free Token / Pro Token" %\} \{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
import openai

client = openai.OpenAI(
    base_url="https://api.llm7.io/v1",
    api_key="your-token-from-dash.llm7.io",
)
```

\{% endcode %\} \{% endtab %\} \{% endtabs %\}

#### 3. Tạo chat completion



\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
resp = client.chat.completions.create(
    model="default",  # or "fast", "pro", or a model ID from /v1/models
    messages=[
        {"role": "user", "content": "Giải thích Docker trong 2 câu"}
    ],
)

print(resp.choices[0].message.content)
```

\{% endcode %\}

### **Streaming** <a href="#user-content-streaming" id="user-content-streaming"></a>



Stream token để render UI tức thì:

\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
stream = client.chat.completions.create(
    model="fast",
    messages=[
        {"role": "system", "content": "Answer concisely."},
        {"role": "user", "content": "List three tips for fast Python scripts."},
    ],
    stream=True,
    temperature=0.4,
)

for chunk in stream:
    delta = chunk.choices[0].delta.content or ""
    print(delta, end="", flush=True)
```

\{% endcode %\}

### **JSON Mode** <a href="#user-content-json-mode" id="user-content-json-mode"></a>



Ép model trả JSON hợp lệ, phù hợp cho structured extraction:

\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
import json

stream = client.chat.completions.create(
    model="bidara",
    messages=[
        {"role": "system", "content": "Answer with valid JSON only."},
        {"role": "user", "content": "Return JSON: city, country, temperature_c."},
    ],
    response_format={"type": "json_object"},
    temperature=0.2,
    stream=True,
)

full = ""
for chunk in stream:
    delta = chunk.choices[0].delta.content or ""
    full += delta

data = json.loads(full)
print(data)
```

\{% endcode %\}

> **Lưu ý:** JSON mode phụ thuộc vào model. Kiểm tra `json_mode: true` tại Models API `/v1/models` trước khi dùng.

### **Function Calling** <a href="#user-content-function-calling" id="user-content-function-calling"></a>



Kết nối model với logic bên ngoài bằng tool calls:

\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get current weather for a location",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {"type": "string", "description": "City name"}
            },
            "required": ["location"]
        }
    }
}]

resp = client.chat.completions.create(
    model="openai",
    messages=[{"role": "user", "content": "Weather in London?"}],
    tools=tools,
    tool_choice="auto",
)
```

\{% endcode %\}

Model sẽ tự quyết định gọi function nếu thấy cần. Bạn nhận `tool_calls` từ response, chạy logic, rồi trả kết quả về bằng `role: "tool"`.

### **Image Recognition** <a href="#user-content-image-recognition" id="user-content-image-recognition"></a>



Gửi ảnh URL + text prompt trong cùng một message:

\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
messages = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": "Mô tả ảnh này cho alt text."},
            {"type": "image_url", "image_url": {"url": "https://example.com/image.jpg"}},
        ],
    }
]

resp = client.chat.completions.create(
    model="default",
    messages=messages,
    temperature=0.5,
    stream=True,
)
```

\{% endcode %\}

> **Lưu ý:** Ảnh phải là HTTPS URL. Models có `modalities.input` chứa `image` mới hỗ trợ.

### **Models API — Kiểm tra model realtime** <a href="#user-content-models-api" id="user-content-models-api"></a>



Endpoint `GET /v1/models` trả danh sách model hiện có, bao gồm pricing, context window và các flag:

\{% code title="terminal" overflow="wrap" %\}

```
curl https://api.llm7.io/v1/models
```

\{% endcode %\}

\{% code title="Response" overflow="wrap" %\}

```
{
  "object": "list",
  "data": [
    {
      "id": "gpt-5.4",
      "tier": "pro",
      "pricing": { "input": 0.5, "output": 4.5, "currency": "USD", "unit": "1M tokens" },
      "context_window": { "tokens": 1050000 },
      "stream": true,
      "json_mode": true,
      "tools_calling": true
    }
  ]
}
```

\{% endcode %\}

#### Chọn model theo capability trong code



\{% code title="Python" overflow="wrap" lineNumbers="true" %\}

```
import requests

models = requests.get("https://api.llm7.io/v1/models").json()["data"]

vision_models = [m for m in models if "image" in m["modalities"]["input"]]
json_models  = [m for m in models if m.get("json_mode")]
```

\{% endcode %\}

### **Ưu và nhược điểm** <a href="#user-content-uu-nhuoc-diem" id="user-content-uu-nhuoc-diem"></a>



* **Ưu điểm:** Miễn phí dùng ngay không cần đăng ký, tương thích OpenAI SDK 100%, API endpoint cố định, Pro plan $12/tháng hợp lý cho cá nhân.
* **Nhược điểm:** Không rõ upstream model nào đang chạy sau selector `default`, tier `turbo` chỉ hỗ trợ basic capabilities, Pro allowance tính dynamic nên cần kiểm tra dashboard thường xuyên.
* **Phù hợp:** Dự án cá nhân, prototyping, test prompt, tích hợp nhanh vào chatbot internal.

### **Lưu ý quan trọng** <a href="#user-content-luu-y" id="user-content-luu-y"></a>



* **Model selection:** Dùng selector (`default`, `fast`, `pro`) để tránh phụ thuộc vào model ID cụ thể vì catalog có thể thay đổi.
* **Rate limit:** Anonymous chỉ 1 req/s — đăng ký token miễn phí để nhận 2 req/s.
* **Token counting:** Input + output token đều bị tính. Kiểm tra `usage` trong response để theo dõi.
* **Minimum cost:** Một số model có `minimum_request_price_usd` — dù prompt ngắn cũng bị charge tối thiểu.

**Tài liệu tham khảo:**

* [LLM7 Chat](https://llm7.chat)
* [LLM7 Dashboard](https://dash.llm7.io/)
* [Quickstart](https://docs.llm7.io/quickstart)
* [Streaming](https://docs.llm7.io/guides/streaming)
* [JSON Mode](https://docs.llm7.io/guides/json-mode)
* [Function Calling](https://docs.llm7.io/guides/function-calling)
* [Image Recognition](https://docs.llm7.io/guides/image-recognition)
* [Models API](https://docs.llm7.io/guides/models-api)
* [Limits](https://docs.llm7.io/limits)
