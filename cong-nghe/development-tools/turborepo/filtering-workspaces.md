---
description: >-
  Hướng dẫn sử dụng --filter trong Turborepo — lọc package theo tên, thư mục,
  source control changes, kết hợp filters và advanced patterns.
---

# Filtering Workspaces — Lọc Package Với --filter

`--filter` cho phép chạy tasks trên một subset của monorepo, thay vì toàn bộ. Kết hợp với caching, đây là công cụ mạnh để tối ưu CI và dev workflow.

## 1. Filter theo package name <a href="#id-1" id="id-1"></a>

```bash
turbo build --filter=@repo/web
turbo build --filter=@repo/ui
```

## 2. Filter theo thư mục <a href="#id-2" id="id-2"></a>

```bash
# Tất cả package trong apps/
turbo build --filter="./apps/*"

# Tất cả package trong packages/utilities/
turbo lint --filter="./packages/utilities/*"
```

## 3. Bao gồm dependencies (suffix `...`) <a href="#id-3" id="id-3"></a>

Chạy task cho package **và dependencies của nó**:

```bash
turbo dev --filter=web...
```

Thứ tự: dependencies → `web` (theo đúng task graph).

## 4. Bao gồm dependents (prefix `...`) <a href="#id-4" id="id-4"></a>

Chạy task cho package **và các package phụ thuộc vào nó**:

```bash
turbo build --filter=...ui
```

Hữu ích khi sửa `ui` — kiểm tra xem `web`, `docs` có bị ảnh hưởng không.

## 5. Filter theo source control changes <a href="#id-5" id="id-5"></a>

**Bắt buộc wrap trong `[]`**:

```bash
# So với commit trước
turbo build --filter=[HEAD^1]

# So với main branch
turbo build --filter=[main...my-feature]

# So với specific commits
turbo build --filter=[a1b2c3d...e4f5g6h]

# Branch name
turbo build --filter=[main...feature/auth]
```

Turborepo tính diff files giữa 2 mốc, map vào packages, chỉ chạy task cho packages có thay đổi.

## 6. Direct task filtering (từ v2.2.4) <a href="#id-6" id="id-6"></a>

Không cần `--filter`, filter trực tiếp trong lệnh:

```bash
# Chạy build cho web
turbo run web#build

# Chạy build cho web + lint cho docs
turbo run web#build docs#lint
```

## 7. Kết hợp nhiều filters <a href="#id-7" id="id-7"></a>

Multiple filters = **union** (OR):

```bash
turbo build --filter=...ui --filter={./packages/*} --filter=[HEAD^1]
```

Task graph sẽ include packages thỏa mãn **bất kỳ** filter nào.

## 8. Advanced Patterns <a href="#id-8" id="id-8"></a>

### Exclude packages

```bash
# Tất cả trừ @repo/docs
turbo build --filter=!@repo/docs

# Tất cả trong apps/ trừ web
turbo build --filter="./apps/*" --filter=!@repo/web
```

### Filter by git changes + dependencies

```bash
# Package thay đổi so với main + dependents của chúng
turbo build --filter=[main...HEAD]... --filter=...[main...HEAD]
```

## 9. Use Cases <a href="#id-9" id="id-9"></a>

| Mục đích | Lệnh |
|---|---|
| Build toàn bộ | `turbo build` |
| Chỉ 1 app | `turbo build --filter=@repo/web` |
| App + dependencies | `turbo build --filter=@repo/web...` |
| Library + tất cả app dùng nó | `turbo build --filter=...@repo/ui` |
| Chỉ package thay đổi từ commit trước | `turbo build --filter=[HEAD^1]` |
| Chỉ package thay đổi trong PR | `turbo build --filter=[main...HEAD]` |
| CI: affected packages + dependents | `turbo build --filter=[main...HEAD]...` |

## 10. CI Workflow Example <a href="#id-10" id="id-10"></a>

```yaml
name: CI
on: [pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
      - run: pnpm install
      - run: pnpm turbo build test lint
        --filter=[main...HEAD]...
        env:
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ vars.TURBO_TEAM }}
```

> `fetch-depth: 0` cần thiết để git diff hoạt động chính xác.

## 11. Lưu ý <a href="#id-11" id="id-11"></a>

- Filter vs Cache: filter giới hạn **entrypoints** vào task graph. Nếu package A phụ thuộc B, filter A → B vẫn chạy (nếu `dependsOn` yêu cầu)
- Dùng caching + Remote Cache để package không thay đổi vẫn hit cache dù không bị filter
- Filter source control yêu cầu **full git history** trong CI

## Tài liệu tham khảo

- [Running Tasks (official)](https://turborepo.dev/docs/crafting-your-repository/running-tasks#using-filters)
- [`--filter` API Reference](https://turborepo.dev/docs/reference/run#--filter-string)
