---
description: >-
  Hướng dẫn từng bước cài đặt và cấu hình Jenkins trên CentOS/RHEL sử dụng DNF,
  bao gồm cài Java 17, cấu hình Docker permissions và khởi động dịch vụ.
---

# Cài đặt và cấu hình Jenkins trên CentOS/RHEL

Jenkins là một trong những công cụ CI/CD (Continuous Integration / Continuous Delivery) mã nguồn mở phổ biến nhất, giúp tự động hóa quá trình build, test và triển khai ứng dụng. Bài viết này hướng dẫn từng bước cài đặt và cấu hình Jenkins trên hệ điều hành CentOS/RHEL sử dụng trình quản lý gói DNF.

***

## Yêu cầu

* **Hệ điều hành:** CentOS 8/9 hoặc RHEL 8/9 (sử dụng DNF package manager)
* **Quyền root hoặc sudo:** Cần quyền quản trị viên để cài đặt gói và quản lý dịch vụ
* **Kết nối Internet:** Để tải về Jenkins và các phụ thuộc từ repository chính thức
* **Firewall:** Mở cổng `8080` (mặc định của Jenkins) nếu cần truy cập từ xa

{% hint style="info" %}
Bài viết này sử dụng DNF — trình quản lý gói mặc định trên CentOS 8+, RHEL 8+ và các bản phân phối tương thích. Nếu bạn đang dùng CentOS 7, hãy tham khảo hướng dẫn sử dụng `yum` thay thế.
{% endhint %}

***

## Bước 1: Cài đặt Java 17 OpenJDK

Jenkins yêu cầu Java Runtime Environment (JRE) hoặc Java Development Kit (JDK) để hoạt động. Phiên bản Java 17 là lựa chọn LTS (Long-Term Support) được Jenkins khuyến nghị.

{% code title="Cài đặt Java 17 OpenJDK" overflow="wrap" lineNumbers="true" %}
```bash
sudo dnf install -y java-17-openjdk
```
{% endcode %}

Sau khi cài đặt xong, kiểm tra phiên bản Java đã được kích hoạt:

{% code title="Kiểm tra phiên bản Java" overflow="wrap" lineNumbers="true" %}
```bash
java -version
```
{% endcode %}

Kết quả mong đợi:

```
openjdk version "17.x.x" 2024-xx-xx LTS
OpenJDK Runtime Environment (build 17.x.x-lts)
OpenJDK 64-Bit Server VM (build 17.x.x-lts, mixed mode, sharing)
```

{% hint style="warning" %}
Nếu hệ thống có nhiều phiên bản Java, sử dụng `sudo alternatives --config java` để chọn phiên bản Java 17 làm mặc định.
{% endhint %}

***

## Bước 2: Thêm repository Jenkins

Để cài đặt Jenkins thông qua DNF, bạn cần thêm repository chính thức của Jenkins vào hệ thống.

{% code title="Tải về file repository Jenkins" overflow="wrap" lineNumbers="true" %}
```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
```
{% endcode %}

Lệnh này tải file `.repo` từ repository chính thức và lưu vào `/etc/yum.repos.d/`, cho phép DNF nhận diện và cài đặt Jenkins như một gói hệ thống.

{% hint style="info" %}
Sử dụng `redhat-stable` thay vì `redhat` để đảm bảo bạn nhận được phiên bản ổn định (stable), phù hợp cho môi trường production.
{% endhint %}

***

## Bước 3: Import GPG key

Trước khi cài đặt, hệ thống cần import GPG key để xác thực tính toàn vẹn của gói Jenkins.

{% code title="Import GPG key của Jenkins" overflow="wrap" lineNumbers="true" %}
```bash
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```
{% endcode %}

GPG key giúp đảm bảo rằng gói tin bạn tải về không bị giả mạo hoặc chứa mã độc. Đây là bước bảo mật quan trọng trong quy trình cài đặt phần mềm từ bên thứ ba.

***

## Bước 4: Cài đặt Jenkins

Sau khi đã thêm repository và import GPG key, tiến hành cài đặt Jenkins.

{% code title="Cài đặt Jenkins" overflow="wrap" lineNumbers="true" %}
```bash
sudo dnf install jenkins -y
```
{% endcode %}

