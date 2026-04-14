---
name: generate-skill
description: Skill chuyên dụng để khởi tạo và chuẩn hóa các AI Skill mới cho dự án Dakia One, đảm bảo tuân thủ cấu trúc Monorepo, tiêu chuẩn mã nguồn và quy trình làm việc của hệ thống.
---

# Skill: Khởi Tạo & Chuẩn Hóa Skill - Dakia One

Mục tiêu: Cung cấp một khung làm việc (framework) để tạo ra các prompt "AI Skill" có cấu trúc tốt, chuyên sâu và dễ bảo trì, giúp mở rộng khả năng tự động hóa của Gemini CLI trong hệ sinh thái Dakia One (Next.js, TurboRepo, Mongoose, Vitest).

## Khi dùng

- Cần tạo một skill mới để tự động hóa một tác vụ lặp đi lặp lại (ví dụ: `generate-api-route`, `fix-lint-errors`, `summarize-prd`).
- Cần cập nhật hoặc chuẩn hóa lại các skill cũ theo phong cách thiết kế của Dakia One.

## Đầu vào

- **skill_name**: Tên skill (định dạng kebab-case, ví dụ: `api-generator`).
- **skill_description**: Mô tả chi tiết mục tiêu và phạm vi của skill.
- **context**: Bối cảnh sử dụng, các công nghệ liên quan (API, Web, Database) hoặc các ràng buộc đặc thù.

## Đầu ra

- Một file `SKILL.md` hoàn chỉnh theo cấu trúc chuẩn của Dakia One để lưu vào thư mục `.agents/skills/<skill-name>/`.

## Quy trình Thực hiện

1. **Phân tích Mục tiêu (Analysis)**: Xác định rõ vấn đề skill cần giải quyết. Skill này phục vụ cho Frontend (`apps/web`), Backend (`apps/api`), hay Shared logic (`packages/`)?
2. **Thiết kế Quy trình (Workflow Design)**: Phác thảo các bước thực hiện của skill (Grounding -> Planning -> Acting -> Validating).
3. **Xây dựng Prompt (Prompt Engineering)**: 
   - Sử dụng ngôn ngữ tiếng Việt (hoặc tiếng Anh nếu đặc thù kỹ thuật yêu cầu).
   - Đảm bảo prompt có tính "Instructional" cao, rõ ràng từng bước.
   - Tích hợp các công cụ (tools) có sẵn của Gemini CLI (grep_search, read_file, run_shell_command, replace).
4. **Chuẩn hóa Định dạng (Standardization)**: Áp dụng Template chuẩn của Dakia One bên dưới.

---

## Template Chuẩn cho Skill mới

```markdown
---
name: <tên-skill-kebab-case>
description: <mô tả ngắn gọn bằng tiếng Việt>
---

# Skill: <Tên Skill Tiếng Việt> - Dakia One

Mục tiêu: <Mô tả chi tiết mục tiêu cuối cùng>

## Khi dùng
- <Trường hợp sử dụng 1>
- <Trường hợp sử dụng 2>

## Đầu vào
- <Danh sách các input cần thiết từ user hoặc context>

## Đầu ra
- <Kết quả mong đợi: File được tạo, code được sửa, hoặc báo cáo phân tích>

## Quy trình Thực hiện
1. **Bước 1 (Grounding)**: ...
2. **Bước 2 (Processing/Action)**: ...
3. **Bước 3 (Validation)**: <Cách kiểm tra kết quả, chạy test, lint...>

---

## Template / Ví dụ (Nếu có)
<Cung cấp mẫu code hoặc cấu trúc file mong muốn>

## Lưu ý Đặc biệt
- <Ràng buộc về Tenant / Multi-tenant>
- <Quy tắc đặt tên file/folder trong Dakia One>
- <Các tiêu chuẩn bảo mật và hiệu năng (Security & Performance)>
```

## Lưu ý Đặc biệt cho Skill Creator

1. **Monorepo Awareness**: Mọi skill mới phải hiểu cấu trúc dự án (apps/api, apps/web, packages/types, packages/utils).
2. **Tool-First**: Khuyến khích skill sử dụng các công cụ tìm kiếm (`grep_search`, `glob`) trước khi đọc file để tiết kiệm context.
3. **Validation is Mandatory**: Mọi skill thực hiện thay đổi code PHẢI có bước kiểm tra lại bằng lệnh shell (`yarn lint`, `yarn test`, `tsc`) hoặc tự kiểm tra logic.
4. **Dakia One Style**: Tuân thủ Glassmorphism cho UI, Mongoose Discriminators cho Multi-tenant, và Zod cho validation.
