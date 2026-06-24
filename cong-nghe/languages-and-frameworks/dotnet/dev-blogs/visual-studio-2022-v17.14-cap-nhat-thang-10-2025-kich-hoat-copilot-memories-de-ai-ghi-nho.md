# Visual Studio 2022 v17.14 (Cập nhật tháng 10/2025) – Kích hoạt Copilot Memories để AI “ghi nhớ”

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/refs/heads/main/gitbook/blogs/cong-nghe/visual-studio-2022-v17.14-copilot-memories.png" alt=""><figcaption><p>Copilot Memories</p></figcaption></figure>

### 🌟 Giới thiệu

[GitHub Copilot](/broken/spaces/wRgsH8wC380GwDCPj7gi/pages/fUK0s5t9IQkASJfoNuDZ) đã trở thành “người bạn đồng hành” quen thuộc với lập trình viên – giúp viết code nhanh hơn, ít lỗi hơn.\
Nhưng trong bản **Visual Studio 2022 v17.14 (tháng 10/2025)**, Copilot đã tiến thêm một bước rất lớn: **nó bắt đầu có trí nhớ.**

Tính năng mới có tên **Copilot Memories**, cho phép AI hiểu và ghi nhớ **cách bạn – hoặc cả nhóm của bạn – làm việc**.\
Điều đó nghĩa là:

* Nếu bạn thường xuyên chỉnh sửa cách Copilot gợi ý, nó sẽ “học” và nhớ.
* Nếu bạn bảo “hãy nhớ dùng `PascalCase` cho class”, nó sẽ ghi nhận và áp dụng.
* Nếu nhóm bạn có quy tắc riêng về cấu trúc thư mục, cách đặt tên, format code… Copilot có thể **ghi nhớ, tái sử dụng và chia sẻ lại cho cả team**.

***

### ⚙️ Copilot Memories hoạt động như thế nào?

Khi bạn sử dụng Copilot Chat, hệ thống sẽ lắng nghe và ghi nhận **những tín hiệu thể hiện quy chuẩn làm việc của bạn**:

* Khi bạn **chỉnh lại đoạn code mà Copilot đề xuất** → AI hiểu bạn có quy tắc riêng.
* Khi bạn **nhắc Copilot nhớ điều gì đó** → nó hiển thị thông báo “Save this preference?” để bạn xác nhận.
* Khi bạn xác nhận, Copilot sẽ lưu “trí nhớ” đó vào **3 loại tệp cấu hình quen thuộc**:

| Loại tệp          | Chức năng                                                         | Ví dụ nội dung                                                            |
| ----------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `.editorconfig`   | Lưu quy tắc định dạng code, đặt tên biến, dấu cách, dòng trống... | “Luôn dùng tab = 4 spaces, đặt tên class dạng PascalCase”                 |
| `CONTRIBUTING.md` | Ghi lại quy trình làm việc, chuẩn commit, review, guideline nhóm  | “Khi thêm tính năng mới, tạo branch `feature/...` và viết test kèm theo.” |
| `README.md`       | Cung cấp thông tin tổng quan, mô tả dự án                         | “Dự án quản lý khách hàng nội bộ, dùng ASP.NET Core + SQL Server.”        |

Nhờ vậy, Copilot không chỉ hỗ trợ bạn trong một file code, mà **tuân thủ nhất quán toàn bộ văn hóa kỹ thuật của team**.

***

### 🔧 Hướng dẫn bật tính năng Copilot Memories trong Visual Studio

Thao tác rất đơn giản – chỉ vài bước là xong:

#### **Bước 1: Mở Visual Studio 2022**

Chọn menu:\
`Tools → Options → GitHub → Copilot → Copilot Chat`

#### **Bước 2: Bật tùy chọn ghi nhớ**

Tích chọn dòng:

> ✅ _Enable custom instructions to be loaded from .github/instructions/_.instructions.md files and added to requests.\*

Tính năng này cho phép Copilot đọc các tệp hướng dẫn bạn viết trong dự án.

#### **Bước 3: Tạo thư mục chứa hướng dẫn**

Trong thư mục gốc của project, tạo đường dẫn:

```
.github/instructions/
```

***

### 📝 Bước 4: Viết file hướng dẫn đầu tiên (.instructions.md)

Dưới đây là ví dụ file thực tế mà bạn có thể copy – dán và chỉnh sửa theo dự án của mình.

#### 🔹 **File: `.github/instructions/csharp-guidelines.instructions.md`**

```markdown
applyTo: **/*.cs

---
# Quy tắc C# nội bộ của nhóm NQDEV

## 1. Cấu trúc và định dạng
- Luôn dùng 4 khoảng trắng cho mỗi tab.
- Mỗi class, interface, enum phải nằm trong file riêng.
- Không sử dụng `var` nếu kiểu dữ liệu không rõ ràng.

## 2. Đặt tên
- Class, Interface: PascalCase.
- Biến, thuộc tính: camelCase.
- Hằng số: SNAKE_UPPERCASE.
- File phải cùng tên với class chính trong đó.

## 3. Bình luận & tài liệu
- Thêm XML comment (`///`) cho public method.
- Viết mô tả ngắn gọn, nêu rõ mục đích hàm.

## 4. Thực hành tốt
- Khi tạo API mới, viết unit test kèm theo.
- Không push code lên `main` trực tiếp – chỉ thông qua pull request.

## 5. Tham chiếu
- Xem thêm quy tắc chi tiết trong file `CONTRIBUTING.md`.
```

> 💡 **Giải thích nhanh:**
>
> * `applyTo: **/*.cs` nghĩa là file này áp dụng cho **mọi file C#** trong dự án.
> * Copilot sẽ **đọc và tuân theo các quy tắc trong file này khi gợi ý code**.
> * Bạn có thể tạo thêm nhiều file khác, ví dụ:
>   * `api-guidelines.instructions.md`
>   * `frontend-style.instructions.md`

***

### 🧩 Bước 5: Dùng Copilot Chat để “dạy” AI hiểu hướng dẫn

Sau khi tạo file xong, mở cửa sổ **Copilot Chat** và gõ lệnh:

```
@copilot read .github/instructions/csharp-guidelines.instructions.md
```

Hoặc đơn giản hơn, chỉ cần bắt đầu chat với Copilot như bình thường:

> “Hãy dùng chuẩn đặt tên trong hướng dẫn nội bộ nhé.”

Copilot sẽ tự động nhận diện file `.instructions.md` và **áp dụng quy tắc khi gợi ý code**.

***

### 🚀 Kết luận

Với **Copilot Memories**, GitHub Copilot không còn chỉ là AI viết code, mà trở thành **trợ lý lập trình có trí nhớ**, hiểu rõ từng quy tắc và thói quen của đội ngũ.

Bạn chỉ cần thiết lập một lần – sau đó, mọi thành viên trong dự án đều nhận được cùng trải nghiệm thống nhất, đồng bộ và chuyên nghiệp.

👉 **Hãy thử ngay hôm nay trên Visual Studio 2022 v17.14** để biến Copilot thành “đồng đội” thực thụ – biết cách bạn muốn code, và giúp bạn duy trì chất lượng dự án ở mức cao nhất.
