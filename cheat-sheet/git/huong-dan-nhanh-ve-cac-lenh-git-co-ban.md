---
description: >-
  Git là một công cụ quản lý mã nguồn mạnh mẽ, nhưng với rất nhiều lệnh và tùy
  chọn, việc ghi nhớ tất cả có thể là một thách thức.
---

# Hướng Dẫn Nhanh về Các Lệnh Git Cơ Bản

**Cheat sheet** (bảng tóm tắt) về Git sẽ giúp bạn dễ dàng tra cứu và sử dụng các lệnh một cách hiệu quả. Dưới đây là hướng dẫn chi tiết về các lệnh cơ bản mà bạn cần biết.

### 1. Cài Đặt và Cấu Hình

#### Cài đặt Git

Đầu tiên, bạn cần cài đặt Git. Truy cập trang [git-scm.com](https://git-scm.com) để tải và cài đặt cho hệ điều hành của bạn.

#### Cấu hình người dùng

```bash
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"
```

Lệnh trên giúp bạn thiết lập thông tin người dùng cho các commit.

### 2. Khởi Tạo và Clone Dự Án

#### Khởi tạo kho mới

```bash
git init
```

Lệnh này tạo một kho Git mới trong thư mục hiện tại.

Clone kho từ xa

```bash
git clone <url>
```

Sao chép một kho Git từ xa về máy tính của bạn.

### 3. Quản Lý Thay Đổi

#### Thêm thay đổi vào staging area

```bash
git add <file>
```

Hoặc để thêm tất cả các thay đổi:

```bash
git add .
```

#### Kiểm tra trạng thái

```bash
git status
```

Hiển thị các thay đổi đã được staged, unstaged và untracked.

#### Commit các thay đổi

```bash
git commit -m "Thông điệp commit"
```

Lưu lại các thay đổi với một thông điệp mô tả.

#### Xem lịch sử commit

```bash
git log
```

Hiển thị danh sách các commit trong kho.

### 4. Quản Lý Nhánh

#### Tạo nhánh mới

```bash
git branch <tên-nhánh>
```

#### Chuyển đổi nhánh

```bash
git checkout <tên-nhánh>
```

#### Tạo và chuyển đổi nhánh cùng lúc

```bash
git checkout -b <tên-nhánh>
```

#### Hợp nhất nhánh

```bash
git merge <tên-nhánh>
```

Hợp nhất nhánh chỉ định vào nhánh hiện tại.

### 5. Chia Sẻ Thay Đổi

#### Đẩy thay đổi lên kho từ xa

```bash
git push origin <tên-nhánh>
```

#### Cập nhật từ kho từ xa

```bash
git pull origin <tên-nhánh>
```

Kéo thay đổi từ kho từ xa về nhánh hiện tại.

### 6. So Sánh và Kiểm Tra

#### So sánh thay đổi

```bash
git diff
```

Xem sự khác biệt giữa các thay đổi chưa được staged.

#### Xem sự khác biệt giữa commit

```bash
git diff <commit1> <commit2>
```

### 7. Gỡ Rối

#### Xem ai đã thay đổi từng dòng

```bash
git blame <file>
```

#### Tìm kiếm trong lịch sử commit

```bash
git grep <từ khóa>
```

### 8. Quản Lý Remote

#### Kiểm tra danh sách remote

```bash
git remote -v
```

#### Thêm remote mới

```bash
git remote add <tên> <url>
```

#### Xóa remote

```bash
git remote remove <tên>
```

### 9. Các Lệnh Khác

#### Khôi phục file

```bash
git restore <file>
```

#### Xóa file khỏi staging

```bash
git reset <file>
```

#### Xem thông tin về một commit cụ thể

```bash
git show <commit-id>
```

### Kết Luận

Bảng tóm tắt lệnh Git (cheat sheet) là một công cụ hữu ích giúp bạn dễ dàng tra cứu và sử dụng các lệnh cần thiết trong quá trình phát triển. Bằng cách nắm vững các lệnh cơ bản này, bạn sẽ có thể quản lý mã nguồn hiệu quả hơn. Hãy thực hành thường xuyên để trở thành một người dùng Git tự tin!
