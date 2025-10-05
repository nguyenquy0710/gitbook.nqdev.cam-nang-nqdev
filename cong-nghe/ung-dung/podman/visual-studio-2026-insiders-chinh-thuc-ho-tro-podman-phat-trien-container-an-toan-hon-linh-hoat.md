# Visual Studio 2026 Insiders chính thức hỗ trợ Podman – Phát triển container an toàn hơn, linh hoạt

Trong nhiều năm qua, **Docker** gần như là “chuẩn mặc định” trong thế giới container. Hầu hết các quy trình CI/CD, môi trường phát triển, và công cụ IDE đều xây dựng quanh Docker. Tuy nhiên, thế giới phần mềm không ngừng thay đổi — và giờ đây, **Visual Studio 2026 Insiders** đã đánh dấu một bước ngoặt quan trọng: **hỗ trợ chính thức Podman**, cho phép các nhà phát triển **xây dựng, chạy và gỡ lỗi ứng dụng container trực tiếp trong Visual Studio mà không cần Docker daemon**.

Đây không chỉ là một cập nhật kỹ thuật, mà còn là **một thay đổi lớn trong cách chúng ta phát triển và triển khai phần mềm containerized**.

***

### 🧩 Podman là gì?

**Podman** (Pod Manager) là một công cụ mã nguồn mở do **Red Hat** phát triển, được thiết kế như một **thay thế tương thích với Docker**. Giống Docker, Podman cho phép người dùng tạo, chạy, và quản lý container OCI (Open Container Initiative). Nhưng điểm khác biệt cốt lõi nằm ở **kiến trúc không có daemon** và khả năng **chạy container không cần quyền root (rootless containers)**.

Cụ thể, Podman hoạt động như một tập hợp các tiến trình người dùng (user-space processes), thay vì một dịch vụ nền duy nhất có quyền cao.\
Điều này mang lại lợi ích lớn về **bảo mật, linh hoạt, và khả năng tích hợp trong môi trường doanh nghiệp**.

***

### ⚙️ Docker vs Podman – So sánh toàn diện

| Tiêu chí                   | **Docker**                                      | **Podman**                                                                     |
| -------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------ |
| **Daemon**                 | Có (Docker Daemon chạy nền, yêu cầu quyền root) | Không có daemon – mọi tiến trình chạy trực tiếp dưới quyền người dùng          |
| **Bảo mật**                | Chạy dưới root (có rủi ro cao hơn)              | Hỗ trợ rootless containers, giảm bề mặt tấn công                               |
| **Tương thích CLI**        | Docker CLI                                      | Podman CLI gần như tương thích 100% với Docker (`alias docker=podman`)         |
| **Quản lý container**      | Container hoạt động tách biệt                   | Dựa trên khái niệm “Pods” (nhóm container chia sẻ namespace, giống Kubernetes) |
| **Tích hợp hệ thống**      | Phụ thuộc vào Docker daemon                     | Sử dụng `conmon` và `runc`, tuân thủ chuẩn OCI                                 |
| **Tích hợp IDE & CI/CD**   | Rất phổ biến                                    | Đang được mở rộng mạnh mẽ (Visual Studio, GitHub Actions, OpenShift, v.v.)     |
| **Hiệu năng & tài nguyên** | Có thể nặng khi daemon hoạt động liên tục       | Nhẹ hơn, khởi chạy nhanh hơn, không tốn tài nguyên nền                         |
| **Tương thích nền tảng**   | Windows, macOS, Linux                           | Linux native, hỗ trợ Windows thông qua WSL2 hoặc Podman Machine                |

Nói cách khác, **Podman là phiên bản “hiện đại hóa” của Docker**, với triết lý tập trung vào **bảo mật, tính mở và khả năng tích hợp tốt với hạ tầng cloud-native**.

***

### 💡 Tại sao Visual Studio 2026 lại chọn hỗ trợ Podman?

Khi Microsoft ra mắt Visual Studio 2026 Insiders, họ không chỉ giới thiệu tính năng mới — mà là **thông điệp rõ ràng về hướng phát triển tương lai**:\
👉 **Visual Studio không còn bị ràng buộc bởi Docker.**

