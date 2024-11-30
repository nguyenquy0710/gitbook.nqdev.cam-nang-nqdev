---
description: >-
  Ansible là công cụ tự động hóa mạnh mẽ và dễ sử dụng, nhưng để tận dụng tối đa
  khả năng của nó, trước tiên chúng ta cần cài đặt đúng cách.
---

# Hướng dẫn chi tiết cài đặt Ansible

Trong bài viết này, bạn sẽ được hướng dẫn từng bước cài đặt Ansible trên các hệ điều hành phổ biến như Linux, macOS, và Windows.

***

## 1. **Cài đặt Ansible trên Linux**

Ansible hoạt động tốt trên nhiều bản phân phối Linux. Dưới đây là hướng dẫn cho các bản phân phối phổ biến:

### **1.1. Trên Ubuntu/Debian**

#### **B1: Cập nhật danh sách gói:**

```bash
sudo apt update
```

#### **B2: Cài đặt gói cần thiết:**

```bash
sudo apt install software-properties-common
```

#### **B3: Thêm PPA chính thức của Ansible:**

```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
```

#### **B4: Cài đặt Ansible:**

```bash
sudo apt install ansible -y
```

#### **B5: Kiểm tra phiên bản:**

```bash
ansible --version
```

### **1.2. Trên CentOS/RHEL**

#### **B1: Cài đặt kho EPEL:**

```bash
sudo yum install epel-release -y
```

#### **B2: Cài đặt Ansible:**

```bash
sudo yum install ansible -y
```

#### **B3: Kiểm tra phiên bản:**

```bash
ansible --version
```

## **1.3. Trên Fedora**

#### **B1: Cập nhật hệ thống:**

```bash
sudo dnf update -y
```

#### **B2: Cài đặt Ansible:**

```bash
sudo dnf install ansible -y
```

#### **B3: Kiểm tra phiên bản:**

```bash
ansible --version
```

***

## 2. **Cài đặt Ansible trên macOS**

Ansible có thể được cài đặt dễ dàng trên macOS thông qua Homebrew.

#### **B1: Cài đặt Homebrew (nếu chưa có):**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### **B2: Cập nhật Homebrew:**

```bash
brew update
```

#### **B3: Cài đặt Ansible:**

```bash
brew install ansible
```

#### **B4: Kiểm tra phiên bản:**

```bash
ansible --version
```

***

## 3. **Cài đặt Ansible trên Windows**

Trên Windows, bạn cần sử dụng WSL (Windows Subsystem for Linux) hoặc một công cụ ảo hóa để cài đặt Ansible. Dưới đây là hướng dẫn sử dụng WSL:

### **3.1. Cài đặt WSL**

1. **Bật WSL trên Windows:** Mở PowerShell với quyền admin và chạy lệnh:
   * ```batch
     wsl --install
     ```
   * Khởi động lại máy tính nếu được yêu cầu.
2. **Cài đặt bản phân phối Linux (Ubuntu):** Sau khi cài đặt WSL, mở Microsoft Store, tải và cài đặt Ubuntu.

### **3.2. Cài đặt Ansible trong WSL**

Sau khi cài đặt Ubuntu trong WSL:

1. Mở Ubuntu và cập nhật gói:
   * <pre class="language-bash"><code class="lang-bash"><strong>sudo apt update &#x26;&#x26; sudo apt upgrade -y
     </strong></code></pre>
2. Cài đặt Ansible tương tự hướng dẫn Ubuntu ở trên:
   * ```bash
     sudo apt install ansible -y
     ```
3. Kiểm tra phiên bản:
   * ```bash
     ansible --version
     ```

***

## 4. **Cài đặt Ansible qua Python Pip**

Nếu bạn muốn cài đặt Ansible trên các môi trường không chính thức hoặc cần phiên bản mới nhất, bạn có thể sử dụng `pip`:

#### **B1: Cài đặt Python và pip (nếu chưa có):**

1. Trên Ubuntu/Debian:
   * ```bash
     sudo apt install python3 python3-pip -y
     ```
2. Trên CentOS/RHEL:
   * ```bash
     sudo yum install python3 python3-pip -y
     ```

#### **B2: Cài đặt Ansible qua pip:**

```bash
pip3 install ansible
```

#### **B3: Kiểm tra phiên bản:**

```bash
ansible --version
```

***

## 5. **Xác thực cài đặt**

Sau khi cài đặt, bạn có thể kiểm tra Ansible bằng cách chạy lệnh:

```bash
ansible localhost -m ping
```

Lệnh này sẽ kiểm tra xem Ansible có hoạt động chính xác hay không. Nếu kết quả trả về là `pong`, bạn đã cài đặt thành công.

***

## Kết luận

Cài đặt Ansible là bước đầu tiên để bạn bắt đầu tự động hóa các công việc quản trị hệ thống và triển khai ứng dụng. Dù bạn sử dụng Linux, macOS hay Windows, việc cài đặt Ansible đều rất đơn giản và nhanh chóng. Hãy tiếp tục tìm hiểu và ứng dụng Ansible để tăng hiệu quả công việc!

Nếu bạn gặp bất kỳ khó khăn nào trong quá trình cài đặt, hãy để lại bình luận để nhận được sự hỗ trợ từ cộng đồng hoặc tham khảo thêm tài liệu tại [Ansible Documentation](https://docs.ansible.com).

Chúc bạn thành công!
