# Mẫu bảng model dạng Tab

Dùng khi cần hiển thị danh sách sản phẩm/dịch vụ/model chia theo danh mục.

## Cấu trúc

```
{% tabs %}
{% tab title="Danh mục 1" %}
| Cột 1 | Cột 2 | Cột 3 |
|---|---|---|
| Giá trị 1 | Giá trị 2 | Giá trị 3 |
{% endtab %}
{% tab title="Danh mục 2" %}
| Cột 1 | Cột 2 | Cột 3 |
|---|---|---|
| Giá trị 1 | Giá trị 2 | Giá trị 3 |
{% endtab %}
{% endtabs %}
```

## Ví dụ thực tế

```markdown
{% tabs %}
{% tab title="Kira Models 🇻🇳" %}
| Model | Loại | Giá đầu vào | Giá đầu ra | Trạng thái |
|---|---|---|---|---|
| **Kira 3.5 Pro** | chat | 20.000đ / 1M tkn | 150.000đ / 1M tkn | ✅ Hoạt động |
| **Kira Mini 1.0** | chat | 🆓 Miễn phí | 🆓 Miễn phí | ✅ Hoạt động |
{% endtab %}
{% tab title="Partner Models 🌍" %}
| Model | Loại | Giá đầu vào | Giá đầu ra | Trạng thái |
|---|---|---|---|---|
| **Claude Opus 4.8** | chat | 120.000đ / 1M tkn | 620.000đ / 1M tkn | ✅ Hoạt động |
| **DeepSeek V4 Pro** | chat | 11.000đ / 1M tkn | 22.000đ / 1M tkn | ✅ Hoạt động |
{% endtab %}
{% endtabs %}
```

## Quy tắc

1. Mỗi `{% tab %}` là một danh mục riêng
2. Bên trong mỗi tab là một bảng Markdown chuẩn
3. Dùng `**tên**` để làm nổi bật tên model/sản phẩm
4. Icon trạng thái: ✅ Hoạt động, 🔧 Bảo trì, 🆓 Miễn phí
5. Luôn đóng tab bằng `{% endtab %}` và `{% endtabs %}`
