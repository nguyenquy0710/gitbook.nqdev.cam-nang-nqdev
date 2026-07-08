---
description: >-
  Turborepo là high-performance build system cho JavaScript/TypeScript monorepo
  của Vercel. Tìm hiểu kiến trúc, cài đặt và cách tối ưu CI/CD với task
  caching, remote cache và task graph.
---

# Turborepo — Build System Tối Ưu Cho Monorepo

Turborepo là **high-performance build system** cho JavaScript và TypeScript codebase, được phát triển bởi **Vercel**. Nó giải quyết vấn đề scaling của monorepo bằng cách tối ưu task scheduling, caching thông minh và parallel execution.

## 1. Tổng quan <a href="#id-1" id="id-1"></a>

Monorepo — nhiều package trong một repo — mang lại lợi ích về chia sẻ code, quản lý dependency tập trung, nhưng **rất khó scale**. Mỗi workspace có test suite, lint, build riêng. Một monorepo có thể có **hàng ngàn tasks** cần thực thi.

Turborepo giải quyết vấn đề này qua 3 cơ chế cốt lõi:

* **Task Graph (DAG):** Tự động xây dựng đồ thị dependency giữa các task, chạy song song tối đa dựa trên luồng dependency.
* **Caching:** Cache kết quả task dựa trên input (code, env, dependencies). Lần sau gặp input giống hệt → skip, replay output ngay lập tức.
* **Remote Cache:** Chia sẻ cache qua mạng, CI không bao giờ chạy lại việc đã làm.

## 2. So sánh: Với và không có Turborepo <a href="#id-2" id="id-2"></a>

| Yếu tố | Không Turborepo | Với Turborepo |
|---|---|---|
| Build app A, B + shared package | Chạy tuần tự từng cái | Chạy song song theo DAG |
| Lần build thứ 2 (không đổi code) | Chạy lại từ đầu | **~80ms** (replay từ cache) |
| CI build trên máy khác | Chạy lại toàn bộ | **Remote Cache** → tải kết quả |
| Cấu hình task dependency | Script tự viết, dễ sai | `dependsOn` trong `turbo.json` |

## 3. Cài đặt <a href="#id-3" id="id-3"></a>

### 3.1 Tạo dự án mới

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# pnpm
pnpm dlx create-turbo@latest

# npm
npx create-turbo@latest

# yarn
yarn dlx create-turbo@latest

# bun
bunx create-turbo@latest
```
{% endcode %}

Dự án starter bao gồm 2 ứng dụng deployable + 3 shared libraries.

### 3.2 Cài đặt global

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
pnpm add turbo --global
# hoặc
npm install turbo --global
# hoặc
yarn global add turbo
```
{% endcode %}

Sau khi cài global, chạy:

* `turbo build` — chạy task `build` theo dependency graph
* `turbo build --filter=docs` — chỉ chạy trong package `docs`
* `turbo generate` — sinh code mới (scaffolding)

### 3.3 Cài đặt trong repository (khuyến nghị)

Pin version cho cả team:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
pnpm add turbo --save-dev --ignore-workspace-root-check
# hoặc
npm install turbo --save-dev
```
{% endcode %}

Global turbo tự động defer về local version nếu có.

## 4. Cấu hình turbo.json <a href="#id-4" id="id-4"></a>

File `turbo.json` ở root là trái tim của Turborepo:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"],
      "inputs": ["$TASKFILES", "!node_modules"]
    },
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**/*.ts", "src/**/*.tsx"]
    },
    "lint": {
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```
{% endcode %}

**Giải thích các options chính:**

* **`dependsOn`:** Task dependency. `"^build"` = build của dependencies phải chạy trước.
* **`outputs`:** glob patterns chỉ định artifact cần cache.
* **`inputs`:** chỉ định file nào thay đổi mới invalidate cache.
* **`cache: false`:** tắt cache cho task dev (không cần thiết).
* **`persistent: true`:** task chạy liên tục (dev server), không timeout.

## 5. Core Concepts <a href="#id-5" id="id-5"></a>

### 5.1 Package Graph vs Task Graph

**Package Graph:** Cấu trúc dependency giữa các workspace do package manager tạo ra. Turborepo tự động đọc để hiểu quan hệ giữa các package.

**Task Graph:** Directed Acyclic Graph (DAG) thể hiện dependency giữa các **task**. Ví dụ:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": { "dependsOn": ["^build"] }
  }
}
```
{% endcode %}

Với cấu hình trên, khi chạy `turbo build`:
1. Package `ui` và `utils` build trước (vì `apps/web` phụ thuộc vào chúng)
2. `apps/web` build sau

Turborepo chạy song song tất cả task không có dependency lẫn nhau.

### 5.2 Local Caching

Mặc định Turborepo cache kết quả task vào `.turbo/cache/`. Cache key được tính từ:

* Nội dung file input (theo `inputs` glob)
* Environment variables (khai báo trong `turbo.json`)
* Lockfile hash

Khi cache hit → Turborepo replay logs và artifacts ngay lập tức (thường ~80ms thay vì vài phút).

### 5.3 Remote Caching

Chia sẻ cache giữa các máy — dev local, CI, đồng nghiệp — thông qua cloud.

**Kích hoạt với Vercel (miễn phí):**

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo login
turbo link
```
{% endcode %}

