# nqdev/postgres-pgagent

Đây là container PostgreSQL tùy chỉnh với pgAgent và HTTP extension, được phát triển bởi NQDEV team. Container này tích hợp đầy đủ các tính năng để quản lý job scheduling và HTTP requests trực tiếp từ PostgreSQL.

### 🚀 Khởi động nhanh



```
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
docker-compose up -d --build --force-recreate --remove-orphans
```

### 🧱 Thành phần & Tính năng



#### Core Components



* **PostgreSQL 17.5**: Database engine chính với timezone Vietnam (`Asia/Ho_Chi_Minh`)
* **pgAgent**: Hệ thống job scheduling cho PostgreSQL
* **HTTP Extension**: Cho phép thực hiện HTTP requests từ PostgreSQL
* **Multi-stage Build**: Tối ưu kích thước image với builder pattern

#### Tính năng đặc biệt



* ✅ **Tự động khởi tạo extensions** (pgagent, http)
* ✅ **Error handling** với trap mechanism trong shell scripts
* ✅ **Custom initialization scripts** với logging chi tiết
* ✅ **Wait-for-it utility** để đảm bảo database sẵn sàng
* ✅ **Data checksums** mặc định cho integrity checking
* ✅ **Resource limits** (CPU: 80%, RAM: 3.2G)

### 📦 Build & Deployment



#### Build với version tùy chỉnh



```
# Build với PostgreSQL version mặc định (17.5)
docker build -t nqdev/postgres-pgagent:latest .

# Build với version khác
docker build --build-arg VERSION=16.4 -t nqdev/postgres-pgagent:16.4 .
```

#### Docker Compose (Khuyến nghị)



```
# # # # # PostgreSQL + pgAgent, pgsql-http extension
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
# # # # #

services:
  postgres-pgagent:
    container_name: postgres-pgagent-custom
    image: postgres:17.5-custom
    build:
      context: ./
      dockerfile: ./Dockerfile
    ports:
      - "5432:5432"
    environment:
      TZ: Asia/Ho_Chi_Minh
      POSTGRES_USER: ${POSTGRES_USER:-superuser}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-superuser}
      POSTGRES_DB: ${POSTGRES_DB:-postgresdb}
      POSTGRES_HOST_AUTH_METHOD: trust
      POSTGRES_PORT: ${POSTGRES_PORT:-5432}
      POSTGRES_INITDB_ARGS: ${POSTGRES_INITDB_ARGS:-"--data-checksums"}
    env_file:
      - .env
    volumes:
      - ./data:/var/lib/postgresql/data:rw
    extra_hosts:
      - "host.docker.internal:host-gateway"
    dns:
      - 1.1.1.1
      - 1.0.0.1
      - 8.8.8.8
      - 8.8.4.4
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "5"
    deploy:
      resources:
        limits:
          cpus: "0.80"
          memory: "3.2G"
        reservations:
          memory: "256M"
```

#### Standalone Docker



```
docker run -d \
  --name postgres-pgagent-custom \
  -e POSTGRES_PASSWORD=superuser \
  -e POSTGRES_USER=superuser \
  -e POSTGRES_DB=postgresdb \
  -e TZ=Asia/Ho_Chi_Minh \
  -v ./data:/var/lib/postgresql/data:rw \
  -p 5432:5432 \
  nqdev/postgres-pgagent:latest
```

### 🗂️ Cấu trúc Container



#### Thư mục chính



```
/docker-entrypoint-initdb.d/          # Auto-initialization scripts
├── 10-init-http.sql                  # HTTP extension setup
└── 11-init-pgagent.sql               # pgAgent extension setup

/nqdev/postgres/                       # Custom NQDEV structure
├── data/                              # Database data (volume mount)
├── logs/                              # Application logs (volume mount)
└── scripts/                           # Shell utilities
    ├── 00-init-custom.sh              # Custom SQL initialization
    ├── 01-docker-entrypoint.sh        # Main entrypoint script
    ├── 02-docker-ensure-initdb.sh     # Init verification
    └── 10-wait-for-it.sh              # Connection utility
```

#### Library locations



* **HTTP Extension**: `/usr/lib/postgresql/17/lib/http.so`
* **pgAgent**: Installed via system packages
* **PostgreSQL Server Dev**: `/usr/include/postgresql/`

### 🧪 Sử dụng Extensions



#### HTTP Extension



```
-- Kích hoạt extension
CREATE EXTENSION IF NOT EXISTS http;

-- Thực hiện GET request
SELECT status, content::json
FROM http_get('https://api.github.com/repos/octocat/Hello-World');

-- POST request với data
SELECT status, content
FROM http_post('https://httpbin.org/post',
               '{"key": "value"}',
               'application/json');
```

