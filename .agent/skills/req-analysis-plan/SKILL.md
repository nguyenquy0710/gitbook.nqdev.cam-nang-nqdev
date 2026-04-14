---
name: req-analysis-plan
description: Phân tích yêu cầu người dùng thành bản kế hoạch triển khai chi tiết (decision-complete) cho dự án Dakia One (Monorepo, Next.js, Mongoose), lưu tại `plans/<slug>-plan.md`.
---

# Skill: Phân Tích Yêu Cầu & Lập Kế Hoạch - Dakia One

Mục tiêu: Chuyển đổi yêu cầu từ người dùng thành một bản kế hoạch triển khai hoàn chỉnh (decision-complete), có cấu trúc rõ ràng, bao quát các khía cạnh Backend API, Frontend Web, Database Schema và các ràng buộc kỹ thuật đặc thù của Dakia One Monorepo. Kế hoạch này sẽ được lưu trữ tại `plans/`.

## Khi dùng

- Người dùng đưa ra yêu cầu về tính năng mới, cải tiến, hoặc sửa lỗi cần được phân tích và lập kế hoạch triển khai.
- Cần làm rõ các yêu cầu về kiến trúc, database, API, và UI/UX trước khi bắt đầu code.
- Muốn tạo một tài liệu kế hoạch chi tiết, có thể dùng làm hướng dẫn cho các lập trình viên.

## Đầu vào

- **user_requirements**: Mô tả ban đầu về yêu cầu từ người dùng (ví dụ: "Tạo trang quản lý khách hàng có CRUD và phân trang").
- **context**: Trạng thái hiện tại của codebase (cấu trúc thư mục, models, API routes hiện có) và các ràng buộc đã được định nghĩa trong `docs/specs` hoặc `plans/`.

## Đầu ra

- Một file Markdown chi tiết, được sinh ra trong thư mục `plans/` với định dạng tên `<slug>-plan.md` (ví dụ: `customer-management-plan.md`).
- Nội dung file tuân thủ theo "Template Chuẩn" đã được định nghĩa trong skill `requirements-plan`.

## Quy trình Thực hiện

1.  **Grounding (Thu thập & Hiểu ngữ cảnh)**:
    -   Đọc kỹ `user_requirements` để nắm bắt mục tiêu nghiệp vụ.
    -   Sử dụng `grep_search` và `read_file` để rà soát các file liên quan trong `apps/api/src/models/`, `apps/api/src/app/api/`, `apps/web/src/app/`, `packages/types/src/` để hiểu kiến trúc hiện tại.
    -   Kiểm tra các kế hoạch hiện có trong `plans/` và các tài liệu đặc tả trong `docs/specs` để đảm bảo tính nhất quán.

2.  **Phân tích & Thiết kế (Analysis & Design)**:
    -   **Database Schema (Mongoose)**: Thiết kế hoặc cập nhật schema MongoDB, bao gồm các fields, types, validators, và mối quan hệ (ví dụ: `ref` cho multi-tenant `workspaceId`).
    -   **Backend API (Next.js)**: Xác định các API routes (`apps/api/src/app/api/.../route.ts`), phương thức HTTP (GET, POST, PUT, DELETE), yêu cầu xác thực/phân quyền (JWT, Role, Tenant-ID), và Zod schema cho validation.
    -   **Frontend Web (Next.js App Router)**: Phác thảo các UI components (`apps/web/src/components/`), pages (`apps/web/src/app/`), luồng điều hướng, quản lý trạng thái (React Query, Zustand), và áp dụng tiêu chuẩn UI UX Pro Max (Glassmorphism, Skeleton Loading).
    -   **Shared Types (`packages/types`)**: Định nghĩa hoặc cập nhật các TypeScript interfaces/enums dùng chung giữa frontend và backend.

