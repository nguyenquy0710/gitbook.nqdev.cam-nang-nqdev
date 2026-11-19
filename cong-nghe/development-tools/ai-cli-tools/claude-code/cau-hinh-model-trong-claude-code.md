---
description: "Cấu hình model trong Claude Code: alias, thứ tự ưu tiên, opusplan, fallback, effort level, extended context và giới hạn model cho team."
---

# Cấu hình model trong Claude Code

Claude Code không cố định một model. Bạn chọn model theo task, theo mức chi phí và theo môi trường làm việc — bằng alias, biến môi trường hoặc settings. Bài này đi qua toàn bộ cơ chế đó.

{% hint style="info" %}
Danh sách model và giá xem ở [Các model Claude hiện tại](cac-model-claude-hien-tai.md). Bài này chỉ nói cách cấu hình.
{% endhint %}

## Chọn model bằng alias

Alias che giấu số phiên bản — dùng được ở `/model`, `--model`, biến môi trường và settings.

| Alias | Hành vi |
| ----- | ------- |
| `default` | Xoá mọi override, quay về model mặc định của tài khoản. Không phải alias thật |
| `best` | Dùng cùng model với `opus` |
| `fable` | Model Fable cho task khó nhất, chạy dài nhất |
| `sonnet` | Sonnet mới nhất — coding hàng ngày |
| `opus` | Opus mới nhất — reasoning phức tạp |
| `haiku` | Haiku — task đơn giản, nhanh |
| `sonnet[1m]` | Sonnet với context 1M |
| `opus[1m]` | Opus với context 1M |
| `opusplan` | Opus khi plan mode, tự chuyển Sonnet khi thực thi |

`sonnet[1m]` và `opus[1m]` không có tác dụng khi alias đã trỏ tới model có native 1M window (Sonnet 5.5, Opus 4.7+).

### Alias resolve khác nhau theo provider

| Provider | `opus` | `sonnet` | `haiku` |
| -------- | ------ | -------- | ------- |
| Anthropic API | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| Claude Platform on AWS | Opus 5.5 | Sonnet 4.6 | Haiku 4.5 |
| Google Cloud (Anthropic managed) | Opus 5.5 | Sonnet 5.5 | Haiku 4.5 |
| Amazon Bedrock, Google Cloud Agent Platform | Opus 5.5 | Sonnet 4.5 | Haiku 4.5 |
| Microsoft Foundry | Opus 4.6 | Sonnet 4.5 | Haiku 4.5 |

Alias trỏ tới phiên bản khuyến nghị của provider và thay đổi theo thời gian. Muốn pin phiên bản cụ thể, dùng model ID đầy đủ (`claude-opus-5-5`) hoặc set `ANTHROPIC_DEFAULT_OPUS_MODEL`.

{% hint style="warning" %}
`default` phụ thuộc loại tài khoản: hầu hết trả về Opus 5.5; riêng Microsoft Foundry trả về Sonnet 4.5. Kiểm tra bằng `/status` nếu cần chắc chắn.
{% endhint %}

## Cách set model

Năm cách, xếp theo thứ tự ưu tiên giảm dần:

1. **Trong session:** `/model <alias|name>` để đổi ngay, hoặc `/model` mở picker
2. **Lúc khởi động:** `claude --model <alias|name>`
3. **Biến môi trường:** `ANTHROPIC_MODEL=<alias|name>`
4. **Settings file:** key `model`
5. **Mặc định cho session mới:** `ANTHROPIC_DEFAULT_MODEL=<alias|name>`

### `/model`: lưu default hay chỉ session hiện tại?

| Thao tác | Hiệu lực |
| -------- | -------- |
| `/model sonnet` hoặc `Enter` trong picker | Đổi model **và** lưu làm default cho session sau |
| `s` trong picker | Đổi cho **session hiện tại** thôi, default giữ nguyên |

`/model` lưu lựa chọn vào `~/.claude/settings.json`. Nếu file đó không ghi được (bị tool khác sinh ra, hoặc link read-only), lựa chọn chỉ sống trong session.

