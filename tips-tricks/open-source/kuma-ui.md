---
description: >-
  🐻‍❄️ Thư viện thành phần giao diện người dùng không đầu, ưu tiên tiện ích và
  không thời gian chạy ✨. Nguồn: kuma-ui.com
cover: >-
  https://repository-images.githubusercontent.com/621481721/33116785-e75f-434d-8335-e495413792b3
coverY: 0
---

# Kuma UI

{% embed url="https://www.kuma-ui.com/docs" %}
Kuma UI
{% endembed %}

## Cài đặt

### Cài đặt gói

Để cài đặt Kuma UI trong dự án của bạn, hãy chạy một trong các lệnh sau trong terminal của bạn:



{% tabs %}
{% tab title="npm" %}
```bash
npm install @kuma-ui/core
```
{% endtab %}

{% tab title="pnpm" %}
```bash
pnpm install @kuma-ui/core
```
{% endtab %}

{% tab title="yarn" %}
```bash
yarn add @kuma-ui/core
```
{% endtab %}
{% endtabs %}

Sau khi cài đặt thành công gói `@kuma-ui/core`, bạn có thể tiến hành cài đặt plugin cho khung cụ thể của mình (Next.js hoặc Vite) như bên dưới.



{% tabs %}
{% tab title="Next.js" %}

{% endtab %}

{% tab title="Vite" %}

{% endtab %}

{% tab title="Webpack" %}

{% endtab %}
{% endtabs %}

### Thiết lập giao diện người dùng Kuma

Sau khi cài đặt plugin, bạn cần định cấu hình plugin trong tệp cấu hình của mình.

{% tabs %}
{% tab title="Next.js" %}

{% endtab %}

{% tab title="Vite" %}

{% endtab %}

{% tab title="Webpack" %}

{% endtab %}
{% endtabs %}

### Kết xuất phía máy chủ

Nếu bạn đang sử dụng Kuma UI với Next.js thì việc thiết lập Kết xuất phía máy chủ (SSR) là không bắt buộc. Tuy nhiên, nếu không có thiết lập này, bạn có thể gặp phải Flash Of Unstyled Content (FOUC). Chúng tôi thực sự khuyên bạn nên thiết lập SSR để ngăn điều này xảy ra.
