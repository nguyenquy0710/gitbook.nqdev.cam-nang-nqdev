---
description: >-
  Hướng dẫn chi tiết cấu hình turbo.json trong Turborepo — tasks, caching,
  global options, environment variables, remote cache, boundaries và
  experimental observability.
---

# Configuring turbo.json — Cấu Hình Chi Tiết

`turbo.json` là file cấu hình trung tâm của Turborepo, đặt tại thư mục gốc của monorepo. Nó định nghĩa **task graph, caching behavior, environment variables** và các global options.

Hỗ trợ cả `.jsonc` (thêm comment).

## 1. Global Options <a href="#id-1" id="id-1"></a>

Các option áp dụng cho toàn bộ monorepo:

### extends

Kế thừa cấu hình từ root `turbo.json`:

{% code title="./apps/web/turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "extends": ["//"]
}
```
{% endcode %}

`"//"` = reference root. Có thể extends từ nhiều package khác: `["//", "shared-config"]`.

### globalDependencies

Glob patterns — file nào thay đổi thì **all tasks miss cache**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "globalDependencies": ["tsconfig.json", ".env"]
}
```
{% endcode %}

Mặc định root `package.json` + lockfile luôn được include.

### globalEnv

Env vars ảnh hưởng đến hash của **tất cả tasks**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "globalEnv": ["GITHUB_TOKEN", "NODE_ENV"]
}
```
{% endcode %}

### globalPassThroughEnv

Cho phép env vars đi qua task runtime, nhưng **không ảnh hưởng cache hash**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "globalPassThroughEnv": ["AWS_SECRET_KEY"]
}
```
{% endcode %}

### ui

Chọn terminal UI:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "ui": "stream"
}
```
{% endcode %}

* `"tui"` — interactive, xem từng log
* `"stream"` — log xuất trực tiếp (mặc định)

### concurrency

Giới hạn số tasks chạy song song:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "concurrency": 4
}
```
{% endcode %}

* Số nguyên ≥ 1
* Percentage: `"50%"` — dùng 50% số cores
* `1` — chạy tuần tự

### cacheDir

Thư mục lưu cache local:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "cacheDir": ".turbo/cache"
}
```
{% endcode %}

### cacheMaxAge

Tự động xóa cache entries cũ theo thời gian:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "cacheMaxAge": "7d"
}
```
{% endcode %}

Hỗ trợ: `30s`, `5m`, `24h`, `7d`, `2w`. Mặc định `"0"` (tắt).

### cacheMaxSize

Giới hạn dung lượng cache local:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "cacheMaxSize": "10GB"
}
```
{% endcode %}

Hỗ trợ: `500MB`, `10GB`, `1TB`. Chạy sau age-based eviction.

## 2. Tasks <a href="#id-2" id="id-2"></a>

### dependsOn

Định nghĩa dependency giữa các tasks — ba loại:

**Dependency relationship** (`^` prefix — chờ task build của dependencies xong trước):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}
```
{% endcode %}

**Same-package relationship** (chờ task khác trong cùng package):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "test": {
      "dependsOn": ["lint", "build"]
    }
  }
}
```
{% endcode %}

**Arbitrary task relationship** (giữa các package cụ thể):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "web#lint": {
      "dependsOn": ["utils#build"]
    }
  }
}
```
{% endcode %}

### env

Khai báo env vars ảnh hưởng cache hash của task:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "env": ["DATABASE_URL", "API_KEY"]
    }
  }
}
```
{% endcode %}

Hỗ trợ **wildcards**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "env": ["MY_API_*"]
    }
  }
}
```
{% endcode %}

Hỗ trợ **negation**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "env": ["!MY_API_URL"]
    }
  }
}
```
{% endcode %}

### passThroughEnv

Cho phép env vars vào task runtime (strict mode) nhưng **không ảnh hưởng hash**:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "passThroughEnv": ["AWS_SECRET_KEY"]
    }
  }
}
```
{% endcode %}

### outputs

