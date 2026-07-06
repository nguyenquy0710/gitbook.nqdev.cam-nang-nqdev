---
description: >-
  Hướng dẫn cấu trúc monorepo với Turborepo — workspace setup, package types,
  internal packages, exports, và common pitfalls.
---

# Structuring a Monorepo — Cấu Trúc Repository

Turborepo xây dựng trên **Workspaces** — tính năng của package manager (pnpm, npm, yarn) cho phép nhóm nhiều packages trong một repo.

## 1. Minimum Requirements <a href="#id-1" id="id-1"></a>

Một monorepo hợp lệ cần:

1. **Package manager lockfile** — `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `bun.lock`
2. **Root `package.json`** — `private: true`, scripts gọi `turbo`
3. **Root `turbo.json`** — cấu hình tasks
4. **Workspace declaration** — `pnpm-workspace.yaml` hoặc `workspaces` trong root `package.json`
5. **`package.json` trong mỗi package**

### Cấu trúc thư mục chuẩn:

```
my-monorepo/
├── apps/
│   ├── web/            # Next.js app
│   ├── docs/           # Documentation site
│   └── api/            # Express/Fastify API
├── packages/
│   ├── ui/             # Shared UI components
│   ├── utils/          # Shared utilities
│   ├── types/          # Shared TypeScript types
│   ├── config-eslint/  # Shared ESLint config
│   └── config-ts/      # Shared tsconfig
├── turbo.json
├── package.json
├── pnpm-workspace.yaml
└── .gitignore
```

## 2. Workspace Setup <a href="#id-2" id="id-2"></a>

### pnpm

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
```

### npm / yarn / bun

```json
{
  "workspaces": ["apps/*", "packages/*"]
}
```

> **Lưu ý:** Không dùng `apps/**` hoặc `packages/**` (nested). Chỉ 1 cấp depth. Nếu cần nhóm sâu hơn: `packages/*`, `packages/group/*` và không tạo `packages/group/package.json`.

### Root package.json

```json
{
  "private": true,
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test"
  },
  "devDependencies": {
    "turbo": "latest"
  },
  "devEngines": {
    "packageManager": {
      "name": "pnpm",
      "version": "9.0.0"
    }
  }
}
```

## 3. Anatomy of a Package <a href="#id-3" id="id-3"></a>

Mỗi package gần như một "dự án nhỏ" — có `package.json`, tooling config, source code riêng.

### package.json

```json
{
  "name": "@repo/ui",
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/button.tsx",
    "./utils": "./src/utils.ts"
  },
  "scripts": {
    "build": "tsc",
    "lint": "eslint .",
    "test": "vitest run"
  }
}
```

**`exports`** — thay thế `main`, hỗ trợ Conditional Exports, tránh barrel files, IDE autocompletion.

### Source code

Thường dùng `src/` → compile ra `dist/` (nếu là Compiled Package).

## 4. Package Types <a href="#id-4" id="id-4"></a>

### Application Packages

- Deployable (Next.js, Vite, Express...)
- Có `.env` riêng
- Chạy bằng `turbo run dev` / `turbo run build`

### Library Packages

- Chia sẻ code giữa các apps
- Có thể là **Just-in-Time** (export TypeScript trực tiếp, zero build) hoặc **Compiled** (build ra JS)

### Tooling Packages

- ESLint config, tsconfig, GitHub Actions

## 5. Just-in-Time vs Compiled Packages <a href="#id-5" id="id-5"></a>

### Just-in-Time (JIT)

```json
{
  "name": "@repo/utils",
  "exports": {
    ".": "./src/index.ts"
  }
}
```

Export TypeScript trực tiếp. App sử dụng sẽ build cùng. Zero config, **không cần `dependsOn: ["^build"]`**.

### Compiled

```json
{
  "name": "@repo/ui",
  "exports": {
    ".": "./dist/index.js"
  },
  "scripts": {
    "build": "tsc"
  }
}
```

Cần build trước khi app dùng → cần `dependsOn: ["^build"]`.

## 6. Internal Package Dependencies <a href="#id-6" id="id-6"></a>

Khai báo dependency giữa các internal packages như package thường:

```json
{
  "name": "@repo/web",
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

pnpm workspace protocol (`workspace:*`) tự động link local packages.

## 7. Dùng exports thay vì barrel files <a href="#id-7" id="id-7"></a>

**Không dùng barrel files** (`index.ts` re-export tất cả). Dùng `exports`:

```json
{
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/button.tsx",
    "./form": "./src/form.tsx"
  }
}
```

Import:

```ts
import { Button } from "@repo/ui/button";
// không phải import { Button } from "@repo/ui"
```

**Lợi ích:** tree-shaking tốt hơn, compiler không bị overload, IDE autocomplete.

## 8. Common Pitfalls <a href="#id-8" id="id-8"></a>

- **Không dùng `../` để import package khác** — luôn install và import bằng package name
- **Không cần `tsconfig.json` root** — mỗi package tự có tsconfig, shared config ở package riêng
- **Không dùng `apps/**` trong workspace glob** — chỉ 1 level depth
- **Không viết `turbo` commands trong package scripts** — chỉ ở root
- **Lockfile là bắt buộc** — nếu thiếu, Turborepo behavior unpredictable
- **Root `.env` không khuyến nghị** — đặt .env trong từng Application Package

## 9. Tạo monorepo mới nhanh <a href="#id-9" id="id-9"></a>

```bash
pnpm dlx create-turbo@latest
cd my-turborepo
pnpm install
pnpm dev
```

Starter bao gồm: 2 apps (web + docs) + các shared packages (ui, utils, config-eslint, config-ts).

## Tài liệu tham khảo

- [Structuring a Repository (official)](https://turborepo.dev/docs/crafting-your-repository/structuring-a-repository)
- [Internal Packages](https://turborepo.dev/docs/core-concepts/internal-packages)
- [Package Types](https://turborepo.dev/docs/core-concepts/package-types)
