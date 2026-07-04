---
description: >-
  Hướng dẫn cấu hình GitBook Integration thông qua file gitbook-manifest.yaml —
  dành cho lập trình viên phát triển tích hợp GitBook, không phải viết tài liệu
  thông thường.
---

# Cấu hình GitBook Integration (gitbook-manifest.yaml)

> ⚠️ **Lưu ý:** Hướng dẫn này dành riêng cho lập trình viên đang phát triển **GitBook Integrations** (các ứng dụng tích hợp) và được cấu hình thông qua file `gitbook-manifest.yaml`, **không áp dụng** cho việc viết tài liệu thông thường.

## 1. Configurations

Khoá `configurations` cho phép định nghĩa các bước và thiết lập cụ thể cho integration thông qua môi trường (environment) của nó.

Hai cấp độ cấu hình:

| Cấp độ | Khoá | Phạm vi |
|--------|------|---------|
| Tài khoản | `configurations.account` | Áp dụng cho toàn bộ tài khoản |
| Site/Space | `configurations.site` | Áp dụng riêng cho từng không gian (space) |

### 1.1 Property types

Mỗi cấu hình chấp nhận các properties (trường thông tin) để mô tả bước người dùng trải qua khi cài đặt integration. Các kiểu dữ liệu hỗ trợ:

| Kiểu | Mô tả |
|------|-------|
| `string` | Nhập liệu từ người dùng. Có thể kết hợp `enum` (danh sách cố định) hoặc `completion_url` (lấy danh sách động từ API) để biến thành dropdown list |
| `number` | Giá trị số |
| `boolean` | Bật/Tắt (true/false) |
| `button` | Kết nối OAuth với nhà cung cấp bên thứ ba (thường kết hợp `createOAuthHandler()`) |

### 1.2 Required fields

Liệt kê tên các properties vào khoá `required` để bắt buộc người dùng phải điền hoặc thực hiện khi cài đặt.

### 1.3 Ví dụ mẫu

{% code title="gitbook-manifest.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
configurations:
  account:
    properties:
      oauth_credentials:
        type: button
        title: Kết nối
        description: Ủy quyền giữa ứng dụng của tôi và GitBook.
        button_text: Ủy quyền
        callback_url: /oauth
      default_channel:
        type: string
        title: Kênh mặc định
        description: Chọn kênh để gửi tin nhắn khi không có kênh nào được cấu hình riêng cho space.
        completion_url: /channels
    required:
      - oauth_credentials
      - default_channel

  site:
    properties:
      channel:
        type: string
        title: Kênh
        description: Chọn kênh để gửi tin nhắn liên quan đến space này.
        completion_url: /channels
      notify_content_update:
        type: boolean
        title: Thông báo cập nhật nội dung
        description: Gửi tin nhắn thông báo mỗi khi nội dung của space được cập nhật.
        default: true
```
{% endcode %}

## 2. Secrets (Biến môi trường & Mã bí mật)

Khai báo mã bí mật hoặc biến môi trường mà integration cần để hoạt động.

> Theo mặc định, biến môi trường không được nạp trực tiếp vào GitBook Manifest.

**Best practice:** Dùng package như `dotenv-cli` để đưa biến từ file `.env` vào cấu hình khi sử dụng CLI.

{% code title="gitbook-manifest.yaml" overflow="wrap" lineNumbers="true" %}
```yaml
secrets:
  CLIENT_ID: ${{ env.CLIENT_ID }}
```
{% endcode %}

## 3. Installation & Configuration flow

Khi người dùng cài đặt integration:

1. **Sự kiện kích hoạt:** `installation_setup` được kích hoạt ngay khi integration được cài lần đầu, và được kích hoạt lại mỗi khi người dùng chỉnh sửa thuộc tính cấu hình.
2. **Kiểm tra trạng thái:** `environment.installation.status != 'active'` → cấu hình chưa hoàn tất.
3. **Hoàn tất:** Trạng thái chuyển sang `active` khi cấu hình vượt qua validate theo schema đã định nghĩa.

### 3.1 Cấu trúc thư mục .gitbook/

{% code title="Directory structure" overflow="wrap" %}
```
.gitbook/
  assets/          # Ảnh và file tải lên qua giao diện GitBook
  includes/        # Reusable content blocks (file .md riêng lẻ)
  vars.yaml        # Biến cấp không gian (space-level variables) dạng key-value
```
{% endcode %}

File `tags.yaml` (nếu có) là tính năng bổ sung cho page tags trong phiên bản Git Sync mới hơn.

## Tài liệu tham khảo

* [GitBook Integrations Documentation](https://developer.gitbook.com/)
