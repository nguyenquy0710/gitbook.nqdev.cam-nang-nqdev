---
description: >-
  Hướng dẫn chi tiết di chuyển containerd từ root filesystem (/) sang partition
  khác để giải phóng dung lượng, tránh lỗi Disk Full trên Ubuntu Linux với Docker.
---

# Hướng dẫn di chuyển Containerd sang partition khác để giải phóng dung lượng root filesystem Ubuntu

Khi root filesystem bị đầy do containerd snapshots chiếm quá nhiều dung lượng — dù các partition khác vẫn còn trống — bạn cần di chuyển containerd data sang partition có dung lượng trống để giải phóng dung lượng cho hệ thống. Hướng dẫn này giúp bạn thực hiện điều đó một cách an toàn và nhanh chóng.

***

## **1. Vấn đề gặp phải**

Triển khai Docker trên Ubuntu, bạn có thể gặp tình huống:

* **Root filesystem đầy trên 80-90%** trong khi các partition khác vẫn còn rất nhiều dung lượng trống.
* Docker containers vẫn hoạt động bình thường nhưng hệ thống cảnh báo dung lượng thấp.
* Lỗi `no space left on device` xuất hiện khi trying pull image hoặc tạo container mới.

Ví dụ thực tế:

```bash
df -h /
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        54G   47G  4.2G  92% /

df -h /mnt/e02
# /dev/mapper/vg01-lv_data  500G  100G  380G  21% /mnt/e02
```

Root filesystem đã đầy **92%** trong khi partition `/mnt/e02` chỉ dùng **21%**.

***

## **2. Nguyên nhân**

Containerd lưu trữ snapshots của Docker images trên root filesystem tại đường dẫn mặc định:

* **Docker data:** Có thể đã được cấu hình ở partition khác (ví dụ: `/mnt/e02/docker`).
* **Containerd snapshots:** Vẫn nằm trên root filesystem tại `/var/lib/containerd/`.
* **Overlay Layers:** Docker containers sử dụng overlay filesystem được store trong containerd snapshots.

Cấu trúc phụ thuộc:

```text
Overlay Layers (Docker containers)
  └── Containerd Snapshots (root filesystem /var/lib/containerd/)
        └── Chứa images, base layers, container layers
```

Vì vậy dù Docker data đã ở partition khác, dung lượng root filesystem vẫn bị chiếm dụng bởi containerd snapshots.

***

## **3. Giải pháp**

Di chuyển containerd data từ `/var/lib/containerd` sang partition có dung lượng trống (ví dụ: `/mnt/e02/uenv/var/lib/containerd`).

Lợi ích của phương pháp này:

* **Giải phóng root filesystem:** Ví dụ từ 92% xuống còn 40%.
* **Tận dụng dung lượng partition khác:** Partition trống trở thành nơi lưu trữ chính.
* **Không mất Docker containers:** Containers vẫn hoạt động bình thường sau khi migrate.
* **Không cần thay đổi Docker config:** Docker daemon vẫn sử dụng cấu hình hiện tại.
* **Thời gian thực hiện nhanh:** Chỉ ~5-10 phút cho ~27GB dữ liệu trên SSD.

***

## **4. Yêu cầu trước khi thực hiện**

Trước khi bắt đầu, đảm bảo hệ thống đáp ứng các yêu cầu sau:

* **Hệ điều hành:** Ubuntu 24.04 LTS (hoặc các bản phân phối Linux khác).
* **Docker:** Docker CE (latest version).
* **Containerd:** v1.7 trở lên.
* **Filesystem:** LVM + ext4 hoặc tương đương.
* **Quyền:** sudo/root access.
* **Partition đích:** Có dung lượng trống >20GB.

***

## **5. Hướng dẫn chi tiết**

### **Bước 1: Kiểm tra tình trạng hiện tại**

Trước khi thực hiện, kiểm tra dung lượng root filesystem, partition đích, dung lượng containerd, và Docker config:

{% code title="Kiểm tra dung lượng" overflow="wrap" lineNumbers="true" %}
```bash
# Kiểm tra dung lượng root filesystem
df -h /

# Kiểm tra dung lượng partition đích
df -h /mnt/e02

# Kiểm tra dung lượng containerd hiện tại
sudo du -sh /var/lib/containerd

# Kiểm tra Docker daemon config
cat /etc/docker/daemon.json
```
{% endcode %}

Kết quả mong đợi:

* **Root filesystem:** >80% used.
* **Containerd:** >10GB.
* **Partition đích:** >100GB available.

