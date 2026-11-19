---
description: >-
  Giám sát Kubernetes với metrics-server, kube-prometheus-stack (Prometheus,
  Grafana, Alertmanager), Loki/Promtail cho logs và bộ alert rules mẫu production.
---

# Giám sát Kubernetes với Prometheus, Grafana và Loki

Cluster chạy mà không có giám sát là chạy mù. Bài này dựng stack giám sát hoàn chỉnh cho cluster self-host: metrics (Prometheus), dashboard (Grafana), logs (Loki) và cảnh báo (Alertmanager) — tất cả qua Helm.

## Kiến trúc monitoring tổng quan

Ba loại tín hiệu, ba công cụ khác nhau:

* **Metrics:** số đo theo thời gian (CPU %, RAM, số Pod restart, request/s). Prometheus thu thập và lưu time-series; Grafana vẽ dashboard; `kubectl top` và HPA dùng metrics-server.
* **Logs:** dòng chữ ứng dụng/container in ra. Loki gom log từ mọi node (qua Promtail hoặc Grafana Alloy), truy vấn bằng LogQL ngay trong Grafana — không cần đánh index nặng như Elasticsearch.
* **Alerts:** quy tắc "khi metric vượt ngưỡng thì báo". Prometheus đánh giá alert rules, Alertmanager route tới Slack/Telegram/email, trực tiếp hoặc qua webhook.

{% code title="Luồng dữ liệu giám sát" overflow="wrap" lineNumbers="false" %}
```text
[node-exporter, kube-state-metrics, kubelet/cAdvisor, app /metrics]
        │  (Prometheus scrape)
        ▼
   Prometheus ──► Alertmanager ──► Slack/Telegram/email
        │  (alert rules)
        ▼
     Grafana ◄──── Loki ◄──── Promtail/Alloy (DaemonSet mọi node)
   (dashboard + LogQL)          (đọc log container)

[metrics-server] ──► kubectl top + HPA   (luồng riêng, ngắn hạn)
```
{% endcode %}

{% hint style="info" %}
**metrics-server ≠ Prometheus, không thay thế nhau.** metrics-server chỉ giữ số đo CPU/RAM mới nhất trong RAM, phục vụ `kubectl top` và HPA — không lưu lịch sử, không alert, không dashboard. Prometheus lưu time-series dài hạn với hàng nghìn metrics, phục vụ giám sát/cảnh báo/phân tích. Cluster production cần CẢ HAI.
{% endhint %}

## Bước 1: metrics-server

Nếu đã cài ở bài cấu hình ứng dụng thì bỏ qua bước này.

{% code title="Cài metrics-server từ manifest chính thức" overflow="wrap" lineNumbers="true" %}
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Chờ ~1 phút rồi verify:
kubectl top nodes
kubectl top pods -A
```
{% endcode %}

{% hint style="warning" %}
Lab kubeadm self-host kubelet thường dùng serving cert self-signed → metrics-server log lỗi `x509: cannot validate certificate for ... because it doesn't contain any IP SANs`. Cách đúng production: cấu hình kubelet serving cert được ký bởi CA cluster. Lab có thể patch args `--kubelet-insecure-tls` cho Deployment `metrics-server` trong namespace `kube-system` — chỉ dùng cho môi trường lab.
{% endhint %}

Vai trò với HPA: HPA đọc CPU/memory utilization từ API `metrics.k8s.io` do metrics-server cung cấp. Không có metrics-server, HPA báo `<unknown>` và không scale — xem lại bài cấu hình ứng dụng:

{% content-ref url="cau-hinh-ung-dung-tren-kubernetes-deployment-service-ingress.md" %}
[cau-hinh-ung-dung-tren-kubernetes-deployment-service-ingress](cau-hinh-ung-dung-tren-kubernetes-deployment-service-ingress.md)
{% endcontent-ref %}

## Bước 2: kube-prometheus-stack qua Helm

Chart `kube-prometheus-stack` (repo prometheus-community) cài trọn bộ trong một lệnh:

* **Prometheus:** thu thập + lưu metrics, đánh giá alert rules.
* **Grafana:** dashboard, kèm sẵn bộ dashboard Kubernetes.
* **Alertmanager:** gom nhóm/route cảnh báo.
* **node-exporter:** DaemonSet xuất metrics phần cứng/OS từng node (CPU, disk, network).
* **kube-state-metrics:** xuất metrics trạng thái object K8s (Pod status, Deployment replicas, PVC...).
* **Prometheus Operator:** quản lý Prometheus/ServiceMonitor/PrometheusRule bằng CRD.

