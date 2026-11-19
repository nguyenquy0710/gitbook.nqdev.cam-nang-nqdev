---
description: "PMM v3.10: kiến trúc, Query Analytics, Advisor, Alerting, Backup/PITR, HA Cluster và quickstart Docker"
---

# Tìm hiểu Percona Monitoring and Management (PMM)

**Percona Monitoring and Management (PMM)** là công cụ mã nguồn mở để giám sát, quan sát và quản lý cơ sở dữ liệu **MySQL, PostgreSQL, MongoDB, Valkey/Redis**, cùng máy chủ chạy chúng. PMM tự lưu trữ (self-hosted), mọi tính năng đều mở; Percona bán hỗ trợ, không bán tính năng. Phiên bản hiện tại: **PMM 3.10.0** (22/10/2026).

## Khái niệm cơ bản

* **PMM Server:** máy chủ trung tâm lưu metric, query data và dashboard. Gồm Grafana (UI/dashboard/alert), VictoriaMetrics (time-series, PromQL-compatible), ClickHouse (Query Analytics), PostgreSQL (metadata).
* **PMM Client:** agent chạy cạnh database (`pmm-agent` + exporters), thu thập metric và gửi lên PMM Server.
* **Query Analytics (QAN):** xếp hạng mọi query theo tải, xem ví dụ, EXPLAIN plan, thống kê bảng.
* **Advisors:** kiểm tra tự động bảo mật, cấu hình, hiệu năng từ kinh nghiệm Percona.
* **Alerting:** template alert có sẵn, gửi qua 15+ kênh liên lạc của Grafana.
* **Backup & PITR:** backup MongoDB và MySQL, khôi phục tại thời điểm cụ thể (PITR).

## Kiến trúc tổng quát

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/databases/percona-pmm/pmm-kien-truc-tong-quat.svg" alt="Kiến trúc tổng quát PMM" width="900"><figcaption><p>Kiến trúc tổng quát PMM: Database → PMM Client → PMM Server</p></figcaption></figure>

| Thành phần | Vai trò | Công nghệ |
| ---------- | ------- | --------- |
| PMM Server | Lưu metrics, query data, dashboard, alert | Grafana, VictoriaMetrics, ClickHouse, PostgreSQL |
| PMM Client | Chạy cạnh DB, thu thập & gửi dữ liệu | `pmm-agent`, exporters, `pmm-admin` |
| Database | Nguồn dữ liệu giám sát | MySQL/MariaDB, PostgreSQL, MongoDB, Valkey/Redis, ProxySQL, HAProxy, RDS/Aurora/Azure/GCP |

> PMM đọc thống kê DB đã có sẵn (Performance Schema, slow log, `pg_stat_statements`/`pg_stat_monitor`, profiler/log Mongo) và bạn chọn nguồn query cho từng service, nên ảnh hưởng tối thiểu đến database.

## Tính năng nổi bật

* **Query Analytics:** xếp hạng query theo tải, drill-down từ fleet xuống một query, anomaly detection, dashboard query tùy chỉnh.
* **Dashboards:** cho node → instance → query, riêng theo engine (InnoDB, WiredTiger, PostgreSQL vacuum, v.v.), xây trên Grafana.
* **Alerting:** template sẵn, contact point bất kỳ, override ngưỡng theo từng node.
* **Advisors:** CVE awareness, kiểm tra cấu hình, tối ưu hiệu năng, compliance liên tục.
* **Backup & Restore:** MongoDB có PITR; MySQL trong Technical Preview.
* **Quản lý mới (3.10):** Apps (MySQL Backups, Support diagnostics), Operations for MongoDB early access, PMM HA Cluster GA (OpenShift, ARM64 Server).
* **Hỗ trợ cloud:** Amazon RDS/Aurora, Azure, Google Cloud — thêm instance từ UI, không cần cài agent trên host.

## Quickstart

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/databases/percona-pmm/pmm-quickstart-workflow.svg" alt="PMM Quickstart workflow" width="900"><figcaption><p>Quickstart: Server → Client → Add service → Query Analytics</p></figcaption></figure>

### Bước 1: Khởi động PMM Server (Docker)

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
curl -fsSL https://www.percona.com/get/pmm | /bin/bash
```
{% endcode %}

Truy cập `https://<server-ip>`, đăng nhập `admin` / `admin`, rồi đổi mật khẩu.

### Bước 2: Cài PMM Client và kết nối database

