# Cách Tối Ưu Hóa Kích Thước Thư Mục .git

Nếu bạn đang gặp vấn đề với kích thước thư mục `.git` trong dự án Git của mình, có một số cách để tối ưu hóa và giảm dung lượng. Dưới đây là các phương pháp hiệu quả nhất:

## **1. Dọn Dẹp Thư Mục `.git`**

Git cung cấp các lệnh để dọn dẹp và nén dữ liệu trong thư mục `.git`.

### **1.1 `git gc`**

Lệnh `git gc` (Garbage Collection) thu dọn rác và nén dữ liệu không cần thiết.

```bash
bashSao chép mãgit gc
```

Sử dụng `--aggressive` để nén mạnh mẽ hơn.

```bash
bashSao chép mãgit gc --aggressive
```

### **1.2 `git prune`**

Lệnh `git prune` loại bỏ các đối tượng không còn tham chiếu từ bất kỳ nhánh nào.

```bash
bashSao chép mãgit prune
```

## **2. Loại Bỏ Các Tệp Lớn và Lịch Sử Không Cần Thiết**

Nếu bạn có các tệp lớn hoặc không cần thiết trong lịch sử Git, bạn có thể loại bỏ chúng.

### **2.1 `BFG Repo-Cleaner`**

BFG Repo-Cleaner là công cụ mạnh mẽ và dễ sử dụng hơn `git filter-branch` để loại bỏ các tệp lớn khỏi lịch sử Git.

1. Tải xuống BFG Repo-Cleaner từ trang chính thức.
2. Sử dụng BFG để loại bỏ các tệp lớn hơn 100MB:

```bash
bashSao chép mãjava -jar bfg.jar --strip-blobs-bigger-than 100M your-repo.git
```

3. Chạy `git gc` để thu dọn rác.

```bash
bashSao chép mãgit gc --prune=now --aggressive
```

### **2.2 `git filter-repo`**

`git filter-repo` là công cụ linh hoạt để loại bỏ các tệp hoặc thư mục không mong muốn khỏi lịch sử Git.

1. Cài đặt `git filter-repo` (nếu chưa có).

```bash
bashSao chép mãpip install git-filter-repo
```

2. Loại bỏ một thư mục cụ thể:

```bash
bashSao chép mãgit filter-repo --path path/to/remove --invert-paths
```

## **3. Sử Dụng Git Large File Storage (LFS)**

Nếu bạn cần lưu trữ các tệp lớn trong repo, cân nhắc sử dụng Git LFS để quản lý chúng.

1. Cài đặt Git LFS.

```bash
bashSao chép mãgit lfs install
```

2. Theo dõi các tệp lớn bằng Git LFS.

```bash
bashSao chép mãgit lfs track "*.psd"
```

3. Thêm và cam kết các tệp lớn như bình thường.

```bash
bashSao chép mãgit add .gitattributes
git add path/to/large/file.psd
git commit -m "Add large file with Git LFS"
```

## **4. Loại Bỏ Các Nhánh Không Cần Thiết**

Các nhánh không còn sử dụng cũng có thể chiếm dung lượng. Hãy kiểm tra và loại bỏ các nhánh không cần thiết.

1. Xóa nhánh cục bộ.

```bash
bashSao chép mãgit branch -d branch_name
```

2. Xóa nhánh từ xa.

```bash
bashSao chép mãgit push origin --delete branch_name
```

## Tóm Lại

Tối ưu hóa kích thước thư mục `.git` bao gồm việc sử dụng các lệnh Git tích hợp như `git gc` và `git prune`, sử dụng các công cụ bên ngoài như BFG Repo-Cleaner và `git filter-repo` để loại bỏ các tệp lớn và không cần thiết, sử dụng Git LFS để quản lý các tệp lớn, và loại bỏ các nhánh không cần thiết. Những phương pháp này giúp giảm kích thước thư mục `.git` và cải thiện hiệu suất của repo Git của bạn.
