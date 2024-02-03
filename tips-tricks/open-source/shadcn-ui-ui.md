---
description: >-
  Các thành phần được thiết kế đẹp mắt mà bạn có thể sao chép và dán vào ứng
  dụng của mình. Có thể truy cập. Có thể tùy chỉnh. Mã nguồn mở. Nguồn:
  ui.shadcn.com
cover: https://ui.shadcn.com/og.jpg
coverY: 53.19576719576719
layout:
  cover:
    visible: true
    size: hero
  title:
    visible: true
  description:
    visible: true
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# shadcn-ui/ui

## Giới thiệu

Các thành phần được thiết kế đẹp mắt mà bạn có thể sao chép và dán vào ứng dụng của mình. Có thể truy cập. Có thể tùy chỉnh. Mã nguồn mở.

Đây **KHÔNG** phải là thư viện thành phần. Đó là tập hợp các thành phần có thể sử dụng lại mà bạn có thể sao chép và dán vào ứng dụng của mình.

### **Ý bạn là gì khi không phải là thư viện thành phần?**

Ý tôi là bạn không cài đặt nó như một phần phụ thuộc. Nó không có sẵn hoặc được phân phối qua npm.

Chọn các thành phần bạn cần. Sao chép và dán mã vào dự án của bạn và tùy chỉnh theo nhu cầu của bạn. Mã này là của bạn.

_Hãy sử dụng thông tin này làm tài liệu tham khảo để xây dựng thư viện thành phần của riêng bạn._

## Cài đặt

Cách cài đặt các phần phụ thuộc và cấu trúc ứng dụng của bạn.

{% @github-files/github-code-block url="https://github.com/nqdev-fork/shadcn-ui-ui" %}

### Frameworks <a href="#frameworks" id="frameworks"></a>

* Next.js - [Tham khảo](https://ui.shadcn.com/docs/installation/next)

### TypeScript <a href="#typescript" id="typescript"></a>

Dự án này và các thành phần được viết bằng TypeScript. Chúng tôi cũng khuyên bạn nên sử dụng TypeScript cho dự án của mình.

Tuy nhiên, chúng tôi cũng cung cấp phiên bản JavaScript của các thành phần. Phiên bản JavaScript có sẵn thông qua [cli](https://ui.shadcn.com/docs/cli).

Để từ chối TypeScript, bạn có thể sử dụng cờ `tsx` trong tệp `components.json` của mình.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "style": "default",
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/app/globals.css",
    "baseColor": "zinc",
    "cssVariables": true
  },
  "rsc": false,
  "tsx": false,
  "aliases": {
    "utils": "~/lib/utils",
    "components": "~/components"
  }
}
```
{% endcode %}

Để định cấu hình bí danh nhập, bạn có thể sử dụng `jsconfig.json` sau:

{% code title="jsconfig.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```
{% endcode %}

## components.json

Tệp `components.json` chứa cấu hình cho dự án của bạn.

Chúng tôi sử dụng nó để hiểu cách thiết lập dự án của bạn và cách tạo các thành phần được tùy chỉnh cho dự án của bạn.

Bạn có thể tạo tệp `components.json` trong dự án của mình bằng cách chạy lệnh sau:

```bash
npx shadcn-ui@latest init
```

Xem [phần CLI](https://ui.shadcn.com/docs/cli) để biết thêm thông tin.

### $schema <a href="#schema" id="schema"></a>

Bạn có thể xem Lược đồ JSON cho `components.json` tại đây.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://ui.shadcn.com/schema.json"
}
```
{% endcode %}

### style <a href="#style" id="style"></a>

Phong cách cho các thành phần của bạn. Điều này không thể thay đổi sau khi khởi tạo.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "style": "default" | "new-york"
}
```
{% endcode %}

### tailwind <a href="#tailwind" id="tailwind"></a>

Cấu hình để giúp CLI hiểu cách thiết lập Tailwind CSS trong dự án của bạn.

Xem [phần cài đặt](https://ui.shadcn.com/docs/installation) để biết cách thiết lập CSS Tailwind.

#### tailwind.config <a href="#tailwindconfig" id="tailwindconfig"></a>

Đường dẫn đến nơi chứa tệp `tailwind.config.js` của bạn.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tailwind": {
    "config": "tailwind.config.js" | "tailwind.config.ts"
  }
}
```
{% endcode %}

### rsc <a href="#rsc" id="rsc"></a>

Có bật hỗ trợ cho các Thành phần máy chủ React hay không.

### tsx <a href="#tsx" id="tsx"></a>

Chọn giữa các thành phần TypeScript hoặc JavaScript.

### aliases <a href="#aliases" id="aliases"></a>

CLI sử dụng các giá trị này và cấu hình đường dẫn từ tệp `tsconfig.json` hoặc `jsconfig.json` của bạn để đặt các thành phần được tạo vào đúng vị trí.

#### aliases.utils <a href="#aliasesutils" id="aliasesutils"></a>

Nhập bí danh cho các chức năng tiện ích của bạn.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "aliases": {
    "utils": "@/lib/utils"
  }
}
```
{% endcode %}

#### aliases.components <a href="#aliasescomponents" id="aliasescomponents"></a>

Nhập bí danh cho các thành phần của bạn.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "aliases": {
    "components": "@/components"
  }
}
```
{% endcode %}

#### aliases.ui <a href="#aliasesui" id="aliasesui"></a>

Nhập bí danh cho các thành phần `ui`.

CLI sẽ sử dụng giá trị `aliases.ui` để xác định vị trí đặt các thành phần `ui` của bạn. Sử dụng cấu hình này nếu bạn muốn tùy chỉnh thư mục cài đặt cho các thành phần `ui` của mình.

{% code title="components.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "aliases": {
    "ui": "@/app/ui"
  }
}
```
{% endcode %}