{% code title="Cài kube-prometheus-stack vào namespace monitoring" overflow="wrap" lineNumbers="true" %}
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kps prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

kubectl get pods -n monitoring
# Chờ tất cả Running: prometheus, alertmanager, grafana,
# operator, node-exporter (mỗi node 1 Pod), kube-state-metrics
```
{% endcode %}

{% hint style="info" %}
Production nên chỉnh qua `values.yaml`: retention (`prometheus.prometheusSpec.retention: 15d`), PVC cho Prometheus/Grafana (mặc định emptyDir — restart là mất dữ liệu), tài nguyên requests/limits. Xem toàn bộ keys: `helm show values prometheus-community/kube-prometheus-stack`.
{% endhint %}

### Truy cập Grafana

{% code title="Port-forward Grafana + lấy mật khẩu admin" overflow="wrap" lineNumbers="true" %}
```bash
# Mật khẩu mặc định của chart (user: admin)
kubectl get secret -n monitoring kps-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d; echo

# Port-forward ra máy local
kubectl port-forward -n monitoring svc/kps-grafana 3000:80
# Mở http://localhost:3000 — đăng nhập admin + mật khẩu ở trên
```
{% endcode %}

### Dashboard gợi ý

Chart đã kèm nhiều dashboard Kubernetes. Import thêm từ grafana.com (Dashboards → Import → nhập ID):

| Dashboard ID | Tên | Dùng cho |
| ------------ | --- | -------- |
| **1860** | Node Exporter Full | Chi tiết OS/phần cứng từng node |
| **15760** | Kubernetes / Views / Pods | Tài nguyên + trạng thái theo Pod |
| **15757** | Kubernetes / Views / Nodes | Tổng quan node |
| **13332** | kube-state-metrics v2 | Trạng thái object cluster |

{% hint style="info" %}
Truy cập Prometheus/Alertmanager khi debug: `kubectl port-forward -n monitoring svc/kps-kube-prometheus-stack-prometheus 9090:9090` — mở `http://localhost:9090/targets` xem scrape targets, `/alerts` xem alert đang fire.
{% endhint %}

## Bước 3: Logs với Loki + Promtail

Loki lưu log theo label (như Prometheus nhưng cho log), nhẹ hơn nhiều so với Elasticsearch vì không full-text index. Promtail chạy DaemonSet đọc log container từng node đẩy về Loki.

{% code title="Cài Loki stack (Loki + Promtail) chế độ SingleBinary" overflow="wrap" lineNumbers="true" %}
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# values tối thiểu cho cluster nhỏ: 1 bản Loki, bật Promtail
cat <<EOF > loki-values.yaml
deploymentMode: SingleBinary
loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
singleBinary:
  replicas: 1
  persistence:
    enabled: true
    size: 10Gi
# Tắt các thành phần của chế độ distributed
backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0
# Promtail đẩy log về Loki
promtail:
  enabled: true
EOF

helm install loki grafana/loki -n monitoring -f loki-values.yaml

kubectl get pods -n monitoring -l app.kubernetes.io/instance=loki
```
{% endcode %}

{% hint style="info" %}
Promtail đang chuyển sang chế độ bảo trì, Grafana khuyến nghị **Grafana Alloy** cho cài mới (chart `grafana/alloy`, cấu hình `loki.source.kubernetes` + `loki.write`). Promtail vẫn chạy tốt và đơn giản cho cluster nhỏ; khi dựng mới hoàn toàn có thể chọn Alloy ngay từ đầu.
{% endhint %}

Thêm Loki làm datasource trong Grafana: **Connections → Data sources → Add data source → Loki**, URL:

{% code title="URL Loki datasource (đổi tên release nếu khác)" overflow="wrap" lineNumbers="true" %}
```text
http://loki.monitoring.svc.cluster.local:3100
```
{% endcode %}

Truy vấn log bằng LogQL trong Grafana → Explore:

{% code title="LogQL mẫu" overflow="wrap" lineNumbers="true" %}
```bash
# Log của namespace demo
{namespace="demo"}

# Log Pod cụ thể, lọc chữ ERROR
{namespace="demo", pod=~"demo-web.*"} |= "ERROR"

