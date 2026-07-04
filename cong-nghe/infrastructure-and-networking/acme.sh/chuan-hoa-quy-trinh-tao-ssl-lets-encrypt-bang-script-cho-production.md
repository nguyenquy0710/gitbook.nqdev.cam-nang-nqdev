# Chuẩn hoá quy trình tạo SSL Let’s Encrypt bằng script cho Production

Ở bài trước, **Cẩm nang NQDEV** đã phân tích vì sao **acme.sh + DNS-01** là lựa chọn tối ưu cho SSL production, đặc biệt trong kiến trúc hiện đại: Docker, HAProxy, Cloud, CI/CD.

👉 Bài này sẽ đi tiếp một bước quan trọng hơn:\
**biến tư duy đúng thành một quy trình chạy được – an toàn – lặp lại – mở rộng**.

<figure><img src="https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/cong-nghe/acme-serial2-001.png" alt=""><figcaption></figcaption></figure>

Chúng ta không chỉ “cấp SSL thành công”, mà xây dựng **một pipeline SSL có thể vận hành lâu dài**.

***

### 1. Tư duy thiết kế trước khi viết script

Trước khi nhìn vào code, cần thống nhất **tư duy kiến trúc**:

* SSL **không gắn cứng** với web server
* SSL được xem là **tài nguyên hạ tầng dùng chung**
* Cấp phát – gia hạn – reload phải **tự động hoàn toàn**
* Có thể mở rộng cho:
  * Multi-domain
  * Wildcard
  * HAProxy / Nginx / Docker

Script bạn đang sử dụng đã phản ánh rất rõ tư duy này.

***

### 2. Cấu trúc tổng thể của bộ script

Toàn bộ giải pháp được chia thành **4 thành phần rõ ràng**:

```
.
├── config.env          # Cấu hình môi trường (DNS, thư mục, container)
├── domains.conf        # Danh sách domain / wildcard
├── issue-all.sh        # Script cấp & cài SSL
└── renew-hook.sh       # Hook xử lý sau khi renew
```

👉 Đây là **chuẩn production**:

* Tách cấu hình khỏi logic
* Dễ audit, dễ backup, dễ CI/CD

***

### 3. \`domains.conf\` – Quản lý domain theo tư duy hạ tầng

{% code title="domains.conf" %}
```conf
# Each line contains a domain for which wildcard SSL will be issued
quyit.id.vn
```
{% endcode %}

#### Vì sao không hard-code domain trong script?

* Tránh sửa code khi thêm domain
* Cho phép **platform team** quản lý domain độc lập
* Dễ tích hợp pipeline (GitOps)

👉 Mỗi dòng = **một đơn vị hạ tầng SSL**\
Wildcard `*.quyit.id.vn` sẽ tự động được cấp kèm domain gốc.

***

### 4. `config.env` – Trái tim cấu hình của hệ thống SSL

Đây là nơi **tách biệt bí mật và môi trường**:

{% code title="config.env" %}
```env
ACME_HOME=/root/.acme.sh
DNS_PROVIDER=dns_cf

CF_Key=xxxxxxxx
CF_Email=admin@example.com

CERT_DIR=/opt/ssl
HAPROXY_DIR_SSL=/opt/haproxy/ssl
HAPROXY_CONTAINER=haproxy
```
{% endcode %}

#### Điểm đáng chú ý

* Không hard-code API key trong script
* Có thể thay Cloudflare bằng Route53, DO, v.v.
* Phù hợp cho:
  * Docker secrets
  * Vault
  * CI/CD environment variables

👉 Đây chính là tư duy **NQDEV Platform**: cấu hình là tài sản, không phải code.

***

### 5. `issue-all.sh` – Engine cấp phát SSL

Script này đảm nhiệm **3 vai trò chính**:

#### 5.1 Kiểm tra & bootstrap môi trường

```bash
require_root
install_acme
```

* Ép chạy với quyền root → tránh lỗi permission
* Tự động cài acme.sh nếu chưa có

👉 Script **idempotent**: chạy lại không gây hỏng hệ thống.

***

#### 5.2 Cấp SSL wildcard qua DNS-01

```bash
"${ACME_HOME}/acme.sh" \
  --issue \
  --dns "${DNS_PROVIDER}" \
  -d "*.domain.com" \
  -d "domain.com"
```

**Lợi ích chiến lược**:

