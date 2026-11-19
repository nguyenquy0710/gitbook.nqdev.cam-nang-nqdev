---
description: >-
  Kubernetes là gì? Hiểu declarative model, kiến trúc control plane và worker
  node, object model Pod/Deployment/Service, và khi nào không cần Kubernetes.
---

# Kubernetes là gì? Kiến trúc và các thành phần cốt lõi

Kubernetes (viết tắt K8s) là hệ thống orchestration container mã nguồn mở: bạn khai báo trạng thái mong muốn (desired state) bằng YAML, Kubernetes tự động đưa hệ thống về đúng trạng thái đó và giữ nó ổn định theo thời gian. Bài này là nền tảng lý thuyết cho cả series self-host kubeadm.

## Kubernetes là gì?

### Declarative + reconciliation loop

Hai ý tưởng cốt lõi làm nên Kubernetes:

* **Declarative (khai báo):** bạn mô tả "tôi muốn 3 bản sao của app này chạy", KHÔNG mô tả các bước "start container A, rồi B, rồi C". File YAML là nguồn sự thật duy nhất.
* **Reconciliation loop (vòng lặp điều hoà):** các controller liên tục so sánh trạng thái thực tế (actual state) với trạng thái khai báo. Nếu lệch — Pod chết, node sập, replica thiếu — controller tự sửa: tạo lại Pod, reschedule sang node khác.

👉 Đây là lý do K8s "self-healing": bạn không cần script giám sát-restart tự viết, bản thân hệ thống đã là một vòng lặp tự sửa lỗi.

### Lịch sử ngắn

* **2003–2004:** Google vận hành nội bộ hệ thống Borg (sau này là Omega) để quản lý hàng trăm nghìn container.
* **2014:** Google open source Kubernetes, viết bằng Go, kế thừa tư duy Borg.
* **2015:** Kubernetes 1.0 ra mắt, Google tặng dự án cho CNCF (Cloud Native Computing Foundation).
* **Hiện nay:** K8s là chuẩn de-facto của container orchestration, mọi cloud lớn đều có managed Kubernetes (EKS, GKE, AKS).

## Kiến trúc tổng quan

Một cluster gồm **control plane** (bộ não) và các **worker node** (nơi chạy workload):

{% code title="Kiến trúc cluster Kubernetes (ASCII)" overflow="wrap" lineNumbers="false" %}
```text
┌────────────────────────── CONTROL PLANE ──────────────────────────┐
│                                                                   │
│  kubectl ──► kube-apiserver ◄──► etcd (store toàn bộ trạng thái)  │
│                   ▲                                               │
│         ┌─────────┴──────────┐                                    │
│   kube-scheduler    kube-controller-manager                       │
│  (chọn node cho Pod)  (reconciliation loops)                      │
└──────────────────────────────┬────────────────────────────────────┘
                               │ (watch/report qua apiserver)
        ┌──────────────────────┼──────────────────────┐
┌───────┴────────┐    ┌────────┴───────┐    ┌─────────┴──────┐
│  WORKER NODE 1 │    │  WORKER NODE 2 │    │  WORKER NODE N │
│  kubelet       │    │  kubelet       │    │  kubelet       │
│  kube-proxy    │    │  kube-proxy    │    │  kube-proxy    │
│  containerd    │    │  containerd    │    │  containerd    │
│  [Pod][Pod]    │    │  [Pod][Pod]    │    │  [Pod]...      │
└────────────────┘    └────────────────┘    └────────────────┘
```
{% endcode %}

### Control plane

* **kube-apiserver:** cửa ngõ duy nhất của cluster. Mọi thành phần (kubectl, kubelet, controller) đều giao tiếp qua REST API của apiserver. Xác thực, phân quyền (RBAC), validation đều xảy ra ở đây.
* **etcd:** database key-value phân tán, lưu TOÀN BỘ trạng thái cluster (mọi object YAML bạn apply). Mất etcd không backup = mất cluster.
* **kube-scheduler:** theo dõi Pod chưa được gán node, chọn node phù hợp dựa trên resources requests, affinity, taint/toleration.
* **kube-controller-manager:** chạy các controller (Deployment, ReplicaSet, Node, Job...). Mỗi controller là một reconciliation loop riêng.

### Worker node

* **kubelet:** agent chạy trên mỗi node, nhận PodSpec từ apiserver, đảm bảo container trong Pod chạy đúng khai báo, báo cáo trạng thái node/Pod về control plane.
* **kube-proxy:** duy trì rule mạng (iptables/IPVS) trên node để traffic tới Service được chuyển đúng tới các Pod backend.
* **containerd:** container runtime thực sự chạy container (chuẩn CRI). Docker Engine cũng dùng containerd bên dưới; K8s bỏ dockershim từ v1.24 nên containerd là lựa chọn mặc định phổ biến nhất.

## Object model — các tài nguyên cần biết

Mọi thứ trong K8s là object khai báo bằng YAML (`apiVersion`, `kind`, `metadata`, `spec`):

### Nhóm workload

