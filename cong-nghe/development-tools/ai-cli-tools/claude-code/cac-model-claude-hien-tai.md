---
description: "So sánh các model Claude hiện tại: Fable 5.2, Opus 5.5, Sonnet 5.5, Haiku 5.5 — giá, context window, cách chọn theo nhu cầu."
---

# Các model Claude hiện tại

Claude gồm nhiều dòng model khác nhau về độ thông minh, tốc độ và giá. Bài này tổng hợp lineup hiện tại, bảng so sánh và cách chọn model phù hợp.

{% hint style="warning" %}
Giá và danh sách model thay đổi theo thời gian. Bài biên soạn **11/2026** dựa trên tài liệu chính thức. Luôn kiểm tra lại nguồn trước khi tính toán chi phí.
{% endhint %}

## Lineup model mới nhất

| Model | Dùng cho | Độ trễ | Giá input | Giá output |
| ----- | -------- | ------ | --------- | ---------- |
| **Claude Fable 5.2** | Reasoning khó, agentic task dài hơi | Moderate | $8 / MTok | $40 / MTok |
| **Claude Opus 5.5** | Coding agentic chạy dài, knowledge work | Moderate | $4 / MTok | $20 / MTok |
| **Claude Sonnet 5.5** | Cân bằng tốt nhất giữa tốc độ và chất lượng | Fast | $2 / MTok | $10 / MTok |
| **Claude Haiku 5.5** | Phân loại, trích xuất, routing — khối lượng lớn, cần latency thấp | Fastest | Từ $0.10 / MTok | Từ $0.50 / MTok |

Đặc điểm chung của cả 4 model:

* **Context window:** 1M tokens (~555k từ)
* **Max output:** 128K tokens (tiêu chuẩn Messages API)
* **Knowledge cutoff:** Jun 2026
* **Thinking:** Adaptive
* **Input:** text + image; hỗ trợ đa ngôn ngữ, vision, tool use

### Model ID theo platform

| Model | Claude API | Amazon Bedrock | Google Cloud (Google managed) | Microsoft Foundry |
| ----- | ---------- | -------------- | ----------------------------- | ----------------- |
| Fable 5.2 | `claude-fable-5-2` | `global.anthropic.claude-fable-5-2` | `claude-fable-5-2` | `claude-fable-5-2` |
| Opus 5.5 | `claude-opus-5-5` | `anthropic.claude-opus-5-5` | `claude-opus-5-5` | `claude-opus-5-5` |
| Sonnet 5.5 | `claude-sonnet-5-5` | `anthropic.claude-sonnet-5-5` | `claude-sonnet-5-5` | `claude-sonnet-5-5` |
| Haiku 5.5 | `claude-haiku-5-5` | `anthropic.claude-haiku-5-5` | `claude-haiku-5-5` | `claude-haiku-5-5` |

Từ thế hệ 4.6 trở đi, model ID không còn ngày tháng — mỗi ID là một pinned snapshot.

### Default effort

| Model | Effort mặc định |
| ----- | --------------- |
| Fable 5.2 | `high` |
| Opus 5.5 | `medium` |
| Sonnet 5.5 | `high` |
| Haiku 5.5 | `medium` |

### Thời điểm retirement

| Model | Không sớm hơn |
| ----- | ------------- |
| Fable 5.2 | 09/11/2027 |
| Opus 5.5 | 22/09/2027 |
| Sonnet 5.5 | 28/09/2027 |
| Haiku 5.5 | 07/10/2027 |

## Model cũ vẫn còn dùng được

Các model dưới đây vẫn hoạt động nhưng nên chuyển sang lineup mới nếu có thể:

