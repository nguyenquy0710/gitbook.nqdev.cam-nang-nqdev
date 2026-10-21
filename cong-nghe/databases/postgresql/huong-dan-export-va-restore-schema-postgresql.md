---
description: >-
  Cách export và restore schema PostgreSQL chỉ gồm cấu trúc bảng, index, constraint
  bằng pg_dump và psql — không kèm dữ liệu, kèm xử lý các lỗi thường gặp.
---

# Hướng dẫn export và restore schema PostgreSQL bằng pg_dump và psql

Khi cần dựng database test, môi trường staging hoặc chuyển cấu trúc bảng sang một server khác, ta thường chỉ cần **cấu trúc** mà không cần **dữ liệu**. PostgreSQL hỗ trợ việc này bằng cờ `--schema-only` của `pg_dump`.

Bài viết này walkthrough trọn quy trình: export schema `public`, tạo database đích, rồi restore bằng `psql` — kèm các lỗi thường gặp và cách xử lý.

***

## Bối cảnh: khi nào cần export schema

* **Dựng môi trường test/staging:** Copy cấu trúc bảng, index, constraint, view, function từ database dev sang database mới.
* **Chuẩn bị dữ liệu mẫu:** Tạo schema đúng như production rồi mới import dữ liệu đã lọc.
* **Di chuyển cấu trúc sang server khác:** Đặt schema vào Git để review thay đổi trước khi áp dụng.
* **Tái tạo môi trường lỗi:** Dựng lại schema tối thiểu để reproduce lỗi.

{% hint style="info" %}
`--schema-only` chỉ xuất **cấu trúc**: bảng, index, constraint, view, function, sequence, type. File dump sẽ **không có dòng dữ liệu** nào.
{% endhint %}

***

## Bước 1: Export schema

{% code title="Export schema public ra file SQL" overflow="wrap" %}
```bash
pg_dump -h localhost -p 5432 -U postgres -d ten_database \
  --schema-only -n public -f schema_public.sql
```
{% endcode %}

### Giải thích tham số

| Tham số | Ý nghĩa |
| ------- | ------- |
| `-h` | Host kết nối |
| `-p` | Port của PostgreSQL server |
| `-U` | User kết nối |
| `-d` | Tên database nguồn cần export |
| `--schema-only` (`-s`) | Chỉ xuất cấu trúc, không xuất dữ liệu |
| `-n public` | Chỉ xuất schema `public`, bỏ trống để xuất tất cả |
| `-f` | Tên file đầu ra |

### Các biến thể hữu ích

{% code title="Các biến thể của lệnh export" overflow="wrap" lineNumbers="true" %}
```bash
# Bỏ owner và quyền — dễ import sang server khác
pg_dump -U postgres -d ten_database --schema-only --no-owner --no-privileges -f schema.sql

# Chỉ một số bảng cụ thể
pg_dump -U postgres -d ten_database --schema-only -t bang_a -t bang_b -f schema_tables.sql

# Dạng nén (custom format) — restore bằng pg_restore
pg_dump -U postgres -d ten_database --schema-only -Fc -f schema.dump
```
{% endcode %}

{% code title="Export schema khi PostgreSQL chạy trong Docker" overflow="wrap" %}
```bash
docker exec -i ten_container pg_dump -U postgres -d ten_database \
  --schema-only -n public > schema_public.sql
```
{% endcode %}

***

## Bước 2: Tạo database đích

{% code title="Tạo database mới" overflow="wrap" %}
```bash
createdb -h localhost -p 5432 -U postgres esm45f0e_qcdd_test
```
{% endcode %}

{% hint style="warning" %}
Database mới **luôn có sẵn schema `public`**. Khi restore, `pg_dump` vẫn phát ra lệnh tạo schema này nên thường gặp cảnh báo `schema "public" already exists` — đây là bình thường, không phải lỗi.
{% endhint %}

***

## Bước 3: Restore schema

{% hint style="danger" %}
Vì dump bằng `-f` (không có `-Fc`), file là **SQL thuần** nên phải restore bằng `psql`. Dùng `pg_restore` chỉ đúng với file ở dạng custom (`-Fc`), directory (`-Fd`) hoặc tar (`-Ft`).
{% endhint %}

{% code title="Restore schema vào database mới" overflow="wrap" %}
```bash
psql -h localhost -p 5432 -U postgres -d esm45f0e_qcdd_test \
  -v ON_ERROR_STOP=1 -f schema_public.sql
```
{% endcode %}

* **Bắt buộc:** File phải nằm đúng thư mục hiện tại, hoặc chỉ định đường dẫn đầy đủ.
* **`-v ON_ERROR_STOP=1`:** Dừng ngay khi gặp lỗi đầu tiên, tránh để lại schema dở dang mà không biết chỗ nào hỏng.