Quá trình cài đặt sẽ tự động tải về Jenkins cùng các phụ thuộc cần thiết. Thời gian cài đặt phụ thuộc vào tốc độ kết nối Internet.

{% hint style="warning" %}
Jenkins được cài đặt mặc định trên cổng `8080`. Nếu cổng này đang bị chiếm bởi dịch vụ khác, bạn cần thay đổi cấu hình trước khi khởi động Jenkins.
{% endhint %}

***

## Bước 5: Bật và khởi động dịch vụ Jenkins

Sau khi cài đặt xong, kích hoạt và khởi động dịch vụ Jenkins bằng systemctl.

{% code title="Bật và khởi động Jenkins service" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
```
{% endcode %}

* **`systemctl enable jenkins`:** Đảm bảo Jenkins tự động khởi động cùng hệ thống mỗi khi boot
* **`systemctl start jenkins`:** Khởi động dịch vụ Jenkins ngay lập tức

Kiểm tra xem dịch vụ đã khởi động thành công:

{% code title="Kiểm tra trạng thái ban đầu" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl status jenkins
```
{% endcode %}

Kết quả mong đợi hiển thị `active (running)` với màu xanh lá.

***

## Bước 6: Lấy mật khẩu admin ban đầu

Khi Jenkins khởi động lần đầu tiên, hệ thống sẽ tạo một mật khẩu quản trị viên tạm thời để xác thực truy cập ban đầu.

{% code title="Lấy initial admin password" overflow="wrap" lineNumbers="true" %}
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
{% endcode %}

Kết quả sẽ là một chuỗi ký tự dạng UUID, ví dụ:

```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

Sao chép chuỗi này và truy cập Jenkins qua trình duyệt:

```
http://<địa-chỉ-IP>:8080
```

Dán mật khẩu vào trường **Administrator password** và nhấn **Continue** để hoàn tất quá trình cài đặt ban đầu.

{% hint style="info" %}
Sau lần đăng nhập đầu tiên, bạn sẽ được yêu cầu cài đặt các plugin đề xuất (Suggested Plugins). Chọn **Install suggested plugins** để có bộ plugin phổ biến nhất.
{% endhint %}

***

## Bước 7: Cấu hình quyền Docker cho Jenkins user

Nếu bạn sử dụng Jenkins để chạy các pipeline liên quan đến Docker, Jenkins user cần được thêm vào nhóm `docker` để có quyền truy cập Docker daemon.

{% code title="Thêm Jenkins user vào nhóm docker" overflow="wrap" lineNumbers="true" %}
```bash
sudo usermod -aG docker jenkins
```
{% endcode %}

* **`usermod`:** Lệnh sửa đổi thông tin user trên Linux
* **`-aG`:** Thêm user vào nhóm bổ sung (`-a` = append, `-G` = group)
* **`docker`:** Nhóm quản lý quyền truy cập Docker daemon

{% hint style="warning" %}
Nếu bạn đã cài đặt Docker trên hệ thống nhưng chưa tạo nhóm `docker`, hãy chạy `sudo groupadd docker` trước khi thực hiện lệnh trên.
{% endhint %}

***

## Bước 8: Kiểm tra thông tin user Jenkins

Sau khi thêm vào nhóm docker, kiểm tra để xác nhận thay đổi đã có hiệu lực.

{% code title="Kiểm tra groups của Jenkins user" overflow="wrap" lineNumbers="true" %}
```bash
groups jenkins
```
{% endcode %}

Kết quả mong đợi:

```
jenkins : jenkins docker
```

Ngoài ra, bạn có thể sử dụng `id` để xem chi tiết hơn:

{% code title="Kiểm tra chi tiết UID, GID và groups" overflow="wrap" lineNumbers="true" %}
```bash
id jenkins
```
{% endcode %}

Kết quả mong đợi:

```
uid=994(jenkins) gid=991(jenkins) groups=991(jenkins),993(docker)
```

* **`uid`:** ID người dùng Jenkins
* **`gid`:** Nhóm chính của Jenkins
* **`groups`:** Danh sách tất cả các nhóm mà Jenkins thuộc về (bao gồm `docker`)

***

## Bước 9: Khởi động lại Jenkins

Để thay đổi quyền nhóm có hiệu lực đối với Jenkins, bạn cần khởi động lại dịch vụ.

{% code title="Khởi động lại Jenkins" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl restart jenkins
```
{% endcode %}

{% hint style="info" %}
Việc khởi động lại Jenkins sẽ làm ngắt các pipeline đang chạy. Hãy đảm bảo không có job nào đang thực thi trước khi restart.
{% endhint %}

***

## Bước 10: Kiểm tra trạng thái dịch vụ

Sau khi khởi động lại, kiểm tra toàn bộ trạng thái để đảm bảo Jenkins hoạt động bình thường.

{% code title="Kiểm tra trạng thái Jenkins" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl status jenkins
```
{% endcode %}

Kết quả mong đợi:

```
● jenkins.service - Jenkins Continuous Integration Server
     Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2024-xx-xx xx:xx:xx UTC; 5s ago
   Main PID: 12345 (java)
      Tasks: 42 (limit: 23567)
     Memory: 512.3M
        CPU: 15.234s
     CGroup: /system.slice/jenkins.service
             └─12345 /usr/bin/java -Djava.awt.headless=true ...
```

Các thông tin quan trọng cần chú ý:

* **`Active: active (running)`:** Dịch vụ đang hoạt động bình thường
* **`Loaded: enabled`:** Dịch vụ được thiết lập tự động khởi động cùng hệ thống
* **`Main PID`:** PID của tiến trình Jenkins chính

Ngoài ra, truy cập Jenkins qua trình duyệt để xác nhận giao diện hoạt động:

```
http://<địa-chỉ-IP>:8080
```

***

## Tóm tắt nhanh các lệnh

{% code title="Tổng hợp lệnh cài đặt Jenkins trên CentOS/RHEL" overflow="wrap" lineNumbers="true" %}
```bash
# 1. Cài đặt Java 17 OpenJDK
sudo dnf install -y java-17-openjdk

# 2. Thêm repository Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# 3. Import GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 4. Cài đặt Jenkins
sudo dnf install jenkins -y

# 5. Bật và khởi động dịch vụ
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 6. Lấy mật khẩu admin ban đầu
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# 7. Cấu hình quyền Docker
sudo usermod -aG docker jenkins

# 8. Kiểm tra user Jenkins
groups jenkins
id jenkins

# 9. Khởi động lại Jenkins
sudo systemctl restart jenkins

# 10. Kiểm tra trạng thái
sudo systemctl status jenkins
```
{% endcode %}

***

## Lưu ý quan trọng

{% hint style="warning" %}
**Bảo mật:** Mật khẩu admin ban đầu (`initialAdminPassword`) chỉ tồn tại tạm thời. Sau khi đăng nhập lần đầu, hãy xóa file này bằng `sudo rm /var/lib/jenkins/secrets/initialAdminPassword` để tăng cường bảo mật.
{% endhint %}

{% hint style="danger" %}
**Firewall:** Nếu bạn truy cập Jenkins từ xa, đảm bảo đã mở cổng `8080` trong firewall:

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```
{% endhint %}

{% hint style="info" %}
**Tài nguyên:** Jenkins sử dụng相当 nhiều bộ nhớ RAM. Với môi trường production, khuyến nghị tối thiểu 2GB RAM và 1GB ổ cứng trống cho Jenkins.
{% endhint %}

* **Cổng mặc định:** Jenkins chạy trên cổng `8080`. Để thay đổi, chỉnh sửa file `/etc/sysconfig/jenkins` và tìm dòng `JENKINS_PORT`
* **Thư mục làm việc:** Thư mục gốc của Jenkins nằm tại `/var/lib/jenkins/`
* **Log file:** Xem log Jenkins tại `/var/log/jenkins/jenkins.log` khi gặp sự cố
* **Quản lý qua CLI:** Jenkins cung cấp CLI tool để quản lý từ dòng lệnh, tham khảo tại [Jenkins CLI Documentation](https://www.jenkins.io/doc/book/managing/cli/)

***

## Tài liệu tham khảo

* [Jenkins Official Documentation](https://www.jenkins.io/doc/)
* [Installing Jenkins on Red Hat Distributions](https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos)
* [Jenkins LTS Release Line](https://www.jenkins.io/download/lts/)
