---
description: >-
  Hướng dẫn chạy tasks trong Turborepo — scripts trong package.json, global
  turbo, chạy đa tasks, automatic scoping, output logs và troubleshooting.
---

# Running Tasks — Chạy Và Quản Lý Tasks

Sau khi cấu hình tasks trong `turbo.json`, Turborepo cung cấp nhiều cách để chạy chúng — từ `package.json` scripts, global CLI, cho đến filter linh hoạt.

## 1. Chạy qua scripts trong package.json <a href="#id-1" id="id-1"></a>

Cách đơn giản nhất: viết `turbo` commands vào root `package.json`:

```json
{
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint"
  }
}
```

Sau đó chạy bằng package manager:

```bash
pnpm build
# hoặc
npm run build
```

> **Khuyến nghị:** Dùng `turbo run build` thay vì `turbo build` trong `package.json` để tránh conflict với subcommands tương lai.

> **Cảnh báo:** Chỉ viết `turbo` commands trong root `package.json`. Viết trong package sẽ gây recursive gọi `turbo`.

## 2. Chạy qua Global Turbo <a href="#id-2" id="id-2"></a>

Cài global (`pnpm add turbo --global`) → chạy trực tiếp từ terminal:

```bash
turbo build
turbo run build test lint
turbo build --filter=@repo/web
turbo build --dry
turbo build --output-logs=errors-only
```

### Automatic Package Scoping

Khi đang trong thư mục của một package, `turbo` tự động scope:

```bash
cd apps/docs
turbo build  # chỉ chạy build cho docs + dependencies
```

Filter tường minh (`--filter`) sẽ override behavior này.

## 3. Chạy nhiều tasks cùng lúc <a href="#id-3" id="id-3"></a>

```bash
turbo run build test lint check-types
```

Turborepo tự động:
1. Parse dependency graph từ `turbo.json`
2. Xác định thứ tự tối ưu (DAG)
3. Parallelize tối đa dựa trên available cores

> Thứ tự liệt kê không quan trọng. `turbo test lint` = `turbo lint test`. Dependency do `dependsOn` quyết định.

## 4. Output Logs <a href="#id-4" id="id-4"></a>

Kiểm soát log verbosity:

| Lệnh | Kết quả |
|---|---|
| `turbo build` | Full logs (mặc định) |
| `turbo build --output-logs=hash-only` | Chỉ hash |
| `turbo build --output-logs=new-only` | Chỉ cache miss |
| `turbo build --output-logs=errors-only` | Chỉ lỗi |
| `turbo build --output-logs=none` | Không logs |

Cấu hình permanent trong `turbo.json`:

```json
{
  "tasks": {
    "lint": {
      "outputLogs": "errors-only"
    }
  }
}
```

## 5. Task Graph Visualization <a href="#id-5" id="id-5"></a>

```bash
turbo build --graph
```

Xuất đồ thị DAG của tasks dạng `.dot` (có thể render với Graphviz).

## 6. Dry Run <a href="#id-6" id="id-6"></a>

Xem task sẽ chạy thế nào mà không chạy thật:

```bash
turbo build --dry

turbo build --dry=json  # JSON format, dễ parse
```

Output gồm: packages, tasks, dependencies, hash của từng task. Dùng để debug cache miss.

## 7. Customizing Behavior <a href="#id-7" id="id-7"></a>

### Override turbo.json từ CLI

```bash
# Override outputLogs
turbo lint --output-logs=errors-only

# Override concurrency
turbo build --concurrency=2

# Override cache
turbo build --no-cache
turbo build --force

# Override env mode
turbo build --env-mode=loose
```

### Passthrough arguments

Truyền argument cho script bên dưới:

```bash
turbo build -- --my-flag value
```
Lưu ý: passthrough args ảnh hưởng global hash → miss cache.

## 8. Common Workflows <a href="#id-8" id="id-8"></a>

```bash
# Build tất cả
turbo run build

# Build + test + lint
turbo run build test lint

# Chỉ 1 package
turbo build --filter=@repo/web

# Package + dependencies của nó
turbo build --filter=@repo/web...

# Package + dependents của nó
turbo build --filter=...@repo/web

# Chỉ package thay đổi từ commit trước
turbo build --filter=[HEAD^1]

# Dev mode (nhiều app cùng lúc)
turbo run dev

# Type-check toàn bộ
turbo run typecheck
```

## 9. Lưu ý <a href="#id-9" id="id-9"></a>

- Task không có trong `turbo.json` nhưng có trong `package.json` → chạy được nhưng không có caching/parallel
- Dùng `turbo run <task>` thay vì `turbo <task>` trong script scripts để an toàn
- `--dry` và `--graph` là công cụ debug mạnh khi cache behavior không như mong đợi

## Tài liệu tham khảo

- [Running Tasks (official)](https://turborepo.dev/docs/crafting-your-repository/running-tasks)
- [`turbo run` reference](https://turborepo.dev/docs/reference/run)
- [Configuring Tasks](https://turborepo.dev/docs/crafting-your-repository/configuring-tasks)