### Restore khi PostgreSQL chạy trong Docker

{% code title="Restore schema trong container" overflow="wrap" %}
```bash
docker exec -i ten_container psql -U postgres -d esm45f0e_qcdd_test < schema_public.sql
```
{% endcode %}

***

## Bước 4: Kiểm tra kết quả

{% code title="Liệt kê các bảng trong schema public" overflow="wrap" %}
```bash
psql -h localhost -U postgres -d esm45f0e_qcdd_test -c "\dt public.*"
```
{% endcode %}

Ngoài ra có thể kiểm tra nhanh số lượng bảng, view và function:

{% code title="Kiểm tra số lượng object trong database" overflow="wrap" %}
```sql
SELECT relkind, count(*)
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
GROUP BY relkind;
-- relkind: r = table, v = view, i = index, m = materialized view
```
{% endcode %}

***

## Các lỗi thường gặp

| Lỗi | Nguyên nhân | Cách xử lý |
| --- | --- | --- |
| `schema "public" already exists` | Database mới luôn có sẵn schema `public` | Bỏ qua — không dùng `ON_ERROR_STOP` cho phần này |
| `role "xxx" does not exist` | File dump chứa câu lệnh `OWNER TO xxx` | Tạo role trước `CREATE ROLE xxx;` hoặc dump lại với `--no-owner --no-privileges` |
| Thiếu extension (`uuid-ossp`, `pg_trgm`, `postgis`…) | Dump với `-n public` không kèm lệnh tạo extension | Tạo trước: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";` |
| Sai encoding hoặc mất dấu tiếng Việt | PowerShell dùng `>` có thể ghi file ở dạng UTF-16 | Dùng `-f` thay vì redirect `>` |
| `pg_restore: error: input file appears to be a text format dump` | Dùng `pg_restore` cho file plain SQL | Chuyển sang dùng `psql` |

{% hint style="info" %}
Muốn schema "sạch" và có thể diff/review trên Git, hãy export với `--no-owner --no-privileges`.
{% endhint %}

***

## Lưu ý khi chạy trên Windows

{% code title="Gọi trực tiếp pg_dump và psql trong PowerShell" overflow="wrap" lineNumbers="true" %}
```powershell
& "C:\Program Files\PostgreSQL\16\bin\pg_dump.exe" -h localhost -U postgres -d ten_database --schema-only -n public -f schema_public.sql

& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -h localhost -U postgres -d esm45f0e_qcdd_test -f schema_public.sql
```
{% endcode %}

* Thay `16` bằng phiên bản PostgreSQL đang cài đặt.
* Nếu `pg_dump` không có trong `PATH`, dùng đường dẫn đầy đủ như trên.
* Nên thêm `pg_dump` vào `PATH` thay vì gõ đường dẫn mỗi lần.

***

## Mẹo bổ sung

* **Nhập mật khẩu không tương tác:** dùng `PGPASSWORD=matkhau` trên Linux/macOS, `$env:PGPASSWORD="matkhau"` trong PowerShell, hoặc lưu vào file `~/.pgpass` với quyền `600`.
* **Muốn có cả schema lẫn dữ liệu:** bỏ `--schema-only`.
* **Chỉ muốn dữ liệu:** dùng `--data-only`.
* **Luôn restore với `-v ON_ERROR_STOP=1`** để dễ tìm và xác định lỗi.
* **Kiểm tra trước khi áp dụng lên production:** dump bằng `--no-owner --no-privileges`, commit file SQL vào Git và review trước khi chạy.

{% hint style="warning" %}
Khi viết bài hoặc chia sẻ file dump ra public, nhớ thay tên database, user và mọi thông tin nhạy cảm — dump schema vẫn có thể lộ cấu trúc bảng và tên cột.
{% endhint %}

***

## Tóm tắt

Quy trình chỉ gồm 3 bước:

1. **Dump schema** → `pg_dump --schema-only -n public -f schema_public.sql`
2. **Tạo DB đích** → `createdb ten_database_moi`
3. **Restore bằng `psql`** → `psql -d ten_database_moi -v ON_ERROR_STOP=1 -f schema_public.sql`

***

**Tài liệu tham khảo:**

* [pg_dump — PostgreSQL Documentation](https://www.postgresql.org/docs/current/app-pgdump.html)
* [psql — PostgreSQL Documentation](https://www.postgresql.org/docs/current/app-psql.html)
* [Tùy chọn dòng lệnh của pg_dump — PostgreSQL Documentation](https://www.postgresql.org/docs/current/app-pgdump.html#APP-PG-DUMP-OPTIONS)