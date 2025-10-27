# smem – Công cụ đo lường bộ nhớ chính xác hơn trên Linux

Nếu bạn từng dùng các lệnh như `top`, `htop` hay `ps` để xem tiến trình đang “ngốn” bao nhiêu RAM mà vẫn cảm thấy kết quả không thật sự rõ ràng, thì **`smem`** chính là “chìa khóa” giúp bạn hiểu sâu hơn về cách bộ nhớ được sử dụng trên hệ thống Linux.

***

#### 💡 1. smem là gì?

`smem` là một tiện ích dòng lệnh giúp **phân tích mức sử dụng bộ nhớ** của các tiến trình một cách chính xác hơn so với các công cụ truyền thống.

Điểm đặc biệt của smem là nó **tính toán hợp lý phần bộ nhớ chia sẻ** giữa các tiến trình bằng các chỉ số như:

| Trường                          | Ý nghĩa                                                                              |
| ------------------------------- | ------------------------------------------------------------------------------------ |
| **USS (Unique Set Size)**       | Lượng RAM mà **chỉ tiến trình này** dùng, không chia sẻ với ai khác.                 |
| **PSS (Proportional Set Size)** | Lượng RAM **được chia sẻ theo tỷ lệ** giữa các tiến trình cùng sử dụng trang bộ nhớ. |
| **RSS (Resident Set Size)**     | Tổng RAM mà tiến trình chiếm trong bộ nhớ vật lý (không tính chia sẻ).               |
| **VSS (Virtual Set Size)**      | Tổng bộ nhớ ảo được ánh xạ, bao gồm cả phần không thực sự chiếm RAM.                 |
| **SWAP**                        | Lượng bộ nhớ bị đẩy ra vùng swap (khi RAM không đủ).                                 |

> 🔸 Tóm gọn:
>
> * **USS** → “RAM thật sự dùng riêng”.
> * **PSS** → “RAM chia sẻ công bằng”.
> * **RSS** → “RAM chiếm thực tế”.

***

#### ⚙️ 2. Cài đặt smem

Tùy vào bản phân phối Linux bạn đang dùng:

**Trên Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install smem
```

**Trên CentOS/RHEL:**

```bash
sudo yum install smem
```

***

#### 👀 3. Cách xem mức sử dụng RAM theo tiến trình

Lệnh cơ bản:

```bash
smem -r -k -c "pid user name uss pss rss swap"
```

**Giải thích:**

* `-r`: chạy với quyền root để thu thập đủ dữ liệu
* `-k`: hiển thị theo đơn vị KB
* `-c`: chọn các cột hiển thị

***

#### 📊 4. Sắp xếp tiến trình theo mức RAM tiêu thụ

Muốn biết tiến trình nào “ngốn” RAM nhất?\
Hãy sắp xếp theo cột `USS` (RAM dùng riêng):

```bash
smem -r -k -c "pid user name uss pss rss swap" | sort -nk4 -r | head -20
```

* `sort -nk4 -r`: sắp xếp giảm dần theo cột thứ 4 (USS)
* `head -20`: chỉ hiển thị 20 dòng đầu

***

#### 📤 5. Xuất dữ liệu ra CSV để phân tích hoặc vẽ biểu đồ

```bash
smem -r -k -c "pid user name uss pss rss swap" > smem_output.csv
```

Sau đó, bạn có thể mở file bằng Excel hoặc gửi dữ liệu đó để trực quan hóa (ví dụ: vẽ biểu đồ RAM/SWAP theo tiến trình).

***

#### 🧠 6. Vì sao nên dùng smem thay vì top/ps?

| Tiêu chí                             | top/ps                    | smem                       |
| ------------------------------------ | ------------------------- | -------------------------- |
| Độ chính xác khi chia sẻ bộ nhớ      | ❌ Không phân bổ chính xác | ✅ Chia sẻ theo tỷ lệ (PSS) |
| Hiển thị bộ nhớ swap                 | ❌ Không luôn có           | ✅ Có                       |
| Báo cáo theo người dùng / tiến trình | ❌ Giới hạn                | ✅ Chi tiết, dễ tổng hợp    |
| Hỗ trợ xuất dữ liệu                  | ❌ Không                   | ✅ Có (CSV, đồ thị)         |

Nhờ đó, smem đặc biệt hữu ích trong **phân tích hiệu năng hệ thống**, **tối ưu ứng dụng**, hay **kiểm tra rò rỉ bộ nhớ** trong môi trường production.

***

#### 🧭 Kết luận

`smem` không chỉ giúp bạn **biết tiến trình nào đang “ngốn” RAM**, mà còn **hiểu được cách Linux phân bổ bộ nhớ thực sự**.\
Nếu bạn là sysadmin, devops, hay đơn giản chỉ muốn tối ưu hệ thống của mình, hãy thử `smem` — công cụ nhỏ gọn nhưng mang lại **góc nhìn rất “sâu”** về bộ nhớ Linux.

> 💬 Gợi ý: Hãy xuất dữ liệu từ `smem` thành file `.csv` và gửi lên — mình có thể giúp bạn **vẽ biểu đồ phân tích RAM/SWAP theo tiến trình** để nhìn rõ hơn bức tranh tổng thể hệ thống.
