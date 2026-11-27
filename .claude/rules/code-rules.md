---
name: code-rules
version: 2.2.2
author: QuyIT Platform
created_date: 2026-09-21
updated_date: 2026-11-19
---

# Code Rules - Project-Specific Guidance

Single source of truth for `.claude/rules/code-rules.md`. The policy blocks below are copied verbatim into every generated project; do not paraphrase or shorten them.

> Số điện thoại test trong Testing Rules là mặc định của NQDev — sửa theo dự án nếu cần.

---

## TESTING RULES

### 🔴 CRITICAL: Phone Number Testing

**APPROVED TEST NUMBERS (USE ONLY THESE):**
- ✅ `0909090909`
- ✅ `0765418062`

**❌ PROHIBITED:**
- Do NOT use other phone numbers (real, fake, or placeholder)
- Do NOT use generic patterns (like `0123456789`, `9999999999`)
- Do NOT skip phone number tests

**Why This Matters:**
- Some payment gateways have hardcoded logic for specific numbers
- Using non-approved numbers may trigger unexpected behavior
- Real phone numbers in code is a privacy/security risk
- Consistency across test suites prevents confusion

**Action on Violation:**
- ❌ Code review will REJECT tests with unapproved numbers
- 🔧 Developer must update to approved numbers
- 📋 Document the reason if a new test number is needed

---

### Unit Testing Guidelines

**Test Structure:**
- Arrange → Act → Assert (AAA pattern)
- One assertion per test when possible
- Clear test names: `test_<function>_<scenario>_<expected_outcome>`

**Coverage Targets:**
- Minimum: 80% code coverage
- Target: 90%+ code coverage
- Critical paths (auth, payments, data): 100% coverage

**Best Practices:**
- Test edge cases and error scenarios
- Mock external dependencies
- Use fixtures for setup/teardown
- Isolate tests from each other

---

### Integration Testing Rules

**Database Testing:**
- Use test database (separate from production)
- Setup/teardown data for each test
- Test transactions and rollbacks
- Verify data consistency

**API Testing:**
- Test all HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Test authentication/authorization
- Test error responses (400, 401, 403, 404, 500)
- Verify response headers and formats

**External Services:**
- Mock external APIs in tests
- Test retry logic with mock failures
- Never call real external services in automated tests
- Document expected behavior for manual testing

---

### End-to-End Testing

**Test Scenarios:**
- Happy path: Normal user workflow
- Error paths: Invalid input, network failures, timeouts
- Edge cases: Boundary values, special characters, etc.
- Performance: Response times, load capacity

**User Data Handling:**
- Use test data only (never production data)
- Clean up after tests complete
- Don't log sensitive information
- Verify data privacy in results

---

### Code Review Requirements

Before committing code:

- [ ] All tests pass locally
- [ ] Phone numbers (if any) use ONLY approved test numbers
- [ ] No real phone numbers, emails, or credentials in code
- [ ] Test coverage meets minimum 80% threshold
- [ ] Edge cases are tested
- [ ] Error scenarios are handled
- [ ] Documentation is updated

---

### Common Test Patterns

**JavaScript/Node.js Example:**
```javascript
describe('userService.login', () => {
  // Setup
  beforeEach(() => {
    this.userService = new UserService();
  });

  // Happy path
  it('should return user when credentials are valid', async () => {
    const result = await this.userService.login('testuser@example.com', 'password123');
    expect(result.id).toBeDefined();
  });

  // Error path with approved phone number
  it('should validate phone number against approved list', () => {
    const validPhone = '0909090909'; // ✅ APPROVED
    const isValid = validatePhoneNumber(validPhone);
    expect(isValid).toBe(true);
  });

  // Edge case
  it('should reject invalid phone number', () => {
    const invalidPhone = '0123456789'; // ❌ NOT APPROVED
    const isValid = validatePhoneNumber(invalidPhone);
    expect(isValid).toBe(false);
  });
});
```

---

### Test Violation Reporting

**How to Report:**
1. Document the specific test that violates rules
2. Include: Test name, file path, violation type
3. Add details: Line number, expected vs. actual behavior
4. Create an issue for tracking

**Follow-up:**
- Developer has 2 working days to fix
- Escalate if not fixed within timeline
- Run full test suite after fix verification

---

---

## Comment Rule

1. Chỉ comment khi logic phức tạp, workaround tạm, hoặc edge case đặc biệt.
2. Comment giải thích WHY, không giải thích WHAT.
3. Sửa code → sửa/xóa comment cũ theo, không để lỗi thời.
4. Code tự rõ nghĩa (CRUD đơn giản, tên biến/hàm rõ ràng) → không comment.
5. Comment ngắn: mặc định một dòng (tối đa khoảng 100 ký tự); không viết nhiều đoạn, không kể lịch sử thay đổi (đã có git).

### Comment label (per developer)

1. Read `.claude/dev.local.json` → `label`; if present, use it without asking.
2. Otherwise suggest a label from `git config user.name` / `user.email`, ask the dev to confirm or override once, then save it to `.claude/dev.local.json` (not committed).
3. Format: `<comment-syntax> [<label>] <WHY explanation>`, e.g. `// [<label>] ...`, `# [<label>] ...`, `-- [<label>] ...`.