Lý do đằng sau quyết định này rất thuyết phục:

#### 1. **Bảo mật tốt hơn cho nhà phát triển**

Docker daemon thường chạy với quyền root, tạo ra rủi ro nếu có lỗi bảo mật hoặc lạm dụng quyền truy cập.\
Podman giải quyết triệt để vấn đề này bằng mô hình **rootless container**, giúp giảm thiểu nguy cơ leo thang đặc quyền (privilege escalation).

#### 2. **Tính tương thích CLI cao**

Podman được thiết kế “drop-in replacement” cho Docker.\
Các lệnh quen thuộc như `docker build`, `docker run`, `docker ps`… đều có thể dùng với Podman mà không cần chỉnh sửa mã hay script.

Điều này giúp Visual Studio dễ dàng **chuyển đổi backend từ Docker sang Podman** mà không thay đổi trải nghiệm của người dùng.

#### 3. **Hiệu suất và độ nhẹ vượt trội**

Do không có daemon chạy nền, Podman tiêu tốn ít tài nguyên hơn, khởi chạy container nhanh hơn và dễ tích hợp vào quy trình phát triển nhẹ (lightweight dev workflows).

#### 4. **Khả năng mở rộng container pods**

Podman hỗ trợ khái niệm **Pods**, tương tự như Kubernetes.\
Điều này cho phép các nhà phát triển mô phỏng môi trường nhiều container (multi-container) ngay trong máy tính cá nhân – mà không cần cluster thật.

***

### 🔧 Trải nghiệm Podman trong Visual Studio 2026 Insiders

Sau khi cài bản **Visual Studio 2026 Insiders** mới nhất, người dùng có thể:

1. **Cài đặt Podman** trên hệ thống (Windows, Linux, hoặc macOS).
2. **Mở dự án có Dockerfile** – Visual Studio sẽ tự động phát hiện và chuyển sang sử dụng Podman backend.
3. **Build, Run, Debug** container trực tiếp trong IDE như với Docker trước đây.

#### 🔍 Những điểm nổi bật khi tích hợp:

* **Tích hợp CLI đầy đủ:** Visual Studio nhận diện Podman CLI tương tự Docker CLI.
* **Gỡ lỗi container trực tiếp:** Debugging hoạt động liền mạch nhờ tích hợp Visual Studio Container Tools.
* **Không yêu cầu Docker Desktop:** Giảm chi phí bản quyền và tài nguyên hệ thống.
* **Hỗ trợ rootless:** Các container chạy trong không gian người dùng, an toàn hơn trên Windows và WSL2.

Microsoft cũng cung cấp bộ **Container Tools** cập nhật để tương thích hoàn toàn với Podman, bao gồm hỗ trợ IntelliSense, logging, và container explorer.

***

### 🧱 Podman và xu hướng “rootless container” trong DevOps

Việc Visual Studio tích hợp Podman không chỉ là tiện ích — mà phản ánh **xu hướng lớn trong cộng đồng DevOps và Cloud-native**.

Các tổ chức ngày càng chú trọng đến:

* **Bảo mật phát triển nội bộ (developer security posture)**
* **Chính sách zero-trust**
* **Giảm quyền hệ thống trong môi trường build/test**

Podman, với mô hình rootless, chính là công cụ lý tưởng để đáp ứng những yêu cầu đó.\
Nó giúp các nhóm DevOps tạo ra môi trường phát triển an toàn hơn mà không ảnh hưởng đến tốc độ hay trải nghiệm.

***

### 💬 Góc nhìn của cộng đồng lập trình viên

Trên các diễn đàn như Reddit, Stack Overflow và GitHub Discussions, phản ứng của cộng đồng khá tích cực.\
Nhiều lập trình viên hoan nghênh việc Visual Studio mở cửa cho Podman, vì:

* Họ có thể **thoát khỏi sự phụ thuộc Docker Desktop** (đặc biệt từ khi Docker chuyển sang mô hình license mới).
* **Podman hoạt động mượt mà trong WSL2** – điều mà nhiều dev Windows yêu cầu.
* Và quan trọng nhất: **Visual Studio vẫn giữ trải nghiệm quen thuộc**, không buộc phải thay đổi workflow hay lệnh CLI.