Glob patterns chỉ định artifacts cần cache:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "outputs": ["dist/**", ".next/**"]
    }
  }
}
```
{% endcode %}

* Bỏ qua hoặc `[]` → chỉ cache logs
* Dùng negations: `"!.next/cache/**"`

### inputs

Kiểm soát file nào thay đổi mới invalidate cache:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "test": {
      "inputs": ["src/**/*.ts", "test/**/*.ts"]
    }
  }
}
```
{% endcode %}

**Ghi chú quan trọng:** Dùng `inputs` sẽ **opt-out** khỏi default `.gitignore` behavior. Dùng `$TURBO_DEFAULT$` để giữ default + mở rộng:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "check-types": {
      "inputs": ["$TURBO_DEFAULT$", "!README.md"]
    }
  }
}
```
{% endcode %}

**$TURBO_ROOT$** — glob relative đến repository root:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "check-types": {
      "inputs": ["$TURBO_ROOT$/tsconfig.json", "src/**/*.ts"]
    }
  }
}
```
{% endcode %}

**Deferred Hashing** — hash files sau khi dependencies chạy xong:

* `mode: "jit"` — hash ngay trước khi task chạy
* `mode: "dependencyOutputs"` — hash dựa trên outputs của dependency

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "dependsOn": ["codegen"],
      "inputs": [
        "$TURBO_DEFAULT$",
        "!src/generated/**",
        { "mode": "jit", "globs": ["src/generated/**"] }
      ]
    }
  }
}
```
{% endcode %}

### cache

Tắt cache cho task (dev server):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```
{% endcode %}

### outputLogs

Kiểm soát log verbosity:

| Option | Mô tả |
|---|---|
| `full` | Hiển thị tất cả logs (mặc định) |
| `hash-only` | Chỉ hiển thị hash |
| `new-only` | Chỉ log từ cache misses |
| `errors-only` | Chỉ log khi task fail |
| `none` | Ẩn tất cả |

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "outputLogs": "new-only"
    }
  }
}
```
{% endcode %}

### persistent / interactive / interruptible

* **`persistent: true`** — task chạy lâu dài (dev server). Các task khác không được dependsOn nó.
* **`interactive: true`** — nhận input từ `stdin`, cần đi với `persistent`.
* **`interruptible: true`** — cho phép `turbo watch` restart task persistent.

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "test:watch": {
      "interactive": true,
      "persistent": true
    }
  }
}
```
{% endcode %}

### with

Chạy task song song với task khác (hữu ích cho dev server):

{% code title="./apps/web/turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "dev": {
      "with": ["api#dev"],
      "persistent": true,
      "cache": false
    }
  }
}
```
{% endcode %}

### description

Mô tả task (chỉ để documentation):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "description": "Compiles the application for production deployment"
    }
  }
}
```
{% endcode %}

## 3. Remote Caching <a href="#id-3" id="id-3"></a>

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "remoteCache": {
    "enabled": true,
    "signature": true,
    "preflight": false,
    "timeout": 30,
    "uploadTimeout": 60,
    "apiUrl": "https://vercel.com",
    "loginUrl": "https://vercel.com",
    "teamId": "team_xxx",
    "teamSlug": "my-team"
  }
}
```
{% endcode %}

* **`signature: true`** — sign artifacts với HMAC-SHA256. Cần set `TURBO_REMOTE_CACHE_SIGNATURE_KEY`.
* **`preflight`** — OPTIONS request trước mỗi HTTP request.
* **`timeout` / `uploadTimeout`** — timeout tính bằng seconds.

## 4. Future Flags <a href="#id-4" id="id-4"></a>

Các tính năng thử nghiệm sẽ trở thành default trong tương lai:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "futureFlags": {
    "errorsOnlyShowHash": true,
    "longerSignatureKey": true,
    "affectedUsingTaskInputs": true,
    "watchUsingTaskInputs": true,
    "pruneIncludesGlobalFiles": true,
    "filterUsingTasks": true,
    "globalConfiguration": true,
    "experimentalObservability": true
  }
}
```
{% endcode %}

