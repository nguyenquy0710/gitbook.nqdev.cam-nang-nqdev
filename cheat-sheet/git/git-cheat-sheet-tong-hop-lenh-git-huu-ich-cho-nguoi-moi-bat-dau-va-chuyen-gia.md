---
description: >-
  Git là một hệ thống quản lý phiên bản phân tán (VCS) phổ biến nhất hiện nay.
  Nó giúp lập trình viên theo dõi thay đổi của mã nguồn và làm việc hiệu quả với
  nhóm.
---

# Git Cheat Sheet: Tổng hợp lệnh Git hữu ích cho người mới bắt đầu và chuyên gia

Dưới đây là **Git Cheat Sheet** tổng hợp các lệnh quan trọng và mẹo sử dụng Git hiệu quả.

***

## **1. Git là gì?**

Git là một công cụ để:

* Theo dõi lịch sử thay đổi của mã nguồn.
* Làm việc nhóm một cách đồng bộ, tránh xung đột.
* Hỗ trợ rollback để khôi phục lại phiên bản trước đó.

***

## **2. Cài đặt và cấu hình Git**

### **Cài đặt Git**

* **Ubuntu**:
* ```bash
  sudo apt update
  sudo apt install git
  ```
* **Windows/MacOS**: Tải từ [git-scm.com](https://git-scm.com/).

### **Cấu hình Git**

* Thiết lập tên và email:
* ```bash
  git config --global user.name "Tên của bạn"
  git config --global user.email "email@example.com"
  ```
* Xem cấu hình hiện tại:
* ```bash
  git config --list
  ```

***

## **3. Các lệnh cơ bản trong Git**

| **Lệnh**                     | **Chức năng**                                           |
| ---------------------------- | ------------------------------------------------------- |
| `git init`                   | Tạo một repository Git mới.                             |
| `git clone <url>`            | Sao chép repository từ remote về máy cục bộ.            |
| `git status`                 | Kiểm tra trạng thái hiện tại của các tệp trong thư mục. |
| `git add <file>`             | Thêm tệp vào staging area.                              |
| `git add .`                  | Thêm tất cả các tệp đã thay đổi vào staging area.       |
| `git commit -m "Thông điệp"` | Lưu các thay đổi vào repository với thông điệp.         |
| `git log`                    | Xem lịch sử commit.                                     |
| `git diff`                   | So sánh sự khác biệt giữa các thay đổi chưa commit.     |

***

## **4. Làm việc với Branch (Nhánh)**

| **Lệnh**                      | **Chức năng**                               |
| ----------------------------- | ------------------------------------------- |
| `git branch`                  | Hiển thị tất cả các nhánh hiện có.          |
| `git branch <tên-nhánh>`      | Tạo một nhánh mới.                          |
| `git checkout <tên-nhánh>`    | Chuyển sang nhánh khác.                     |
| `git checkout -b <tên-nhánh>` | Tạo và chuyển ngay sang nhánh mới.          |
| `git merge <tên-nhánh>`       | Gộp nhánh được chỉ định vào nhánh hiện tại. |
| `git branch -d <tên-nhánh>`   | Xóa một nhánh (đã gộp).                     |

***

## **5. Làm việc với Remote (Kho từ xa)**

| **Lệnh**                      | **Chức năng**                                                           |
| ----------------------------- | ----------------------------------------------------------------------- |
| `git remote add origin <url>` | Kết nối repository cục bộ với repository từ xa (remote).                |
| `git remote -v`               | Hiển thị danh sách các remote đang kết nối.                             |
| `git push origin <tên-nhánh>` | Đẩy nhánh hiện tại lên remote.                                          |
| `git pull origin <tên-nhánh>` | Lấy thay đổi từ remote và hợp nhất vào nhánh hiện tại.                  |
| `git fetch origin`            | Lấy toàn bộ thay đổi từ remote nhưng không hợp nhất vào nhánh hiện tại. |

***

## **6. Undo (Hoàn tác các thay đổi)**

| **Lệnh**                         | **Chức năng**                                                      |
| -------------------------------- | ------------------------------------------------------------------ |
| `git checkout -- <file>`         | Khôi phục tệp về trạng thái trước đó (chưa thêm vào staging area). |
| `git reset HEAD <file>`          | Gỡ tệp khỏi staging area.                                          |
| `git reset --soft <commit-hash>` | Quay lại commit cũ, giữ thay đổi ở staging area.                   |
| `git reset --hard <commit-hash>` | Quay lại commit cũ, xóa tất cả thay đổi.                           |
| `git revert <commit-hash>`       | Tạo commit mới để hoàn tác thay đổi từ commit được chỉ định.       |

***

## **7. Các lệnh Git nâng cao**

| **Lệnh**                        | **Chức năng**                                          |
| ------------------------------- | ------------------------------------------------------ |
| `git stash`                     | Lưu tạm thời các thay đổi chưa commit.                 |
| `git stash apply`               | Áp dụng lại thay đổi từ stash.                         |
| `git stash drop`                | Xóa một stash đã lưu.                                  |
| `git tag <tag-name>`            | Tạo một tag (dán nhãn) cho commit hiện tại.            |
| `git cherry-pick <commit-hash>` | Sao chép một commit từ nhánh khác sang nhánh hiện tại. |

***

## **8. Xem lịch sử và theo dõi thay đổi**

| **Lệnh**                 | **Chức năng**                            |
| ------------------------ | ---------------------------------------- |
| `git log`                | Hiển thị lịch sử commit.                 |
| `git log --oneline`      | Hiển thị lịch sử commit ở dạng rút gọn.  |
| `git blame <file>`       | Xem ai đã thay đổi từng dòng trong file. |
| `git show <commit-hash>` | Hiển thị chi tiết một commit.            |

***

## **9. Mẹo sử dụng Git hiệu quả**

1. **Viết thông điệp commit rõ ràng**:
   * Thay vì `git commit -m "fix"`, hãy dùng `git commit -m "Fix lỗi đăng nhập khi nhập mật khẩu sai"`.
2. **Sử dụng `.gitignore`**:
   * Tạo file `.gitignore` để bỏ qua các tệp hoặc thư mục không cần theo dõi:
   * ```
     node_modules/
     *.log
     .env
     ```
3. **Thường xuyên kiểm tra trạng thái**:
   * Lệnh `git status` giúp bạn biết rõ các thay đổi nào đã được thêm vào staging và chưa commit.
4. **Pull trước khi Push**:
   * Tránh xung đột bằng cách luôn chạy `git pull` trước khi `git push`.

***

## **10. Git Flow (Quy trình nhánh)**

Git Flow là mô hình phân nhánh phổ biến, yêu cầu cài đặt thêm `git-flow` (AVH Edition).

* Cài đặt (Ubuntu):
* ```bash
  sudo apt install git-flow
  ```

| **Lệnh**                               | **Chức năng**                                                          |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `git flow init`                        | Khởi tạo Git Flow, hỏi tương tác tên các nhánh (master/develop/...).  |
| `git flow init -d`                     | Khởi tạo Git Flow với các giá trị mặc định, không hỏi tương tác.      |
| `git flow feature start <tên>`          | Tạo nhánh feature mới từ develop.                                      |
| `git flow feature finish <tên>`        | Gộp feature vào develop và xóa nhánh feature.                          |
| `git flow release start <version>`      | Tạo nhánh release từ develop.                                          |
| `git flow release finish <version>`    | Gộp release vào master và develop, tạo tag.                            |
| `git flow hotfix start <version>`      | Tạo nhánh hotfix từ master.                                            |
| `git flow hotfix finish <version>`     | Gộp hotfix vào master và develop, tạo tag.                            |

> **Mẹo:** Dùng `git flow init -d` khi muốn thiết lập nhanh với tên nhánh mặc định (`master`, `develop`, `feature/`, `release/`, `hotfix/`, `support/`, `versiontag`), tránh phải trả lời từng câu hỏi.

***

## **11. Tài nguyên tham khảo**

* [Git Cheat Sheet của GitHub](https://education.github.com/git-cheat-sheet-education.pdf)
* [Git Cheat Sheet của GitLab](https://about.gitlab.com/images/press/git-cheat-sheet.pdf)
* [Git Cheat Sheet trên Viblo](https://viblo.asia/p/git-cheat-sheet-bo-suu-tap-cac-lenh-thuong-xuyen-duoc-su-dung-nhat-Az45bGXQKxY)
* [Git Cheat Sheet trên GeeksForGeeks](https://www.geeksforgeeks.org/git-cheat-sheet/)

***

## **Kết Luận**

Git là công cụ không thể thiếu đối với bất kỳ lập trình viên nào. Cheat sheet này sẽ giúp bạn nắm bắt các lệnh quan trọng và tối ưu hóa quy trình làm việc của mình. Hãy lưu lại và thực hành thường xuyên để làm chủ Git! 🚀