* **Pod:** đơn vị deploy nhỏ nhất — một hoặc nhiều container chia sẻ network namespace (chung IP) và volume. Pod là "ephemeral": chết là tạo lại Pod mới với IP mới, không bao giờ sửa Pod tại chỗ.
* **ReplicaSet:** đảm bảo đúng N bản sao Pod chạy tại mọi thời điểm. Hiếm khi tạo trực tiếp — Deployment quản lý ReplicaSet cho bạn.
* **Deployment:** object phổ biến nhất để chạy app stateless. Quản lý ReplicaSet, hỗ trợ rolling update và rollback (`kubectl rollout undo`).
* **StatefulSet:** cho app stateful (database, Kafka...): mỗi Pod có tên cố định (`db-0`, `db-1`), thứ tự khởi động/dừng xác định, mỗi Pod gắn một PVC riêng.
* **DaemonSet:** đảm bảo mỗi node (hoặc node được chọn) chạy đúng 1 Pod — dùng cho agent như log collector (Promtail), node-exporter, CNI.
* **Job / CronJob:** Job chạy tác vụ đến khi hoàn thành (migration, batch); CronJob chạy Job theo lịch cron (backup đêm, report).

### Nhóm network

* **Service:** IP + DNS name ổn định đứng trước nhóm Pod thay đổi liên tục. Các loại: ClusterIP (nội bộ), NodePort (mở port trên mọi node), LoadBalancer (tích hợp LB của cloud).
* **Ingress:** định tuyến HTTP/HTTPS từ bên ngoài vào Service theo hostname/path, kèm TLS. Cần một Ingress Controller (phổ biến: ingress-nginx) chạy trong cluster.

### Nhóm cấu hình & lưu trữ

* **ConfigMap:** lưu cấu hình không nhạy cảm (key-value, file config), inject vào Pod qua env hoặc mount file.
* **Secret:** như ConfigMap nhưng cho dữ liệu nhạy cảm (password, token, TLS key). Mặc định chỉ encode base64 — nên bật encryption at rest cho etcd ở production.
* **Namespace:** phân vùng logic tài nguyên trong cluster (team, môi trường). KHÔNG phải isolation mạng mặc định — muốn chặn traffic giữa namespace cần NetworkPolicy.
* **PersistentVolume (PV) / PersistentVolumeClaim (PVC):** PV là mảnh storage thực tế; PVC là "phiếu yêu cầu" storage của Pod. Pod khai báo PVC, K8s bind PVC với PV phù hợp.
* **StorageClass:** định nghĩa "loại" storage và provisioner để tự động tạo PV khi có PVC (dynamic provisioning) — ví dụ local-path, NFS, Ceph RBD, cloud disk.

## So sánh Docker Compose vs Kubernetes

| Tiêu chí | Docker Compose | Kubernetes |
| -------- | -------------- | ---------- |
| Phạm vi | 1 host | Nhiều node (cluster) |
| Khai báo | 1 file `compose.yaml` | Nhiều object YAML, tách bạch |
| Self-healing | Restart container tại chỗ (`restart: always`) | Reschedule Pod sang node khác khi node chết |
| Scaling | `--scale` thủ công, 1 host | Replica + HPA tự động theo CPU/memory |
| Rolling update / rollback | Không native | Deployment hỗ trợ sẵn |
| Load balancing / service discovery | DNS nội bộ đơn giản | Service + Ingress + kube-proxy |
| Storage | Bind mount / volume trên host | PV/PVC/StorageClass, dynamic provisioning |
| Độ phức tạp vận hành | Thấp — vài lệnh | Cao — control plane, etcd, CNI, upgrade, backup |
| Chi phí tài nguyên tối thiểu | Vài chục MB | Control plane ~2 CPU / 2GB RAM trở lên |

## Khi nào KHÔNG cần Kubernetes

{% hint style="warning" %}
Kubernetes không phải mục tiêu, nó là công cụ. App nhỏ, team 1–3 người, chạy trên 1 VPS: **Docker Compose là đủ** — đơn giản hơn nhiều, ít thứ phải vận hành hơn nhiều. K8s chỉ đáng tiền khi bạn thực sự cần: nhiều node, tự động failover giữa các node, scale tự động, rolling update không downtime, hoặc chuẩn hoá platform cho nhiều team/nhiều service. Đừng mang "bộ điều khiển tàu vũ trụ" đi chạy một chiếc xe máy.
{% endhint %}

Dấu hiệu bạn CHƯA cần K8s:

* **Một host là đủ tải:** app + database nằm gọn trên 1 VPS, chưa có kế hoạch multi-node.
* **Không có người vận hành:** không ai trực xử lý sự cố cluster, upgrade, backup etcd.
* **Deploy thưa:** vài lần/tháng, downtime vài giây chấp nhận được — Compose + script deploy là đủ.
* **Chưa container hoá xong:** chưa có Dockerfile chuẩn thì học K8s là đốt cháy giai đoạn.

## Bước tiếp theo

Hiểu kiến trúc rồi, bắt tay dựng cluster thật:

{% content-ref url="cai-dat-cluster-kubernetes-bang-kubeadm-tren-ubuntu.md" %}
[cai-dat-cluster-kubernetes-bang-kubeadm-tren-ubuntu](cai-dat-cluster-kubernetes-bang-kubeadm-tren-ubuntu.md)
{% endcontent-ref %}

## Tài liệu tham khảo

* [Kubernetes Overview — kubernetes.io](https://kubernetes.io/docs/concepts/overview/)
* [Cluster Architecture — kubernetes.io](https://kubernetes.io/docs/concepts/architecture/)
* [Kubernetes Objects — kubernetes.io](https://kubernetes.io/docs/concepts/overview/working-with-objects/)
* [Nodes — kubernetes.io](https://kubernetes.io/docs/concepts/architecture/nodes/)