#### pgAgent Job Scheduling



```
-- Kích hoạt extension
CREATE EXTENSION IF NOT EXISTS pgagent;

-- Tạo job đơn giản
DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
    -- Tạo job
    INSERT INTO pgagent.pga_job (jobjclid, jobname)
    VALUES (1, 'Daily Maintenance') RETURNING jobid INTO jid;

    -- Tạo step
    INSERT INTO pgagent.pga_jobstep (jstjobid, jstname, jstkind, jstcode)
    VALUES (jid, 'Analyze Tables', 's', 'ANALYZE;');
END $$;
```

### ⚙️ Biến môi trường



| Biến                        | Mặc định           | Mô tả                   |
| --------------------------- | ------------------ | ----------------------- |
| `POSTGRES_USER`             | `superuser`        | Username cho PostgreSQL |
| `POSTGRES_PASSWORD`         | `superuser`        | Password (bắt buộc)     |
| `POSTGRES_DB`               | `postgresdb`       | Database name mặc định  |
| `POSTGRES_HOST_AUTH_METHOD` | `trust`            | Phương thức xác thực    |
| `POSTGRES_PORT`             | `5432`             | Port PostgreSQL         |
| `POSTGRES_INITDB_ARGS`      | `--data-checksums` | Tham số initdb          |
| `TZ`                        | `Asia/Ho_Chi_Minh` | Timezone                |

### 🔧 Scripts & Automation



#### Initialization Flow



1. **00-init-custom.sh**: Thực thi custom SQL scripts với error handling
2. **01-docker-entrypoint.sh**: Main PostgreSQL entrypoint với extended features
3. **02-docker-ensure-initdb.sh**: Đảm bảo database được khởi tạo đúng cách

#### Error Handling Features



* Global error trapping với `set -Eeo pipefail`
* Detailed logging cho mọi bước initialization
* Graceful error messages với line number tracking

#### Wait-for-it Utility



```
# Đợi PostgreSQL sẵn sàng
./scripts/10-wait-for-it.sh localhost:5432 --timeout=30 -- echo "PostgreSQL is ready!"
```

### 🔍 Health Checks & Monitoring



#### Kiểm tra trạng thái



```
# Kết nối database
docker exec -it postgres-pgagent-custom psql -U superuser -d postgresdb

# Kiểm tra extensions
docker exec -it postgres-pgagent-custom psql -U superuser -d postgresdb -c "\dx"

# Xem logs
docker logs postgres-pgagent-custom
```

#### Performance Monitoring



```
-- Kiểm tra connection stats
SELECT * FROM pg_stat_activity;

-- Monitor job execution (pgAgent)
SELECT * FROM pgagent.pga_joblog ORDER BY jlgstart DESC LIMIT 10;
```

### 📋 Volumes & Data Management



#### Recommended Volume Mounts



```
# Persistent data storage
-v ./data:/var/lib/postgresql/data:rw

# Log access (optional)
-v ./logs:/nqdev/postgres/logs:rw

# Custom config (optional)
-v ./custom-config:/nqdev/postgres/config:ro
```

#### Backup Strategy



```
# Database dump
docker exec postgres-pgagent-custom pg_dump -U superuser postgresdb > backup.sql

# Full data directory backup (với container dừng)
docker-compose down
tar -czf postgres-backup-$(date +%Y%m%d).tar.gz ./data
docker-compose up -d
```

### 🔒 Security Notes



* **Host Auth Method**: Mặc định `trust` cho development, khuyến nghị `scram-sha-256` cho production
* **Network Security**: Container isolated với custom DNS servers
* **Resource Limits**: CPU 80%, Memory 3.2G để tránh system overload
* **Data Checksums**: Enabled mặc định cho data integrity

### 🚀 Production Deployment



#### Docker Compose Override



```
# docker-compose.prod.yml
services:
  postgres-pgagent:
    environment:
      POSTGRES_HOST_AUTH_METHOD: scram-sha-256
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - postgres-logs:/nqdev/postgres/logs
    networks:
      - postgres-network

volumes:
  postgres-data:
    driver: local
  postgres-logs:
    driver: local

networks:
  postgres-network:
    driver: bridge
```

### 📜 License



Distributed under the MIT License. See `LICENSE` for more information.

### 👨‍💻 Maintainer



**NQDEV Team**

* 📧 Email: [quynh@nhquydev.net](mailto:quynh@nhquydev.net)
* 🌐 Website: [nhquydev.net](https://nhquydev.net/)
* 📦 Container Registry: [GitHub Packages](https://github.com/nqdev-group/containers/pkgs/container/postgres-pgagent)
