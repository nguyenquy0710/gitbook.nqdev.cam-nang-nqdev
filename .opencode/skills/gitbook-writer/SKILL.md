---
name: gitbook-writer
description: Use when creating GitBook content with structured data tables, especially multi-tab model/service/plan comparison tables using {% tabs %} syntax. Trigger on keywords like "bảng model", "so sánh dịch vụ", "bảng giá", "model table", "pricing table", "tabs", "{% tabs %}", or when asked to format API/service model listings in GitBook tabs. Works alongside viet-bai-gitbook for the structural table parts of GitBook articles.
---

# Skill: GitBook Writer — Model Tables & Structured Data

Tạo bảng dữ liệu dạng tab (`{% tabs %}`) cho GitBook. Tối ưu cho danh sách model/dịch vụ/gói sản phẩm có phân loại.

## Khi nào dùng

- Viết bài có danh sách model/service cần chia danh mục (Kira Models, Partner Models...)
- Bảng so sánh giá/dịch vụ theo gói
- Bất kỳ nội dung nào cần `{% tabs %}` với bảng Markdown bên trong

## Template cơ bản

```markdown
{% tabs %}
{% tab title="Danh mục 1 🇻🇳" %}
| Cột 1 | Cột 2 | Cột 3 |
|---|---|---|
| Giá trị | Giá trị | Giá trị |
{% endtab %}
{% tab title="Danh mục 2 🌍" %}
| Cột 1 | Cột 2 | Cột 3 |
|---|---|---|
| Giá trị | Giá trị | Giá trị |
{% endtab %}
{% endtabs %}
```

## Script sinh bảng tự động

Script `scripts/generate-model-tables.sh` nhận JSON đầu vào, xuất ra định dạng GitBook tabs.

### Cách dùng

1. Tạo file JSON:

```json
{
  "intro": "Mô tả ngắn trước bảng (có thể để trống)",
  "tabs": [
    {
      "title": "Kira Models 🇻🇳",
      "headers": ["Model", "Loại", "Giá đầu vào", "Giá đầu ra", "Trạng thái"],
      "rows": [
        ["**Kira 3.5 Pro**", "chat", "20.000đ / 1M tkn", "150.000đ / 1M tkn", "✅ Hoạt động"],
        ["**Kira Mini 1.0**", "chat", "🆓 Miễn phí", "🆓 Miễn phí", "✅ Hoạt động"]
      ]
    },
    {
      "title": "Partner Models 🌍",
      "headers": ["Model", "Loại", "Giá đầu vào", "Giá đầu ra", "Trạng thái"],
      "rows": [
        ["**Claude Opus 4.8**", "chat", "120.000đ / 1M tkn", "620.000đ / 1M tkn", "✅ Hoạt động"]
      ]
    }
  ]
}
```

2. Chạy script:

```bash
.opencode/skills/gitbook-writer/scripts/generate-model-tables.sh models.json
# hoặc pipe
cat models.json | .opencode/skills/gitbook-writer/scripts/generate-model-tables.sh
```

3. Copy output vào file `.md`.

### Yêu cầu

- Python 3 (dùng để parse JSON)
- Script có sẵn trong `.opencode/skills/gitbook-writer/scripts/`

## Reference

Xem file `references/model-table-template.md` cho full template và ví dụ.

## Quy ước trình bày

| Thành phần | Format |
|---|---|
| Tên model/sản phẩm | `**tên**` (bold) |
| Giá miễn phí | `🆓 Miễn phí` |
| Trạng thái hoạt động | `✅ Hoạt động` |
| Trạng thái bảo trì | `🔧 Bảo trì` |
| Icon danh mục | 🇻🇳 cho nội địa, 🌍 cho quốc tế |