# Đếm số dòng error mỗi phút theo container
sum by (container) (rate({namespace="demo"} |= "error" [1m]))
```
{% endcode %}

## Bước 4: Alert rules mẫu

kube-prometheus-stack nhận alert rules qua CRD `PrometheusRule`. Bộ rule tối thiểu nên có: node NotReady, Pod crash/restart nhiều, CPU/memory pressure, disk sắp đầy, PVC sắp đầy.

{% code title="alert-rules.yaml — PrometheusRule tối thiểu" overflow="wrap" lineNumbers="true" %}
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cluster-alerts
  namespace: monitoring
  labels:
    release: kps   # phải khớp label release của kube-prometheus-stack
spec:
  groups:
    - name: cluster.rules
      rules:
        # Node NotReady quá 5 phút
        - alert: KubeNodeNotReady
          expr: kube_node_status_condition{condition="Ready",status="true"} == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Node {{ $labels.node }} NotReady"
            description: "Node {{ $labels.node }} không ở trạng thái Ready hơn 5 phút."

        # Pod CrashLoopBackOff
        - alert: KubePodCrashLooping
          expr: kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"} > 0
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} CrashLoopBackOff"

        # Container restart nhiều trong 15 phút
        - alert: KubeContainerRestartsHigh
          expr: increase(kube_pod_container_status_restarts_total[15m]) > 3
          for: 0m
          labels:
            severity: warning
          annotations:
            summary: "{{ $labels.namespace }}/{{ $labels.pod }} restart > 3 lần/15 phút"

        # CPU node > 90% trong 10 phút
        - alert: NodeCPUHigh
          expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "CPU node {{ $labels.instance }} > 90%"

        # Memory node > 90%
        - alert: NodeMemoryHigh
          expr: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 90
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "RAM node {{ $labels.instance }} > 90%"

        # Disk còn dưới 10% (filesystem thật, bỏ qua tmpfs)
        - alert: NodeDiskAlmostFull
          expr: |
            (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"}
              / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}) * 100 < 10
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "Disk {{ $labels.instance }} {{ $labels.mountpoint }} còn < 10%"

        # PVC còn dưới 10% dung lượng
        - alert: KubePVCAlmostFull
          expr: |
            (kubelet_volume_stats_available_bytes
              / kubelet_volume_stats_capacity_bytes) * 100 < 10
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "PVC {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} còn < 10%"
```
{% endcode %}

{% code title="Apply + verify rules đã nạp" overflow="wrap" lineNumbers="true" %}
```bash
kubectl apply -f alert-rules.yaml

# Prometheus UI: Status -> Rules phải thấy group cluster.rules
kubectl port-forward -n monitoring svc/kps-kube-prometheus-stack-prometheus 9090:9090
```
{% endcode %}

{% hint style="warning" %}
Label `release: kps` trên PrometheusRule phải khớp tên release Helm của kube-prometheus-stack, nếu không Prometheus Operator sẽ bỏ qua rule (kiểm tra `ruleSelector` trong values). Alert fire rồi nhưng không nhận được thông báo: cấu hình receiver trong Alertmanager (`alertmanager.config` của chart — Slack/Telegram/email), mặc định chart không gửi đi đâu cả.
{% endhint %}

## Xác minh toàn bộ stack

{% code title="Checklist monitoring" overflow="wrap" lineNumbers="true" %}
```bash
kubectl top nodes                          # metrics-server OK
kubectl get pods -n monitoring             # toàn bộ Running
kubectl get prometheusrule -n monitoring   # rules đã tạo

# Grafana: dashboard có dữ liệu, Explore Loki trả về log
# Prometheus: /targets đều UP, /rules thấy cluster.rules
```
{% endcode %}

## Tài liệu tham khảo

* [metrics-server — GitHub](https://github.com/kubernetes-sigs/metrics-server)
* [kube-prometheus-stack — Artifact Hub](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
* [Prometheus Documentation — prometheus.io](https://prometheus.io/docs/)
* [Grafana Dashboards — grafana.com](https://grafana.com/grafana/dashboards/)
* [Loki Documentation — grafana.com](https://grafana.com/docs/loki/latest/)
* [Grafana Alloy — grafana.com](https://grafana.com/docs/alloy/latest/)
* [Helm Documentation — helm.sh](https://helm.sh/docs/)