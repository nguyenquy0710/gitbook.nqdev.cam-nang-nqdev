---
description: >-
  Git là công cụ quản lý phiên bản không thể thiếu trong lập trình, giúp theo
  dõi và quản lý thay đổi trong mã nguồn của các dự án.
---

# 20 lệnh Git hữu ích mọi lập trình viên nên biết

Dù các công cụ giao diện đồ họa (GUI) giúp đơn giản hóa thao tác, việc thành thạo dòng lệnh Git mang lại sự kiểm soát và linh hoạt tối đa. Dưới đây là **20 lệnh Git hữu ích** mà mọi lập trình viên nên biết để tối ưu hóa quy trình làm việc hàng ngày.

{% code title="Git Cheat Sheet" overflow="wrap" lineNumbers="true" %}
```http
https://about.gitlab.com/images/press/git-cheat-sheet.pdf
https://education.github.com/git-cheat-sheet-education.pdf
```
{% endcode %}

## 1. Thiết Lập Cấu Hình Toàn Cầu

**Chức năng:** Xác định tên và email sẽ xuất hiện trong các commit của bạn. Thông tin này giúp các thành viên khác dễ dàng nhận diện ai đã thực hiện commit.

```bash
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"
```

> 💡 **Mẹo:** Sử dụng `--local` thay vì `--global` để cấu hình riêng cho từng dự án.

## 2. Hoàn Tác Commit Cuối (Không Mất Thay Đổi)

**Chức năng:** Hoàn tác commit cuối nhưng vẫn giữ các thay đổi trong giai đoạn "staged". Thường dùng khi commit nhầm.

```bash
git reset --soft HEAD~1
```

> **Ghi chú:** Sử dụng `--soft` để hoàn tác commit nhưng không xóa các thay đổi đã staged.

## 3. Chỉnh Sửa Commit Cuối

**Chức năng:** Cập nhật lại nội dung hoặc mô tả commit cuối cùng, thường dùng để sửa thông tin sau khi đã commit.

```bash
git add .
git commit --amend -m "Mô tả commit mới"
```

> **Ghi chú:** `--amend` cho phép bạn thay đổi commit cuối mà không tạo ra một commit mới.

## 4. Lưu Trữ Tạm Thời Các Thay Đổi Chưa Commit

**Chức năng:** Lưu trữ các thay đổi hiện tại mà không commit, giúp bạn chuyển nhanh sang nhánh khác hoặc thực hiện công việc khác.

```bash
git stash
```

> 💡 Lấy lại các thay đổi đã lưu trữ bằng lệnh `git stash pop`.

## 5. Xem Lịch Sử Commit Dưới Dạng Đồ Họa

**Chức năng:** Hiển thị lịch sử commit dưới dạng đồ họa đơn giản, giúp theo dõi nhánh và commit dễ dàng.

```bash
git log --graph --oneline --all
```

> **Ghi chú:** `--oneline` rút gọn thông tin commit trên một dòng, và `--all` hiển thị tất cả nhánh.

## 6. Thay Đổi Tác Giả Của Commit

**Chức năng:** Cập nhật thông tin tác giả commit cuối cùng, giúp chỉnh sửa khi commit bằng thông tin sai.

```bash
git commit --amend --author="Tác giả mới <email@example.com>"
```

> **Ghi chú:** `--author` thay đổi thông tin tác giả mà không tạo commit mới.

## 7. Kiểm Tra Sự Khác Biệt Của Các Thay Đổi Đã Staged

**Chức năng:** So sánh các tệp đã staged với phiên bản trước đó để xem chi tiết thay đổi.

```bash
git diff --staged
```

> **Ghi chú:** `--staged` giúp bạn chỉ xem sự khác biệt ở những thay đổi đã staged.

## 8. Tìm Bug Bằng Bisect

**Chức năng:** Tìm kiếm commit cụ thể gây ra lỗi bằng cách chia đôi lịch sử commit và kiểm tra dần để xác định lỗi.

```bash
git bisect start
git bisect bad  # Commit hiện tại có lỗi
git bisect good <commit-hash>  # Commit không có lỗi
```

> **Ghi chú:** Git sẽ tự động chia đôi lịch sử và yêu cầu bạn kiểm tra từng phần để xác định lỗi.

