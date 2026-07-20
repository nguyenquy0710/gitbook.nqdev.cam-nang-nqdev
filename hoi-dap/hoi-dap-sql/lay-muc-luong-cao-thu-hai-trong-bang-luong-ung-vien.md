---
description: >-
  Hướng dẫn các cách viết SQL lấy mức lương cao thứ 2 từ bảng lương ứng viên
  — dùng MAX(), DENSE_RANK(), LIMIT/OFFSET trên MySQL, SQL Server, PostgreSQL.
---

# Lấy mức lương cao thứ 2 trong bảng lương ứng viên

Cho bảng `candidate_salary` lưu lương ứng viên. Viết truy vấn lấy **mức lương cao thứ 2** (các mức lương khác nhau, không tính trùng).

## Dữ liệu mẫu

{% code title="candidate_salary" overflow="wrap" lineNumbers="true" %}
```sql
CREATE TABLE candidate_salary (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2)
);

INSERT INTO candidate_salary VALUES
(1, 'Nguyen Van A', 1000),
(2, 'Tran Thi B',  2000),
(3, 'Le Van C',    3000),
(4, 'Pham Thi D',  3000),
(5, 'Hoang Van E', 1500);
```
{% endcode %}

Kết quả mong đợi: **2000** (mức lương cao nhất là 3000, cao thứ 2 là 2000).

## Các cách giải

{% tabs %}
{% tab title="MAX() — phổ biến nhất" %}
{% code title="Dùng MAX() lồng nhau, tương thích mọi CSDL" overflow="wrap" lineNumbers="true" %}
```sql
SELECT MAX(salary) AS second_highest_salary
FROM candidate_salary
WHERE salary < (
    SELECT MAX(salary)
    FROM candidate_salary
);
```
{% endcode %}

**Cách hoạt động:**
1. Subquery lấy mức lương cao nhất (3000).
2. Query chính lấy `MAX(salary)` của các mức lương **thấp hơn** mức đó → 2000.

**Ưu điểm:** Chạy trên mọi hệ quản trị CSDL (MySQL, SQL Server, PostgreSQL, Oracle).\
**Nhược điểm:** Phải scan bảng 2 lần.
{% endtab %}

{% tab title="DENSE_RANK() — ANSI SQL" %}
{% code title="Dùng window function DENSE_RANK() — SQL Server, PostgreSQL, MySQL 8+, Oracle" overflow="wrap" lineNumbers="true" %}
```sql
SELECT salary
FROM (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rn
    FROM candidate_salary
) t
WHERE rn = 2;
```
{% endcode %}

**Cách hoạt động:**
- `DENSE_RANK()` xếp hạng các mức lương, không bỏ khoảng trống khi có giá trị trùng.
- Lọc `WHERE rn = 2` lấy mức lương cao thứ 2.

**Lưu ý:** Nếu có nhiều bản ghi cùng mức lương cao thứ 2, kết quả trả về **tất cả các bản ghi đó**.

{% hint style="info" %}
`DENSE_RANK()` không bỏ qua số thứ tự khi có giá trị trùng. `RANK()` sẽ bỏ qua, không phù hợp cho bài toán này.
{% endhint %}
{% endtab %}

{% tab title="LIMIT/OFFSET — MySQL, PostgreSQL" %}
{% code title="MySQL / PostgreSQL — DISTINCT + ORDER BY + LIMIT" overflow="wrap" lineNumbers="true" %}
```sql
SELECT DISTINCT salary
FROM candidate_salary
ORDER BY salary DESC
LIMIT 1 OFFSET 1;
```
{% endcode %}

Hoặc dùng shorthand `LIMIT 1, 1` (MySQL):

{% code title="MySQL shorthand" overflow="wrap" %}
```sql
SELECT DISTINCT salary
FROM candidate_salary
ORDER BY salary DESC
LIMIT 1, 1;
```
{% endcode %}

**Cách hoạt động:**
- `DISTINCT` loại bỏ các mức lương trùng nhau.
- `ORDER BY salary DESC` sắp xếp giảm dần.
- `LIMIT 1 OFFSET 1` bỏ qua dòng đầu (cao nhất), lấy dòng tiếp theo.
{% endtab %}

{% tab title="SQL Server — TOP" %}
{% code title="SQL Server — TOP + subquery" overflow="wrap" lineNumbers="true" %}
```sql
SELECT TOP 1 salary
FROM (
    SELECT DISTINCT TOP 2 salary
    FROM candidate_salary
    ORDER BY salary DESC
) t
ORDER BY salary ASC;
```
{% endcode %}

**Cách hoạt động:**
1. Subquery lấy 2 mức lương cao nhất (`TOP 2 ... ORDER BY DESC`).
2. Query chính lấy mức thấp hơn trong 2 mức đó (`TOP 1 ... ORDER BY ASC`).
{% endtab %}
{% endtabs %}

## Lấy toàn bộ thông tin ứng viên có lương cao thứ 2

{% code title="Thông tin đầy đủ ứng viên" overflow="wrap" lineNumbers="true" %}
```sql
SELECT *
FROM candidate_salary
WHERE salary = (
    SELECT MAX(salary)
    FROM candidate_salary
    WHERE salary < (
        SELECT MAX(salary)
        FROM candidate_salary
    )
);
```
{% endcode %}

Hoặc dùng `DENSE_RANK()`:

{% code title="Dùng DENSE_RANK() lấy full row" overflow="wrap" lineNumbers="true" %}
```sql
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rn
    FROM candidate_salary
) t
WHERE rn = 2;
```
{% endcode %}

## Tổng kết

| Cách               | CSDL hỗ trợ                            | Ghi chú                        |
| ------------------ | -------------------------------------- | ------------------------------ |
| `MAX()` lồng nhau   | Tất cả                                 | Đơn giản, portable             |
| `DENSE_RANK()`     | SQL Server, PostgreSQL, MySQL 8+, Oracle | Chuẩn ANSI, linh hoạt        |
| `LIMIT ... OFFSET` | MySQL, PostgreSQL                      | Ngắn gọn, nhanh                |
| `TOP`              | SQL Server                             | Cú pháp T-SQL đặc thù           |

{% hint style="success" %}
Đây là câu hỏi phỏng vấn SQL kinh điển. Cách dùng `MAX()` lồng nhau là an toàn nhất — chạy được mọi nơi, dễ giải thích.
{% endhint %}