---

## Database Execution Policy

NOT run by Claude — cần DBA review

1. Claude/agents never execute SQL directly against any database (dev, staging, production), by any means (CLI, ORM migration tool, MCP DB connector).
2. Applies to all DDL (`CREATE`/`ALTER`/`DROP`/`TRUNCATE`), DML (`INSERT`/`UPDATE`/`DELETE`) and schema migrations.
3. Write the statement into the chat session only, prefix it with `-- NOT run by Claude — cần DBA review`, then stop. A human DBA reviews and executes it.
4. Read-only `SELECT` for diagnostics/inspection is the only exemption.

---

## Git Commit Policy

1. KHÔNG tự ý `git commit` (kể cả `--amend`) — luôn hỏi và chờ dev xác nhận rõ ràng trước khi commit.
2. Khi hỏi, nêu rõ: danh sách file sẽ commit + message dự kiến.
3. Xác nhận cho 1 lần commit không áp dụng cho các lần sau — mỗi lần commit hỏi lại.
4. Không tự `git push`, `git push --force`, `git reset --hard`, tạo/xóa branch, tag nếu dev chưa yêu cầu.

---

## Development Workflow Policy

0. Yêu cầu tính năng mới, sửa bug hoặc chuẩn bị release: nếu plugin `nqdev` đã cài, đề xuất chạy `/nqdev:nqdev-task-flow <feature|bugfix|release>` trước khi phân tích hay code; người dùng từ chối thì làm theo các mục dưới.
1. Trong session trao đổi: chỉ phân tích yêu cầu mới và hỏi làm rõ — KHÔNG viết/sửa code.
2. Sau khi phân tích xong: viết plan (phạm vi, file sẽ đổi, các bước) rồi dừng lại chờ duyệt. Ưu tiên dùng skill `/nqdev-write-plan` để viết plan (nếu có); không có thì tự viết theo cấu trúc trên.
3. Chỉ bắt đầu code sau khi dev duyệt plan rõ ràng. Im lặng hoặc trả lời mơ hồ = chưa duyệt.
4. Tuyệt đối không viết code khi đang trao đổi mà chưa có sự cho phép.
5. Plan thay đổi đáng kể trong lúc làm → dừng lại, cập nhật plan, xin duyệt lại.
6. Viết code xong (từng bước hoặc toàn bộ) → cập nhật trạng thái vào plan (bước nào xong / đang làm / còn lại) rồi báo dev.

---

## Task Execution Policy

1. Mỗi lần chỉ làm một task trong plan đã duyệt; không tự mở rộng phạm vi.
2. Làm trên nhánh riêng; mỗi task một commit nhỏ, đúng phạm vi. Tạo nhánh và commit theo Git Commit Policy (hỏi và chờ dev xác nhận).
3. Trước khi code: nêu file sẽ sửa. Cần sửa file ngoài danh sách đó hoặc thêm thư viện mới → dừng và hỏi; chưa được duyệt thì không làm.
4. Sau mỗi task: báo những gì đã đổi và task tiếp theo trong plan (cập nhật trạng thái plan theo mục 6 của Development Workflow Policy).
5. Gặp mơ hồ hoặc xung đột với plan: dừng và hỏi, không tự quyết.

---

## INTEGRATION & WORKFLOW

### CI/CD Integration

**Suggested Checks:**
- Linter: Cảnh báo "TODO", "FIXME" không có issue/PR
- Code review: Verify comments explain "WHY", không "WHAT"
- Tests: Validate all phone numbers use approved numbers only
- Documentation: Ensure complex logic có tương ứng docs entry

**Test Pipeline:**
1. Unit tests (80%+ coverage minimum)
2. Integration tests (database, API, external services)
3. E2E tests (user workflows)
4. Code quality check (comments, phone numbers)

---

### Code Review Workflow

1. **Before Submission:**
   - Run full test suite locally
   - Check phone numbers against approved list
   - Review comments for clarity (WHY vs WHAT)
   - Update documentation if needed

2. **During Review:**
   - Verify test coverage
   - Validate comment quality
   - Check for stale comments
   - Ensure no real phone numbers/credentials

3. **After Approval:**
   - Merge to main branch
   - Trigger CI/CD pipeline
   - Deploy to staging/production

---

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.2.2 | 2026-11-19 | Comment label: examples use the `[<label>]` placeholder instead of a fixed label |
| 2.2.1 | 2026-11-19 | Development Workflow Policy rule 0: renamed `/nqdev:nqdev-flow` to `/nqdev:nqdev-task-flow` |
| 2.2.0 | 2026-11-17 | Development Workflow Policy: added rule 0 (suggest `/nqdev:nqdev-flow` for features, bugs, releases) |
| 2.1.1 | 2026-11-11 | Comment Rule: added rule 5 (short comments) |
| 2.1.0 | 2026-11-09 | Added Task Execution Policy |
| 2.0.0 | 2026-11-04 | Added Database, Git, Workflow policies; Comment Rule shortened to 4 rules + per-dev label |
| 1.0.0 | 2026-09-21 | Consolidated: Testing Rules + Comment Cleanup Rule |