***

### 🔮 Tương lai của hệ sinh thái container trong Visual Studio

Sự kiện này chỉ là **khởi đầu**.\
Khi Podman được chấp nhận rộng rãi hơn, chúng ta có thể kỳ vọng Visual Studio sẽ mở rộng hỗ trợ cho các công nghệ container khác trong hệ sinh thái **OCI (Open Container Initiative)** như **Buildah** hoặc **Skopeo** – vốn cùng họ với Podman.

Microsoft có thể hướng tới:

* **Tích hợp sâu hơn với Kubernetes & OpenShift**, nhờ mô hình Pods tương thích.
* **Cải thiện trải nghiệm CI/CD** trong Azure DevOps và GitHub Actions dựa trên Podman runner.
* **Tối ưu hóa trải nghiệm cross-platform**, cho phép lập trình viên Windows, Linux, và macOS chia sẻ cùng một công cụ container backend.

### 🧱 Hướng dẫn cài đặt và cấu hình **Podman trong Visual Studio 2026**

Sẵn sàng trải nghiệm container không cần Docker?\
Dưới đây là hướng dẫn chi tiết từng bước để **thiết lập Podman và tích hợp trực tiếp với Visual Studio 2026 Insiders**.

***

#### 🔹 Bước 1: Cài đặt **Podman**

**💻 Trên Windows**

1. **Tải Podman Machine Installer** từ trang chính thức:\
   👉 https://podman.io/getting-started/installation
2. Chạy file cài đặt (`Podman-Setup.exe`) và làm theo hướng dẫn.
3.  Sau khi hoàn tất, mở **Windows Terminal (hoặc PowerShell)** và khởi tạo máy ảo Podman:

    ```bash
    podman machine init
    podman machine start
    ```
4.  Kiểm tra phiên bản:

    ```bash
    podman --version
    ```

    → Nếu hiển thị phiên bản (ví dụ: `Podman version 5.1.2`), bạn đã cài đặt thành công.

> 💡 _Podman trên Windows chạy thông qua một VM nhẹ tương tự Docker Desktop, nhưng không yêu cầu daemon._

***

**🐧 Trên Linux**

Podman đã có sẵn trong hầu hết các kho phần mềm:

```bash
sudo apt install -y podman        # Ubuntu/Debian
sudo dnf install -y podman        # Fedora/RHEL
sudo pacman -S podman             # Arch Linux
```

Kiểm tra bằng:

```bash
podman info
```

Nếu bạn muốn chạy container rootless:

```bash
podman system migrate
```

***

**🍎 Trên macOS**

1.  Cài đặt qua Homebrew:

    ```bash
    brew install podman
    ```
2.  Khởi tạo Podman machine:

    ```bash
    podman machine init
    podman machine start
    ```
3.  Kiểm tra:

    ```bash
    podman ps
    ```

***

#### 🔹 Bước 2: Cài đặt **Visual Studio 2026 Insiders**

