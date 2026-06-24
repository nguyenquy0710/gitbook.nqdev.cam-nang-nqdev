---
description: >-
  Các thành phần được thiết kế đẹp mắt mà bạn có thể sao chép và dán vào ứng
  dụng của mình. Có thể truy cập. Có thể tùy chỉnh. Mã nguồn mở. Nguồn:
  ui.shadcn.com
---

# shadcn-ui/ui

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