## 9. Rebase Để Làm Sạch Lịch Sử Commit

**Chức năng:** Tổ chức lại lịch sử commit, giúp kết hợp hoặc chỉnh sửa các commit gần nhau để dễ theo dõi.

```bash
git rebase -i HEAD~3
```

> **Ghi chú:** `-i` bật chế độ tương tác, cho phép bạn chọn hành động cho từng commit.

## 10. Cherry-Pick Commit Cụ Thể

**Chức năng:** Áp dụng một commit từ nhánh khác vào nhánh hiện tại.

```bash
git cherry-pick <commit-hash>
```

> **Ghi chú:** Dùng để sao chép một commit hữu ích từ nhánh khác mà không phải merge toàn bộ.

## 11. Liệt Kê Tất Cả Các Nhánh (Local Và Remote)

**Chức năng:** Hiển thị danh sách tất cả các nhánh trên cả local và remote.

```bash
git branch -a
```

> **Ghi chú:** `-a` hiển thị tất cả các nhánh, bao gồm cả những nhánh trên remote.

## 12. Xóa Các Tệp và Thư Mục Không Được Theo Dõi

**Chức năng:** Xóa các tệp và thư mục mà Git không theo dõi, giữ cho repo gọn gàng.

```bash
git clean -fd
```

> 💡 Sử dụng `-n` để xem trước những gì sẽ bị xóa.

## 13. Theo Dõi Một Nhánh Upstream

**Chức năng:** Liên kết nhánh local với nhánh remote, giúp theo dõi và đồng bộ.

```bash
git branch --set-upstream-to=origin/main
```

> **Ghi chú:** Hữu ích khi bạn làm việc với các nhánh remote và cần đồng bộ dễ dàng.

## 14. Gộp Commit Bằng Rebase Tương Tác

**Chức năng:** Kết hợp nhiều commit lại thành một commit duy nhất để lịch sử commit rõ ràng hơn.

```bash
git rebase -i HEAD~n  # Thay 'n' bằng số lượng commit
```

> **Ghi chú:** Thao tác này giúp bạn chỉnh sửa, gộp, hoặc bỏ qua các commit không cần thiết.

## 15. Xem Tệp Tại Một Commit Cụ Thể

**Chức năng:** Xem nội dung của một tệp tại thời điểm commit cụ thể, giúp kiểm tra trạng thái mã nguồn.

```bash
git show <commit-hash>:đường/dẫn/tới/tệp
```

## 16. Chỉnh Sửa `.gitignore` Sau Khi Commit

**Chức năng:** Nếu quên cập nhật `.gitignore`, bạn có thể chỉnh sửa và loại bỏ các tệp không cần thiết sau khi commit.

```bash
echo "node_modules/" >> .gitignore
git rm -r --cached node_modules/
git commit -m "Cập nhật .gitignore"
```

> **Ghi chú:** Lệnh này xóa tệp khỏi Git mà không xóa khỏi thư mục dự án.

## 17. Hoàn Tác Một Commit Đã Đẩy Lên

**Chức năng:** Hoàn tác các thay đổi từ một commit cụ thể mà không thay đổi lịch sử commit.

```bash
git revert <commit-hash>
```

## 18. Fetch Chỉ Metadata

**Chức năng:** Kiểm tra thay đổi mới trên remote mà không tải xuống toàn bộ dữ liệu.

```bash
git fetch --dry-run
```

## 19. Blame Một Dòng Code

**Chức năng:** Tìm thông tin ai đã chỉnh sửa từng dòng trong một tệp, giúp xác định người chịu trách nhiệm.

```bash
git blame đường/dẫn/tới/tệp
```

## 20. Reset Một Tệp Về Commit Cuối Cùng

**Chức năng:** Loại bỏ các thay đổi local cho một tệp cụ thể, khôi phục về trạng thái commit cuối.

```bash
git checkout -- đường/dẫn/tới/tệp
```

## Kết Luận

Với các lệnh Git trên, bạn có thể quản lý mã nguồn một cách hiệu quả và tự tin hơn trong mọi dự án. Việc làm chủ dòng lệnh Git sẽ mang lại sự linh hoạt và tiện lợi khi xử lý các tác vụ phức tạp.