* Không phụ thuộc port 80
* Hỗ trợ wildcard
* Phù hợp môi trường private network

Đây chính là lý do **DNS-01 được ưu tiên cho production**.

***

#### 5.3 Cài chứng chỉ & hook reload

```bash
--install-cert \
--reloadcmd "${BASE_DIR}/renew-hook.sh"
```

Điểm mấu chốt:

* acme.sh chỉ lo cấp SSL
* Mọi logic “sau khi có SSL” được chuyển sang hook

👉 Giữ **single responsibility principle**.

{% code title="issue-all.sh" %}
```bash
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${BASE_DIR}/config.env"

DOMAINS_FILE="${BASE_DIR}/domains.conf"
FORCE="false"

log() {
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    log "ERROR: You must run this script as root."
    exit 1
  fi
}

install_acme() {
  if [[ ! -x "${ACME_HOME}/acme.sh" ]]; then
    log "acme.sh not found. Installing..."
    curl -s https://get.acme.sh | sh
    "${ACME_HOME}/acme.sh" --set-default-ca --server letsencrypt
  fi
}

# Function to issue single domain certificates
issue_cert() {
  local domain="$1"
  log "Issuing SSL certificate for domain: ${domain}"
  
  # Debugging: Print CF_Key and CF_Email to verify they are loaded
  echo "Loaded CF_Key=${CF_Key}, CF_Email=${CF_Email}"
  
  # Ensure the credentials are exported explicitly
  export CF_Key="${CF_Key}"
  export CF_Email="${CF_Email}"

  # Run acme.sh to issue a single domain certificate using Cloudflare DNS
  if [[ "$FORCE" == "true" ]]; then
    "${ACME_HOME}/acme.sh" \
      --issue \
      -d "${domain}" \
      --dns "${DNS_PROVIDER}" \
      --force \
      --server letsencrypt
  else
    "${ACME_HOME}/acme.sh" \
      --issue \
      -d "${domain}" \
      --dns "${DNS_PROVIDER}" \
      --server letsencrypt
  fi

  "${ACME_HOME}/acme.sh" \
    --install-cert -d "${domain}" \
    --key-file       "${CERT_DIR}/${domain}.key" \
    --fullchain-file "${CERT_DIR}/${domain}.cer" \
    --reloadcmd      "${BASE_DIR}/renew-hook.sh"
}

# Function to issue wildcard certificates
issue_wildcard_cert() {
  local domain="$1"
  log "Issuing SSL certificate for domain: ${domain}"
  
  # Check if the domain is wildcard
  local wildcard_domain="*.${domain}"

  # Debugging: Print CF_Key and CF_Email to verify they are loaded
  echo "Loaded CF_Key=${CF_Key}, CF_Email=${CF_Email}"
  
  # Ensure the credentials are exported explicitly
  export CF_Key="${CF_Key}"
  export CF_Email="${CF_Email}"

  # Run acme.sh with wildcard flag using Cloudflare DNS
  if [[ "$FORCE" == "true" ]]; then
    "${ACME_HOME}/acme.sh" \
      --issue \
      --dns "${DNS_PROVIDER}" \
      -d "${wildcard_domain}" \
      -d "${domain}" \
      --force \
      --server letsencrypt
  else
    "${ACME_HOME}/acme.sh" \
      --issue \
      --dns "${DNS_PROVIDER}" \
      -d "${wildcard_domain}" \
      -d "${domain}" \
      --server letsencrypt
  fi

  # Install the wildcard certificate
  "${ACME_HOME}/acme.sh" \
    --install-cert -d "${domain}" \
    --key-file       "${CERT_DIR}/${domain}.key" \
    --fullchain-file "${CERT_DIR}/${domain}.cer" \
    --reloadcmd      "${BASE_DIR}/renew-hook.sh"
}

# Main script execution
main() {
  # Check for the --force argument
  if [[ $# -gt 0 && "$1" == "--force" ]]; then
    FORCE="true"
    log "Force mode enabled: All certificates will be renewed even if not expired."
  fi

  require_root
  install_acme

  mkdir -p "${CERT_DIR}"
  chmod 700 "${CERT_DIR}"
  chmod 700 "${HAPROXY_DIR_SSL}"

  while read -r domain; do
    [[ -z "$domain" || "$domain" =~ ^# ]] && continue
    # issue_cert "$domain"
    issue_wildcard_cert "$domain"
  done < "${DOMAINS_FILE}"

  log "SSL certificates issued for all specified domains."
}

# Invoke main with all script arguments
main "$@"
```
{% endcode %}

