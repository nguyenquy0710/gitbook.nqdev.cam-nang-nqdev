---
name: project-sync
description: Đồng bộ hóa toàn diện kế hoạch phát triển (development-plan), tài liệu kỹ thuật (technical-plan), các bản kế hoạch tính năng (feature plans) và nhật ký thay đổi (CHANGELOG.md) dựa trên thực tế mã nguồn.
---

# Skill: Đồng Bộ Hóa Dự Án (Project Sync) - Dakia One

Mục tiêu: Đảm bảo "Nguồn Sự Thật" (Source of Truth) của dự án luôn nhất quán. Đồng bộ hóa giữa mã nguồn thực tế (`apps/`, `packages/`) với các tài liệu hướng dẫn (`README.md`, `docs/`) và kế hoạch triển khai (`plans/`).

## Khi dùng

- Sau khi hoàn thành một Epic, Feature hoặc một Phase trong `development-plan.md`.
- Khi có sự thay đổi lớn về kiến trúc, database schema hoặc tech stack.
- Trước khi bắt đầu một chu kỳ phát triển mới để rà soát lại các task tồn đọng.
- Người dùng yêu cầu: "Cập nhật tiến độ dự án", "Đồng bộ lại tài liệu", hoặc "Kiểm tra xem plan còn đúng không".

## Đầu vào

- **context**: Trạng thái hiện tại của repo (Git logs, file changes).
- **plans_dir**: Thư mục `plans/` chứa các bản kế hoạch.
- **docs_dir**: Thư mục `docs/` chứa tài liệu đặc tả và changelog.

## Đầu ra

- Các file trong `plans/*.md`, `docs/*.md` và `README.md` được cập nhật trạng thái mới nhất.
- Một báo cáo tóm tắt về các phần đã đồng bộ.

## Quy trình Thực hiện

1. **Grounding (Rà soát Thực tế)**:
   - Sử dụng `git status` và `git diff` để xem các thay đổi chưa được ghi nhận.
   - Quét thư mục `apps/api/src/models` để tìm thay đổi Schema.
   - Quét `apps/api/src/app/api` để xác định các Endpoint mới.
   - Kiểm tra `apps/web/src/app` để xác định các Page/UI mới đã hoàn thành.

2. **Cập nhật Feature Plans (`plans/<feature>-plan.md`)**:
   - Đánh dấu `[x]` cho các task đã code xong và đã qua kiểm thử.
   - Cập nhật phần "Proposed Changes" nếu thực tế triển khai khác với thiết kế ban đầu.
   - Cập nhật trạng thái ưu tiên hoặc ngày hoàn thành.

3. **Cập nhật Master Plans (`plans/development-plan.md` & `technical-plan.md`)**:
   - Đồng bộ tiến độ các Phase.
   - Cập nhật Database Design và API Spec trong `technical-plan.md` nếu có thay đổi.
   - Đảm bảo Tech Stack phản ánh đúng các thư viện mới được cài đặt.

4. **Ghi Nhật ký Thay đổi (`docs/CHANGELOG.md`)**:
   - Sử dụng skill `generate-changelog` để tạo entry mới cho các thay đổi vừa rà soát được.
   - Đảm bảo entry mới phản ánh đúng các module bị ảnh hưởng.

5. **Cập nhật README & Docs**:
   - Cập nhật Roadmap trong `README.md`.
   - Nếu có thay đổi về quy trình, cập nhật `docs/CONTRIBUTING.md`.

6. **Kiểm tra Nhất quán (Final Validation)**:
   - Đảm bảo không có sự mâu thuẫn giữa các file (ví dụ: `development-plan` bảo Phase 1 xong nhưng `CHANGELOG` chưa ghi nhận).

---

## Lưu ý Đặc biệt cho Dakia One

1. **Monorepo Awareness**: Luôn phân loại thay đổi theo `apps/api`, `apps/web` và `packages/`.
2. **Phase-Based**: Luôn đối chiếu với 5 Phase phát triển đã định nghĩa trong `development-plan.md`.
3. **Multi-tenant Integrity**: Khi đồng bộ Technical Plan, đặc biệt chú ý đến các thay đổi liên quan đến `Tenant-ID` và phân quyền.
4. **UI UX Pro Max**: Đảm bảo các thay đổi giao diện được ghi nhận là đã tuân thủ chuẩn Glassmorphism và Responsive.

## Công cụ Hỗ trợ
- Sử dụng `grep_search` để tìm các TODO hoặc FIXME còn sót lại trong code để đưa vào mục "Next Steps".
- Sử dụng `run_shell_command` với `git log --pretty=format:"%s" -n 20` để lấy danh sách thay đổi nhanh.