Có thể **self-host** Remote Cache với API tuân theo [OpenAPI spec](https://turborepo.dev/docs/openapi):

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo login --manual
```
{% endcode %}

Cộng đồng có sẵn các implementation open-source:
* [`brunojppb/turbo-cache-server`](https://github.com/brunojppb/turbo-cache-server)
* [`ducktors/turborepo-remote-cache`](https://github.com/ducktors/turborepo-remote-cache)

**Xác thực artifact** — bật `signature: true` trong `turbo.json` + set `TURBO_REMOTE_CACHE_SIGNATURE_KEY` để HMAC-SHA256 sign artifacts, chống giả mạo cache.

## 6. Running Tasks <a href="#id-6" id="id-6"></a>

### 6.1 Các lệnh cơ bản

| Lệnh | Mô tả |
|---|---|
| `turbo build` | Chạy task build trong tất cả package |
| `turbo run build test lint` | Chạy nhiều task, tối ưu scheduling |
| `turbo build --filter=@repo/web` | Chạy build cho 1 package cụ thể |
| `turbo build --filter=@repo/web...` | Bao gồm dependencies của package đó |
| `turbo build --dry` | Xem task graph mà không chạy thật |
| `turbo build --graph` | Xuất task graph visualization |
| `turbo build --summarize` | Tạo file summary cho phân tích |

### 6.2 Task Scheduling

Turborepo tự động:
1. Parse dependency graph từ `turbo.json`
2. Xác định thứ tự tối ưu
3. Parallelize tối đa dựa trên available cores
4. Cache kết quả từng task

### 6.3 Automatic Package Scoping

Khi chạy `cd apps/docs && turbo build`, Turborepo tự động scope vào package hiện tại và dependencies của nó — không cần `--filter`.

## 7. Structuring a Repository <a href="#id-7" id="id-7"></a>

Cấu trúc monorepo điển hình với Turborepo:

```
my-monorepo/
├── apps/
│   ├── web/          # Next.js app
│   └── docs/         # Documentation site
├── packages/
│   ├── ui/           # Shared UI components
│   ├── utils/        # Shared utilities
│   ├── types/        # Shared TypeScript types
│   └── config-eslint/# Shared ESLint config
├── tooling/
│   └── github/       # GitHub Actions workflows
├── turbo.json
├── package.json
├── pnpm-workspace.yaml
└── .gitignore
```

**Nguyên tắc:**
* `apps/`: ứng dụng deployable (Next.js, Vite, etc.)
* `packages/`: internal packages chia sẻ giữa các app
* `tooling/`: config tooling chung

## 8. Advanced Features <a href="#id-8" id="id-8"></a>

### 8.1 Prune

Tạo partial monorepo cho deployment — chỉ giữ lại package target và dependencies của nó:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo prune @repo/web --docker
```
{% endcode %}

Output: thư mục chứa đúng code cần thiết để build Docker image.

### 8.2 Boundaries

Enforce architectural rules — package `ui` không được import từ `web`:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo boundaries
```
{% endcode %}

Cấu hình trong `package.json`:

{% code title="./packages/ui/package.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "name": "@repo/ui",
  "dependencies": { ... },
  "turbo": {
    "boundaries": {
      "tags": ["ui"]
    }
  }
}
```
{% endcode %}

### 8.3 Watch Mode

Dependency-aware file watcher — khi file thay đổi, chỉ chạy lại task bị ảnh hưởng:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo watch build
```
{% endcode %}

### 8.4 Query (GraphQL)

Inspect monorepo với GraphQL:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
turbo query 'query { packages { name } }'
```
{% endcode %}

Hữu ích cho CI/CD scripting và tooling integration.

### 8.5 Environment Variables

Khai báo env vars ảnh hưởng đến cache:

{% code title="./turbo.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "tasks": {
    "build": {
      "env": ["NEXT_PUBLIC_API_URL", "MY_VAR"],
      "outputs": [".next/**"]
    }
  }
}
```
{% endcode %}

Thay đổi env → cache miss → rebuild.

## 9. CI/CD Integration <a href="#id-9" id="id-9"></a>

Ví dụ GitHub Actions workflow tối ưu với Turborepo:

{% code title=".github/workflows/ci.yml" overflow="wrap" lineNumbers="true" %}
```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install
      - run: pnpm turbo build test lint
        env:
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ vars.TURBO_TEAM }}
```
{% endcode %}

Với Remote Cache, CI chỉ build những package thay đổi — giảm thời gian từ 30 phút xuống còn vài giây.

## 10. Ecosystem và Package Manager <a href="#id-10" id="id-10"></a>

Turborepo hoạt động với mọi package manager phổ biến:

| PM | Workspace support | Ghi chú |
|---|---|---|
| pnpm | ✅ Native | Khuyến nghị — strict isolation |
| npm | ✅ OK | Cần workspaces |
| yarn | ✅ OK | Yarn Berry hoặc Classic |
| bun | ✅ Experimental | Đang phát triển |

## 11. Lưu ý quan trọng <a href="#id-11" id="id-11"></a>

* **Không global install trùng:** Chỉ dùng 1 package manager để cài global, tránh conflict.
* **Cache logs là artifacts:** Logs cũng được cache và replay — không in secret ra console.
* **Environment variables:** Khai báo đầy đủ trong `turbo.json` nếu không muốn cache sai.
* **Transit Nodes:** Nếu package A không có task `build` nhưng dependencies của nó có, Turborepo vẫn build dependencies (hành vi DAG thuần túy).
* **Single-package workspace:** Turborepo cũng hoạt động với repo chỉ có 1 package — vẫn được hưởng caching và task scheduling.

## Tài liệu tham khảo

* [Turborepo Documentation](https://turborepo.dev/docs)
* [GitHub: vercel/turborepo](https://github.com/vercel/turborepo)
* [Remote Caching API Spec](https://turborepo.dev/docs/openapi)
* [Vercel Remote Cache](https://vercel.com/docs/monorepos/remote-caching)