{% code title="Ví dụ settings.json" overflow="wrap" %}
```json
{
  "model": "opus",
  "permissions": {
    "allow": ["Bash(npm run lint)"]
  }
}
```
{% endcode %}

### Vì sao session mới lại chạy model khác?

* Bạn chọn `s` hoặc dùng `--model` → chỉ áp dụng session đó
* Project/managed settings, `ANTHROPIC_MODEL`, hoặc organization default có độ ưu tiên cao hơn
* File settings không ghi được
* Bạn resume session cũ — session giữ model lúc lưu transcript

### Sửa tên model gõ sai

Khi tên gần giống một model/alias có thật, Claude Code gợi ý:

{% code title="Cảnh báo" overflow="wrap" %}
```text
⚠ Model "opus-5.5" isn't recognized · did you mean "claude-opus-5-5"?
```
{% endcode %}

Nếu ID là cố ý (gateway riêng), để nguyên — nhưng phải khai báo context window cho Claude Code biết, xem phần [Gateway và model ID tuỳ chỉnh](#gateway-va-model-id-tuy-chinh).

## `opusplan` — lai Opus và Sonnet

Chế độ hybrid tự động:

* **Plan mode:** dùng `opus` cho reasoning và quyết định kiến trúc
* **Execution mode:** tự chuyển `sonnet` để sinh code

{% code title="terminal" overflow="wrap" %}
```bash
claude --model opusplan
```
{% endcode %}

Muốn cả hai pha đều 1M context khi model không native 1M: `/model opusplan[1m]`.

## Fallback model

Khi model chính quá tải, không available, hoặc trả server error không retry được, Claude Code chuyển sang model dự phòng thay vì fail request.

{% code title="terminal" overflow="wrap" %}
```bash
claude --fallback-model sonnet,haiku
```
{% endcode %}

* Chain tối đa **3 model** sau khi loại trùng, phần dư bị bỏ qua
* Fallback chỉ có hiệu lực **cho turn hiện tại** — tin nhắn tiếp theo thử model chính trước
* Lỗi authentication, billing, rate-limit, request-size, transport **không** trigger fallback

### Automatic model fallback

Riêng dòng Fable có cơ chế fallback tự động khi safety classifier gắn cờ request — thường ở domain cybersecurity và biology. Request bị gắn cờ sẽ chuyển sang model khác thay vì bị refuse.

Muốn biết cái gì đã trigger fallback, xem log ở chế độ debug.

## Effort level

Adaptive reasoning để model tự quyết định mức độ suy nghĩ ở mỗi bước. Effort level là tay lái cho việc đó.

### Mức hỗ trợ theo model

| Model | Levels |
| ----- | ------ |
| Fable / Opus 5.5 / Sonnet 5.5 / Haiku 5.5 / Opus 5 / Sonnet 5 / Opus 4.8 / Opus 4.7 | `low`, `medium`, `high`, `xhigh`, `max` |
| Opus 4.6 / Sonnet 4.6 | `low`, `medium`, `high`, `max` |

Set mức model không hỗ trợ → Claude Code tự hạ xuống mức cao nhất ≤ mức bạn chọn. Ví dụ `xhigh` chạy thành `high` trên Opus 4.6.

### Thứ tự resolve effort

1. `CLAUDE_CODE_EFFORT_LEVEL`
2. Mức chọn trong session (`/effort`, `/model` picker)
3. `--effort` lúc khởi động
4. Settings (`modelSettings` per-model hoặc `effortLevel`)
5. Default của model

Default effort theo model xem ở [bài lineup model](cac-model-claude-hien-tai.md#default-effort).

### Chọn nhanh trong session

{% code title="Claude Code prompt" overflow="wrap" %}
```text
/effort high
/effort status
/effort ultracode
```
{% endcode %}

`Enter` trong slider `/effort` → lưu làm default. `s` → chỉ session hiện tại. Mức `max` chỉ áp dụng session hiện tại trừ khi set qua biến môi trường.

### Ultrathink và ultracode

* **Ultrathink:** từ khoá trong prompt để xin reasoning sâu cho một câu hỏi cụ thể — không đổi effort của cả session
* **Ultracode:** toggle trong slider `/effort`. Khi bật, Claude tự orchestrate dynamic workflows cho task lớn, ở effort level hiện tại. Yêu cầu model hỗ trợ `xhigh`

{% code title="terminal" overflow="wrap" %}
```bash
claude --effort ultracode   # bật ultracode + effort xhigh
```
{% endcode %}

### Effort của subagent

Subagent chạy trên model của main conversation sẽ dùng effort của session. Subagent chạy model khác thì không — phải set `effort` riêng trong định nghĩa subagent.

### Không gửi effort level

Muốn để API tự quyết, không gửi level từ Claude Code:

{% code title="terminal" overflow="wrap" %}
```bash
export CLAUDE_CODE_EFFORT_LEVEL=auto   # hoặc 'unset'
```
{% endcode %}

Kiểm tra bằng `/effort status`: `auto` = không gửi, `auto (currently high)` = vẫn gửi level.

## Extended thinking

| Điều khiển | Cách set |
| ---------- | -------- |
| Toggle session hiện tại | `Option+T` (macOS) / `Alt+T` (Windows, Linux) |
| Default toàn cục | `/config` → thinking mode, lưu thành `alwaysThinkingEnabled` |
| Tắt qua env | `MAX_THINKING_TOKENS=0` |

Thinking output mặc định bị thu gọn. `Ctrl+O` để xem dạng verbose.

{% hint style="danger" %}
Không tắt được thinking trên Opus 5.5, Sonnet 5.5, Haiku 5.5 và dòng Fable — toggle hiển thị "Thinking can't be turned off". Trên các model này, cách duy nhất để giảm suy nghĩ là **hạ effort level**. Bạn vẫn bị tính tiền cho toàn bộ thinking token, kể cả khi bị thu gọn hoặc redacted.
{% endhint %}

## Extended context (1M)

Các model sau chạy 1M window mặc định, không cần suffix `[1m]`:

* Dòng Fable
* Sonnet 5 trở lên
* Haiku 5.5
* Opus 4.7 trở lên

Opus 4.6 và Sonnet 4.6 chỉ đạt 1M qua variant `[1m]`, và quyền truy cập phụ thuộc plan.

Muốn ép về 200K:

{% code title="terminal" overflow="wrap" %}
```bash
export CLAUDE_CODE_DISABLE_1M_CONTEXT=1
```
{% endcode %}

Lệnh này cũng bỏ các variant `[1m]` khỏi picker và coi model native-1M như model 200K.

## Context window và auto-compaction

Auto-compact window = ngưỡng context đầy bao nhiêu thì nén hội thoại.

### Cách set

| Phạm vi | Cách |
| ------- | ---- |
| Một model, session này và sau | `/autocompact 500k` |
| Mọi model | `"autoCompactWindow": 200000` trong settings |
| Một lần chạy | `claude --autocompact 500k` |
| Script / cloud | `CLAUDE_CODE_AUTO_COMPACT_WINDOW=200000` |
| Một subagent | set trong định nghĩa subagent |

Cú pháp chấp nhận: `200000`, `500k`, `1M`, hoặc số trần 100–1000 (hiểu là nghìn — `200` = 200.000).

{% hint style="warning" %}
`/autocompact 200` = 200.000 token. Nhưng `CLAUDE_CODE_AUTO_COMPACT_WINDOW=200` = **200 token**. Khác ngữ nghĩa giữa hai chỗ — dễ sai.
{% endhint %}

### Ngưỡng mặc định

Không set gì → compact khi chạm context limit của model. Ngoại lệ:

* Cloud session: compact khi tiến gần limit
* Sonnet 4.6 / Opus 4.6 không extended context: compact ở 200K
* `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`: model native 1M cũng compact ở 200K
* Model native 1M: compact sớm, khoảng **967K token**

## Giới hạn model cho team và enterprise

Admin dùng `availableModels` trong managed settings để chặn bớt lựa chọn.

{% code title="managed settings" overflow="wrap" %}
```json
{
  "availableModels": ["sonnet", "haiku"],
  "enforceAvailableModels": true,
  "deniedModels": ["claude-opus-5-5"]
}
```
{% endcode %}

* **`availableModels`:** mỗi entry có thể là family (`sonnet`), version prefix (`claude-sonnet-4-5`), hoặc model ID đầy đủ
* **`enforceAvailableModels: true`:** áp allowlist lên cả option **Default** — thiếu key này, Default vẫn resolve ra model ngoài list
* **`deniedModels`:** chặn cụ thể, kể cả khi `availableModels` cho phép
* **`availableModelsMatch: "exact"`:** mỗi ID chỉ cho đúng phiên bản nêu tên, phiên bản mới hơn vẫn bị chặn

Cả hai key `deniedModels` và `availableModelsMatch` **chỉ đọc từ managed settings** — đặt ở user/project settings sẽ bị bỏ qua kèm warning.

{% hint style="info" %}
`availableModels: []` chặn toàn bộ lựa chọn có tên, và `enforceAvailableModels` mất tác dụng.
{% endhint %}

### Kiểm soát đầy đủ

Kết hợp nhiều lớp để khép kín:

| Key | Vai trò |
| --- | ------- |
| `availableModels` | Giới hạn model được chọn |
| `enforceAvailableModels` | Áp allowlist lên Default |
| `deniedModels` / `availableModelsMatch` | Chặn phiên bản cụ thể |
| `model` | Model khởi động |
| `ANTHROPIC_DEFAULT_*_MODEL` | Pin alias trỏ tới phiên bản nào |

`model` chỉ là lựa chọn ban đầu, **không phải enforcement** — user vẫn mở `/model` chọn Default được.

## Gateway và model ID tuỳ chỉnh

`ANTHROPIC_BASE_URL` đổi nơi gửi request, **không** đổi model trả lời.

Thêm một entry tuỳ chỉnh vào picker:

{% code title="terminal" overflow="wrap" %}
```bash
export ANTHROPIC_CUSTOM_MODEL_OPTION="my-gateway/claude-opus-5-5"
export ANTHROPIC_CUSTOM_MODEL_OPTION_NAME="Opus via Gateway"
export ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION="Deployment qua LLM gateway nội bộ"
```
{% endcode %}

Nếu Claude Code không nhận ra ID, nó cảnh báo và giả định context window:

{% code title="Cảnh báo" overflow="wrap" %}
```text
⚠ Model "my-gateway-opus" isn't recognized · context assumed to be 1m tokens
```
{% endcode %}

Sửa bằng `CLAUDE_CODE_MAX_CONTEXT_TOKENS` để khai báo đúng window.

## Kiểm tra model đang dùng

* Status line (nếu đã cấu hình)
* `/status` — hiển thị cả thông tin tài khoản

## Bài liên quan

* [Các model Claude hiện tại](cac-model-claude-hien-tai.md)
* [Hướng dẫn cấu hình settings.json của Claude Code](cau-hinh-settings-json-claude-code.md)
* [Tổng quan cấu hình Settings trong Claude Code](tong-quan-cau-hinh-settings-trong-claude-code.md)
* [Claude Code Cheatsheet (2026)](claude-code-cheatsheet-2026.md)
* [Quy tắc Permission và Bảo mật trong Claude Code](quy-tac-permission-va-bao-mat-claude-code.md)

## Tài liệu tham khảo

* [Model configuration](https://code.claude.com/docs/en/model-config)
* [Choosing a Claude model and effort level in Claude Code](https://claude.com/blog/claude-model-and-effort-level-in-claude-code)
* [Effort](https://platform.claude.com/docs/en/build-with-claude/effort)
* [Context windows](https://platform.claude.com/docs/en/build-with-claude/context-windows)