### **Bước 2: Dừng Docker và Containerd**

Dừng các dịch vụ Docker và Containerd trước khi di chuyển dữ liệu:

{% code title="Dừng services" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl stop docker
sudo systemctl stop containerd

# Xác nhận đã dừng
sudo systemctl is-active docker containerd
```
{% endcode %}

{% hint style="warning" %}
Tất cả containers sẽ bị dừng trong quá trình thực hiện. Hãy thông báo cho team/users trước khi bắt đầu.
{% endhint %}

### **Bước 3: Tạo thư mục đích**

Tạo thư mục trên partition đích để lưu containerd data:

{% code title="Tạo thư mục đích" overflow="wrap" lineNumbers="true" %}
```bash
sudo mkdir -p /mnt/e02/uenv/var/lib/containerd

# Xác nhận thư mục đã tạo
ls -ld /mnt/e02/uenv/var/lib/containerd
```
{% endcode %}

### **Bước 4: Di chuyển dữ liệu**

Di chuyển toàn bộ dữ liệu containerd từ root filesystem sang partition đích:

{% code title="Di chuyển dữ liệu containerd" overflow="wrap" lineNumbers="true" %}
```bash
# Di chuyển dữ liệu
sudo mv /var/lib/containerd/* /mnt/e02/uenv/var/lib/containerd/ 2>/dev/null || true

# Kiểm tra dung lượng sau di chuyển
sudo du -sh /var/lib/containerd
sudo du -sh /mnt/e02/uenv/var/lib/containerd
```
{% endcode %}

Kết quả mong đợi:

* `/var/lib/containerd` = 4.0K (rỗng).
* `/mnt/e02/uenv/var/lib/containerd` = ~27GB.

### **Bước 5: Sửa cấu hình Containerd**

Backup config hiện tại và sửa `root =` trong `/etc/containerd/config.toml`:

{% code title="Backup và sửa config" overflow="wrap" lineNumbers="true" %}
```bash
# Backup config
sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak

# Sửa config
sudo nano /etc/containerd/config.toml
```
{% endcode %}

Thay đổi dòng `root`:

```text
# Trước
root = "/var/lib/containerd"

# Sau
root = "/mnt/e02/uenv/var/lib/containerd"
```

### **Bước 6: Khởi động lại services**

Khởi động lại Containerd và Docker để áp dụng cấu hình mới:

{% code title="Khởi động services" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl start containerd
sudo systemctl start docker

# Kiểm tra trạng thái
sudo systemctl status containerd docker
```
{% endcode %}

### **Bước 7: Xác minh containers chạy bình thường**

Sau khi khởi động, kiểm tra Docker hoạt động bình thường:

{% code title="Xác minh Docker" overflow="wrap" lineNumbers="true" %}
```bash
# Danh sách containers đang chạy
sudo docker ps

# Kiểm tra Docker Root Dir
sudo docker info | grep "Docker Root Dir"

# Chạy thử container
sudo docker run --rm alpine echo "Hello World"
```
{% endcode %}

***

## **6. Xác minh kết quả**

Sau khi hoàn thành, kiểm tra kỹ lưỡng các khía cạnh sau:

### **Kiểm tra dung lượng filesystem**

{% code title="Kiểm tra dung lượng" overflow="wrap" lineNumbers="true" %}
```bash
df -h /
df -h /mnt/e02
sudo du -sh /var/lib/containerd
sudo du -sh /mnt/e02/uenv/var/lib/containerd
```
{% endcode %}

### **Kiểm tra Containerd config**

{% code title="Kiểm tra config" overflow="wrap" lineNumbers="true" %}
```bash
grep "^root = " /etc/containerd/config.toml
sudo ctr snapshots list | head -5
```
{% endcode %}

### **Kiểm tra Docker operation**

{% code title="Kiểm tra Docker" overflow="wrap" lineNumbers="true" %}
```bash
sudo docker images | head -5
sudo docker volume ls
```
{% endcode %}

***

## **7. Troubleshooting**

### **Lỗi "permission denied" khi di chuyển dữ liệu**

{% code title="Fix permission" overflow="wrap" lineNumbers="true" %}
```bash
sudo chown -R root:root /mnt/e02/uenv/var/lib/containerd
sudo chmod -R 755 /mnt/e02/uenv/var/lib/containerd
```
{% endcode %}

### **Docker không start sau khi config**

{% code title="Debug Docker startup" overflow="wrap" lineNumbers="true" %}
```bash
# Validate containerd config
sudo /usr/bin/containerd -c /etc/containerd/config.toml validate

# Kiểm tra thư mục đích
ls -la /mnt/e02/uenv/var/lib/containerd

# Xem logs containerd
sudo journalctl -u containerd -n 50 --no-pager

# Xem logs docker
sudo journalctl -u docker -n 50 --no-pager
```
{% endcode %}

### **Containers không start sau migration**

{% code title="Debug containers" overflow="wrap" lineNumbers="true" %}
```bash
# Kiểm tra snapshots
sudo ctr snapshots list

# Fix permission nếu cần
sudo chown -R root:root /mnt/e02/uenv/var/lib/containerd

# Restart services
sudo systemctl restart containerd
sudo systemctl restart docker
```
{% endcode %}

### **Rollback nếu có vấn đề**

Nếu gặp sự cố không thể giải quyết, hoàn nguyên về cấu hình cũ:

{% code title="Rollback" overflow="wrap" lineNumbers="true" %}
```bash
sudo systemctl stop docker containerd

# Restore config
sudo cp /etc/containerd/config.toml.bak /etc/containerd/config.toml

# Di chuyển dữ liệu về vị trí cũ
sudo mv /mnt/e02/uenv/var/lib/containerd/* /var/lib/containerd/ 2>/dev/null || true

# Khởi động lại
sudo systemctl start containerd docker
```
{% endcode %}

***

## **8. Best Practices**

* **Lên kế hoạch trước:** Thông báo team, chọn lịch giờ ít traffic, backup containers quan trọng.
* **Giám sát trong quá trình migrate:** Sử dụng `watch -n 1 'df -h / | tail -1'` và `sudo lsof | grep containerd` để theo dõi.
* **Tối ưu thêm nếu cần:** Chạy `sudo docker image prune -a -f` để dọn dẹp images không dùng, cleanup snapd cache.
* **Document lại:** Lưu note containerd root path mới, backup config, thêm vào runbook team.
* **Giám sát dài hạn:** Thiết lập cron job kiểm tra dung lượng hoặc dùng monitoring tools (Prometheus + Grafana, Datadog).

***

## **9. Kết quả thực tế**

Trên một máy Ubuntu 24.04 LTS với Docker CE và Containerd v1.7+:

### **Trước khi di chuyển**

* **Root filesystem:** 54G volume, 47G used (**92%**)
* **Containerd:** 27G (trên root)
* **Status:** FULL

### **Sau khi di chuyển**

* **Root filesystem:** 54G volume, 21G used (**40%**)
* **Containerd:** Đã chuyển sang `/mnt/e02/uenv` (27G)
* **Status:** HEALTHY

Kênh giải phóng: **26GB** (+52% khả dụng root filesystem).

***

## **10. Tài liệu tham khảo**

* **Containerd:** [https://containerd.io/docs/](https://containerd.io/docs/)
* **Docker:** [https://docs.docker.com/](https://docs.docker.com/)
* **LVM:** [https://ubuntu.com/server/docs/lvm2](https://ubuntu.com/server/docs/lvm2)
* **Systemd:** [https://systemd.io/](https://systemd.io/)

***

## **FAQ**

* **Q: Có ảnh hưởng gì đến containers không?**
  * **A:** Không. Containers sẽ restart tự động khi Docker start lại. Dữ liệu containers được lưu trên overlay filesystem, không bị mất.

* **Q: Nên chọn partition nào?**
  * **A:** Chọn partition có dung lượng trống >50GB, SSD ưu tiên để đảm bảo hiệu năng I/O.

* **Q: Có cần thay đổi Docker config không?**
  * **A:** Không. Docker chỉ phụ thuộc vào containerd config. Docker daemon vẫn sử dụng cấu hình hiện tại.

* **Q: Tốn bao lâu để di chuyển?**
  * **A:** Với ~27GB dữ liệu trên SSD, thời gian di chuyển khoảng 5-10 phút.

* **Q: Có thể di chuyển lại không?**
  * **A:** Được. Làm tương tự các bước trên với path đích khác. Lưu ý cập nhật config cho đúng.

***

## **Ghi chú**

* Hướng dẫn dựa trên Ubuntu 24.04 LTS, Docker CE, Containerd v1.7+, LVM + ext4.
* Các bản phân phối Linux khác có thể cần điều chỉnh nhỏ về đường dẫn và tên package.
* Luôn backup config trước khi thực hiện bất kỳ thay đổi nào.
