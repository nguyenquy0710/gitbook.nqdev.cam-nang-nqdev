---
description: >-
  🐻‍❄️ Thư viện thành phần giao diện người dùng không đầu, ưu tiên tiện ích và
  không thời gian chạy ✨. Nguồn: kuma-ui.com
---

# Kuma UI

{% embed url="https://www.kuma-ui.com/docs" %}

### Cài đặt <a href="#cai-dat" id="cai-dat"></a>

#### Cài đặt gói <a href="#cai-dat-goi" id="cai-dat-goi"></a>

Để cài đặt Kuma UI trong dự án của bạn, hãy chạy một trong các lệnh sau trong terminal của bạn:​npmpnpmyarnnpm install @kuma-ui/coreSau khi cài đặt thành công gói `@kuma-ui/core`, bạn có thể tiến hành cài đặt plugin cho khung cụ thể của mình (Next.js hoặc Vite) như bên dưới.​Next.jsViteWebpack​

#### Thiết lập giao diện người dùng Kuma <a href="#thiet-lap-giao-dien-nguoi-dung-kuma" id="thiet-lap-giao-dien-nguoi-dung-kuma"></a>

Sau khi cài đặt plugin, bạn cần định cấu hình plugin trong tệp cấu hình của mình.Next.jsViteWebpack​

#### Kết xuất phía máy chủ <a href="#ket-xuat-phia-may-chu" id="ket-xuat-phia-may-chu"></a>

Nếu bạn đang sử dụng Kuma UI với Next.js thì việc thiết lập Kết xuất phía máy chủ (SSR) là không bắt buộc. Tuy nhiên, nếu không có thiết lập này, bạn có thể gặp phải Flash Of Unstyled Content (FOUC). Chúng tôi thực sự khuyên bạn nên thiết lập SSR để ngăn điều này xảy ra.
