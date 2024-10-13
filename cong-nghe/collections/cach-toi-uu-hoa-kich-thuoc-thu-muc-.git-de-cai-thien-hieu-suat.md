# Cách tối ưu hóa kích thước thư mục .git để cải thiện hiệu suất

Khi làm việc với Git, đặc biệt là các dự án lớn hoặc có lịch sử dài, thư mục `.git` có thể chiếm dung lượng đáng kể, ảnh hưởng đến hiệu suất. Bài viết này sẽ hướng dẫn bạn các phương pháp tối ưu hóa kích thước thư mục `.git`, giúp giảm dung lượng và cải thiện hiệu suất cho repo của mình.

## 1. Dọn Dẹp Thư Mục `.git` Với Các Lệnh Git Tích Hợp

Git cung cấp một số lệnh tích hợp để dọn dẹp và nén dữ liệu không cần thiết trong thư mục `.git`. Các lệnh này rất hữu ích để giảm dung lượng lưu trữ.

### **1.1. Sử Dụng `git gc` (Garbage Collection)**

Lệnh `git gc` giúp thu dọn rác và nén dữ liệu không cần thiết trong Git, giúp tối ưu hóa kích thước thư mục `.git`.

* Chạy lệnh cơ bản để thu dọn rác:

```bash
git gc
```

* Sử dụng tùy chọn `--aggressive` để thực hiện nén mạnh mẽ hơn. Tuy nhiên, thao tác này có thể mất nhiều thời gian hơn.

```bash
git gc --aggressive
```

### **1.2. Sử Dụng `git prune`**

Lệnh `git prune` loại bỏ các đối tượng không còn tham chiếu từ bất kỳ nhánh nào trong repo. Điều này giúp loại bỏ các dữ liệu dư thừa, giảm kích thước thư mục `.git`.

* Chạy lệnh `git prune` để loại bỏ các đối tượng không cần thiết:

```bash
git prune
```

## 2. Loại Bỏ Các Tệp Lớn Và Lịch Sử Không Cần Thiết

Khi repo của bạn chứa các tệp lớn hoặc các tệp không còn cần thiết, việc giữ chúng trong lịch sử Git có thể làm tăng đáng kể kích thước thư mục `.git`. Dưới đây là một số công cụ để loại bỏ chúng.

### **2.1. BFG Repo-Cleaner**

**BFG Repo-Cleaner** là một công cụ mạnh mẽ và dễ sử dụng hơn `git filter-branch`, cho phép bạn loại bỏ các tệp lớn khỏi lịch sử Git một cách nhanh chóng.

* Đầu tiên, tải xuống **BFG Repo-Cleaner** từ trang chính thức.
* Loại bỏ các tệp lớn hơn 100MB khỏi lịch sử bằng lệnh:

```bash
java -jar bfg.jar --strip-blobs-bigger-than 100M your-repo.git
```

* Sau đó, chạy lệnh `git gc` để thu dọn rác:

```bash
git gc --prune=now --aggressive
```

### **2.2. Sử Dụng `git filter-repo`**

**`git filter-repo`** là công cụ linh hoạt hơn `git filter-branch`, giúp loại bỏ các tệp hoặc thư mục không mong muốn khỏi lịch sử Git.

* Để sử dụng, bạn cần cài đặt `git filter-repo` nếu chưa có:

```bash
pip install git-filter-repo
```

* Loại bỏ một thư mục cụ thể khỏi lịch sử với lệnh:

```bash
git filter-repo --path path/to/remove --invert-paths
```

## 3. Sử Dụng Git Large File Storage (LFS)

Nếu bạn cần lưu trữ các tệp lớn trong repo, cân nhắc sử dụng **Git LFS** để quản lý chúng. Git LFS lưu trữ các tệp lớn ngoài repo chính, giúp giảm kích thước thư mục `.git`.

* Cài đặt Git LFS:

```bash
git lfs install
```

* Theo dõi các tệp lớn bằng Git LFS. Ví dụ: theo dõi các tệp `.psd`:

```bash
git lfs track "*.psd"
```

* Sau đó, thêm và cam kết các tệp lớn như bình thường:

```bash
git add .gitattributes
git add path/to/large/file.psd
git commit -m "Add large file with Git LFS"
```

## 4. Loại Bỏ Các Nhánh Không Cần Thiết

Các nhánh không còn sử dụng cũng có thể chiếm dung lượng. Hãy kiểm tra và loại bỏ các nhánh không cần thiết để tối ưu hóa repo.

* Xóa nhánh cục bộ:

```bash
git branch -d branch_name
```

* Xóa nhánh từ xa:

```bash
git push origin --delete branch_name
```

## Kết Luận

Tối ưu hóa kích thước thư mục `.git` là việc cần thiết để cải thiện hiệu suất của repo Git, đặc biệt là đối với các dự án lớn. Các phương pháp như sử dụng `git gc`, `git prune`, BFG Repo-Cleaner, `git filter-repo`, và Git LFS sẽ giúp giảm dung lượng thư mục `.git` và tối ưu hóa quản lý dữ liệu trong repo của bạn. Hãy thường xuyên kiểm tra và dọn dẹp repo để duy trì hiệu suất tốt nhất.

Nếu bạn cần thêm hỗ trợ hoặc có bất kỳ câu hỏi nào về tối ưu hóa Git, đừng ngần ngại liên hệ với chúng tôi!

