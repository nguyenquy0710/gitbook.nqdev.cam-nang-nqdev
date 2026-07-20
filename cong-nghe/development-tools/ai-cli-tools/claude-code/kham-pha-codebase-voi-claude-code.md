---
description: >-
  Các workflow khám phá codebase với Claude Code: overview, tìm code, hỏi
  như senior engineer, dùng subagents và plan mode để hiểu hệ thống nhanh.
---

# Khám phá và hiểu codebase với Claude Code

Khi vào dự án mới hoặc cần hiểu một phần hệ thống, Claude Code giúp bạn explore codebase nhanh hơn đáng kể so với đọc thủ công. Bài này cover các workflow thực chiến từ broad overview đến deep dive.

## Tại sao dùng Claude Code để explore?

* **Nhanh:** Claude đọc và tóm tắt hàng trăm files trong vài giây
* **Context-aware:** Hiểu mối quan hệ giữa các files, modules
* **Interactive:** Bạn drill down vào bất kỳ phần nào bằng ngôn ngữ tự nhiên
* **Không mất context:** Dùng subagents để explore mà không làm sạch main conversation

## Lấy overview nhanh

### Bắt đầu broad

Sau khi cd vào project và chạy `claude`, hỏi broad questions trước:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
give me an overview of this codebase
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
explain the main architecture patterns used here
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what are the key data models?
```
{% endcode %}

### Drill down vào chi tiết

Sau khi có overview, hỏi sâu hơn:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
how is authentication handled?
what database does this project use and how is it configured?
what's the deployment pipeline?
```
{% endcode %}

{% hint style="info" %}
Bắt đầu broad rồi narrow down. Hỏi về coding conventions và patterns trước khi hỏi về implementation chi tiết.
{% endhint %}

## Tìm code liên quan

### Locate feature code

{% code title="Claude Code prompt" overflow="wrap" %}
```text
find the files that handle user authentication
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
where is the payment processing logic?
```
{% endcode %}

### Hiểu mối quan hệ giữa files

{% code title="Claude Code prompt" overflow="wrap" %}
```text
how do these authentication files work together?
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
trace the login process from front-end to database
```
{% endcode %}

Claude sẽ đọc các files liên quan và giải thích flow từ request đến response.

### Dùng @ để reference trực tiếp

{% code title="Claude Code prompt" overflow="wrap" %}
```text
Explain the logic in @src/utils/auth.js
What's the structure of @src/components?
```
{% endcode %}

`@path/to/file` include toàn bộ nội dung vào conversation. `@path/to/dir` hiển thị directory listing.

## Hỏi như senior engineer

Claude Code rất mạnh cho onboarding — bạn có thể hỏi như đang hỏi một senior engineer cùng team:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
how does logging work in this project?
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
how do I make a new API endpoint?
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what does `async move { ... }` do on line 134 of foo.rs?
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
what edge cases does CustomerOnboardingFlowImpl handle?
```
{% endcode %}

{% code title="Claude Code prompt" overflow="wrap" %}
```text
why does this code call foo() instead of bar() on line 333?
```
{% endcode %}

{% hint style="info" %}
Đây là workflow onboarding hiệu quả — giảm thời gian ramp-up và giảm load cho các engineer khác trong team.
{% endhint %}

## Dùng subagents để investigate

Khi explore codebase lớn, mỗi file Claude đọc đều consuming context. Subagents chạy trong context riêng — chỉ report summary findings:

{% code title="Claude Code prompt" overflow="wrap" %}
```text
use subagents to investigate how our auth system handles
token refresh, and whether we have any existing OAuth
utilities I should reuse.
```
{% endcode %}

Subagent sẽ:
1. Đọc files trong context riêng
2. Phân tích auth flow
3. Report findings tóm tắt

Main conversation giữ sạch — chỉ nhận findings, không bị pollution từ file reads.

{% code title="Claude Code prompt" overflow="wrap" %}
```text
use a subagent to review this code for edge cases
```
{% endcode %}

## Plan mode: explore → plan → implement

Để tránh solving wrong problem, dùng plan mode để tách research và planning khỏi implementation.

### Phase 1: Explore

{% code title="Claude Code (plan mode)" overflow="wrap" %}
```text
read /src/auth and understand how we handle sessions and login.
also look at how we manage environment variables for secrets.
```
{% endcode %}

### Phase 2: Plan

{% code title="Claude Code (plan mode)" overflow="wrap" %}
```text
I want to add Google OAuth. What files need to change?
What's the session flow? Create a plan.
```
{% endcode %}

Nhấn `Ctrl+G` để mở plan trong text editor và edit trực tiếp trước khi Claude proceed.

### Phase 3: Implement

Chuyển sang default mode và implement:

{% code title="Claude Code (default mode)" overflow="wrap" %}
```text
implement the OAuth flow from your plan. write tests for the
callback handler, run the test suite and fix any failures.
```
{% endcode %}

### Phase 4: Commit

{% code title="Claude Code (default mode)" overflow="wrap" %}
```text
commit with a descriptive message and open a PR
```
{% endcode %}

{% hint style="warning" %}
Plan mode hữu ích nhưng cũng thêm overhead. Với task scope rõ ràng và fix nhỏ (sửa typo, thêm log line, rename variable), bỏ qua plan và làm thẳng.
{% endhint %}

## Khi nào nên explore, khi nào code thẳng?

| Tình huống | Nên |
| ---------- | --- |
| Vào dự án mới lần đầu | Explore broad → narrow |
| Không chắc approach | Plan mode |
| Fix bug rõ ràng | Code thẳng |
| Task lớn, multi-file | Plan → implement → verify |
| Muốn hiểu flow trước khi sửa | Explore với subagent |
| Task nhỏ, scope rõ | Code thẳng |

## Tài liệu tham khảo

* [Common Workflows](https://code.claude.com/docs/en/common-workflows)
* [Best Practices](https://code.claude.com/docs/en/best-practices)
* [Subagents](https://code.claude.com/docs/en/sub-agents)
* [Plan Mode](https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode)
