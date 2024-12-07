---
description: >-
  Bash (Bourne Again Shell) là một shell phổ biến trên các hệ điều hành Linux và
  macOS, được sử dụng rộng rãi để tự động hóa các tác vụ qua script.
---

# Bash Cheat Sheet: Tập hợp lệnh Bash cơ bản và nâng cao

Dưới đây là cheat sheet tổng hợp các lệnh Bash từ cơ bản đến nâng cao, giúp bạn làm việc hiệu quả hơn.

***

## **1. Các lệnh cơ bản trong Bash**

| **Lệnh**            | **Chức năng**                                      |
| ------------------- | -------------------------------------------------- |
| `pwd`               | Hiển thị đường dẫn thư mục hiện tại.               |
| `ls`                | Liệt kê các tệp và thư mục trong thư mục hiện tại. |
| `cd <thư-mục>`      | Chuyển đến thư mục khác.                           |
| `mkdir <thư-mục>`   | Tạo thư mục mới.                                   |
| `rm <tệp>`          | Xóa tệp.                                           |
| `rm -r <thư-mục>`   | Xóa thư mục và tất cả nội dung bên trong.          |
| `cp <nguồn> <đích>` | Sao chép tệp/thư mục từ nguồn đến đích.            |
| `mv <nguồn> <đích>` | Di chuyển hoặc đổi tên tệp/thư mục.                |
| `touch <tệp>`       | Tạo một tệp rỗng mới.                              |
| `echo "nội dung"`   | In nội dung ra màn hình.                           |
| `cat <tệp>`         | Hiển thị nội dung của tệp.                         |

***

## **2. Quản lý tệp và quyền**

| **Lệnh**                   | **Chức năng**                                                        |
| -------------------------- | -------------------------------------------------------------------- |
| `chmod +x <tệp>`           | Cấp quyền thực thi cho tệp.                                          |
| `chmod 755 <tệp>`          | Cấp quyền đọc/ghi/thực thi cho chủ sở hữu và chỉ đọc cho người khác. |
| `chown <người-dùng> <tệp>` | Thay đổi chủ sở hữu của tệp/thư mục.                                 |
| `ln -s <nguồn> <liên-kết>` | Tạo liên kết tượng trưng (symbolic link).                            |
| `df -h`                    | Hiển thị thông tin không gian đĩa.                                   |
| `du -sh <thư-mục>`         | Hiển thị kích thước thư mục.                                         |

***

## **3. Các toán tử trong Bash**

### **3.1. Toán tử điều kiện**

* So sánh số:
* ```bash
  [[ $a -eq $b ]]   # a bằng b
  [[ $a -ne $b ]]   # a không bằng b
  [[ $a -gt $b ]]   # a lớn hơn b
  [[ $a -lt $b ]]   # a nhỏ hơn b
  [[ $a -ge $b ]]   # a lớn hơn hoặc bằng b
  [[ $a -le $b ]]   # a nhỏ hơn hoặc bằng b
  ```
* So sánh chuỗi:
* ```bash
  [[ $a == $b ]]    # a bằng b
  [[ $a != $b ]]    # a không bằng b
  [[ -z $a ]]       # Chuỗi a rỗng
  ```

### **3.2. Toán tử logic**

```bash
[[ $a -eq 1 && $b -eq 2 ]]  # AND
[[ $a -eq 1 || $b -eq 2 ]]  # OR
! [[ $a -eq 1 ]]            # NOT
```

***

## **4. Vòng lặp trong Bash**

### **4.1. Vòng lặp for**

```bash
for i in 1 2 3; do
    echo "Số: $i"
done
```

### **4.2. Vòng lặp while**

```bash
counter=1
while [[ $counter -le 5 ]]; do
    echo "Đếm: $counter"
    ((counter++))
done
```

### **4.3. Vòng lặp until**

```bash
counter=1
until [[ $counter -gt 5 ]]; do
    echo "Đếm: $counter"
    ((counter++))
done
```

***

## **5. Hàm trong Bash**

Hàm giúp bạn tái sử dụng mã lệnh một cách dễ dàng:

```bash
function say_hello() {
    echo "Xin chào, $1!"
}

say_hello "Bash"
```

***

## **6. Quản lý quy trình (Process Management)**

| **Lệnh**     | **Chức năng**                                |
| ------------ | -------------------------------------------- |
| `ps`         | Hiển thị danh sách các process đang chạy.    |
| `top`        | Giám sát hệ thống và các process.            |
| `kill <PID>` | Dừng một process theo PID.                   |
| `jobs`       | Hiển thị các job đang chạy nền.              |
| `fg %1`      | Chuyển job nền số 1 ra chạy foreground.      |
| `bg %1`      | Tiếp tục chạy job nền số 1 trong background. |

***

## **7. Xử lý chuỗi**

| **Lệnh**                 | **Chức năng**                                  |
| ------------------------ | ---------------------------------------------- |
| `${#variable}`           | Độ dài của chuỗi trong biến.                   |
| `${variable:3:5}`        | Lấy chuỗi con từ vị trí 3, độ dài 5.           |
| `${variable%%pattern}`   | Xóa phần trùng khớp với pattern từ cuối chuỗi. |
| `tr 'a-z' 'A-Z'`         | Chuyển chữ thường thành chữ hoa.               |
| `grep "pattern" <tệp>`   | Tìm kiếm pattern trong file.                   |
| `awk '{print $1}' <tệp>` | Lấy cột đầu tiên từ file.                      |

***

## **8. Xử lý tệp nén**

| **Lệnh**                | **Chức năng**                        |
| ----------------------- | ------------------------------------ |
| `tar -cvf file.tar dir` | Nén thư mục `dir` thành file `.tar`. |
| `tar -xvf file.tar`     | Giải nén file `.tar`.                |
| `gzip file`             | Nén file thành `.gz`.                |
| `gunzip file.gz`        | Giải nén file `.gz`.                 |

***

## **9. Tạo Autocomplete trong Bash**

Bash cho phép bạn tùy chỉnh autocomplete để tăng hiệu quả làm việc.

Ví dụ: Tạo autocomplete cho lệnh `mycommand`:

1.  Thêm vào file `/etc/bash_completion.d/mycommand`:

    <pre class="language-bash"><code class="lang-bash"><strong>_mycommand() {
    </strong>    COMPREPLY=($(compgen -W "start stop restart" -- "${COMP_WORDS[1]}"))
    }
    complete -F _mycommand mycommand
    </code></pre>
2.  Load lại bash:

    ```bash
    source ~/.bashrc
    ```

Khi gõ `mycommand`, Bash sẽ hiển thị gợi ý `start`, `stop`, hoặc `restart`.

***

## **Kết luận**

Bash là một công cụ mạnh mẽ giúp tự động hóa và quản lý hệ thống hiệu quả. Cheat sheet này sẽ giúp bạn nắm bắt nhanh các lệnh và kỹ thuật quan trọng trong Bash. Hãy lưu lại và thực hành để làm chủ Bash! 🚀



{% code title="Tài liệu tham khảo:" overflow="wrap" lineNumbers="true" %}
```http
https://devdocs.io/bash/a-programmable-completion-example
```
{% endcode %}