3.  **Lập kế hoạch Triển khai (Implementation Planning)**:
    -   Phân chia công việc thành các bước nhỏ, rõ ràng, có thứ tự ưu tiên.
    -   Xác định các file bị ảnh hưởng (`NEW`/`MODIFY`) và mô tả chi tiết thay đổi trong từng file.
    -   Lên kế hoạch kiểm thử (Unit/Integration Tests với Vitest cho Backend, Manual UI Tests cho Frontend).

4.  **Tạo & Lưu File Kế Hoạch (Generate & Save Plan File)**:
    -   Tạo một file Markdown mới trong thư mục `plans/` với tên theo định dạng `<slug>-plan.md`.
    -   Điền nội dung kế hoạch theo "Template Chuẩn" được quy định trong skill `requirements-plan`.

---

## Template Chuẩn (Kế thừa từ `requirements-plan`)

```markdown
# 📋 Kế Hoạch: <Tên Tính Năng>

> **Mục tiêu**: Mô tả tóm tắt mục tiêu của tính năng.
> **Thuộc Phase**: (Ví dụ: 1 – CRM + Pipeline + Notification)
> **Ưu tiên**: 🔴 Cao / 🟡 Trung bình / 🟢 Thấp
> **Cập nhật**: YYYY-MM-DD

---

## 📌 Tổng Quan
- Trạng thái hiện tại: ...
- Kết quả mong đợi: ...

---

## 🔧 Thay Đổi Kiến Trúc / Triển Khai (Proposed Changes)

### 1. Types Package & Shared (`packages/types`)
- **File**: `packages/types/src/index.ts`
- Bổ sung / Sửa đổi các interface, enum dùng chung.

### 2. Backend – Mongoose Models & API (`apps/api`)
- **Database Schema**: Các Models (`apps/api/src/models/`). Lưu ý ràng buộc đa tenant (Tenant-ID / workspaceId).
- **API Routes**: Các thư mục route trong `apps/api/src/app/api/.../route.ts`. Bổ sung Zod Schema để validate.

### 3. Frontend – UI & State (`apps/web`)
- **State Management / Hooks**: Bổ sung logic fetch/mutate với React Query hoặc Zustand.
- **UI Components**: Tạo mới component ở `apps/web/src/components/`. Áp dụng Skeleton loading, trạng thái Disabled, Empty, Error theo chuẩn UI UX Pro Max.
- **Pages**: Chỉnh sửa tại `apps/web/src/app/`.

---

## 🔌 API Endpoints
| Method | Endpoint | Mô tả | Yêu cầu Quyền |
|--------|----------|-------|---------------|
| ...    | ...      | ...   | ...           |

---

## 🧪 Kế Hoạch Kiểm Thử (Verification Plan)
- **Automated Tests**: Viết Unit/Integration Test cho Backend ở `*.test.ts`. Command: `yarn test`.
- **Manual UI Tests**: Các bước người dùng thao tác kiểm chứng trên giao diện Web, xử lý các luồng edge case...

---

## 📁 Files Affected (Dự Kiến)
| Loại | File | Mô tả |
|------|------|-------|
| NEW / MODIFY | ... | ... |
```

## Lưu ý Đặc biệt cho Dakia One

1.  **"Decision-Complete"**: Mỗi kế hoạch phải đủ chi tiết để bắt đầu code ngay mà không cần thêm thông tin.
2.  **Monorepo Awareness**: Luôn tham chiếu đúng đường dẫn trong Monorepo (`apps/api`, `apps/web`, `packages/`).
3.  **Multi-tenant & Security**: Các thiết kế liên quan đến dữ liệu và API phải tích hợp cơ chế Multi-tenant (Tenant-ID) và bảo mật (JWT).
4.  **UI UX Pro Max**: Các đề xuất về giao diện phải tuân thủ nghiêm ngặt các nguyên tắc thiết kế đã định của Dakia One.
5.  **Validation**: Kế hoạch phải bao gồm rõ ràng cách thức kiểm thử các thay đổi được đề xuất.