| Model | Context | Max output | Input | Output |
| ----- | ------- | ---------- | ----- | ------ |
| Claude Mythos 5.2 (limited) | 1M | 128K | $8 / MTok | $40 / MTok |
| Claude Fable 5.1 | 1M | 128K | $10 / MTok | $50 / MTok |
| Claude Mythos 5.1 (limited) | 1M | 128K | $10 / MTok | $50 / MTok |
| Claude Fable 5 | 1M | 128K | $10 / MTok | $50 / MTok |
| Claude Mythos 5 (limited) | 1M | 128K | $10 / MTok | $50 / MTok |
| Claude Opus 5 | 1M | 128K | $5 / MTok | $25 / MTok |
| Claude Opus 4.8 | 1M | 128K | $5 / MTok | $25 / MTok |
| Claude Opus 4.7 | 1M | 128K | $5 / MTok | $25 / MTok |
| Claude Opus 4.6 | 1M | 128K | $5 / MTok | $25 / MTok |
| Claude Opus 4.5 | 200K | 64K | $5 / MTok | $25 / MTok |
| Claude Sonnet 5 | 1M | 128K | $2 / MTok | $10 / MTok |
| Claude Sonnet 4.6 | 1M | 128K | $3 / MTok | $15 / MTok |
| Claude Sonnet 4.5 | 200K | 64K | $3 / MTok | $15 / MTok |
| Claude Haiku 4.5 | 200K | 64K | $1 / MTok | $5 / MTok |

{% hint style="info" %}
**Mythos** là dòng limited availability — chỉ mở cho tổ chức đã xác minh qua chương trình của Anthropic (ví dụ Cyber Verification Program).
{% endhint %}

**Đã retire:** Claude Opus 4.1, Opus 4, Sonnet 4 — vẫn có thể chạy trên một số cloud platform nhưng không còn trên Claude API.

## Chọn model nào?

* **Mặc định cho hầu hết workload:** Claude Opus 5.5. Đây là điểm khởi đầu được khuyến nghị.
* **Reasoning khó, task agentic kéo dài, eval trên Opus 5.5 vẫn chưa đủ:** Claude Fable 5.2.
* **Coding hàng ngày, cần phản hồi nhanh, chi phí hợp lý:** Claude Sonnet 5.5.
* **Phân loại, trích xuất, routing, xử lý khối lượng lớn:** Claude Haiku 5.5.

### Bảng quyết định nhanh

| Nhu cầu | Model |
| ------- | ----- |
| Chat, viết, phân tích thông thường | Opus 5.5 |
| Agent chạy nhiều giờ, debug hệ thống phức tạp | Fable 5.2 |
| Code review, refactor, viết test hằng ngày | Sonnet 5.5 |
| Xử lý 10.000 request/phút phân loại email | Haiku 5.5 |
| Cần context cực dài (cả codebase) | Bất kỳ model 1M — ưu tiên Sonnet 5.5 |

## Chi phí: các mức giảm giá

* **Batch API:** giảm 50% so với giá gốc.
* **Prompt cache read:** 10% giá input gốc — riêng Fable 5.2 và Fable 5.1 là 2.5%, Opus 5.5 và Sonnet 5.5 là 5%.
* **Context window:** tính theo bảng giá riêng cho long-context, xem trang Pricing.

{% code title="Ví dụ tính chi phí Opus 5.5" overflow="wrap" %}
```text
Input:  200.000 tokens / 1.000.000 × $4  = $0.80
Output:  20.000 tokens / 1.000.000 × $20 = $0.40
Tổng: $1.20 cho một request lớn
```
{% endcode %}

## Models API

Có thể truy vấn capability và giới hạn token bằng Models API thay vì hard-code:

* `max_input_tokens`, `max_tokens` — giới hạn context và output
* `capabilities` — thinking, server_tools, code_execution
* `line` — dòng model (`opus`, `sonnet`, `haiku`...). Dùng field này để group trong model picker thay vì suy ra từ `id`.

{% code title="Kiểm tra capability thinking của một model" overflow="wrap" %}
```json
{
  "capabilities": {
    "thinking": {
      "types": {
        "disabled": { "supported": false },
        "between_tools": { "supported": true }
      }
    }
  }
}
```
{% endcode %}

Ví dụ trên là hành vi của Claude Sonnet 5.5: không tắt được thinking hoàn toàn, nhưng tắt được thinking trước khi gọi tool.

## Bài liên quan

* [Cấu hình model trong Claude Code](cau-hinh-model-trong-claude-code.md) — alias, effort level, fallback
* [Claude Code cho người mới bắt đầu](claude-code-cho-nguoi-moi-bat-dau.md)
* [Hướng dẫn cấu hình settings.json của Claude Code](cau-hinh-settings-json-claude-code.md)

## Tài liệu tham khảo

* [Models overview](https://platform.claude.com/docs/en/models/overview)
* [Choosing a model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)
* [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
* [Model deprecations](https://platform.claude.com/docs/en/about-claude/model-deprecations)
* [Models API](https://platform.claude.com/docs/en/api/models/list)