{% tabs %}
{% tab title="MySQL" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb
sudo percona-release enable pmm3-client release
sudo apt update && sudo apt install -y pmm-client

sudo pmm-admin config --server-insecure-tls --server-url=https://admin:<password>@<server-ip>:443
sudo pmm-admin add mysql --username=pmm --password=<pass> --query-source=perfschema
```
{% endcode %}
{% endtab %}
{% tab title="PostgreSQL" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
sudo pmm-admin config --server-insecure-tls --server-url=https://admin:<password>@<server-ip>:443
sudo pmm-admin add postgresql --username=pmm --password=<pass>
```
{% endcode %}
{% endtab %}
{% tab title="MongoDB" %}
{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
sudo pmm-admin config --server-insecure-tls --server-url=https://admin:<password>@<server-ip>:443
sudo pmm-admin add mongodb --username=pmm --password=<pass>
```
{% endcode %}
{% endtab %}
{% endtabs %}

Mở **Query Analytics**; query xuất hiện trong khoảng một phút. User `pmm` cần quyền tương ứng (xem docs kết nối từng engine). PMM Server cũng chạy được bằng Docker/Podman/Kubernetes (Helm)/AWS Marketplace.

## So sánh nhanh

| Tiêu chí | PMM | Prometheus+Grafana tự dựng | Datadog DB Monitoring | pganalyze |
| -------- | --- | ------------------------- | --------------------- | --------- |
| Query analytics per-query | Có sẵn | Tự xây | Có | Có (chỉ PG) |
| Dashboard/advisor/alert template | Có sẵn | Lắp tay | Có | Có |
| Nơi lưu dữ liệu | Server của bạn | Server của bạn | Cloud nhà cung cấp | Cloud |
| Chi phí | Miễn phí, OSS | Miễn phí + thời gian | Per host/tháng | Thương mại |
| Engine hỗ trợ | MySQL, PG, Mongo, Valkey/Redis | Tùy exporter | Nhiều | Chỉ PostgreSQL |

## Cài đặt & vận hành nâng cao

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/databases/percona-pmm/pmm-ha-backup-alerting.svg" alt="PMM HA Cluster, Backup và Alerting" width="900"><figcaption><p>PMM HA Cluster (Raft quorum), Backup/Restore lên S3 và Alerting</p></figcaption></figure>

### HA Cluster (GA từ PMM 3.10)

PMM HA Cluster chạy 1/3/5 replica PMM Server trên Kubernetes/OpenShift, dùng Raft quorum.

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
helm repo add percona https://percona.github.io/percona-helm-charts/
helm upgrade --install pmm-ha percona/pmm-ha -n pmm --create-namespace
```
{% endcode %}

* **Scale:** 1, 3 hoặc 5 replica; Helm từ chối số chẵn.
* **Nâng cấp:** `helm upgrade` rolling, replica restart tuần tự.
* **Backup/Restore:** backup PostgreSQL, ClickHouse, VictoriaMetrics, PMM Server data và encryption key lên S3/shared volume, on-demand hoặc theo lịch; restore tại chỗ hoặc namespace mới.
* **Lưu ý:** mọi node dùng chung encryption key; đặt `dataRetentionDays` trong chart; alert built-in cho no leader, split-brain, quorum at risk, PV >80%.

### Backup & Restore

* **MongoDB:** backup hot/incremental/physical/logical + PITR.
* **MySQL:** Technical Preview, dùng XtraBackup/Mydumper/Binlog.
* **Lưu trữ:** S3-compatible hoặc shared volume; theo dõi job status, loại backup, lịch sử thực thi.
* **Quản lý:** qua **Backups > All backups** hoặc app **MySQL Backups** (Tech Preview).

### Alerting

1. Cấu hình **Contact point** (email, Slack, PagerDuty, v.v.).
2. Bật/chỉnh template từ **Alerts > Templates**; PMM 3.10 tự tạo alert cho VictoriaMetrics, ClickHouse, Grafana, QAN API.
3. Override ngưỡng theo từng node từ **Inventory > Nodes** (cần role Admin) cho template hỗ trợ Dynamic.
4. PMM HA có alert riêng: no active leader, split-brain, leader flapping, node unreachable, quorum at risk, PV >80%.

## Lưu ý production

{% hint style="warning" %}
Trong production, dùng chứng chỉ tin cậy và bỏ `--server-insecure-tls`; đăng ký bằng service account token thay vì mật khẩu admin. PMM Server mặc định Grafana chỉ listen loopback, truy cập qua nginx.
{% endhint %}

* **Không làm chậm DB:** client đọc stats DB đã có sẵn; chọn nguồn query phù hợp (`perfschema`/slow log, `pg_stat_statements`/`pg_stat_monitor`).
* **HA:** PMM 3.10 hỗ trợ HA Cluster 1/3/5 replica, backup/restore lên S3, alert built-in cho component.
* **ARM64:** `percona/pmm-server:3` có build ARM64 (Graviton) tự chọn theo host; Apps chỉ amd64.

## Tài liệu tham khảo

* [Percona PMM — trang sản phẩm](https://www.percona.com/monitoring/)
* [PMM Documentation v3](https://docs.percona.com/percona-monitoring-and-management/3/index.html)
* [Quickstart](https://docs.percona.com/percona-monitoring-and-management/3/quickstart/quickstart.html)
* [GitHub: percona/pmm (latest v3.10.0)](https://github.com/percona/pmm/releases/tag/v3.10.0)
* [Live demo](https://pmmdemo.percona.com/graph/)