* **`errorsOnlyShowHash`** — khi dùng `outputLogs: "errors-only"`, vẫn hiện hash cho task thành công.
* **`longerSignatureKey`** — enforce key ≥ 32 bytes cho HMAC-SHA256.
* **`affectedUsingTaskInputs`** — `--affected` hoạt động ở task-level (dựa trên `inputs`), không phải package-level.
* **`pruneIncludesGlobalFiles`** — `turbo prune` copy cả `globalDependencies` files.
* **`filterUsingTasks`** — `--filter` hoạt động ở task-level.
* **`globalConfiguration`** — dồn global options vào key `global`:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "futureFlags": { "globalConfiguration": true },
  "global": {
    "inputs": ["tsconfig.json"],
    "env": ["NODE_ENV"],
    "passThroughEnv": ["AWS_SECRET_KEY"],
    "ui": "tui",
    "envMode": "strict",
    "concurrency": 4,
    "remoteCache": { ... }
  }
}
```
{% endcode %}

## 5. Boundaries <a href="#id-5" id="id-5"></a>

Enforce architectural rules giữa các package:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "boundaries": {
    "utils": {
      "dependencies": {
        "allow": ["ui"],
        "deny": ["unsafe"]
      },
      "dependents": {
        "allow": ["web"]
      }
    }
  }
}
```
{% endcode %}

Tags được khai báo trong Package Configurations:

{% code title="./apps/web/turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tags": ["web"]
}
```
{% endcode %}

## 6. Experimental Observability <a href="#id-6" id="id-6"></a>

Gửi metrics đến OTLP collector (Datadog, Prometheus, etc.):

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "futureFlags": { "experimentalObservability": true },
  "experimentalObservability": {
    "otel": {
      "enabled": true,
      "protocol": "grpc",
      "endpoint": "https://api.datadoghq.com/api/v2/otlp",
      "headers": {
        "DD-API-KEY": "xxx"
      },
      "timeoutMs": 10000,
      "intervalMs": 15000,
      "resource": {
        "service.name": "turborepo"
      },
      "metrics": {
        "runSummary": true,
        "taskDetails": false,
        "runAttributes": {
          "id": false,
          "scmRevision": false
        },
        "taskAttributes": {
          "id": false,
          "hashes": false
        }
      },
      "useRemoteCacheToken": false
    }
  }
}
```
{% endcode %}

**Lưu ý:** Endpoint bắt buộc dùng `https://`. Headers và token gắn với endpoint — nếu override endpoint từ nguồn ưu tiên cao hơn, credentials không được kế thừa.

## 7. Env Mode <a href="#id-7" id="id-7"></a>

Kiểm soát env vars available cho task:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "envMode": "strict"
}
```
{% endcode %}

* `"strict"` (default) — chỉ cho phép env vars khai báo trong `env` và `globalEnv`.
* `"loose"` — cho phép tất cả env vars của process.

## 8. Ví dụ Hoàn Chỉnh <a href="#id-8" id="id-8"></a>

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://turborepo.dev/schema.json",
  "globalDependencies": ["tsconfig.json"],
  "globalEnv": ["NODE_ENV", "CI"],
  "concurrency": 4,
  "cacheDir": ".turbo/cache",
  "cacheMaxAge": "7d",
  "cacheMaxSize": "10GB",
  "ui": "stream",
  "remoteCache": {
    "signature": true
  },
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "inputs": ["$TURBO_DEFAULT$", "!README.md"],
      "env": ["NEXT_PUBLIC_API_URL"]
    },
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**/*.ts", "test/**/*.ts"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "outputs": [],
      "outputLogs": "errors-only"
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "inputs": ["$TURBO_DEFAULT$", "!**/*.test.ts"]
    }
  },
  "experimentalObservability": {
    "otel": {
      "enabled": true,
      "protocol": "grpc",
      "endpoint": "https://otel-collector:4317"
    }
  }
}
```
{% endcode %}

## Tài liệu tham khảo

* [Turborepo Configuration Reference](https://turborepo.dev/docs/reference/configuration)
* [Package Configurations](https://turborepo.dev/docs/reference/package-configurations)
* [System Environment Variables](https://turborepo.dev/docs/reference/system-environment-variables)
* [File Globs](https://turborepo.dev/docs/reference/globs)
