---
name: git-push-resolver
description: Chẩn đoán và xử lý các lỗi git push không thành công. Sử dụng skill này khi git push bị từ chối, báo lỗi divergent branches, non-fast-forward, pre-receive hook rejected, permission denied, protected branch, large file, hoặc repository not found. Phân tích thông báo lỗi từ git push và đưa ra hướng xử lý chính xác, an toàn.
---

# Git Push Resolver

Xử lý các tình huống `git push` bị từ chối. Phân tích lỗi từ terminal, xác định nguyên nhân, đề xuất giải pháp cụ thể.

## Quy trình chẩn đoán

Khi `git push` thất bại, làm theo các bước sau:

### 0. Đồng bộ remote trước

Trước khi xử lý bất kỳ lỗi nào, luôn chạy:

```bash
git fetch                      # cập nhật thông tin remote
git pull --no-rebase           # merge thay đổi remote về local
```

Sau đó kiểm tra `git status`:
- Nếu conflict → báo cáo cho user như workflow bên dưới
- Nếu không conflict → thử `git push` lại

**Lý do:** nhiều lỗi push (đặc biệt là non-fast-forward) được giải quyết đơn giản bằng fetch + pull.

### 1. Đọc thông báo lỗi

Chạy `git push` và đọc toàn bộ output. Xác định mã lỗi/message từ remote:

| Thông báo lỗi | Nguyên nhân |
|---|---|
| `[rejected]` / `non-fast-forward` | Divergent branches |
| `pre-receive hook declined` | Hook phía server từ chối |
| `permission denied` | Không có quyền ghi |
| `protected branch` | Branch được bảo vệ |
| `file too large` / `exceeds limit` | File vượt quá dung lượng cho phép |
| `repository not found` | Remote URL sai hoặc không có quyền |

### 2. Thu thập thông tin bổ sung

```bash
git status                    # trạng thái hiện tại
git log --oneline -10        # lịch sử commit local
git log --oneline origin/<branch> -5  # lịch sử remote
git remote -v                # kiểm tra remote URL
```

## Xử lý theo tình huống

### Divergent branches (non-fast-forward)

Local và remote có lịch sử phân nhánh. Đây là tình huống phổ biến nhất.

**Luôn kiểm tra working tree sạch trước khi pull:**
```bash
git status
```
Nếu có uncommitted changes → `git stash` trước, stash lại sau khi merge xong.

**Bước 1 — Merge (mặc định, ưu tiên an toàn):**
```bash
git pull --no-rebase
```

**Bước 2 — Kiểm tra conflict ngay sau pull:**
```bash
git status
```
- Nếu thấy `Unmerged paths` / `both modified` / `both added` → **CONFLICT DETECTED. DỪNG LẠI.**
- Không tự ý resolve conflict. Báo cáo cho user:
  - Danh sách file bị conflict
  - Nội dung conflict markers nếu cần
  - Hỏi user hướng xử lý tiếp theo
- Nếu không có conflict → commit merge tự động được tạo → chạy `git push`.

**Khi bị conflict, chỉ đưa ra hướng dẫn cho user tự resolve:**
```bash
# 1. Mở từng file conflict, tìm <<<<<<< ======= >>>>>>>
# 2. Sửa nội dung theo ý muốn
# 3. Sau khi sửa xong:
git add <file-da-sua>
# 4. Hoàn tất merge:
git commit                # hoặc git merge --continue
git push
```

**Hoặc hủy merge nếu user muốn quay lại:**
```bash
git merge --abort
# Trạng thái trở về trước lúc pull
```

### Pre-receive hook rejected

Server từ chối do hook kiểm tra (CI, lint, policy).

```bash
# Kiểm tra lý do từ chối từ message hook
# Sửa theo yêu cầu hook, sau đó:
git commit --amend -m "message"  # sửa commit nếu cần
git push                          # push lại
```
**Không** force push trừ khi chắc chắn hook sai.

### Permission denied

```bash
# Kiểm tra remote URL và quyền
git remote -v
# Kiểm tra token/credential đã hết hạn chưa
# Nếu dùng HTTPS + token:
git remote set-url origin https://<username>:<token>@github.com/<owner>/<repo>.git
```
Nếu remote URL chứa token, nhắc user kiểm tra token còn hiệu lực.

### Protected branch

Branch main/master được bảo vệ (GitHub/GitLab settings).

```bash
# Tạo branch mới và push
git checkout -b feature/<name>
git push -u origin feature/<name>
# Tạo Pull Request/Merge Request qua GitHub/GitLab
```
Không force push vào protected branch.

### Large file / size limit

GitHub giới hạn: single file ≤ 100 MB.

```bash
# Xác định file lớn
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print $3, $4}' | sort -rn | head -10
# Xóa file khỏi lịch sử (dùng git-filter-repo hoặc BFG)
```
Dùng Git LFS nếu cần lưu file lớn hợp lệ.

### Repository not found / 404

```bash
# Kiểm tra remote
git remote -v
# Sửa remote nếu sai
git remote set-url origin <correct-url>
# Kiểm tra public/private và quyền truy cập
```

## Các trường hợp đặc biệt

| Tình huống | Xử lý |
|---|---|
| Đã commit local, push bị từ chối, local chưa có remote | `git branch -u origin/<branch>` |
| Cần hủy commit local đã push không thành công | `git reset HEAD~1` (giữ changes) hoặc `git reset --hard HEAD~1` (xóa) |
| Lỡ force push vào shared branch | `git reflog` để tìm commit cũ, `git reset --hard <sha>` |
| Ngắt giữa chừng pull/rebase | `git merge --abort` hoặc `git rebase --abort` |

## Nguyên tắc an toàn

- **Không force push** vào branch shared (main/master/release) khi chưa confirm với team
- **Không tự ý resolve conflict.** Chỉ phát hiện và báo cáo conflict cho user, cung cấp hướng dẫn để user tự xử lý
- **Không tự ý chạy `git add`** khi có conflict. Chờ user xác nhận đã resolve xong
- Kiểm tra `git status` trước và sau mỗi bước để phát hiện conflict sớm
- Nếu phát hiện conflict: DỪNG LẠI, báo cáo danh sách file conflict, hỏi user hướng xử lý
- Không conflict → mới tiếp tục `git push`
- Nếu không chắc, dùng `--abort` để quay lại trạng thái ban đầu
