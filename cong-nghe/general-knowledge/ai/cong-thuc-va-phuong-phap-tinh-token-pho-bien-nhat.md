---
description: >-
  Công thức ước lượng nhanh và phương pháp tính token chính xác cho LLM: OpenAI tiktoken, Anthropic count_tokens, lưu ý tiếng Việt.
---

# Công thức và phương pháp tính token phổ biến nhất

Token là đơn vị cơ bản mà các mô hình ngôn ngữ lớn (LLM) dùng để đọc và sinh văn bản. Hiểu cách tính token giúp bạn ước lượng chi phí API, quản lý context window và tối ưu prompt hiệu quả hơn.

## Công thức ước lượng nhanh (tiếng Anh)

Các quy tắc dưới đây thường được OpenAI và nhiều nhà cung cấp khác sử dụng, chủ yếu áp dụng cho văn bản tiếng Anh thông thường:

* **1 token ≈ 4 ký tự** (bao gồm cả khoảng trắng).
* **1 token ≈ ¾ từ** (0.75 từ).
* **100 token ≈ 75 từ**.

**Ví dụ:** Chuỗi `"ChatGPT is great!"` được mã hóa thành 6 token: `["Chat", "G", "PT", " is", " great", "!"]`.

{% hint style="info" %}
Các công thức ước lượng chỉ nên dùng để có con số hình dung ban đầu. Để có kết quả chính xác, hãy dùng tokenizer hoặc API đếm token chính thức của nhà cung cấp.
{% endhint %}

## Công thức tính tổng token (Total Tokens)

Khi gọi API của LLM, tổng số token được tính bằng tổng của token đầu vào và token đầu ra.

* **Công thức:** `Tổng Tokens = Prompt Tokens (Đầu vào) + Completion Tokens (Đầu ra)`
* **Prompt Tokens (Token đầu vào):** Số token trong yêu cầu của bạn (câu hỏi, ngữ cảnh, hướng dẫn...).
* **Completion Tokens (Token đầu ra):** Số token mà mô hình tạo ra trong phản hồi.

**Ví dụ về chi phí:** Nếu một yêu cầu API sử dụng 10 token đầu vào và nhận được 20 token đầu ra, bạn sẽ bị tính phí cho 30 token (10 + 20).

## Phương pháp tính chính xác (sử dụng Tokenizer)

Để có con số chính xác tuyệt đối, bạn cần sử dụng **tokenizer** – công cụ mà chính mô hình đó dùng để chia văn bản. Mỗi dòng mô hình (model family) dùng một tokenizer khác nhau, nên kết quả có thể chênh lệch.

### OpenAI (GPT-3.5, GPT-4, GPT-4o...)

OpenAI cung cấp thư viện `tiktoken` để đếm token chính xác cho các mô hình của họ. Các mô hình như GPT-4 và GPT-3.5 thường sử dụng bảng mã `cl100k_base`.

{% code title="dem-token-openai.py" overflow="wrap" lineNumbers="true" %}
```python
import tiktoken

# Chọn bảng mã cho mô hình (ví dụ: GPT-4)
encoding = tiktoken.get_encoding("cl100k_base")
# Hoặc: encoding = tiktoken.encoding_for_model("gpt-4")

text = "Xin chào, đây là một ví dụ."
tokens = encoding.encode(text)
print(f"Số token: {len(tokens)}")
```
{% endcode %}

Ngoài ra, OpenAI còn cung cấp **API Input Token Count** để đếm token đầu vào một cách chính xác trước khi gửi yêu cầu.

### Anthropic Claude

Claude có tokenizer riêng và **không nên** dùng `tiktoken` của OpenAI để ước lượng, vì nó có thể đếm thiếu khoảng 15–20% so với thực tế. Anthropic cung cấp endpoint `/v1/messages/count_tokens` để đếm chính xác số token trong một tin nhắn mà không cần tạo phản hồi.

{% hint style="warning" %}
Với Claude, hãy luôn dùng endpoint chính thức `/v1/messages/count_tokens` thay vì ước lượng bằng `tiktoken`.
{% endhint %}

## Lưu ý đặc biệt cho tiếng Việt và các ngôn ngữ khác

Các công thức ước lượng ở trên chủ yếu dành cho tiếng Anh. Với tiếng Việt, số lượng token thường **nhiều hơn đáng kể** so với tiếng Anh cho cùng một lượng thông tin, do các từ có thể bị tách thành nhiều token con (subword).

* **Tiếng Việt:** Chưa có một tỷ lệ quy đổi chính thức. Nên dùng tokenizer của mô hình để đếm chính xác thay vì áp dụng công thức 4 ký tự/token.
* **Tiếng Trung:** Là ví dụ điển hình cho sự khác biệt. Trong khi tiếng Anh có thể đạt 4 ký tự/token, thì với tiếng Trung, 1 token thường chỉ tương ứng với 1 đến 2 ký tự (chữ Hán). Quy tắc ước lượng cho tiếng Trung là **1 token ≈ 0.5 – 0.7 chữ Hán**.

## Tổng kết

Để có kết quả chính xác nhất cho ứng dụng của bạn, hãy luôn sử dụng tokenizer hoặc API đếm token chính thức từ nhà cung cấp mô hình mà bạn đang dùng. Các công thức ước lượng chỉ nên dùng để có một con số hình dung ban đầu, đặc biệt khi làm việc với tiếng Việt và các ngôn ngữ non-Latin.

**Tài liệu tham khảo:**
* [OpenAI Tokenizer](https://platform.openai.com/tokenizer)
* [Anthropic Token Counting](https://docs.anthropic.com/en/docs/build-with-claude/token-counting)
* [tiktoken (GitHub)](https://github.com/openai/tiktoken)