1. Tải bản mới nhất tại:\
   👉 [https://msft.it/6184ssGAp](https://msft.it/6184ssGAp)\
   👉 [https://podman.io/docs/installation](https://podman.io/docs/installation)
2. Trong quá trình cài đặt, chọn **“Container Development Tools”** (nằm trong mục Workloads).
3. Sau khi hoàn tất, mở Visual Studio và xác nhận rằng **Container Tools** đã được bật:
   * Vào **Tools → Get Tools and Features → Individual Components**
   * Đảm bảo tùy chọn **“Container Tools”** được tick.

***

#### 🔹 Bước 3: Cấu hình Visual Studio để sử dụng Podman thay cho Docker

1. Mở Visual Studio → **Tools → Options**.
2.  Điều hướng tới:

    ```
    Containers → Container Engine
    ```
3.  Trong mục **Engine**, chọn:

    ```
    Podman (instead of Docker)
    ```
4. Visual Studio sẽ tự động phát hiện `podman` từ PATH hệ thống.\
   Nếu không, bạn có thể chỉ định thủ công đường dẫn đến `podman.exe`.

> 🧠 _Visual Studio sử dụng các lệnh CLI tương tự Docker, vì vậy bạn không cần chỉnh sửa Dockerfile hoặc task build._

***

#### 🔹 Bước 4: Kiểm tra bằng dự án mẫu

1. Tạo dự án mới:\
   **File → New → Project → ASP.NET Core Web App (Containerized)**
2. Chọn **Enable container support**.
3.  Khi được hỏi chọn công cụ container, chọn:

    ```
    Use Podman
    ```
4.  Sau khi dự án được tạo, mở **Terminal trong Visual Studio** và chạy:

    ```bash
    podman ps
    ```

    Bạn sẽ thấy container của ứng dụng đang chạy.

***

#### 🔹 Bước 5: Debug ứng dụng containerized với Podman

Visual Studio 2026 cho phép bạn **gỡ lỗi (debug)** ứng dụng container tương tự như Docker.

* Nhấn **F5** để khởi chạy container.
* IDE sẽ tự động gắn debugger vào tiến trình trong container.
* Bạn có thể:
  * Đặt breakpoint
  * Xem biến, call stack
  * Theo dõi log container trực tiếp trong cửa sổ **Output**.

> 📸 _Hình minh họa gợi ý cho bài blog:_
>
> * Ảnh giao diện Visual Studio hiển thị “Podman Container Tools”
> * Ảnh container đang chạy trong **Container Explorer**
> * Ảnh breakpoint đang hoạt động trong Podman container

***

#### 🔹 Bước 6: (Tuỳ chọn) Gỡ lỗi nhiều container (multi-container)

Nếu dự án của bạn bao gồm nhiều service (ví dụ: API + Database), Visual Studio vẫn hỗ trợ khởi chạy và gỡ lỗi đồng thời với Podman thông qua **Compose hoặc Pods**.

* Sử dụng `podman pod create` để nhóm các container.
* Visual Studio sẽ tự nhận dạng các service trong cùng Pod và cho phép debug đa tiến trình.

***

#### 🔹 Bước 7: Tích hợp CI/CD với Podman

Khi đã cấu hình ổn định, bạn có thể mở rộng sang pipeline CI/CD:

* GitHub Actions: sử dụng `podman build` thay vì `docker build`.
* Azure DevOps: cài Podman trên agent và build image không cần Docker Desktop.

Ví dụ GitHub Action đơn giản:

```yaml
- name: Build container with Podman
  run: podman build -t myapp:latest .
```

***

### 🧭 Tổng kết

Sự tích hợp **Podman trong Visual Studio 2026 Insiders** không chỉ là một tính năng mới, mà là **tuyên bố chiến lược** của Microsoft:

> “Tự do chọn công cụ container bạn muốn, mà vẫn giữ nguyên trải nghiệm Visual Studio.”

Nhờ sự hỗ trợ Podman trong Visual Studio 2026, lập trình viên nay có thể:

* Xây dựng, chạy, và gỡ lỗi ứng dụng container **trực tiếp trong IDE**.
* **Không cần Docker Desktop**, giảm tải hệ thống.
* **Tận dụng bảo mật rootless**, an toàn hơn trong môi trường doanh nghiệp.
* Và **giữ nguyên trải nghiệm phát triển quen thuộc** – chỉ khác ở backend.

Visual Studio một lần nữa chứng minh vì sao nó không chỉ là IDE mạnh mẽ cho .NET, mà còn là nền tảng phát triển container hàng đầu trong kỷ nguyên cloud-native.

Với bước đi này, Visual Studio tiếp tục khẳng định vị thế **IDE hàng đầu cho phát triển containerized ứng dụng hiện đại**, nơi mà hiệu năng, bảo mật và trải nghiệm người dùng cùng song hành.

***

📦 **Tải ngay bản Visual Studio 2026 Insiders mới nhất và khám phá Podman:**\
👉 [https://msft.it/6184ssGAp](https://msft.it/6184ssGAp)