***

### 6. `renew-hook.sh` – Chuẩn hoá SSL cho HAProxy & Nginx

Hook này thực hiện **3 nhiệm vụ quan trọng**:

#### 6.1 Chuẩn hoá định dạng chứng chỉ

* Tách:
  * Certificate
  * Private key
  * CA bundle
* Ghép lại thành `.crt` cho HAProxy

```bash
cat cert + ca + key > haproxy.crt
```

👉 HAProxy **yêu cầu strict format**, nếu làm sai → downtime.

***

#### 6.2 Quản lý permission an toàn

```bash
chmod 600 *.key *.crt
```

* Ngăn rò rỉ private key
* Đáp ứng security baseline production

***

#### 6.3 Reload HAProxy không downtime

```bash
docker kill -s HUP haproxy
```

* Reload graceful
* Không ngắt kết nối hiện tại
* Không restart container

👉 Đây là điểm khác biệt giữa **demo** và **production**.

{% code title="renew-hook.sh" %}
```bash
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${BASE_DIR}/config.env"

log() {
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

log "Rebuilding certificate files for Nginx and HAProxy..."

for cer in ${CERT_DIR}/*.cer; do
  domain=$(basename "$cer" .cer)
  
  # Paths for Nginx
  cert_path="${CERT_DIR}/${domain}.certificate.crt"
  key_path="${CERT_DIR}/${domain}.private.key"
  ca_bundle_path="${CERT_DIR}/${domain}.ca_bundle.crt"

  # Paths for HAProxy
  haproxy_cert_path="${HAPROXY_DIR_SSL}/${domain}.crt"

  # Extract and create files for Nginx
  sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' "${CERT_DIR}/${domain}.cer" > "${cert_path}"
  cp "${CERT_DIR}/${domain}.key" "${key_path}"
  sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' "${CERT_DIR}/${domain}.cer" | tail -n +2 > "${ca_bundle_path}"

  cat \
    "${cert_path}" \
    "${ca_bundle_path}" \
    "${key_path}" \
    > "${haproxy_cert_path}"

  # Permissions
  chmod 600 "${cert_path}" "${key_path}" "${ca_bundle_path}" "${haproxy_cert_path}"

  log "Created HAProxy certificate files for ${domain}:"
  log "- ${cert_path} (Certificate)"
  log "- ${key_path} (Private Key)"
  log "- ${ca_bundle_path} (CA Bundle)"
done

log "Reloading HAProxy container..."
docker kill -s HUP "${HAPROXY_CONTAINER}"

log "HAProxy reloaded successfully."
```
{% endcode %}

***

### 7. Auto-renew: SSL tự vận hành như hạ tầng

acme.sh tự tạo cron:

* Check \~ mỗi ngày
* Renew trước hạn \~30 ngày
* Tự động gọi `renew-hook.sh`

👉 Khi đã setup xong, **bạn gần như không cần động tay vào SSL nữa**.

***

### 8. Góc nhìn chiến lược từ Cẩm nang NQDEV

Script này không chỉ là “tool” – nó là:

* Một **mẫu kiến trúc SSL**
* Một **nền móng để mở rộng**
* Một bước tiến từ _admin thủ công_ → _platform automation_

Trong tương lai, bạn có thể:

* Đồng bộ SSL vào Kubernetes Secret
* Tạo SSL service nội bộ
* Gắn alert khi renew fail
* Tích hợp GitOps / CI/CD

***

### Kết luận

Nếu bài trước trả lời câu hỏi:\
&#xNAN;**“Vì sao nên dùng acme.sh cho production?”**

Thì bài này trả lời rõ ràng hơn:\
&#xNAN;**“Làm thế nào để triển khai acme.sh đúng chuẩn production, có thể vận hành nhiều năm?”**

SSL không chỉ là bảo mật.\
SSL là **kỷ luật hạ tầng**.

Và đó chính là triết lý mà **Cẩm nang NQDEV** và **NQDEV Platform** luôn theo đuổi.

***

#### Gist hosted with ❤ by [GitHub](https://github.com/)

{% embed url="https://gist.github.com/nguyenquy0710/8ad0a11c29959a624186f81bd6d67118" %}
